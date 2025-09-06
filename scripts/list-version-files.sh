#!/bin/bash

# List Version Files Script
# This script provides a comprehensive list of all files that contain version information

set -e

echo "📋 Version-managed Files in Repository"
echo "====================================="
echo ""

# Get the main version
if [ ! -f "VERSION" ]; then
    echo "❌ Root VERSION file not found!"
    exit 1
fi

MAIN_VERSION=$(cat VERSION | tr -d '\n')
echo "🔹 Source of Truth: VERSION file contains: $MAIN_VERSION"
echo ""

echo "📦 Package.json Files:"
for package_file in "package.json" "examples/package.json" "docs-site/package.json" "docs-site/public/examples/package.json"; do
    if [ -f "$package_file" ]; then
        PACKAGE_VERSION=$(grep '"version":' "$package_file" | sed 's/.*"version": "\([^"]*\)".*/\1/')
        echo "  ✓ $package_file: $PACKAGE_VERSION"
    else
        echo "  ⚠ $package_file: NOT FOUND"
    fi
done

echo ""
echo "📄 Template Version Files:"
for version_file in "docs/.template-version" "docs/templates/VERSION" "docs-site/public/docs/.template-version" "docs-site/public/docs/templates/VERSION"; do
    if [ -f "$version_file" ]; then
        FILE_VERSION=$(cat "$version_file" | tr -d '\n')
        echo "  ✓ $version_file: $FILE_VERSION"
    else
        echo "  ⚠ $version_file: NOT FOUND"
    fi
done

echo ""
echo "📝 Documentation Files with Version Metadata:"
for doc_file in "docs/architecture/system-architecture.md" "docs/security.md" "docs/performance.md" "docs-site/public/docs/architecture/system-architecture.md"; do
    if [ -f "$doc_file" ]; then
        DOC_VERSION=$(grep -o "\*\*Version\*\*: [^*]*" "$doc_file" 2>/dev/null | sed 's/.*\*\*Version\*\*: //' || echo "NOT_FOUND")
        echo "  ✓ $doc_file: $DOC_VERSION"
    else
        echo "  ⚠ $doc_file: NOT FOUND"
    fi
done

echo ""
echo "📋 Template Files (docs/templates):"
if [ -d "docs/templates" ]; then
    find docs/templates -name "*.md" | while read template_file; do
        TEMPLATE_VERSION=$(grep -o "\*\*Template Version\*\*: [^*]*" "$template_file" 2>/dev/null | sed 's/\*\*Template Version\*\*: //')
        if [ -z "$TEMPLATE_VERSION" ]; then
            TEMPLATE_VERSION=$(grep -o "\*Template Version: [^*]*" "$template_file" 2>/dev/null | sed 's/\*Template Version: //')
        fi
        if [ -z "$TEMPLATE_VERSION" ]; then
            TEMPLATE_VERSION="NOT_FOUND"
        fi
        echo "  ✓ $template_file: $TEMPLATE_VERSION"
    done
else
    echo "  ⚠ docs/templates directory not found"
fi

echo ""
echo "📋 Documentation Site Template Files:"
if [ -d "docs-site/public/docs/templates" ]; then
    find docs-site/public/docs/templates -name "*.md" | while read template_file; do
        TEMPLATE_VERSION=$(grep -o "\*\*Template Version\*\*: [^*]*" "$template_file" 2>/dev/null | sed 's/\*\*Template Version\*\*: //')
        if [ -z "$TEMPLATE_VERSION" ]; then
            TEMPLATE_VERSION=$(grep -o "\*Template Version: [^*]*" "$template_file" 2>/dev/null | sed 's/\*Template Version: //')
        fi
        if [ -z "$TEMPLATE_VERSION" ]; then
            TEMPLATE_VERSION="NOT_FOUND"
        fi
        echo "  ✓ $template_file: $TEMPLATE_VERSION"
    done
else
    echo "  ⚠ docs-site/public/docs/templates directory not found"
fi

echo ""
echo "🤖 AI Agent Instruction Files:"
AI_FILES_FOUND=0
for ai_file in docs/ai-agents/claude/claude-architecture-instructions-v*.md docs/ai-agents/*.md docs-site/public/docs/ai-agents/claude/claude-architecture-instructions-v*.md docs-site/public/docs/ai-agents/*.md; do
    if [ -f "$ai_file" ]; then
        AI_FILES_FOUND=$((AI_FILES_FOUND + 1))
        VERSION_MATCHES=$(grep -o "Version: [0-9][0-9.]*[0-9]" "$ai_file" 2>/dev/null || echo "NO_EXPLICIT_VERSION")
        if [ "$VERSION_MATCHES" = "NO_EXPLICIT_VERSION" ]; then
            echo "  ✓ $ai_file: (no explicit version markers)"
        else
            echo "  ✓ $ai_file: $VERSION_MATCHES"
        fi
    fi
done

if [ $AI_FILES_FOUND -eq 0 ]; then
    echo "  ⚠ No AI agent instruction files found"
fi

echo ""
echo "🔧 Available Commands:"
echo "  npm run versions:validate  - Check version consistency"
echo "  npm run versions:sync      - Synchronize all versions to root VERSION"
echo "  ./scripts/list-version-files.sh - Show this summary"
echo ""
echo "📊 Total managed files: Check the output above for a complete count"