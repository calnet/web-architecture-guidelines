#!/bin/bash

# Breaking Change Detection Script
# Analyzes changes to detect potential breaking changes in templates and APIs

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$ROOT_DIR"

# Configuration
COMPARE_AGAINST="${1:-HEAD~1}"  # Default to previous commit
OUTPUT_FORMAT="${2:-text}"      # text, json, or markdown

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

BREAKING_CHANGES=0
WARNINGS=0

log() {
    if [[ "$OUTPUT_FORMAT" == "text" ]]; then
        echo -e "${BLUE}[INFO]${NC} $1"
    fi
}

warn() {
    if [[ "$OUTPUT_FORMAT" == "text" ]]; then
        echo -e "${YELLOW}[WARN]${NC} $1"
    fi
    WARNINGS=$((WARNINGS + 1))
}

breaking() {
    if [[ "$OUTPUT_FORMAT" == "text" ]]; then
        echo -e "${RED}[BREAKING]${NC} $1"
    fi
    BREAKING_CHANGES=$((BREAKING_CHANGES + 1))
}

success() {
    if [[ "$OUTPUT_FORMAT" == "text" ]]; then
        echo -e "${GREEN}[SUCCESS]${NC} $1"
    fi
}

header() {
    if [[ "$OUTPUT_FORMAT" == "text" ]]; then
        echo -e "${MAGENTA}$1${NC}"
        echo "=================================="
    fi
}

# Initialize output
if [[ "$OUTPUT_FORMAT" == "json" ]]; then
    echo "{"
    echo "  \"breaking_changes\": [],"
    echo "  \"warnings\": [],"
    echo "  \"summary\": {"
elif [[ "$OUTPUT_FORMAT" == "markdown" ]]; then
    echo "# Breaking Change Analysis"
    echo ""
    echo "**Comparing against:** $COMPARE_AGAINST"
    echo ""
fi

header "🔍 Breaking Change Detection"
log "Comparing against: $COMPARE_AGAINST"

# 1. Detect template structure changes
analyze_template_changes() {
    header "📋 Analyzing Template Changes"
    
    local breaking_items=()
    local warning_items=()
    
    # Get list of changed template files
    changed_templates=$(git diff --name-only "$COMPARE_AGAINST" -- docs/templates/ 2>/dev/null || echo "")
    
    if [[ -z "$changed_templates" ]]; then
        log "No template files changed"
        return
    fi
    
    for template in $changed_templates; do
        if [[ ! -f "$template" ]]; then
            breaking "Template deleted: $template"
            breaking_items+=("Template deleted: $template")
            continue
        fi
        
        log "Analyzing template: $template"
        
        # Check for removed sections
        removed_sections=$(git diff "$COMPARE_AGAINST" "$template" | grep '^-#' | grep -v '^-##' | sed 's/^-//')
        if [[ -n "$removed_sections" ]]; then
            while IFS= read -r section; do
                breaking "Removed section in $template: $section"
                breaking_items+=("Removed section in $template: $section")
            done <<< "$removed_sections"
        fi
        
        # Check for removed required fields
        removed_required=$(git diff "$COMPARE_AGAINST" "$template" | grep '^-.*\*\*.*\*\*.*:' | sed 's/^-//')
        if [[ -n "$removed_required" ]]; then
            while IFS= read -r field; do
                breaking "Removed required field in $template: $field"
                breaking_items+=("Removed required field in $template: $field")
            done <<< "$removed_required"
        fi
        
        # Check for changed field names
        changed_fields=$(git diff "$COMPARE_AGAINST" "$template" | grep -E '^[-+].*\*\*.*\*\*.*:' | sort | uniq -c | awk '$1==1 {print $0}')
        if [[ -n "$changed_fields" ]]; then
            warn "Field changes detected in $template - review for breaking changes"
            warning_items+=("Field changes detected in $template")
        fi
        
        # Check for version changes that might indicate breaking changes
        version_changes=$(git diff "$COMPARE_AGAINST" "$template" | grep -E '^[-+].*Template Version.*[0-9]+\.[0-9]+\.[0-9]+')
        if [[ -n "$version_changes" ]]; then
            old_version=$(echo "$version_changes" | grep '^-' | sed 's/.*Template Version.*: //' | tr -d ' ')
            new_version=$(echo "$version_changes" | grep '^+' | sed 's/.*Template Version.*: //' | tr -d ' ')
            
            if [[ -n "$old_version" ]] && [[ -n "$new_version" ]]; then
                # Parse versions
                old_major=$(echo "$old_version" | cut -d. -f1)
                new_major=$(echo "$new_version" | cut -d. -f1)
                
                if [[ "$new_major" -gt "$old_major" ]]; then
                    breaking "Major version increase in $template: $old_version -> $new_version"
                    breaking_items+=("Major version increase in $template: $old_version -> $new_version")
                fi
            fi
        fi
    done
    
    # Store results for JSON/Markdown output
    if [[ "$OUTPUT_FORMAT" != "text" ]]; then
        template_breaking_changes=("${breaking_items[@]}")
        template_warnings=("${warning_items[@]}")
    fi
}

