#!/bin/bash

# Enhanced Version Management Script
# This script creates a comprehensive, automated version management system
# that discovers and manages all files with version information

set -e

echo "🚀 Enhancing Version Management System"
echo "======================================"
echo ""

# Get the main version
if [ ! -f "VERSION" ]; then
    echo "❌ Root VERSION file not found!"
    exit 1
fi

MAIN_VERSION=$(cat VERSION | tr -d '\n')
echo "📋 Current version: $MAIN_VERSION"

# Create enhanced sync-versions script
echo "📝 Creating enhanced sync-versions.sh..."

cat > scripts/sync-versions.sh << 'EOF'
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
for version_file in "docs/.template-version" "docs/templates/VERSION" "docs-site/public/docs/.template-version" "docs-site/public/docs/templates/VERSION"; do
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
EOF

chmod +x scripts/sync-versions.sh

# Create enhanced list-version-files script
echo "📝 Creating enhanced list-version-files.sh..."

cat > scripts/list-version-files.sh << 'EOF'
#!/bin/bash

# Enhanced Version File Listing Script
# This script provides a comprehensive, automated inventory of all version-managed files

set -e

echo "📋 Enhanced Version-managed Files Inventory"
echo "==========================================="
echo ""

# Get the main version
if [ ! -f "VERSION" ]; then
    echo "❌ Root VERSION file not found!"
    exit 1
fi

MAIN_VERSION=$(cat VERSION | tr -d '\n')
echo "🔹 Source of Truth: VERSION file contains: $MAIN_VERSION"
echo ""

# Function to extract version safely
extract_version_safe() {
    local file="$1"
    local pattern="$2"
    local version=""
    
    case "$pattern" in
        "**Version**:")
            version=$(grep "\*\*Version\*\*:" "$file" 2>/dev/null | tail -1 | sed 's/.*\*\*Version\*\*: *//' | sed 's/ *$//' | tr -d '\n' || echo "NOT_FOUND")
            ;;
        "**Template Version**:")
            version=$(grep "\*\*Template Version\*\*:" "$file" 2>/dev/null | tail -1 | sed 's/.*\*\*Template Version\*\*: *//' | sed 's/ *$//' | tr -d '\n' || echo "NOT_FOUND")
            ;;
        "*Template Version:")
            version=$(grep "\*Template Version:" "$file" 2>/dev/null | tail -1 | sed 's/.*\*Template Version: *//' | sed 's/\*.*$//' | tr -d '\n' || echo "NOT_FOUND")
            ;;
        "**Instruction Version**:")
            version=$(grep "\*\*Instruction Version\*\*:" "$file" 2>/dev/null | tail -1 | sed 's/.*\*\*Instruction Version\*\*: *//' | sed 's/ *$//' | tr -d '\n' || echo "NOT_FOUND")
            ;;
        "JSON_version")
            version=$(grep '"version":' "$file" 2>/dev/null | head -1 | sed 's/.*"version": *"\([^"]*\)".*/\1/' || echo "NOT_FOUND")
            ;;
        "List_Version")
            version=$(grep "\- \*\*Version\*\*:" "$file" 2>/dev/null | sed 's/.*\*\*Version\*\*: *//' | sed 's/ *$//' | tr -d '\n' || echo "NOT_FOUND")
            ;;
    esac
    
    echo "$version"
}

# Function to check version status
check_version_status() {
    local current_version="$1"
    local expected_version="$2"
    
    if [[ "$current_version" == "NOT_FOUND" ]]; then
        echo "❓"
    elif [[ "$current_version" == "$expected_version" ]]; then
        echo "✅"
    else
        echo "❌"
    fi
}

# Arrays to hold categorized files
declare -A categories
categories["package"]="📦 Package Files"
categories["template_version"]="📄 Template Version Files"
categories["root_docs"]="🗂️  Root Documentation"
categories["main_docs"]="📚 Main Documentation"
categories["templates"]="📋 Template Files"
categories["ai_agents"]="🤖 AI Agent Instructions"
categories["scripts"]="🔧 Scripts"
categories["workflows"]="🔄 Workflow Files"

# Scan all files and categorize them
declare -A file_lists

echo "🔍 Scanning repository for version-managed files..."
echo ""

# Scan package.json files
while IFS= read -r -d '' package_file; do
    if [[ "$package_file" != *"node_modules"* ]] && [[ "$package_file" != *"/.git/"* ]]; then
        version=$(extract_version_safe "$package_file" "JSON_version")
        status=$(check_version_status "$version" "$MAIN_VERSION")
        file_lists["package"]+="  $status $(basename "$(dirname "$package_file")")/$(basename "$package_file"): $version"$'\n'
    fi
done < <(find . -name "package.json" -type f -print0)

# Template version files
for version_file in "docs/.template-version" "docs/templates/VERSION" "docs-site/public/docs/.template-version" "docs-site/public/docs/templates/VERSION"; do
    if [ -f "$version_file" ]; then
        version=$(cat "$version_file" 2>/dev/null | tr -d '\n' || echo "NOT_FOUND")
        status=$(check_version_status "$version" "$MAIN_VERSION")
        file_lists["template_version"]+="  $status $version_file: $version"$'\n'
    fi
