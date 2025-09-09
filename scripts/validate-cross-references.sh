#!/bin/bash

# Validate documentation cross-references and consistency
# Ensures all referenced files and scripts exist and are consistent

set -euo pipefail

echo "🔗 Validating documentation cross-references and consistency..."

ERRORS=0

# Function to check if a referenced file exists
check_reference() {
    local file="$1"
    local reference="$2"
    local line_num="$3"
    
    if [ ! -f "$reference" ]; then
        echo "❌ Broken reference in $file:$line_num -> $reference"
        ERRORS=$((ERRORS + 1))
        return 1
    else
        echo "✅ Valid reference: $file -> $reference"
        return 0
    fi
}

# Function to extract and validate markdown links
validate_markdown_links() {
    local file="$1"
    echo "🔍 Checking internal links in $file..."
    
    # Extract relative markdown links (not URLs)
    if grep -n '\[.*\]([^http][^)]*\.md[^)]*)' "$file" >/dev/null 2>&1; then
        grep -n '\[.*\]([^http][^)]*\.md[^)]*)' "$file" | while IFS=: read -r line_num match; do
            # Extract the link path
            link=$(echo "$match" | sed -n 's/.*\](\([^)]*\.md[^)]*\)).*/\1/p')
            
            if [ -n "$link" ]; then
                # Resolve relative path
                dir=$(dirname "$file")
                if [[ "$link" == /* ]]; then
                    # Absolute path from repo root
                    ref_file=".${link}"
                else
                    # Relative path
                    ref_file="$dir/$link"
                fi
                
                # Normalize the path
                ref_file=$(realpath -m "$ref_file" 2>/dev/null || echo "$ref_file")
                
                check_reference "$file" "$ref_file" "$line_num" || true
            fi
        done
    else
        echo "✅ No internal markdown links found in $file"
    fi
}

# Function to extract and validate script references
validate_script_references() {
    local file="$1"
    echo "🔍 Checking script references in $file..."
    
    # Find references to scripts
    if grep -n 'scripts/[a-zA-Z0-9_-]*\.sh' "$file" >/dev/null 2>&1; then
        grep -n 'scripts/[a-zA-Z0-9_-]*\.sh' "$file" | while IFS=: read -r line_num match; do
            # Extract script path
            script=$(echo "$match" | grep -o 'scripts/[a-zA-Z0-9_-]*\.sh' | head -1)
            
            if [ -n "$script" ]; then
                check_reference "$file" "$script" "$line_num" || true
            fi
        done
    else
        echo "✅ No script references found in $file"
    fi
}

# Function to validate workflow file references
validate_workflow_references() {
    local file="$1"
    echo "🔍 Checking workflow references in $file..."
    
    # Find references to workflow files
    if grep -n '\.github/workflows/[a-zA-Z0-9_-]*\.yml' "$file" >/dev/null 2>&1; then
        grep -n '\.github/workflows/[a-zA-Z0-9_-]*\.yml' "$file" | while IFS=: read -r line_num match; do
            # Extract workflow path
            workflow=$(echo "$match" | grep -o '\.github/workflows/[a-zA-Z0-9_-]*\.yml' | head -1)
            
            if [ -n "$workflow" ]; then
                check_reference "$file" "$workflow" "$line_num" || true
            fi
        done
    else
        echo "✅ No workflow references found in $file"
    fi
}

# Function to validate npm script references
validate_npm_script_references() {
    echo "🔍 Checking npm script references..."
    
    # Get list of defined npm scripts
    if [ -f "package.json" ]; then
        available_scripts=$(jq -r '.scripts | keys[]' package.json 2>/dev/null || echo "")
        
        # Check workflow files for npm script references
        find .github/workflows -name "*.yml" -type f | while read -r workflow_file; do
            grep -n 'npm run [a-zA-Z0-9_:-]*' "$workflow_file" | while IFS=: read -r line_num match; do
                # Extract script name
                script_name=$(echo "$match" | sed -n 's/.*npm run \([a-zA-Z0-9_:-]*\).*/\1/p')
                
                if [ -n "$script_name" ]; then
                    if echo "$available_scripts" | grep -q "^$script_name$"; then
                        echo "✅ Valid npm script reference: $workflow_file:$line_num -> npm run $script_name"
                    else
                        echo "❌ Invalid npm script reference: $workflow_file:$line_num -> npm run $script_name (script not defined)"
                        ERRORS=$((ERRORS + 1))
                    fi
                fi
            done
        done
    fi
}

# Function to check for duplicate documentation
check_duplicate_documentation() {
    echo "🔍 Checking for documentation synchronization..."
    
    # Compare docs/ and docs-site/public/docs/
    if [ -d "docs" ] && [ -d "docs-site/public/docs" ]; then
        # Check if directories are synchronized
        diff_output=$(diff -r docs/ docs-site/public/docs/ 2>/dev/null || true)
        
        if [ -n "$diff_output" ]; then
            echo "❌ Documentation directories are not synchronized:"
            echo "$diff_output"
            ERRORS=$((ERRORS + 1))
        else
            echo "✅ Documentation directories are synchronized"
        fi
    fi
    
    # Compare scripts/ and docs-site/public/scripts/
    if [ -d "scripts" ] && [ -d "docs-site/public/scripts" ]; then
        # Check if critical scripts are synchronized
        for script in scripts/*.sh; do
            script_name=$(basename "$script")
            public_script="docs-site/public/scripts/$script_name"
            
            if [ -f "$public_script" ]; then
                if ! diff -q "$script" "$public_script" >/dev/null 2>&1; then
                    echo "❌ Script not synchronized: $script vs $public_script"
                    ERRORS=$((ERRORS + 1))
                else
                    echo "✅ Script synchronized: $script_name"
                fi
            else
                echo "⚠️  Script missing in public: $script_name"
            fi
        done
    fi
}

# Function to validate action versions in workflows
validate_action_versions() {
    echo "🔍 Checking GitHub Actions versions..."
    
    find .github/workflows -name "*.yml" -type f | while read -r workflow_file; do
        # Check for outdated action versions
        grep -n 'uses: actions/checkout@v[0-9]' "$workflow_file" | while IFS=: read -r line_num match; do
            version=$(echo "$match" | sed -n 's/.*@v\([0-9]*\).*/\1/p')
            
            if [ "$version" -lt 4 ]; then
                echo "⚠️  Outdated action version in $workflow_file:$line_num -> checkout@v$version (consider updating to v4)"
            else
                echo "✅ Current action version: $workflow_file:$line_num -> checkout@v$version"
            fi
        done
        
        grep -n 'uses: actions/setup-node@v[0-9]' "$workflow_file" | while IFS=: read -r line_num match; do
            version=$(echo "$match" | sed -n 's/.*@v\([0-9]*\).*/\1/p')
            
            if [ "$version" -lt 4 ]; then
                echo "⚠️  Outdated action version in $workflow_file:$line_num -> setup-node@v$version (consider updating to v4)"
            else
                echo "✅ Current action version: $workflow_file:$line_num -> setup-node@v$version"
            fi
        done
    done
}

# Main validation process
echo "Starting comprehensive cross-reference validation..."
echo ""

# Validate all markdown files
find docs -name "*.md" -type f | while read -r md_file; do
    validate_markdown_links "$md_file"
    validate_script_references "$md_file"
    validate_workflow_references "$md_file"
    echo ""
done

# Validate npm script references
validate_npm_script_references
echo ""

# Check for documentation synchronization
check_duplicate_documentation
echo ""

# Validate GitHub Actions versions
validate_action_versions
echo ""

# Summary
if [ $ERRORS -eq 0 ]; then
    echo "🎉 All cross-reference validation checks passed!"
    exit 0
else
    echo "❌ Found $ERRORS cross-reference errors that need attention"
    exit 1
fi