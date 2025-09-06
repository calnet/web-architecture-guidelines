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

# Check package.json versions
echo "📦 Checking package.json versions..."
for package_file in "package.json" "examples/package.json" "docs-site/package.json" "docs-site/public/examples/package.json"; do
    if [ -f "$package_file" ]; then
        PACKAGE_VERSION=$(grep '"version":' "$package_file" | sed 's/.*"version": "\([^"]*\)".*/\1/')
        if [ "$PACKAGE_VERSION" = "$MAIN_VERSION" ]; then
            echo "✅ $package_file version: $PACKAGE_VERSION"
        else
            echo "❌ $package_file version mismatch: $PACKAGE_VERSION (expected: $MAIN_VERSION)"
            ERRORS=$((ERRORS + 1))
        fi
    else
        echo "⚠️  $package_file not found"
    fi
done

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

# Check template versions in docs-site/public/docs/templates
echo ""
echo "📋 Checking documentation site template versions..."
if [ -d "docs-site/public/docs/templates" ]; then
    find docs-site/public/docs/templates -name "*.md" | while read template_file; do
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
else
    echo "ℹ️  docs-site/public/docs/templates directory not found"
fi

# Check AI agent instruction files for version consistency
echo ""
echo "🤖 Checking AI agent instruction versions..."
AI_AGENT_VERSION_ERRORS=0
for ai_file in docs/ai-agents/claude/claude-architecture-instructions-v*.md docs/ai-agents/*.md docs-site/public/docs/ai-agents/claude/claude-architecture-instructions-v*.md docs-site/public/docs/ai-agents/*.md; do
    if [ -f "$ai_file" ]; then
        # Look for explicit version references
        VERSION_MATCHES=$(grep -o "Version: [0-9][0-9.]*[0-9]" "$ai_file" 2>/dev/null || true)
        if [ -n "$VERSION_MATCHES" ]; then
            echo "$VERSION_MATCHES" | while read -r version_line; do
                AI_VERSION=$(echo "$version_line" | sed 's/Version: //')
                if [ "$AI_VERSION" = "$MAIN_VERSION" ]; then
                    echo "✅ $ai_file version reference: $AI_VERSION"
                else
                    echo "❌ $ai_file version mismatch: $AI_VERSION (expected: $MAIN_VERSION)"
                    # Note: Can't increment ERRORS here due to subshell
                fi
            done
        else
            echo "ℹ️  No explicit version references found in $ai_file"
        fi
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