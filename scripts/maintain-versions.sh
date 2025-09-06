#!/bin/bash

# Version Management Maintenance Script
# This script provides ongoing maintenance and ensures all relevant files have version information

set -e

echo "🔧 Version Management Maintenance"
echo "================================"
echo ""

# Get the main version
if [ ! -f "VERSION" ]; then
    echo "❌ Root VERSION file not found!"
    exit 1
fi

MAIN_VERSION=$(cat VERSION | tr -d '\n')
echo "📋 Current version: $MAIN_VERSION"
echo ""

# Function to add version to file if it doesn't have one
add_version_to_file() {
    local file="$1"
    local file_type="$2"
    local backup_file="${file}.maintenance_backup"
    
    # Create backup
    cp "$file" "$backup_file"
    
    # Determine what type of version to add based on file type and content
    case "$file_type" in
        "root_doc")
            # Add version to root documentation files
            if ! grep -q "\*\*Version\*\*:" "$file" 2>/dev/null; then
                echo "📝 Adding version to root documentation: $file"
                # Add to the end of the file
                echo "" >> "$file"
                echo "---" >> "$file"
                echo "" >> "$file"
                echo "- **Version**: $MAIN_VERSION" >> "$file"
                echo "- **Last Updated**: $(date '+%B %Y')" >> "$file"
                echo "- **Template Version**: $MAIN_VERSION" >> "$file"
                return 0
            fi
            ;;
        "main_doc")
            # Add version to main documentation files
            if ! grep -q "\*\*Version\*\*:" "$file" 2>/dev/null; then
                echo "📝 Adding version to main documentation: $file"
                # Add to the end of the file
                echo "" >> "$file"
                echo "---" >> "$file"
                echo "" >> "$file"
                echo "- **Version**: $MAIN_VERSION" >> "$file"
                echo "- **Last Updated**: $(date '+%B %Y')" >> "$file"
                return 0
            fi
            ;;
        "ai_agent")
            # Add instruction version to AI agent files
            if ! grep -q "\*\*Instruction Version\*\*:" "$file" 2>/dev/null; then
                echo "📝 Adding instruction version to AI agent file: $file"
                # Add to the end of the file
                echo "" >> "$file"
                echo "---" >> "$file"
                echo "" >> "$file"
                echo "- **Instruction Version**: $MAIN_VERSION" >> "$file"
                echo "- **Last Updated**: $(date '+%B %Y')" >> "$file"
                return 0
            fi
            ;;
        "template")
            # Add template version to template files
            if ! grep -q "\*\*Template Version\*\*:" "$file" && ! grep -q "\*Template Version:" "$file" 2>/dev/null; then
                echo "📝 Adding template version to template file: $file"
                # Add to the end of the file
                echo "" >> "$file"
                echo "---" >> "$file"
                echo "" >> "$file"
                echo "**Template Version**: $MAIN_VERSION" >> "$file"
                return 0
            fi
            ;;
    esac
    
    # No changes needed
    rm "$backup_file"
    return 1
}

echo "🔍 Checking for files that should have versions but don't..."
echo ""

ADDED_COUNT=0

# Check root documentation files
echo "📁 Checking root documentation files..."
for root_file in *.md; do
    if [[ -f "$root_file" ]] && [[ "$root_file" != "CHANGELOG.md" ]]; then
        if add_version_to_file "$root_file" "root_doc"; then
            ADDED_COUNT=$((ADDED_COUNT + 1))
        fi
    fi
done

# Check main documentation files
echo ""
echo "📁 Checking main documentation files..."
while IFS= read -r -d '' doc_file; do
    if [[ "$doc_file" != *"/templates/"* ]] && [[ "$doc_file" != *"/ai-agents/"* ]]; then
        if add_version_to_file "$doc_file" "main_doc"; then
            ADDED_COUNT=$((ADDED_COUNT + 1))
        fi
    fi
done < <(find docs -name "*.md" -type f -print0)

# Check AI agent instruction files
echo ""
echo "📁 Checking AI agent instruction files..."
while IFS= read -r -d '' ai_file; do
    if add_version_to_file "$ai_file" "ai_agent"; then
        ADDED_COUNT=$((ADDED_COUNT + 1))
    fi
done < <(find docs/ai-agents -name "*.md" -type f -print0)

# Check template files
echo ""
echo "📁 Checking template files..."
while IFS= read -r -d '' template_file; do
    if add_version_to_file "$template_file" "template"; then
        ADDED_COUNT=$((ADDED_COUNT + 1))
    fi
done < <(find docs/templates -name "*.md" -type f -print0)

echo ""
echo "📊 Maintenance Summary:"
echo "   Files with versions added: $ADDED_COUNT"

if [[ $ADDED_COUNT -gt 0 ]]; then
    echo ""
    echo "🔧 Running version synchronization to ensure consistency..."
    ./scripts/sync-versions.sh
    echo ""
    echo "🔍 Running validation to confirm all versions are correct..."
    ./scripts/validate-versions.sh
else
    echo "   No maintenance required - all files already have appropriate versions"
fi

echo ""
echo "🎉 Version management maintenance completed!"
echo ""
echo "📋 Summary of available commands:"
echo "   ./scripts/maintain-versions.sh     - This maintenance script"
echo "   ./scripts/sync-versions.sh         - Synchronize all versions"
echo "   ./scripts/validate-versions.sh     - Validate version consistency"
echo "   ./scripts/list-version-files.sh    - Show comprehensive inventory"
echo "   ./scripts/discover-version-files.sh - Discover all version files"