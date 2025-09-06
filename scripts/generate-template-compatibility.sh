#!/bin/bash

# Template Compatibility Matrix Generator
# Creates a compatibility matrix showing template dependencies and version requirements

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$ROOT_DIR"

# Configuration
OUTPUT_FILE="${1:-docs/TEMPLATE_COMPATIBILITY.md}"
FORMAT="${2:-markdown}"  # markdown, json, csv

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log "🔍 Generating Template Compatibility Matrix"
log "==========================================="

# Initialize data structures
declare -A template_versions
declare -A template_dependencies
declare -A template_categories
declare -A template_target_audience
declare -A template_frameworks
declare -A template_last_updated

# Analyze template files
analyze_templates() {
    log "📋 Analyzing template files..."
    
    find docs/templates -name "*.md" -type f | while read -r template_file; do
        local template_name=$(basename "$template_file" .md)
        local category=$(basename "$(dirname "$template_file")")
        
        log "  Processing: $template_name"
        
        # Extract template version
        local version=$(grep -o "\*\*Template Version\*\*: [^*]*" "$template_file" 2>/dev/null | sed 's/\*\*Template Version\*\*: //' | tr -d ' ' || echo "1.0.0")
        template_versions["$template_name"]="$version"
        
        # Extract category
        template_categories["$template_name"]="$category"
        
        # Extract target audience
        local audience=$(grep -o "\*\*Target Audience\*\*: [^*]*" "$template_file" 2>/dev/null | sed 's/\*\*Target Audience\*\*: //' | head -1 || echo "General")
        template_target_audience["$template_name"]="$audience"
        
        # Extract last updated
        local last_updated=$(grep -o "\*\*Last Updated\*\*: [^*]*" "$template_file" 2>/dev/null | sed 's/\*\*Last Updated\*\*: //' | head -1 || echo "Unknown")
        template_last_updated["$template_name"]="$last_updated"
        
        # Look for framework dependencies
        local frameworks=""
        if grep -qi "react" "$template_file"; then frameworks+="React "; fi
        if grep -qi "vue" "$template_file"; then frameworks+="Vue "; fi
        if grep -qi "angular" "$template_file"; then frameworks+="Angular "; fi
        if grep -qi "django" "$template_file"; then frameworks+="Django "; fi
        if grep -qi "spring" "$template_file"; then frameworks+="Spring "; fi
        if grep -qi "express" "$template_file"; then frameworks+="Express "; fi
        if grep -qi "flask" "$template_file"; then frameworks+="Flask "; fi
        if grep -qi "laravel" "$template_file"; then frameworks+="Laravel "; fi
        if grep -qi "docker" "$template_file"; then frameworks+="Docker "; fi
        if grep -qi "kubernetes" "$template_file"; then frameworks+="Kubernetes "; fi
        
        template_frameworks["$template_name"]="${frameworks% }"  # Remove trailing space
        
        # Look for template dependencies (references to other templates)
        local dependencies=""
        while IFS= read -r line; do
            if [[ "$line" =~ docs/templates/.*\.md ]]; then
                local dep=$(echo "$line" | grep -o "docs/templates/[^)]*\.md" | sed 's|docs/templates/||' | sed 's|\.md||')
                if [[ "$dep" != "$template_name" ]]; then
                    dependencies+="$dep "
                fi
            fi
        done < "$template_file"
        
        template_dependencies["$template_name"]="${dependencies% }"  # Remove trailing space
        
        # Write data to temporary files for the main script to read
        echo "$template_name|$version|$category|$audience|${frameworks% }|${dependencies% }|$last_updated" >> "/tmp/template_data.txt"
    done
}

