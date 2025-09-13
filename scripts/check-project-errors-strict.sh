#!/bin/bash

# Enhanced project error checking with strict exit codes
# This script distinguishes between blocking errors and warnings
# and provides proper exit codes for CI/CD integration

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters for different severity levels
CRITICAL_ERRORS=0
BLOCKING_ERRORS=0
WARNINGS=0
PASSED_CHECKS=0

# Functions for incrementing counters
increment_critical() {
    CRITICAL_ERRORS=$((CRITICAL_ERRORS + $1))
}

increment_blocking() {
    BLOCKING_ERRORS=$((BLOCKING_ERRORS + $1))
}

increment_warnings() {
    WARNINGS=$((WARNINGS + $1))
}

increment_passed() {
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
}

# Function to check external links
# shellcheck disable=SC2317  # Function is called via timeout command
check_external_links() {
    if [ -f "docs/external-documentation-links.md" ]; then
        grep -o "http[s]*://[^)]*" docs/external-documentation-links.md | head -5 | while read -r url; do
            if curl -s --head --fail "$url" > /dev/null 2>&1; then
                echo "✅ Link accessible: $url"
            else
                echo "⚠️ Link issue: $url"
            fi
        done
    fi
}

# Function to run a check and handle its results
run_check() {
    local check_name="$1"
    local check_command="$2"
    local is_critical="${3:-false}"

    echo -e "${BLUE}🔍 Running $check_name...${NC}"

    if eval "$check_command" > "/tmp/${check_name}.log" 2>&1; then
        echo -e "${GREEN}✅ $check_name: PASSED${NC}"
        increment_passed
        return 0
    else
        local exit_code=$?
        if [[ "$is_critical" == "true" ]]; then
            echo -e "${RED}❌ $check_name: CRITICAL FAILURE${NC}"
            increment_critical 1
        else
            echo -e "${YELLOW}⚠️ $check_name: WARNINGS DETECTED${NC}"
            increment_warnings 1
        fi

        # Show last few lines of error output
        echo -e "${YELLOW}Last few lines of output:${NC}"
        tail -5 "/tmp/${check_name}.log" | sed 's/^/   /'

        return $exit_code
    fi
}

echo -e "${BLUE}🔍 Enhanced Project Error Check (Strict Mode)${NC}"
echo "============================================="
echo ""

# Create temp directory for logs
mkdir -p /tmp

# CRITICAL CHECKS - These block PR merging
echo -e "${RED}🚨 CRITICAL CHECKS (Must Pass for Merge)${NC}"
echo "----------------------------------------"

# Critical: Security validation
run_check "Security Validation" "npm run lint:security" "true"

# Critical: Architecture compliance
run_check "Architecture Compliance" "npm run lint:architecture" "true"

# Critical: Template validation
run_check "Template Validation" "npm run lint:templates" "true"

# Critical: High/Critical dependency vulnerabilities
echo -e "${BLUE}🔍 Running Dependency Security Check...${NC}"
if npm audit --audit-level=high > /tmp/dependency-security.log 2>&1; then
    echo -e "${GREEN}✅ Dependency Security: PASSED${NC}"
    increment_passed
else
    echo -e "${RED}❌ Dependency Security: CRITICAL VULNERABILITIES FOUND${NC}"
    echo -e "${YELLOW}High or critical vulnerabilities detected:${NC}"
    grep -E "(high|critical)" /tmp/dependency-security.log | head -3 | sed 's/^/   /'
    increment_critical 1
fi

# Critical: File system integrity
echo -e "${BLUE}🔍 Running File System Integrity Check...${NC}"
missing_files=0
required_files=("README.md" "LICENSE" "package.json" ".gitignore" "VERSION")
for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        echo -e "${RED}❌ Missing required file: $file${NC}"
        missing_files=$((missing_files + 1))
    fi
done

if [ $missing_files -eq 0 ]; then
    echo -e "${GREEN}✅ File System Integrity: PASSED${NC}"
    increment_passed
else
    echo -e "${RED}❌ File System Integrity: CRITICAL - $missing_files missing files${NC}"
    increment_critical $missing_files
fi

echo ""

# BLOCKING CHECKS - These should be fixed but may not block immediate merge
echo -e "${YELLOW}⚠️ BLOCKING CHECKS (Should Be Fixed)${NC}"
echo "----------------------------------"

# Blocking: Documentation structure
run_check "Documentation Structure" "npm run docs:validate-structure" "false"

# Blocking: Version consistency
run_check "Version Consistency" "npm run versions:validate" "false"

# Blocking: Cross-reference validation (major issues only)
echo -e "${BLUE}🔍 Running Cross-Reference Validation...${NC}"
if npm run check:cross-references-enhanced > /tmp/cross-ref.log 2>&1; then
    echo -e "${GREEN}✅ Cross-Reference Validation: PASSED${NC}"
    increment_passed
