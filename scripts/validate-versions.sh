#!/bin/bash

# Enhanced Version Validation Script
# This script performs comprehensive validation of version consistency across all repository files

set -e

# Performance tracking and logging
start_time=$(date +%s)
VALIDATION_LOG="/tmp/version_validation_$(date +%Y%m%d_%H%M%S).log"

echo "🔍 Enhanced Version Validation" | tee "$VALIDATION_LOG"
echo "=============================" | tee -a "$VALIDATION_LOG"
echo "" | tee -a "$VALIDATION_LOG"

# Get the main version from the root VERSION file
if [ ! -f "VERSION" ]; then
    echo "❌ Root VERSION file not found!" | tee -a "$VALIDATION_LOG"
    exit 1
fi

MAIN_VERSION=$(cat VERSION | tr -d '\n')
echo "📋 Expected version: $MAIN_VERSION" | tee -a "$VALIDATION_LOG"
echo "" | tee -a "$VALIDATION_LOG"

ERRORS=0
WARNINGS=0
TOTAL_FILES=0

# Function to validate version in file
validate_version_in_file() {
    local file="$1"
    local pattern="$2"
    local expected_version="$3"
    local current_version=""
    
    TOTAL_FILES=$((TOTAL_FILES + 1))
    
    case "$pattern" in
        "**Version**:")
            current_version=$(grep "\*\*Version\*\*:" "$file" 2>/dev/null | tail -1 | sed 's/.*\*\*Version\*\*: *//' | sed 's/ *$//' | tr -d '\n' || echo "NOT_FOUND")
            ;;
        "**Template Version**:")
            current_version=$(grep "\*\*Template Version\*\*:" "$file" 2>/dev/null | tail -1 | sed 's/.*\*\*Template Version\*\*: *//' | sed 's/ *$//' | tr -d '\n' || echo "NOT_FOUND")
            ;;
        "*Template Version:")
            current_version=$(grep "\*Template Version:" "$file" 2>/dev/null | tail -1 | sed 's/.*\*Template Version: *//' | sed 's/\*.*$//' | tr -d '\n' || echo "NOT_FOUND")
            ;;
        "**Instruction Version**:")
            current_version=$(grep "\*\*Instruction Version\*\*:" "$file" 2>/dev/null | tail -1 | sed 's/.*\*\*Instruction Version\*\*: *//' | sed 's/ *$//' | tr -d '\n' || echo "NOT_FOUND")
            ;;
        "JSON_version")
            current_version=$(grep '"version":' "$file" 2>/dev/null | head -1 | sed 's/.*"version": *"\([^"]*\)".*/\1/' || echo "NOT_FOUND")
            ;;
        "List_Version")
            current_version=$(grep "\- \*\*Version\*\*:" "$file" 2>/dev/null | sed 's/.*\*\*Version\*\*: *//' | sed 's/ *$//' | tr -d '\n' || echo "NOT_FOUND")
            ;;
    esac
    
    if [[ "$current_version" == "NOT_FOUND" ]]; then
        echo "⚠️  Pattern $pattern not found in $file" | tee -a "$VALIDATION_LOG"
        WARNINGS=$((WARNINGS + 1))
    elif [[ "$current_version" == "$expected_version" ]]; then
        echo "✅ $file ($pattern): $current_version" | tee -a "$VALIDATION_LOG"
    else
        echo "❌ $file ($pattern): $current_version (expected: $expected_version)" | tee -a "$VALIDATION_LOG"
        ERRORS=$((ERRORS + 1))
    fi
}

# Validate all files with version patterns
echo "🔍 Validating all version-managed files..." | tee -a "$VALIDATION_LOG"
echo "" | tee -a "$VALIDATION_LOG"

# 1. Validate package.json files
echo "📦 Validating package.json files..." | tee -a "$VALIDATION_LOG"
while IFS= read -r -d '' package_file; do
    if [[ "$package_file" != *"node_modules"* ]] && [[ "$package_file" != *"/.git/"* ]]; then
        validate_version_in_file "$package_file" "JSON_version" "$MAIN_VERSION"
    fi
