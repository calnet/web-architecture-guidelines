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