# Generate compatibility matrix in markdown format
generate_markdown() {
    local output_file="$1"
    
    log "📄 Generating Markdown compatibility matrix..."
    
    cat > "$output_file" << 'EOF'
# Template Compatibility Matrix

This document provides a comprehensive overview of template compatibility, dependencies, and version requirements across the web architecture guidelines repository.

**Generated:** $(date '+%Y-%m-%d %H:%M:%S')

## Overview

The template compatibility matrix helps developers understand:
- Template version dependencies
- Framework compatibility
- Inter-template relationships
- Target audience and use cases

## Template Categories

EOF

    # Add category overview
    categories=$(cut -d'|' -f3 /tmp/template_data.txt | sort | uniq)
    for category in $categories; do
        echo "### $category" >> "$output_file"
        echo "" >> "$output_file"
        grep "|$category|" /tmp/template_data.txt | while IFS='|' read -r name version cat audience frameworks deps updated; do
            echo "- **$name** (v$version) - $audience" >> "$output_file"
        done
        echo "" >> "$output_file"
    done
    
    cat >> "$output_file" << 'EOF'

## Compatibility Matrix

| Template | Version | Category | Target Audience | Frameworks | Dependencies | Last Updated |
|----------|---------|----------|-----------------|------------|--------------|--------------|
EOF

    # Sort templates by category then name
    sort -t'|' -k3,3 -k1,1 /tmp/template_data.txt | while IFS='|' read -r name version category audience frameworks deps updated; do
        deps_formatted=$(echo "$deps" | sed 's/ /, /g')
        frameworks_formatted=$(echo "$frameworks" | sed 's/ /, /g')
        
        echo "| $name | $version | $category | $audience | $frameworks_formatted | $deps_formatted | $updated |" >> "$output_file"
    done
    
    cat >> "$output_file" << 'EOF'

## Framework Compatibility

### Supported Frameworks

EOF

    # Framework analysis
    all_frameworks=$(cut -d'|' -f5 /tmp/template_data.txt | tr ' ' '\n' | sort | uniq | grep -v '^$')
    for framework in $all_frameworks; do
        count=$(grep -c "|[^|]*$framework" /tmp/template_data.txt || echo "0")
        echo "- **$framework**: $count templates" >> "$output_file"
    done
    
    cat >> "$output_file" << 'EOF'

### Framework-Specific Templates

EOF

    for framework in $all_frameworks; do
        echo "#### $framework" >> "$output_file"
        echo "" >> "$output_file"
        grep "|[^|]*$framework" /tmp/template_data.txt | while IFS='|' read -r name version category audience frameworks deps updated; do
            echo "- $name (v$version) - $category" >> "$output_file"
        done
        echo "" >> "$output_file"
    done
    
    cat >> "$output_file" << 'EOF'

## Dependency Graph

### Templates with Dependencies

EOF

    # Dependency analysis
    grep -v '||$' /tmp/template_data.txt | grep '|[^|]*|$' | while IFS='|' read -r name version category audience frameworks deps updated; do
        if [[ -n "$deps" ]]; then
            echo "#### $name" >> "$output_file"
            echo "" >> "$output_file"
            echo "**Dependencies:** $deps" >> "$output_file"
            echo "" >> "$output_file"
            for dep in $deps; do
                dep_info=$(grep "^$dep|" /tmp/template_data.txt | head -1)
                if [[ -n "$dep_info" ]]; then
                    dep_version=$(echo "$dep_info" | cut -d'|' -f2)
                    dep_category=$(echo "$dep_info" | cut -d'|' -f3)
                    echo "- $dep (v$dep_version) - $dep_category" >> "$output_file"
                fi
            done
            echo "" >> "$output_file"
        fi
    done
    
    cat >> "$output_file" << 'EOF'

## Version Compatibility Rules

### Semantic Versioning

All templates follow [Semantic Versioning](https://semver.org/):
- **Major version** (X.y.z): Breaking changes that require user action
- **Minor version** (x.Y.z): New features, backward compatible
- **Patch version** (x.y.Z): Bug fixes, backward compatible

### Compatibility Guidelines

1. **Same Major Version**: Templates within the same major version are compatible
2. **Dependency Versions**: Use templates with matching or compatible dependency versions
3. **Framework Versions**: Ensure framework compatibility when mixing templates
4. **Update Strategy**: Update dependencies before dependent templates

### Breaking Changes

When major versions change, review:
- Template structure changes
- Required field modifications
- Framework compatibility updates
- Dependency requirement changes

## Usage Recommendations

### For New Projects

1. **Start with latest versions** of all required templates
2. **Check framework compatibility** before selection
3. **Review dependencies** to ensure consistency
4. **Consider target audience** alignment

### For Existing Projects

1. **Review breaking changes** before updating
2. **Update dependencies first** before main templates
3. **Test compatibility** in development environment
4. **Update incrementally** rather than all at once

### Best Practices

- Maintain template version consistency across project
- Document any customizations made to templates
- Regular review and update of template versions
- Follow repository upgrade guides for major version changes

## Maintenance

This compatibility matrix is automatically generated and should be updated:
- After any template version changes
- When new templates are added
- During major repository releases
- Quarterly as part of regular maintenance

**Last Generated:** $(date '+%Y-%m-%d %H:%M:%S')
EOF

    # Replace the date placeholder
    sed -i "s/\*\*Generated:\*\* \$(date.*)/\*\*Generated:\*\* $(date '+%Y-%m-%d %H:%M:%S')/" "$output_file"
    sed -i "s/\*\*Last Generated:\*\* \$(date.*)/\*\*Last Generated:\*\* $(date '+%Y-%m-%d %H:%M:%S')/" "$output_file"
}

# Generate JSON format
generate_json() {
    local output_file="$1"
    
    log "📊 Generating JSON compatibility matrix..."
    
    cat > "$output_file" << EOF
{
  "metadata": {
    "generated": "$(date -Iseconds)",
    "repository": "web-architecture-guidelines",
    "version": "$(cat VERSION 2>/dev/null || echo '1.0.0')"
  },
  "templates": [
EOF

    local first=true
    while IFS='|' read -r name version category audience frameworks deps updated; do
        if [[ "$first" == "true" ]]; then
            first=false
        else
            echo "," >> "$output_file"
        fi
        
        # Convert space-separated to JSON arrays
        frameworks_json=$(echo "$frameworks" | sed 's/ /", "/g' | sed 's/^/["/' | sed 's/$/"]/' | sed 's/\[""\]$/[]/')
        deps_json=$(echo "$deps" | sed 's/ /", "/g' | sed 's/^/["/' | sed 's/$/"]/' | sed 's/\[""\]$/[]/')
        
        cat >> "$output_file" << EOF
    {
      "name": "$name",
      "version": "$version",
      "category": "$category",
      "target_audience": "$audience",
      "frameworks": $frameworks_json,
      "dependencies": $deps_json,
      "last_updated": "$updated"
    }
EOF
    done < /tmp/template_data.txt
    
    cat >> "$output_file" << EOF

  ],
  "categories": [
EOF

    categories=$(cut -d'|' -f3 /tmp/template_data.txt | sort | uniq)
    first=true
    for category in $categories; do
        if [[ "$first" == "true" ]]; then
            first=false
        else
            echo "," >> "$output_file"
        fi
        
        count=$(grep -c "|$category|" /tmp/template_data.txt)
        echo "    { \"name\": \"$category\", \"template_count\": $count }" >> "$output_file"
    done
    
    cat >> "$output_file" << EOF

  ],
  "frameworks": [
EOF

    all_frameworks=$(cut -d'|' -f5 /tmp/template_data.txt | tr ' ' '\n' | sort | uniq | grep -v '^$')
    first=true
    for framework in $all_frameworks; do
        if [[ "$first" == "true" ]]; then
            first=false
        else
            echo "," >> "$output_file"
        fi
        
        count=$(grep -c "|[^|]*$framework" /tmp/template_data.txt || echo "0")
        echo "    { \"name\": \"$framework\", \"template_count\": $count }" >> "$output_file"
    done
    
    echo "" >> "$output_file"
    echo "  ]" >> "$output_file"
    echo "}" >> "$output_file"
}

# Generate CSV format  
generate_csv() {
    local output_file="$1"
    
    log "📊 Generating CSV compatibility matrix..."
    
    echo "Template,Version,Category,Target Audience,Frameworks,Dependencies,Last Updated" > "$output_file"
    
    while IFS='|' read -r name version category audience frameworks deps updated; do
        # Escape commas in fields
        frameworks_csv=$(echo "$frameworks" | sed 's/,/;/g')
        deps_csv=$(echo "$deps" | sed 's/,/;/g')
        audience_csv=$(echo "$audience" | sed 's/,/;/g')
        
        echo "$name,$version,$category,$audience_csv,$frameworks_csv,$deps_csv,$updated" >> "$output_file"
    done < /tmp/template_data.txt
}

# Clean up temporary files
cleanup() {
    rm -f /tmp/template_data.txt
}

# Set up cleanup trap
trap cleanup EXIT

# Main execution
analyze_templates

case "$FORMAT" in
    markdown|md)
        generate_markdown "$OUTPUT_FILE"
        ;;
    json)
        generate_json "$OUTPUT_FILE"
        ;;
    csv)
        generate_csv "$OUTPUT_FILE"
        ;;
    *)
        log "Unknown format: $FORMAT. Using markdown."
        generate_markdown "$OUTPUT_FILE"
        ;;
esac

success "Template compatibility matrix generated: $OUTPUT_FILE"
log "Format: $FORMAT"
log "Templates analyzed: $(wc -l < /tmp/template_data.txt)"

# Validation
if [[ "$FORMAT" == "json" ]]; then
    if command -v jq >/dev/null 2>&1; then
        if jq . "$OUTPUT_FILE" >/dev/null 2>&1; then
            success "JSON validation passed"
        else
            log "Warning: Generated JSON may have syntax errors"
        fi
    fi
fi