else
    # Count ERROR vs WARN in the output
    error_count=$(grep -c "ERROR" /tmp/cross-ref.log || echo "0")
    warn_count=$(grep -c "WARN" /tmp/cross-ref.log || echo "0")

    if [ "$error_count" -gt 0 ]; then
        echo -e "${RED}❌ Cross-Reference Validation: $error_count ERRORS${NC}"
        increment_blocking "$error_count"
        echo -e "${YELLOW}First few errors:${NC}"
        grep "ERROR" /tmp/cross-ref.log | head -3 | sed 's/^/   /'
    fi

    if [ "$warn_count" -gt 0 ]; then
        echo -e "${YELLOW}⚠️ Cross-Reference Warnings: $warn_count warnings${NC}"
        increment_warnings "$warn_count"
    fi
fi

echo ""

# WARNING CHECKS - These provide feedback but don't block PRs
echo -e "${BLUE}ℹ️ WARNING CHECKS (Advisory Only)${NC}"
echo "-------------------------------"

# Warning: Performance validation
run_check "Performance Validation" "npm run lint:performance" "false"

# Warning: External links (network dependent)
echo -e "${BLUE}🔍 Running External Link Check...${NC}"
timeout 30s check_external_links > /tmp/link-check.log 2>&1 || true

if grep -q "Link issue" /tmp/link-check.log 2>/dev/null; then
    echo -e "${YELLOW}⚠️ External Links: Some links may be inaccessible (warnings only)${NC}"
    increment_warnings 1
else
    echo -e "${GREEN}✅ External Links: PASSED${NC}"
    increment_passed
fi

# Warning: Potential secrets
echo -e "${BLUE}🔍 Running Secrets Scan...${NC}"
secret_files=$(find . -type f \( -name "*.js" -o -name "*.ts" -o -name "*.json" -o -name "*.md" \) \
    -not -path "./node_modules/*" \
    -not -path "./.git/*" \
    -exec grep -l "api_key\|apikey\|password.*=\|secret.*=" {} \; 2>/dev/null | \
    grep -cv ".env.example" || echo "0")

if [ "$secret_files" -gt 0 ]; then
    echo -e "${YELLOW}⚠️ Potential Secrets: Found in $secret_files files (review recommended)${NC}"
    increment_warnings 1
else
    echo -e "${GREEN}✅ Secrets Scan: PASSED${NC}"
    increment_passed
fi

echo ""

# SUMMARY AND EXIT CODE DETERMINATION
echo -e "${BLUE}📊 FINAL SUMMARY${NC}"
echo "================"
echo "Critical Errors: $CRITICAL_ERRORS"
echo "Blocking Errors: $BLOCKING_ERRORS"
echo "Warnings: $WARNINGS"
echo "Passed Checks: $PASSED_CHECKS"
echo ""

# Determine final exit status
if [ $CRITICAL_ERRORS -gt 0 ]; then
    echo -e "${RED}❌ PROJECT STATUS: CRITICAL FAILURE${NC}"
    echo "Critical errors must be fixed before PR can be merged."
    echo ""
    echo -e "${YELLOW}💡 IMMEDIATE ACTIONS REQUIRED:${NC}"
    echo "1. Fix all critical security, architecture, or dependency issues"
    echo "2. Ensure all required files exist and are properly formatted"
    echo "3. Re-run: npm run check:errors"
    echo "4. Re-run: npm run validate:all"
    echo ""
    exit 1
elif [ $BLOCKING_ERRORS -gt 5 ]; then
    echo -e "${YELLOW}⚠️ PROJECT STATUS: TOO MANY BLOCKING ERRORS${NC}"
    echo "While not critical, $BLOCKING_ERRORS blocking errors should be addressed."
    echo ""
    echo -e "${YELLOW}💡 RECOMMENDED ACTIONS:${NC}"
    echo "1. Fix documentation structure and cross-reference issues"
    echo "2. Ensure version consistency across all files"
    echo "3. Re-run: npm run validate:all"
    echo ""
    exit 1
elif [ $CRITICAL_ERRORS -eq 0 ] && [ $BLOCKING_ERRORS -le 5 ]; then
    echo -e "${GREEN}✅ PROJECT STATUS: GOOD${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo "No critical issues found. $WARNINGS warnings detected for improvement."
        echo ""
        echo -e "${BLUE}💡 OPTIONAL IMPROVEMENTS:${NC}"
        echo "1. Review warning-level issues when convenient"
        echo "2. Consider fixing external links"
        echo "3. Review potential secrets (may be false positives)"
    else
        echo "No issues found. Project is in excellent condition."
    fi
    echo ""
    exit 0
else
    echo -e "${YELLOW}⚠️ PROJECT STATUS: UNKNOWN${NC}"
    echo "Unexpected error count combination. Manual review recommended."
    exit 1
fi