done

# Scan markdown files
while IFS= read -r -d '' md_file; do
    if [[ "$md_file" != *"node_modules"* ]] && [[ "$md_file" != *"/.git/"* ]]; then
        # Determine category
        category=""
        if [[ "$md_file" == ./*.md ]] && [[ "$md_file" != *"/"* ]]; then
            category="root_docs"
        elif [[ "$md_file" == ./docs/ai-agents/* ]]; then
            category="ai_agents"
        elif [[ "$md_file" == */templates/* ]]; then
            category="templates"
        elif [[ "$md_file" == ./docs/* ]]; then
            category="main_docs"
        fi
        
        # Check for version patterns and add to appropriate category
        if [[ -n "$category" ]]; then
            versions_found=""
            
            if grep -q "\*\*Version\*\*:" "$md_file" 2>/dev/null; then
                version=$(extract_version_safe "$md_file" "**Version**:")
                status=$(check_version_status "$version" "$MAIN_VERSION")
                versions_found+="**Version**:$version "
            fi
            
            if grep -q "\*\*Template Version\*\*:" "$md_file" 2>/dev/null; then
                version=$(extract_version_safe "$md_file" "**Template Version**:")
                status=$(check_version_status "$version" "$MAIN_VERSION")
                versions_found+="**Template Version**:$version "
            fi
            
            if grep -q "\*Template Version:" "$md_file" 2>/dev/null; then
                version=$(extract_version_safe "$md_file" "*Template Version:")
                status=$(check_version_status "$version" "$MAIN_VERSION")
                versions_found+="*Template Version:$version "
            fi
            
            if grep -q "\*\*Instruction Version\*\*:" "$md_file" 2>/dev/null; then
                version=$(extract_version_safe "$md_file" "**Instruction Version**:")
                status=$(check_version_status "$version" "$MAIN_VERSION")
                versions_found+="**Instruction Version**:$version "
            fi
            
            if grep -q "\- \*\*Version\*\*:" "$md_file" 2>/dev/null; then
                version=$(extract_version_safe "$md_file" "List_Version")
                status=$(check_version_status "$version" "$MAIN_VERSION")
                versions_found+="List_Version:$version "
            fi
            
            if [[ -n "$versions_found" ]]; then
                # Use overall status (❌ if any version is wrong, ✅ if all correct)
                overall_status="✅"
                if [[ "$versions_found" == *"NOT_FOUND"* ]] || [[ "$versions_found" != *"$MAIN_VERSION"* ]]; then
                    overall_status="❌"
                fi
                
                file_lists["$category"]+="  $overall_status $md_file: $versions_found"$'\n'
            fi
        fi
    fi
done < <(find . -name "*.md" -type f -print0)

# Display results
for category in "package" "template_version" "root_docs" "main_docs" "templates" "ai_agents" "scripts" "workflows"; do
    if [[ -n "${file_lists[$category]}" ]]; then
        echo "${categories[$category]}:"
        echo -e "${file_lists[$category]}"
        echo ""
    fi
done

# Summary statistics
total_files=0
correct_files=0
incorrect_files=0

for category in "${!file_lists[@]}"; do
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            total_files=$((total_files + 1))
            if [[ "$line" == *"✅"* ]]; then
                correct_files=$((correct_files + 1))
            elif [[ "$line" == *"❌"* ]]; then
                incorrect_files=$((incorrect_files + 1))
            fi
        fi
    done <<< "${file_lists[$category]}"
done

echo "📊 Summary Statistics:"
echo "   Total version-managed files: $total_files"
echo "   Correctly versioned: $correct_files"
echo "   Incorrectly versioned: $incorrect_files"
echo "   Missing versions: $((total_files - correct_files - incorrect_files))"
echo ""
echo "🔧 Available Commands:"
echo "  ./scripts/sync-versions.sh     - Synchronize all versions to root VERSION"
echo "  ./scripts/validate-versions.sh - Detailed version consistency check"
echo "  ./scripts/discover-version-files.sh - Discover new version files"
EOF

chmod +x scripts/list-version-files.sh

# Create enhanced validate-versions script
echo "📝 Creating enhanced validate-versions.sh..."

cat > scripts/validate-versions.sh << 'EOF'
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
EOF

chmod +x scripts/validate-versions.sh

echo ""
echo "✅ Enhanced version management system created!"
echo ""
echo "📋 New capabilities:"
echo "   - Automatic discovery of all version-managed files"
echo "   - Comprehensive pattern matching for different version formats"
echo "   - Enhanced logging and performance tracking"
echo "   - Better error handling and status reporting"
echo ""
echo "🔧 Updated scripts:"
echo "   - scripts/sync-versions.sh (enhanced with auto-discovery)"
echo "   - scripts/list-version-files.sh (comprehensive inventory)"
echo "   - scripts/validate-versions.sh (detailed validation)"
echo "   - scripts/discover-version-files.sh (new discovery tool)"
echo ""
echo "🚀 Next steps:"
echo "1. Run './scripts/validate-versions.sh' to check current state"
echo "2. Run './scripts/sync-versions.sh' to fix any inconsistencies"
echo "3. Run './scripts/list-version-files.sh' to see the full inventory"