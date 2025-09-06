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

# Update package.json files
echo "📦 Updating package.json versions..."
for package_file in "package.json" "examples/package.json" "docs-site/package.json" "docs-site/public/examples/package.json"; do
    if [ -f "$package_file" ]; then
        echo "📄 Updating $package_file..."
        sed -i "s/\"version\": \"[^\"]*\"/\"version\": \"$MAIN_VERSION\"/" "$package_file"
        echo "✅ $package_file updated"
    else
        echo "⚠️  $package_file not found, skipping"
    fi
done

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
    echo "📋 Updating documentation site template versions..."
    find docs-site/public/docs/templates -name "*.md" -exec sed -i "s/\*\*Template Version\*\*: [^*]*/\*\*Template Version\*\*: $MAIN_VERSION/" {} \; 2>/dev/null || true
    find docs-site/public/docs/templates -name "*.md" -exec sed -i "s/\*Template Version: [^*]*/\*Template Version: $MAIN_VERSION\*/" {} \; 2>/dev/null || true
    echo "✅ Documentation site template versions updated"
fi

# Update AI agent instruction versions (if they have version markers)
echo "🤖 Updating AI agent instruction versions..."
AI_AGENT_FILES_UPDATED=0
for ai_file in docs/ai-agents/claude/claude-architecture-instructions-v*.md docs/ai-agents/*.md docs-site/public/docs/ai-agents/claude/claude-architecture-instructions-v*.md docs-site/public/docs/ai-agents/*.md; do
    if [ -f "$ai_file" ]; then
        # Update any explicit version references that match pattern "Version: X.X.X"
        if grep -q "Version: [0-9]" "$ai_file" 2>/dev/null; then
            sed -i "s/Version: [0-9][0-9.]*[0-9]/Version: $MAIN_VERSION/g" "$ai_file"
            echo "✅ Updated version references in $ai_file"
            AI_AGENT_FILES_UPDATED=$((AI_AGENT_FILES_UPDATED + 1))
        fi
    fi
done

if [ $AI_AGENT_FILES_UPDATED -eq 0 ]; then
    echo "ℹ️  No AI agent instruction files found with explicit version markers"
fi

echo ""
echo "🎉 Version synchronization completed!"
echo "📊 All files now use version: $MAIN_VERSION"
echo ""
echo "🔍 To verify, run: ./scripts/validate-versions.sh"