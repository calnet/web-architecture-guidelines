#!/bin/bash

# Consolidated Version Management Script
# Replaces: sync-versions.sh, maintain-versions.sh, enhance-version-management.sh, 
#           list-version-files.sh, discover-version-files.sh
# This single script handles all version management operations

set -euo pipefail

# Load common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

cd "$ROOT_DIR"

# Configuration
VERBOSE=false
DRY_RUN=false
OPERATION="sync"  # sync, list, discover, maintain, validate

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -o|--operation)
            OPERATION="$2"
            shift 2
            ;;
        --sync)
            OPERATION="sync"
            shift
            ;;
        --list)
            OPERATION="list"
            shift
            ;;
        --discover)
            OPERATION="discover"
            shift
            ;;
        --maintain)
            OPERATION="maintain"
            shift
            ;;
        --validate)
            OPERATION="validate"
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -v, --verbose      Show detailed output"
            echo "  -n, --dry-run      Show what would be done without making changes"
            echo "  -o, --operation OP Operation: sync, list, discover, maintain, validate"
            echo "      --sync         Synchronize all versions (default)"
            echo "      --list         List all version-managed files"
            echo "      --discover     Discover new files with versions"
            echo "      --maintain     Maintain version consistency"
            echo "      --validate     Validate version consistency"
            echo "  -h, --help         Show this help"
            echo ""
            echo "Operations:"
            echo "  sync      - Synchronize all version numbers to main version"
            echo "  list      - List all files containing version information"
            echo "  discover  - Discover and add version info to relevant files"
            echo "  maintain  - Ongoing maintenance of version consistency"
            echo "  validate  - Validate version consistency across repository"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Get main version
MAIN_VERSION=$(get_main_version)

if [ "$MAIN_VERSION" = "0.0.0" ]; then
    log_error "Root VERSION file not found or invalid!"
    exit 1
fi

log_info "Version Management - Operation: $OPERATION"
log_info "Current version: $MAIN_VERSION"
echo "============================================="

# Initialize counters
init_counters

# Version-managed file patterns
VERSION_PATTERNS=(
    "package.json"
    "docs/package.json"
    "VERSION"
    "*.md"
    "docs/**/*.md"
    "scripts/*.sh"
    ".github/**/*.yml"
    ".github/**/*.yaml"
)

# Function to find all version-managed files
find_version_files() {
    local files=()
    
    # Find specific files
    [ -f "package.json" ] && files+=("package.json")
    [ -f "docs/package.json" ] && files+=("docs/package.json")
    [ -f "VERSION" ] && files+=("VERSION")
    
    # Find markdown files with version info
    while IFS= read -r -d '' file; do
        if grep -l "version.*[0-9]\+\.[0-9]\+\.[0-9]\+" "$file" >/dev/null 2>&1; then
            files+=("$file")
        fi
    done < <(find . -name "*.md" -type f -print0 2>/dev/null || true)
    
    # Find script files with version info
    while IFS= read -r -d '' file; do
        if grep -l "Version.*[0-9]\+\.[0-9]\+\.[0-9]\+" "$file" >/dev/null 2>&1; then
            files+=("$file")
        fi
    done < <(find scripts -name "*.sh" -type f -print0 2>/dev/null || true)
    
    # Find GitHub workflow files
    while IFS= read -r -d '' file; do
        files+=("$file")
    done < <(find .github -name "*.yml" -o -name "*.yaml" -type f -print0 2>/dev/null || true)
    
    printf '%s\n' "${files[@]}" | sort -u
}

