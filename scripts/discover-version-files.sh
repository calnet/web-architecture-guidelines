#!/bin/bash

# Version File Discovery Script
# This script automatically discovers all files that contain version information
# and provides a comprehensive inventory for version management

set -e

echo "🔍 Discovering all version-managed files in repository..."
echo "========================================================="
echo ""

# Function to check if a file contains version patterns
check_version_patterns() {
    local file="$1"
    local patterns_found=""
    
    # Check for various version patterns
    if grep -q "\*\*Version\*\*:" "$file" 2>/dev/null; then
        patterns_found="${patterns_found}**Version**: "
    fi
    
    if grep -q "\*\*Template Version\*\*:" "$file" 2>/dev/null; then
        patterns_found="${patterns_found}**Template Version**: "
    fi
    
    if grep -q "\*Template Version:" "$file" 2>/dev/null; then
        patterns_found="${patterns_found}*Template Version: "
    fi
    
    if grep -q "\*\*Instruction Version\*\*:" "$file" 2>/dev/null; then
        patterns_found="${patterns_found}**Instruction Version**: "
    fi
    
    if grep -q "\"version\":" "$file" 2>/dev/null; then
        patterns_found="${patterns_found}JSON_version "
    fi
    
    if grep -q "\- \*\*Version\*\*:" "$file" 2>/dev/null; then
        patterns_found="${patterns_found}List_Version "
    fi
    
    echo "$patterns_found"
}

# Function to extract version value
extract_version() {
    local file="$1"
    local pattern="$2"
    local version=""
    
    case "$pattern" in
        "**Version**: ")
            version=$(grep "\*\*Version\*\*:" "$file" 2>/dev/null | tail -1 | sed 's/.*\*\*Version\*\*: *//' | sed 's/ *$//')
            ;;
        "**Template Version**: ")
            version=$(grep "\*\*Template Version\*\*:" "$file" 2>/dev/null | tail -1 | sed 's/.*\*\*Template Version\*\*: *//' | sed 's/ *$//')
            ;;
        "*Template Version: ")
            version=$(grep "\*Template Version:" "$file" 2>/dev/null | tail -1 | sed 's/.*\*Template Version: *//' | sed 's/\*.*$//')
            ;;
        "**Instruction Version**: ")
            version=$(grep "\*\*Instruction Version\*\*:" "$file" 2>/dev/null | tail -1 | sed 's/.*\*\*Instruction Version\*\*: *//' | sed 's/ *$//')
            ;;
        "JSON_version ")
            version=$(grep '"version":' "$file" 2>/dev/null | sed 's/.*"version": *"\([^"]*\)".*/\1/')
            ;;
        "List_Version ")
            version=$(grep "\- \*\*Version\*\*:" "$file" 2>/dev/null | sed 's/.*\*\*Version\*\*: *//' | sed 's/ *$//')
            ;;
    esac
    
    echo "$version"
}

# Output files
DISCOVERED_FILES="/tmp/discovered_version_files.txt"
SUMMARY_FILE="/tmp/version_discovery_summary.txt"

> "$DISCOVERED_FILES"
> "$SUMMARY_FILE"

echo "📋 Scanning repository for version patterns..."
echo ""

# Categories
ROOT_MD_FILES=()
DOCS_FILES=()
TEMPLATE_FILES=()
PACKAGE_FILES=()
CONFIG_FILES=()
WORKFLOW_FILES=()
SCRIPT_FILES=()

# Scan all files
while IFS= read -r -d '' file; do
    # Skip hidden directories and files
    if [[ "$file" == *"/.git"* ]] || [[ "$file" == *"/node_modules"* ]] || [[ "$file" == *"/.vscode"* ]]; then
        continue
    fi
    
    patterns=$(check_version_patterns "$file")
    
    if [[ -n "$patterns" ]]; then
        echo "📄 Found version file: $file"
        echo "    Patterns: $patterns"
        
        # Extract all versions found
        versions=""
        for pattern in $patterns; do
            version=$(extract_version "$file" "$pattern")
            if [[ -n "$version" ]]; then
                versions="${versions}${pattern}${version} "
            fi
        done
        
        echo "    Versions: $versions"
        echo ""
        
        # Categorize the file
        if [[ "$file" == ./*.md ]] && [[ ! "$file" == *"/"* ]]; then
            ROOT_MD_FILES+=("$file")
        elif [[ "$file" == ./docs/* ]] && [[ "$file" == *.md ]]; then
            DOCS_FILES+=("$file")
        elif [[ "$file" == */templates/* ]] && [[ "$file" == *.md ]]; then
            TEMPLATE_FILES+=("$file")
        elif [[ "$file" == *package.json ]]; then
            PACKAGE_FILES+=("$file")
        elif [[ "$file" == *.yml ]] || [[ "$file" == *.yaml ]]; then
            CONFIG_FILES+=("$file")
        elif [[ "$file" == .github/workflows/* ]]; then
            WORKFLOW_FILES+=("$file")
        elif [[ "$file" == *.sh ]]; then
            SCRIPT_FILES+=("$file")
        fi
        
        # Write to discovery file
        echo "$file|$patterns|$versions" >> "$DISCOVERED_FILES"
    fi
done < <(find . -type f \( -name "*.md" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" -o -name "*.sh" \) -print0)

# Generate summary
echo "📊 Version File Discovery Summary" > "$SUMMARY_FILE"
echo "=================================" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"

echo "🗂️  Root Markdown Files:" >> "$SUMMARY_FILE"
printf '%s\n' "${ROOT_MD_FILES[@]}" | sort >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"

echo "📚 Documentation Files:" >> "$SUMMARY_FILE"
printf '%s\n' "${DOCS_FILES[@]}" | sort >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"

echo "📋 Template Files:" >> "$SUMMARY_FILE"
printf '%s\n' "${TEMPLATE_FILES[@]}" | sort >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"

echo "📦 Package Files:" >> "$SUMMARY_FILE"
printf '%s\n' "${PACKAGE_FILES[@]}" | sort >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"

echo "⚙️  Configuration Files:" >> "$SUMMARY_FILE"
printf '%s\n' "${CONFIG_FILES[@]}" | sort >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"

echo "🔄 Workflow Files:" >> "$SUMMARY_FILE"
printf '%s\n' "${WORKFLOW_FILES[@]}" | sort >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"

echo "🔧 Script Files:" >> "$SUMMARY_FILE"
printf '%s\n' "${SCRIPT_FILES[@]}" | sort >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"

# Display summary
cat "$SUMMARY_FILE"

echo "📝 Detailed file information saved to: $DISCOVERED_FILES"
echo "📊 Summary saved to: $SUMMARY_FILE"
echo ""
echo "🔧 Recommendations:"
echo "1. Run './scripts/enhance-version-management.sh' to update version scripts"
echo "2. Run './scripts/validate-versions.sh' to check consistency"
echo "3. Run './scripts/sync-versions.sh' to synchronize all versions"

# Count totals
total_files=$(wc -l < "$DISCOVERED_FILES")
echo ""
echo "📊 Total files with version information: $total_files"