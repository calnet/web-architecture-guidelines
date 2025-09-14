#!/bin/bash

# Enhanced Version Synchronization Script
# This script automatically discovers and synchronizes all version numbers across the repository

set -e

# Performance and logging
start_time=$(date +%s)
SYNC_LOG="/tmp/version_sync_$(date +%Y%m%d_%H%M%S).log"

echo "🔄 Enhanced Version Synchronization" | tee "$SYNC_LOG"
echo "===================================" | tee -a "$SYNC_LOG"
echo "" | tee -a "$SYNC_LOG"

# Get the main version from the root VERSION file
if [ ! -f "VERSION" ]; then
    echo "❌ Root VERSION file not found!" | tee -a "$SYNC_LOG"
    exit 1
fi

MAIN_VERSION=$(cat VERSION | tr -d '\n')
echo "📋 Synchronizing all versions to: $MAIN_VERSION" | tee -a "$SYNC_LOG"
echo "" | tee -a "$SYNC_LOG"

UPDATED_FILES=0
SKIPPED_FILES=0
ERROR_FILES=0

# Function to update version in file
update_version_in_file() {
    local file="$1"
    local pattern="$2"
    local new_version="$3"
    local backup_file="${file}.version_backup"
    
    # Create backup
    cp "$file" "$backup_file"
    
    case "$pattern" in
        "**Version**:")
            sed -i "s/\*\*Version\*\*: [^*]*/\*\*Version\*\*: $new_version/" "$file"
            ;;
        "**Template Version**:")
            sed -i "s/\*\*Template Version\*\*: [^*]*/\*\*Template Version\*\*: $new_version/" "$file"
            ;;
        "*Template Version:")
            sed -i "s/\*Template Version: [^*]*/\*Template Version: $new_version\*/" "$file"
            ;;
        "**Instruction Version**:")
            sed -i "s/\*\*Instruction Version\*\*: [^*]*/\*\*Instruction Version\*\*: $new_version/" "$file"
            ;;
        "JSON_version")
            sed -i "s/\"version\": \"[^\"]*\"/\"version\": \"$new_version\"/" "$file"
            ;;
        "List_Version")
            sed -i "s/\- \*\*Version\*\*: [^*]*/\- \*\*Version\*\*: $new_version/" "$file"
            ;;
    esac
    
    # Check if file was actually changed
    if diff -q "$file" "$backup_file" >/dev/null 2>&1; then
        echo "⚠️  No changes made to $file" | tee -a "$SYNC_LOG"
        SKIPPED_FILES=$((SKIPPED_FILES + 1))
    else
        echo "✅ Updated $file ($pattern)" | tee -a "$SYNC_LOG"
        UPDATED_FILES=$((UPDATED_FILES + 1))
    fi
    
    # Remove backup
    rm "$backup_file"
}

# Discover and update all version files
echo "🔍 Discovering version files..." | tee -a "$SYNC_LOG"

# 1. Update package.json files
echo "" | tee -a "$SYNC_LOG"
echo "📦 Updating package.json files..." | tee -a "$SYNC_LOG"
while IFS= read -r -d '' package_file; do
    if [[ "$package_file" != *"node_modules"* ]] && [[ "$package_file" != *"/.git/"* ]]; then
        echo "📄 Processing $package_file..." | tee -a "$SYNC_LOG"
        update_version_in_file "$package_file" "JSON_version" "$MAIN_VERSION"
    fi
done < <(find . -name "package.json" -type f -print0)

# 2. Update template version files
echo "" | tee -a "$SYNC_LOG"
echo "📄 Updating template version files..." | tee -a "$SYNC_LOG"
for version_file in "docs/.template-version" "docs/templates/VERSION"; do
    if [ -f "$version_file" ]; then
        echo "📄 Processing $version_file..." | tee -a "$SYNC_LOG"
        echo "$MAIN_VERSION" > "$version_file"
        echo "✅ Updated $version_file" | tee -a "$SYNC_LOG"
        UPDATED_FILES=$((UPDATED_FILES + 1))
    fi
done

# 3. Update all markdown files with version patterns
echo "" | tee -a "$SYNC_LOG"
echo "📝 Updating markdown files with version patterns..." | tee -a "$SYNC_LOG"

while IFS= read -r -d '' md_file; do
    if [[ "$md_file" != *"node_modules"* ]] && [[ "$md_file" != *"/.git/"* ]]; then
        # Check what patterns exist in this file
        patterns_found=""
        
        if grep -q "\*\*Version\*\*:" "$md_file" 2>/dev/null; then
            update_version_in_file "$md_file" "**Version**:" "$MAIN_VERSION"
        fi
        
        if grep -q "\*\*Template Version\*\*:" "$md_file" 2>/dev/null; then
            update_version_in_file "$md_file" "**Template Version**:" "$MAIN_VERSION"
        fi
        
        if grep -q "\*Template Version:" "$md_file" 2>/dev/null; then
            update_version_in_file "$md_file" "*Template Version:" "$MAIN_VERSION"
        fi
        
        if grep -q "\*\*Instruction Version\*\*:" "$md_file" 2>/dev/null; then
            update_version_in_file "$md_file" "**Instruction Version**:" "$MAIN_VERSION"
        fi
        
        if grep -q "\- \*\*Version\*\*:" "$md_file" 2>/dev/null; then
            update_version_in_file "$md_file" "List_Version" "$MAIN_VERSION"
        fi
    fi
done < <(find . -name "*.md" -type f -print0)

# Summary
end_time=$(date +%s)
duration=$((end_time - start_time))

echo "" | tee -a "$SYNC_LOG"
echo "🎉 Version synchronization completed!" | tee -a "$SYNC_LOG"
echo "📊 Summary:" | tee -a "$SYNC_LOG"
echo "   - Updated files: $UPDATED_FILES" | tee -a "$SYNC_LOG"
echo "   - Skipped files: $SKIPPED_FILES" | tee -a "$SYNC_LOG"
echo "   - Error files: $ERROR_FILES" | tee -a "$SYNC_LOG"
echo "   - Duration: ${duration}s" | tee -a "$SYNC_LOG"
echo "📋 Target version: $MAIN_VERSION" | tee -a "$SYNC_LOG"
echo "" | tee -a "$SYNC_LOG"
echo "📝 Full log saved to: $SYNC_LOG" | tee -a "$SYNC_LOG"
echo "🔍 To verify, run: ./scripts/validate-versions.sh" | tee -a "$SYNC_LOG"