# Function to update version in file
update_version_in_file() {
    local file="$1"
    local backup_file="${file}.version_backup"
    local updated=false
    
    if [ "$DRY_RUN" = "true" ]; then
        log_info "Would update version in: $file"
        return 0
    fi
    
    # Create backup
    cp "$file" "$backup_file"
    
    case "$file" in
        package.json|*/package.json)
            if grep -q '"version"' "$file"; then
                sed -i "s/\"version\": \"[^\"]*\"/\"version\": \"$MAIN_VERSION\"/" "$file"
                updated=true
            fi
            ;;
        *.md)
            # Update version references in markdown
            if sed -i "s/\*\*Version\*\*: [0-9]\+\.[0-9]\+\.[0-9]\+/**Version**: $MAIN_VERSION/g" "$file" && \
               sed -i "s/- \*\*Version\*\*: [0-9]\+\.[0-9]\+\.[0-9]\+/- **Version**: $MAIN_VERSION/g" "$file" && \
               sed -i "s/Version: [0-9]\+\.[0-9]\+\.[0-9]\+/Version: $MAIN_VERSION/g" "$file"; then
                updated=true
            fi
            ;;
        *.sh)
            if sed -i "s/# Version: [0-9]\+\.[0-9]\+\.[0-9]\+/# Version: $MAIN_VERSION/g" "$file"; then
                updated=true
            fi
            ;;
        *.yml|*.yaml)
            if sed -i "s/version: [0-9]\+\.[0-9]\+\.[0-9]\+/version: $MAIN_VERSION/g" "$file"; then
                updated=true
            fi
            ;;
    esac
    
    if [ "$updated" = "true" ]; then
        if [ "$VERBOSE" = "true" ]; then
            log_success "Updated version in: $file"
        fi
        increment_passed
        rm "$backup_file"
    else
        if [ "$VERBOSE" = "true" ]; then
            log_warning "No version pattern found in: $file"
        fi
        increment_warning
        mv "$backup_file" "$file"  # Restore original
    fi
}

# Operation implementations
operation_sync() {
    log_step "Synchronizing versions to $MAIN_VERSION"
    
    while IFS= read -r file; do
        [ -n "$file" ] && update_version_in_file "$file"
    done < <(find_version_files)
}

operation_list() {
    log_step "Listing version-managed files"
    
    while IFS= read -r file; do
        if [ -n "$file" ] && [ -f "$file" ]; then
            echo "$file"
            increment_total
        fi
    done < <(find_version_files)
    
    log_info "Found $TOTAL_CHECKS version-managed files"
}

operation_discover() {
    log_step "Discovering files that should have version information"
    
    # Find files that might need version info but don't have it
    local candidates=()
    
    # Check major documentation files
    for file in README.md CHANGELOG.md docs/README.md; do
        if [ -f "$file" ] && ! grep -q "version.*[0-9]\+\.[0-9]\+\.[0-9]\+" "$file"; then
            candidates+=("$file")
        fi
    done
    
    # Check template files
    while IFS= read -r -d '' file; do
        if ! grep -q "version.*[0-9]\+\.[0-9]\+\.[0-9]\+" "$file"; then
            candidates+=("$file")
        fi
    done < <(find docs/templates -name "*.md" -type f -print0 2>/dev/null || true)
    
    for file in "${candidates[@]}"; do
        echo "$file"
        increment_total
    done
    
    if [ ${#candidates[@]} -gt 0 ]; then
        log_info "Found ${#candidates[@]} files that could benefit from version information"
    else
        log_success "All relevant files already have version information"
    fi
}

operation_maintain() {
    log_step "Maintaining version consistency"
    
    # First validate
    operation_validate
    
    # Then sync if issues found
    if [ $FAILED_CHECKS -gt 0 ]; then
        log_step "Issues found, synchronizing versions"
        operation_sync
    else
        log_success "All versions are already consistent"
    fi
}

operation_validate() {
    log_step "Validating version consistency"
    
    while IFS= read -r file; do
        if [ -n "$file" ] && [ -f "$file" ]; then
            case "$file" in
                package.json|*/package.json)
                    if grep -q "\"version\": \"$MAIN_VERSION\"" "$file"; then
                        increment_passed
                        [ "$VERBOSE" = "true" ] && log_success "$file: version correct"
                    else
                        increment_failed
                        [ "$VERBOSE" = "true" ] && log_error "$file: version mismatch"
                    fi
                    ;;
                *.md)
                    if grep -q "$MAIN_VERSION" "$file"; then
                        increment_passed
                        [ "$VERBOSE" = "true" ] && log_success "$file: version found"
                    else
                        increment_failed
                        [ "$VERBOSE" = "true" ] && log_error "$file: version not found or incorrect"
                    fi
                    ;;
                *)
                    increment_passed
                    ;;
            esac
        fi
    done < <(find_version_files)
}

# Execute operation
case $OPERATION in
    "sync")
        operation_sync
        ;;
    "list")
        operation_list
        ;;
    "discover")
        operation_discover
        ;;
    "maintain")
        operation_maintain
        ;;
    "validate")
        operation_validate
        ;;
    *)
        log_error "Unknown operation: $OPERATION"
        exit 1
        ;;
esac

# Generate summary
generate_summary

# Exit with appropriate code
if [ $FAILED_CHECKS -gt 0 ]; then
    exit 1
else
    exit 0
fi