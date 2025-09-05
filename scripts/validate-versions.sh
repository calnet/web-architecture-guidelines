#!/bin/bash

# Version Validation Script
# This script checks that all version numbers across the repository are aligned

set -e

echo "🔍 Validating version consistency across repository..."

# Get the main version from the root VERSION file
if [ ! -f "VERSION" ]; then
    echo "❌ Root VERSION file not found!"
    exit 1
fi

MAIN_VERSION=$(cat VERSION | tr -d '\n')
echo "📋 Expected version: $MAIN_VERSION"
echo ""

ERRORS=0

# Check package.json version
if [ -f "package.json" ]; then
    PACKAGE_VERSION=$(grep '"version":' package.json | sed 's/.*"version": "\([^"]*\)".*/\1/')
    if [ "$PACKAGE_VERSION" = "$MAIN_VERSION" ]; then
        echo "✅ package.json version: $PACKAGE_VERSION"
    else
        echo "❌ package.json version mismatch: $PACKAGE_VERSION (expected: $MAIN_VERSION)"
        ERRORS=$((ERRORS + 1))
    fi
fi

# Check template version files
for version_file in "docs/.template-version" "docs/templates/VERSION" "docs-site/public/docs/.template-version" "docs-site/public/docs/templates/VERSION"; do
    if [ -f "$version_file" ]; then
        FILE_VERSION=$(cat "$version_file" | tr -d '\n')
        if [ "$FILE_VERSION" = "$MAIN_VERSION" ]; then
            echo "✅ $version_file: $FILE_VERSION"
        else
            echo "❌ $version_file version mismatch: $FILE_VERSION (expected: $MAIN_VERSION)"
            ERRORS=$((ERRORS + 1))
        fi
    else
        echo "⚠️  $version_file not found"
    fi
done

# Check document versions
echo ""
echo "📄 Checking document versions..."

for doc_file in "docs/architecture/system-architecture.md" "docs/security.md" "docs/performance.md" "docs-site/public/docs/architecture/system-architecture.md"; do
    if [ -f "$doc_file" ]; then
        DOC_VERSION=$(grep -o "\*\*Version\*\*: [^*]*" "$doc_file" 2>/dev/null | sed 's/.*\*\*Version\*\*: //' || echo "NOT_FOUND")
        if [ "$DOC_VERSION" = "$MAIN_VERSION" ]; then
            echo "✅ $doc_file: $DOC_VERSION"
        elif [ "$DOC_VERSION" = "NOT_FOUND" ]; then
            echo "⚠️  No version found in $doc_file"
        else
            echo "❌ $doc_file version mismatch: $DOC_VERSION (expected: $MAIN_VERSION)"
            ERRORS=$((ERRORS + 1))
        fi
    fi
done

# Check template versions
echo ""
echo "📋 Checking template versions..."
TEMPLATE_ERRORS=0

find docs/templates -name "*.md" | while read template_file; do
    # Try both formats: **Template Version**: and *Template Version:
    TEMPLATE_VERSION=$(grep -o "\*\*Template Version\*\*: [^*]*" "$template_file" 2>/dev/null | sed 's/\*\*Template Version\*\*: //')
    if [ -z "$TEMPLATE_VERSION" ]; then
        TEMPLATE_VERSION=$(grep -o "\*Template Version: [^*]*" "$template_file" 2>/dev/null | sed 's/\*Template Version: //')
    fi
    if [ -z "$TEMPLATE_VERSION" ]; then
        TEMPLATE_VERSION="NOT_FOUND"
    fi
    
    if [ "$TEMPLATE_VERSION" = "$MAIN_VERSION" ]; then
        echo "✅ $template_file: $TEMPLATE_VERSION"
    elif [ "$TEMPLATE_VERSION" = "NOT_FOUND" ]; then
        echo "⚠️  No template version found in $template_file"
    else
        echo "❌ $template_file version mismatch: $TEMPLATE_VERSION (expected: $MAIN_VERSION)"
        # Note: Can't increment ERRORS here due to subshell
    fi
done

echo ""
if [ $ERRORS -eq 0 ]; then
    echo "🎉 All versions are aligned!"
    echo "📊 Repository version: $MAIN_VERSION"
    exit 0
else
    echo "💥 Found $ERRORS version mismatches!"
    echo "🔧 Run './scripts/sync-versions.sh' to fix inconsistencies"
    exit 1
fi