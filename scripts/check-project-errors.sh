#!/bin/bash

echo "🔍 Comprehensive Project Error Check"
echo "=================================="
echo ""

TOTAL_ERRORS=0
TOTAL_WARNINGS=0

# Function to increment error/warning counters
increment_errors() {
    TOTAL_ERRORS=$((TOTAL_ERRORS + "$1"))
}

increment_warnings() {
    TOTAL_WARNINGS=$((TOTAL_WARNINGS + "$1"))
}

# Documentation Structure Validation
echo "📁 DOCUMENTATION STRUCTURE VALIDATION"
echo "------------------------------------"
if ./scripts/validate-docs-structure.sh > /tmp/docs-structure.log 2>&1; then
    echo "✅ Documentation structure: PASSED"
    grep -c "✅" /tmp/docs-structure.log | xargs echo "   - Files validated:"
else
    echo "❌ Documentation structure: FAILED"
    errors=$(grep -c "❌" /tmp/docs-structure.log)
    echo "   - Errors found: $errors"
    increment_errors "$errors"
fi
echo ""

# Architecture Validation
echo "🏗️ ARCHITECTURE VALIDATION"
echo "-------------------------"
if ./scripts/validate-architecture.sh > /tmp/arch.log 2>&1; then
    echo "✅ Architecture compliance: PASSED"
    grep -c "✅" /tmp/arch.log | xargs echo "   - Checks passed:"
else
    echo "❌ Architecture compliance: FAILED"
    errors=$(grep -c "❌" /tmp/arch.log)
    echo "   - Errors found: $errors"
    increment_errors "$errors"
fi
warnings=$(grep -c "⚠️" /tmp/arch.log)
if [ "$warnings" -gt 0 ]; then
    echo "   - Warnings: $warnings"
    increment_warnings "$warnings"
fi
echo ""

# Security Validation
echo "🔒 SECURITY VALIDATION"
echo "--------------------"
if ./scripts/validate-security.sh > /tmp/security.log 2>&1; then
    echo "✅ Security compliance: PASSED"
    grep -c "✅" /tmp/security.log | xargs echo "   - Checks passed:"
else
    echo "❌ Security compliance: FAILED"
    errors=$(grep -c "❌" /tmp/security.log)
    echo "   - Errors found: $errors"
    increment_errors "$errors"
fi
warnings=$(grep -c "⚠️" /tmp/security.log)
if [ "$warnings" -gt 0 ]; then
    echo "   - Warnings: $warnings"
    increment_warnings "$warnings"
fi

# Check for potential secrets
echo "   - Checking for potential secrets..."
secret_files=$(find . -type f \( -name "*.js" -o -name "*.ts" -o -name "*.json" -o -name "*.md" \) -print0 | xargs -0 grep -l "api_key\|apikey\|password.*=\|secret.*=" 2>/dev/null | grep -v ".env.example" | grep -v -c "node_modules")
if [ "$secret_files" -gt 0 ]; then
    echo "   ⚠️  Potential secrets in $secret_files files (review needed)"
    increment_warnings 1
fi
echo ""

# Performance Validation
echo "⚡ PERFORMANCE VALIDATION"
echo "-----------------------"
if ./scripts/validate-performance.sh > /tmp/performance.log 2>&1; then
    echo "✅ Performance compliance: PASSED"
    grep -c "✅" /tmp/performance.log | xargs echo "   - Checks passed:"
else
    echo "❌ Performance compliance: FAILED"
    errors=$(grep -c "❌" /tmp/performance.log)
    echo "   - Errors found: $errors"
    increment_errors "$errors"
fi
warnings=$(grep -c "⚠️" /tmp/performance.log)
if [ "$warnings" -gt 0 ]; then
    echo "   - Warnings: $warnings"
    increment_warnings "$warnings"
fi
echo ""

# Template Validation
echo "📋 TEMPLATE VALIDATION"
echo "--------------------"
if ./scripts/validate-templates.sh > /tmp/templates.log 2>&1; then
    echo "✅ Template validation: PASSED"
    grep -c "✅" /tmp/templates.log | xargs echo "   - Checks passed:"
else
    echo "❌ Template validation: FAILED"
    errors=$(grep -c "❌" /tmp/templates.log)
    echo "   - Errors found: $errors"
    increment_errors "$errors"
fi
echo ""

# TypeScript Compliance Check
echo "📊 TEMPLATE COMPLIANCE ANALYSIS"
echo "------------------------------"
if [ -f "tools/template-compliance-checker.ts" ]; then
    npx ts-node tools/template-compliance-checker.ts . > /tmp/compliance.log 2>&1
    if grep -q "❌ NEEDS ATTENTION" /tmp/compliance.log; then
        echo "⚠️  Template compliance: NEEDS ATTENTION"
        grep "Overall Score:" /tmp/compliance.log | head -1
        increment_warnings 1
    else
        echo "✅ Template compliance: PASSED"
        grep "Overall Score:" /tmp/compliance.log | head -1
    fi
