#!/bin/bash

# Version Synchronization Script
# This script ensures all version numbers across the repository are aligned

set -e

# Get the main version from the root VERSION file
if [ ! -f "VERSION" ]; then
    echo "❌ Root VERSION file not found!"
    exit 1
fi

MAIN_VERSION=$(cat VERSION | tr -d '\n')
echo "🔄 Synchronizing all versions to: $MAIN_VERSION"

# Update package.json
if [ -f "package.json" ]; then
    echo "📦 Updating package.json version..."
    sed -i "s/\"version\": \"[^\"]*\"/\"version\": \"$MAIN_VERSION\"/" package.json
    echo "✅ package.json updated"
fi

# Update template version files
for version_file in "docs/.template-version" "docs/templates/VERSION" "docs-site/public/docs/.template-version" "docs-site/public/docs/templates/VERSION"; do
    if [ -f "$version_file" ]; then
        echo "📄 Updating $version_file..."
        echo "$MAIN_VERSION" > "$version_file"
        echo "✅ $version_file updated"
    fi
done

# Update document versions in key files
echo "📝 Updating document versions..."

# Update main documentation files
for doc_file in "docs/architecture/system-architecture.md" "docs/security.md" "docs/performance.md" "docs-site/public/docs/architecture/system-architecture.md"; do
    if [ -f "$doc_file" ]; then
        sed -i "s/\*\*Version\*\*: [^*]*/\*\*Version\*\*: $MAIN_VERSION/" "$doc_file"
        echo "✅ Updated version in $doc_file"
    fi
done

# Update template versions
echo "📋 Updating template versions..."
find docs/templates -name "*.md" -exec sed -i "s/\*\*Template Version\*\*: [^*]*/\*\*Template Version\*\*: $MAIN_VERSION/" {} \;
find docs/templates -name "*.md" -exec sed -i "s/\*Template Version: [^*]*/\*Template Version: $MAIN_VERSION\*/" {} \;
echo "✅ All template versions updated"

# Update documentation site templates if they exist
if [ -d "docs-site/public/docs/templates" ]; then
    find docs-site/public/docs/templates -name "*.md" -exec sed -i "s/\*\*Template Version\*\*: [^*]*/\*\*Template Version\*\*: $MAIN_VERSION/" {} \; 2>/dev/null || true
    echo "✅ Documentation site template versions updated"
fi

echo ""
echo "🎉 Version synchronization completed!"
echo "📊 All files now use version: $MAIN_VERSION"
echo ""
echo "🔍 To verify, run: ./scripts/validate-versions.sh"