# 2. Detect API/interface changes
analyze_api_changes() {
    header "🔌 Analyzing API Changes"
    
    local breaking_items=()
    local warning_items=()
    
    # Check for changes in API documentation
    api_docs=$(git diff --name-only "$COMPARE_AGAINST" -- docs/api/ 2>/dev/null || echo "")
    
    if [[ -z "$api_docs" ]]; then
        log "No API documentation changed"
        return
    fi
    
    for api_doc in $api_docs; do
        if [[ ! -f "$api_doc" ]]; then
            breaking "API documentation deleted: $api_doc"
            breaking_items+=("API documentation deleted: $api_doc")
            continue
        fi
        
        log "Analyzing API documentation: $api_doc"
        
        # Check for removed endpoints
        removed_endpoints=$(git diff "$COMPARE_AGAINST" "$api_doc" | grep -E '^-.*\/(GET|POST|PUT|DELETE|PATCH)' | sed 's/^-//')
        if [[ -n "$removed_endpoints" ]]; then
            while IFS= read -r endpoint; do
                breaking "Removed API endpoint in $api_doc: $endpoint"
                breaking_items+=("Removed API endpoint in $api_doc: $endpoint")
            done <<< "$removed_endpoints"
        fi
        
        # Check for changed response formats
        response_changes=$(git diff "$COMPARE_AGAINST" "$api_doc" | grep -E '^[-+].*response.*:')
        if [[ -n "$response_changes" ]]; then
            warn "Response format changes detected in $api_doc"
            warning_items+=("Response format changes detected in $api_doc")
        fi
    done
    
    # Store results for JSON/Markdown output
    if [[ "$OUTPUT_FORMAT" != "text" ]]; then
        api_breaking_changes=("${breaking_items[@]}")
        api_warnings=("${warning_items[@]}")
    fi
}

# 3. Detect configuration changes
analyze_config_changes() {
    header "⚙️ Analyzing Configuration Changes"
    
    local breaking_items=()
    local warning_items=()
    
    # Check for changes in configuration files
    config_files=$(git diff --name-only "$COMPARE_AGAINST" -- "*.json" "*.yml" "*.yaml" "*.toml" "*.config.*" 2>/dev/null || echo "")
    
    for config_file in $config_files; do
        if [[ ! -f "$config_file" ]]; then
            breaking "Configuration file deleted: $config_file"
            breaking_items+=("Configuration file deleted: $config_file")
            continue
        fi
        
        log "Analyzing configuration: $config_file"
        
        # Check for removed configuration keys
        if [[ "$config_file" == *.json ]]; then
            removed_keys=$(git diff "$COMPARE_AGAINST" "$config_file" | grep '^-.*".*":' | sed 's/^-//' | sed 's/.*"\(.*\)".*/\1/')
            if [[ -n "$removed_keys" ]]; then
                while IFS= read -r key; do
                    if [[ -n "$key" ]]; then
                        breaking "Removed configuration key in $config_file: $key"
                        breaking_items+=("Removed configuration key in $config_file: $key")
                    fi
                done <<< "$removed_keys"
            fi
        fi
    done
    
    # Store results for JSON/Markdown output
    if [[ "$OUTPUT_FORMAT" != "text" ]]; then
        config_breaking_changes=("${breaking_items[@]}")
        config_warnings=("${warning_items[@]}")
    fi
}