done < <(find . -name "package.json" -type f -print0)

# 2. Validate template version files
echo "" | tee -a "$VALIDATION_LOG"
echo "📄 Validating template version files..." | tee -a "$VALIDATION_LOG"
for version_file in "docs/.template-version" "docs/templates/VERSION" "docs-site/public/docs/.template-version" "docs-site/public/docs/templates/VERSION"; do
    if [ -f "$version_file" ]; then
        current_version=$(cat "$version_file" 2>/dev/null | tr -d '\n' || echo "NOT_FOUND")
        if [[ "$current_version" == "$MAIN_VERSION" ]]; then
            echo "✅ $version_file: $current_version" | tee -a "$VALIDATION_LOG"
        else
            echo "❌ $version_file: $current_version (expected: $MAIN_VERSION)" | tee -a "$VALIDATION_LOG"
            ERRORS=$((ERRORS + 1))
        fi
        TOTAL_FILES=$((TOTAL_FILES + 1))
    fi
done

# 3. Validate all markdown files with version patterns
echo "" | tee -a "$VALIDATION_LOG"
echo "📝 Validating markdown files..." | tee -a "$VALIDATION_LOG"

while IFS= read -r -d '' md_file; do
    if [[ "$md_file" != *"node_modules"* ]] && [[ "$md_file" != *"/.git/"* ]]; then
        # Check each pattern type
        if grep -q "\*\*Version\*\*:" "$md_file" 2>/dev/null; then
            validate_version_in_file "$md_file" "**Version**:" "$MAIN_VERSION"
        fi
        
        if grep -q "\*\*Template Version\*\*:" "$md_file" 2>/dev/null; then
            validate_version_in_file "$md_file" "**Template Version**:" "$MAIN_VERSION"
        fi
        
        if grep -q "\*Template Version:" "$md_file" 2>/dev/null; then
            validate_version_in_file "$md_file" "*Template Version:" "$MAIN_VERSION"
        fi
        
        if grep -q "\*\*Instruction Version\*\*:" "$md_file" 2>/dev/null; then
            validate_version_in_file "$md_file" "**Instruction Version**:" "$MAIN_VERSION"
        fi
        
        if grep -q "\- \*\*Version\*\*:" "$md_file" 2>/dev/null; then
            validate_version_in_file "$md_file" "List_Version" "$MAIN_VERSION"
        fi
    fi
done < <(find . -name "*.md" -type f -print0)

# Final summary
end_time=$(date +%s)
duration=$((end_time - start_time))

echo "" | tee -a "$VALIDATION_LOG"
echo "📊 Validation Summary:" | tee -a "$VALIDATION_LOG"
echo "   Total files checked: $TOTAL_FILES" | tee -a "$VALIDATION_LOG"
echo "   Errors found: $ERRORS" | tee -a "$VALIDATION_LOG"
echo "   Warnings: $WARNINGS" | tee -a "$VALIDATION_LOG"
echo "   Duration: ${duration}s" | tee -a "$VALIDATION_LOG"
echo "" | tee -a "$VALIDATION_LOG"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo "🎉 All versions are perfectly aligned!" | tee -a "$VALIDATION_LOG"
    echo "📋 Repository version: $MAIN_VERSION" | tee -a "$VALIDATION_LOG"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo "⚠️  All versions are correct, but found $WARNINGS warnings" | tee -a "$VALIDATION_LOG"
    echo "🔧 Consider reviewing warnings above" | tee -a "$VALIDATION_LOG"
    exit 0
else
    echo "💥 Found $ERRORS version mismatches and $WARNINGS warnings!" | tee -a "$VALIDATION_LOG"
    echo "🔧 Run './scripts/sync-versions.sh' to fix inconsistencies" | tee -a "$VALIDATION_LOG"
    echo "📝 Full log saved to: $VALIDATION_LOG" | tee -a "$VALIDATION_LOG"
    exit 1
fi
