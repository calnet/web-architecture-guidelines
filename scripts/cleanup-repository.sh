#!/bin/bash

# Repository Cleanup and Maintenance Script
# Automated cleanup for redundant files and process optimization

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
DRY_RUN=false
VERBOSE=false
BACKUP_DIR="backups/cleanup/$(date +%Y%m%d_%H%M%S)"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --dry-run        Show what would be done without making changes"
            echo "  -v, --verbose    Enable verbose output"
            echo "  -h, --help       Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Logging functions
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[DONE]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

header() {
    echo -e "${CYAN}=== $1 ===${NC}"
}

# Backup function
backup_file() {
    local file="$1"
    if [[ -f "$file" ]] && [[ "$DRY_RUN" == "false" ]]; then
        mkdir -p "$BACKUP_DIR"
        cp "$file" "$BACKUP_DIR/"
        log "Backed up: $file"
    fi
}

# Remove file with backup
remove_file() {
    local file="$1"
    local reason="$2"
    
    if [[ -f "$file" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log "Would remove: $file ($reason)"
        else
            backup_file "$file"
            rm -f "$file"
            success "Removed: $file ($reason)"
        fi
    else
        if [[ "$VERBOSE" == "true" ]]; then
            log "Not found: $file (already removed)"
        fi
    fi
}

# Check for duplicate npm scripts
check_duplicate_scripts() {
    header "Checking for Duplicate NPM Scripts"
    
    if [[ -f "package.json" ]]; then
        # Extract script names and look for patterns that suggest duplicates
        local scripts=$(grep -o '"[^"]*":' package.json | grep -v '^"name":' | grep -v '^"version":' | grep -v '^"description":' | sort)
        
        # Look for patterns like script/script-enhanced, script/script-strict
        echo "$scripts" | grep -o '"[^"]*"' | tr -d '"' | while read script; do
            if echo "$scripts" | grep -q "\"${script}-enhanced\":\|\"${script}-strict\":\|\"${script}-basic\":"; then
                warning "Potential duplicate script pattern: $script"
            fi
        done
    fi
}

# Main cleanup function
main() {
    header "Repository Cleanup and Maintenance"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "Running in DRY RUN mode - no changes will be made"
    fi
    
    # 1. Remove redundant merge tracking files
    header "Removing Redundant Merge Files"
    remove_file "CONFLICT_ANALYSIS.md" "outdated conflict tracking"
    remove_file "MERGE_COMMIT_PLAN.md" "historical merge documentation"
    remove_file "MERGE_COMPLETION_SUMMARY.md" "completed merge tracking"
    remove_file "MERGE_PLAN_CLEAN.md" "redundant merge planning"
    remove_file "PR_SUMMARY.md" "outdated PR documentation"
    
    # 2. Remove redundant validation scripts
    header "Consolidating Validation Scripts"
    remove_file "scripts/validate-cross-references.sh" "replaced by enhanced version"
    remove_file "scripts/check-project-errors.sh" "replaced by strict version"
    remove_file "scripts/create-simple-monitoring.sh" "redundant monitoring script"
    remove_file "scripts/copy-templates.sh" "replaced by GitHub workflow"
    
    # 3. Remove redundant workflows
    header "Streamlining GitHub Workflows"
    remove_file ".github/workflows/claude.yml" "basic claude workflow replaced by comprehensive version"
    
    # 4. Check for orphaned files
    header "Checking for Orphaned Files"
    
    # Look for backup directories that are too old
    if [[ -d "backups" ]]; then
        find backups -type d -name "*" -mtime +30 2>/dev/null | while read old_backup; do
            if [[ "$DRY_RUN" == "true" ]]; then
                log "Would remove old backup: $old_backup"
            else
                warning "Old backup found: $old_backup (consider manual removal)"
            fi
        done
    fi
    
    # 5. Check npm scripts for redundancies
    check_duplicate_scripts
    
    # 6. Validate file structure
    header "Validating File Structure"
    
    # Check for empty directories
    find . -type d -empty -not -path "./.git/*" 2>/dev/null | while read empty_dir; do
        warning "Empty directory found: $empty_dir"
    done
    
    # Check for large files that might be accidentally committed
    find . -type f -size +10M -not -path "./.git/*" 2>/dev/null | while read large_file; do
        warning "Large file found: $large_file ($(du -h "$large_file" | cut -f1))"
    done
    
    # 7. Cleanup summary
    header "Cleanup Summary"
    
    if [[ "$DRY_RUN" == "false" ]] && [[ -d "$BACKUP_DIR" ]]; then
        success "Backup created: $BACKUP_DIR"
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "Dry run completed. Use without --dry-run to apply changes."
    else
        success "Repository cleanup completed"
        log "To validate the repository after cleanup, run: npm run validate:all"
    fi
}

# Run main function
main "$@"