# 4. Detect script/tool interface changes
analyze_script_changes() {
    header "🔧 Analyzing Script Interface Changes"
    
    local breaking_items=()
    local warning_items=()
    
    # Check for changes in script files
    script_files=$(git diff --name-only "$COMPARE_AGAINST" -- "scripts/*.sh" "*.sh" 2>/dev/null || echo "")
    
    for script_file in $script_files; do
        if [[ ! -f "$script_file" ]]; then
            warn "Script deleted: $script_file"
            warning_items+=("Script deleted: $script_file")
            continue
        fi
        
        log "Analyzing script: $script_file"
        
        # Check for removed command line options
        removed_options=$(git diff "$COMPARE_AGAINST" "$script_file" | grep -E '^-.*(-[a-zA-Z]|--[a-zA-Z])' | sed 's/^-//')
        if [[ -n "$removed_options" ]]; then
            while IFS= read -r option; do
                if [[ -n "$option" ]]; then
                    warn "Removed script option in $script_file: $option"
                    warning_items+=("Removed script option in $script_file: $option")
                fi
            done <<< "$removed_options"
        fi
        
        # Check for changed exit codes or error handling
        exit_changes=$(git diff "$COMPARE_AGAINST" "$script_file" | grep -E '^[-+].*exit [0-9]+')
        if [[ -n "$exit_changes" ]]; then
            warn "Exit code changes detected in $script_file"
            warning_items+=("Exit code changes detected in $script_file")
        fi
    done
    
    # Store results for JSON/Markdown output
    if [[ "$OUTPUT_FORMAT" != "text" ]]; then
        script_breaking_changes=()
        script_warnings=("${warning_items[@]}")
    fi
}

# Run all analyses
analyze_template_changes
analyze_api_changes  
analyze_config_changes
analyze_script_changes

# Generate output based on format
if [[ "$OUTPUT_FORMAT" == "json" ]]; then
    # Combine all breaking changes
    all_breaking=()
    all_warnings=()
    
    [[ -n "${template_breaking_changes:-}" ]] && all_breaking+=("${template_breaking_changes[@]}")
    [[ -n "${api_breaking_changes:-}" ]] && all_breaking+=("${api_breaking_changes[@]}")
    [[ -n "${config_breaking_changes:-}" ]] && all_breaking+=("${config_breaking_changes[@]}")
    
    [[ -n "${template_warnings:-}" ]] && all_warnings+=("${template_warnings[@]}")
    [[ -n "${api_warnings:-}" ]] && all_warnings+=("${api_warnings[@]}")
    [[ -n "${config_warnings:-}" ]] && all_warnings+=("${config_warnings[@]}")
    [[ -n "${script_warnings:-}" ]] && all_warnings+=("${script_warnings[@]}")
    
    echo "    \"breaking_count\": $BREAKING_CHANGES,"
    echo "    \"warning_count\": $WARNINGS"
    echo "  }"
    echo "}"
    
elif [[ "$OUTPUT_FORMAT" == "markdown" ]]; then
    echo "## Summary"
    echo ""
    echo "- **Breaking Changes:** $BREAKING_CHANGES"
    echo "- **Warnings:** $WARNINGS"
    echo ""
    
    if [[ $BREAKING_CHANGES -gt 0 ]]; then
        echo "### 🚨 Breaking Changes Detected"
        echo ""
        echo "This release contains breaking changes that may require user action."
        echo ""
    fi
    
    if [[ $WARNINGS -gt 0 ]]; then
        echo "### ⚠️ Warnings"
        echo ""
        echo "Please review these changes for potential compatibility issues."
        echo ""
    fi
    
    if [[ $BREAKING_CHANGES -eq 0 ]] && [[ $WARNINGS -eq 0 ]]; then
        echo "### ✅ No Breaking Changes Detected"
        echo ""
        echo "This release appears to be backward compatible."
        echo ""
    fi
fi

# Final summary for text output
if [[ "$OUTPUT_FORMAT" == "text" ]]; then
    header "📊 Breaking Change Analysis Summary"
    
    if [[ $BREAKING_CHANGES -eq 0 ]] && [[ $WARNINGS -eq 0 ]]; then
        success "No breaking changes detected!"
    elif [[ $BREAKING_CHANGES -eq 0 ]]; then
        warn "No breaking changes detected, but $WARNINGS warnings found"
    else
        breaking "Found $BREAKING_CHANGES breaking changes and $WARNINGS warnings"
        log ""
        log "💡 Consider:"
        log "  - Bumping major version for breaking changes"
        log "  - Adding migration documentation"
        log "  - Updating changelog with breaking change notices"
    fi
fi

# Exit with appropriate code
if [[ $BREAKING_CHANGES -gt 0 ]]; then
    exit 2  # Breaking changes detected
elif [[ $WARNINGS -gt 0 ]]; then
    exit 1  # Warnings detected
else
    exit 0  # No issues
fi