else
    echo "⚠️  Template compliance checker not available"
    increment_warnings 1
fi
echo ""

# Link Validation
echo "🔗 LINK VALIDATION"
echo "----------------"
echo "Checking main README links..."
if npx --yes markdown-link-check README.md > /tmp/readme-links.log 2>&1; then
    echo "✅ README links: PASSED"
else
    dead_links=$(grep "ERROR:" /tmp/readme-links.log | head -1 | grep -o "[0-9]* dead links" | grep -o "[0-9]*")
    if [ -n "$dead_links" ] && [ "$dead_links" -gt 0 ]; then
        echo "❌ README links: $dead_links broken links found"
        increment_errors "$dead_links"
    fi
fi

echo "Checking external documentation links..."
if npx --yes markdown-link-check docs/external-documentation-links.md > /tmp/external-links.log 2>&1; then
    echo "✅ External links: PASSED"
else
    dead_links=$(grep "ERROR:" /tmp/external-links.log | head -1 | grep -o "[0-9]* dead links" | grep -o "[0-9]*")
    if [ -n "$dead_links" ] && [ "$dead_links" -gt 0 ]; then
        echo "⚠️  External links: $dead_links broken links found (may be network-related)"
        increment_warnings 1
    fi
fi
echo ""

# Dependencies Check
echo "📦 DEPENDENCIES CHECK"
echo "-------------------"
if npm audit --audit-level=high > /tmp/audit.log 2>&1; then
    echo "✅ Dependencies security: PASSED"
else
    vulnerabilities=$(grep "vulnerabilities" /tmp/audit.log | tail -1)
    echo "⚠️  Dependencies: $vulnerabilities"
    increment_warnings 1
fi
echo ""

# File System Check
echo "🗂️ FILE SYSTEM INTEGRITY"
echo "-----------------------"
missing_files=0

# Check for required root files
required_files=("README.md" "LICENSE" "package.json" ".gitignore")
for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ Missing required file: $file"
        missing_files=$((missing_files + 1))
    fi
done

# Check for duplicate scripts (potential sync issues)
duplicate_scripts=$(find . -name "validate-*.sh" | sort | uniq -d | wc -l)
if [ "$duplicate_scripts" -gt 0 ]; then
    echo "⚠️  Found $duplicate_scripts duplicate validation scripts"
    increment_warnings 1
fi

if [ $missing_files -eq 0 ] && [ "$duplicate_scripts" -eq 0 ]; then
    echo "✅ File system integrity: PASSED"
else
    increment_errors $missing_files
fi
echo ""

# Summary Report
echo "📊 FINAL SUMMARY"
echo "================"
echo "Total Errors: $TOTAL_ERRORS"
echo "Total Warnings: $TOTAL_WARNINGS"
echo ""

if [ $TOTAL_ERRORS -eq 0 ] && [ $TOTAL_WARNINGS -eq 0 ]; then
    echo "🎉 PROJECT STATUS: EXCELLENT"
    echo "All checks passed with no errors or warnings!"
elif [ $TOTAL_ERRORS -eq 0 ] && [ $TOTAL_WARNINGS -gt 0 ]; then
    echo "✅ PROJECT STATUS: GOOD"
    echo "No critical errors found, but $TOTAL_WARNINGS warnings need attention."
elif [ $TOTAL_ERRORS -le 5 ]; then
    echo "⚠️  PROJECT STATUS: NEEDS ATTENTION"
    echo "$TOTAL_ERRORS errors and $TOTAL_WARNINGS warnings found."
else
    echo "❌ PROJECT STATUS: CRITICAL ISSUES"
    echo "$TOTAL_ERRORS errors and $TOTAL_WARNINGS warnings found."
fi

echo ""
echo "📋 RECOMMENDATIONS:"

if [ $TOTAL_ERRORS -gt 0 ] || [ $TOTAL_WARNINGS -gt 0 ]; then
    echo "1. Review error logs in /tmp/ directory for details"
    echo "2. Fix broken links in documentation"
    echo "3. Address any security warnings"
    echo "4. Update template compliance where needed"

    if [ $TOTAL_ERRORS -gt 0 ]; then
        echo "5. PRIORITY: Fix $TOTAL_ERRORS critical errors first"
        exit 1
    else
        echo "5. Address $TOTAL_WARNINGS warnings when possible"
        exit 0
    fi
else
    echo "1. Maintain current excellent standards"
    echo "2. Continue regular validation checks"
    echo "3. Keep dependencies updated"
    exit 0
fi
