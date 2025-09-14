#!/bin/bash

# Comprehensive Change Detection and Synchronization Script
# Ensures all changes across commit history are properly reflected in the repository

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
COMMIT_RANGE="0fa994af55bac02d58cedc59f1525aa3771ba1a0..HEAD"
VERBOSE=false
GENERATE_REPORT=false
REPORT_FILE="change-analysis-report.md"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --since)
            COMMIT_RANGE="$2..HEAD"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -r|--report)
            GENERATE_REPORT=true
            if [[ $# -gt 1 ]] && [[ ! "$2" =~ ^- ]]; then
                REPORT_FILE="$2"
                shift 2
            else
                shift
            fi
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --since COMMIT   Analyze changes since specified commit"
            echo "  -v, --verbose    Enable verbose output"
            echo "  -r, --report     Generate detailed report"
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
    echo -e "${GREEN}[PASS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

header() {
    echo -e "${CYAN}=== $1 ===${NC}"
}

# Analyze commit changes
analyze_commits() {
    header "Analyzing Commit History"
    
    log "Analyzing changes since: $COMMIT_RANGE"
    
    # Get commit count
    local commit_count=$(git rev-list --count $COMMIT_RANGE 2>/dev/null || echo "0")
    log "Commits to analyze: $commit_count"
    
    if [[ $commit_count -eq 0 ]]; then
        warning "No commits found in specified range"
        return 0
    fi
    
    # Analyze file changes
    log "Analyzing file changes..."
    
    # Files added
    local files_added=$(git diff --name-only --diff-filter=A $COMMIT_RANGE | wc -l)
    
    # Files modified
    local files_modified=$(git diff --name-only --diff-filter=M $COMMIT_RANGE | wc -l)
    
    # Files deleted
    local files_deleted=$(git diff --name-only --diff-filter=D $COMMIT_RANGE | wc -l)
    
    # Lines added/removed
    local line_changes=$(git diff --shortstat $COMMIT_RANGE | tail -1)
    
    success "Files added: $files_added"
    success "Files modified: $files_modified"
    success "Files deleted: $files_deleted"
    
    if [[ -n "$line_changes" ]]; then
        success "Line changes: $line_changes"
    fi
    
    # List significant changes if verbose
    if [[ "$VERBOSE" == "true" ]]; then
        echo ""
        log "Recent commit messages:"
        git log --oneline $COMMIT_RANGE | head -10
        
        echo ""
        log "Files with most changes:"
        git diff --name-only $COMMIT_RANGE | sort | uniq -c | sort -nr | head -10
    fi
}

# Check for missing updates
check_missing_updates() {
    header "Checking for Missing Updates"
    
    local issues_found=0
    
    # 1. Check version consistency
    log "Checking version consistency..."
    if ./scripts/validate-versions.sh > /dev/null 2>&1; then
        success "Version consistency: OK"
    else
        error "Version inconsistencies found"
        issues_found=$((issues_found + 1))
    fi
    
    # 2. Check date consistency  
    log "Checking date consistency..."
    if ./scripts/validate-dates.sh > /dev/null 2>&1; then
        success "Date consistency: OK"
    else
        error "Date inconsistencies found"
        issues_found=$((issues_found + 1))
    fi
    
    # 3. Check cross-references
    log "Checking cross-references..."
    if ./scripts/validate-cross-references-enhanced.sh > /dev/null 2>&1; then
        success "Cross-references: OK"
    else
        error "Cross-reference issues found"
        issues_found=$((issues_found + 1))
    fi
    
    # 4. Check for orphaned files
    log "Checking for orphaned files..."
    local orphaned_files=0
    
    # Look for backup files
    find . -name "*.bak" -o -name "*.tmp" -o -name "*~" | while read backup_file; do
        warning "Backup file found: $backup_file"
        orphaned_files=$((orphaned_files + 1))
    done
    
    # Look for duplicate documentation
    find . -name "*.md" | sort | while read file; do
        local basename=$(basename "$file")
        local duplicates=$(find . -name "$basename" -not -path "$file" | wc -l)
        if [[ $duplicates -gt 0 ]]; then
            warning "Potential duplicate documentation: $basename"
        fi
    done
    
    if [[ $issues_found -eq 0 ]]; then
        success "No missing updates detected"
    else
        error "Found $issues_found issues requiring attention"
    fi
    
    return $issues_found
}

# Generate comprehensive report
generate_report() {
    header "Generating Comprehensive Report"
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local current_version=$(cat VERSION 2>/dev/null || echo "unknown")
    local commit_count=$(git rev-list --count $COMMIT_RANGE 2>/dev/null || echo "0")
    
    cat > "$REPORT_FILE" << EOF
# Repository Change Analysis Report

**Generated:** $timestamp  
**Repository:** web-architecture-guidelines  
**Current Version:** $current_version  
**Analysis Range:** $COMMIT_RANGE  
**Commits Analyzed:** $commit_count

## Change Summary

### File Changes
$(git diff --name-status $COMMIT_RANGE | head -20)

### Line Changes
$(git diff --shortstat $COMMIT_RANGE || echo "No changes detected")

## Recent Commits
$(git log --oneline $COMMIT_RANGE | head -10)

## Validation Status

### Version Management
$(./scripts/validate-versions.sh 2>&1 | head -5 || echo "Validation failed")

### Cross-References
$(./scripts/validate-cross-references-enhanced.sh 2>&1 | head -5 || echo "Validation failed")

## Repository Health

### File Structure
- Total Markdown Files: $(find . -name "*.md" | wc -l)
- Total Scripts: $(find scripts -name "*.sh" | wc -l)
- Total Workflows: $(find .github/workflows -name "*.yml" | wc -l)

### Potential Issues
$(find . -name "*.bak" -o -name "*.tmp" | wc -l) backup/temporary files found
$(find . -type d -empty | wc -l) empty directories found

## Recommendations

1. **Regular Cleanup**: Run \`npm run cleanup:dry-run\` to identify cleanup opportunities
2. **Validation**: Run \`npm run validate:all\` to ensure repository health
3. **Version Sync**: Run \`npm run versions:sync\` if version inconsistencies are found
4. **Date Sync**: Run \`npm run dates:sync\` if date inconsistencies are found

## Action Items

- [ ] Review and address any validation failures
- [ ] Clean up identified backup/temporary files
- [ ] Ensure all changes are properly documented
- [ ] Update version numbers if significant changes were made

---
*Report generated by: scripts/change-detection.sh*
EOF
    
    success "Report generated: $REPORT_FILE"
}

# Suggest fixes for common issues
suggest_fixes() {
    header "Automated Fix Suggestions"
    
    log "Analyzing repository for common issues and fixes..."
    
    # Check if version sync is needed
    if ! ./scripts/validate-versions.sh > /dev/null 2>&1; then
        log "💡 Suggested fix: npm run versions:sync"
    fi
    
    # Check if date sync is needed
    if ! ./scripts/validate-dates.sh > /dev/null 2>&1; then
        log "💡 Suggested fix: npm run dates:sync"
    fi
    
    # Check for cleanup opportunities
    local cleanup_count=$(./scripts/cleanup-repository.sh --dry-run 2>/dev/null | grep "Would remove" | wc -l)
    if [[ $cleanup_count -gt 0 ]]; then
        log "💡 Cleanup available: $cleanup_count files can be cleaned up"
        log "💡 Suggested fix: npm run cleanup:run"
    fi
    
    # Check if comprehensive validation is needed
    if ! ./scripts/validate.sh --mode quick > /dev/null 2>&1; then
        log "💡 Validation issues found"
        log "💡 Suggested fix: npm run validate:verbose"
    fi
}

# Main function
main() {
    header "Comprehensive Change Detection and Analysis"
    
    log "Repository: $(basename "$(pwd)")"
    log "Branch: $(git branch --show-current)"
    log "Last commit: $(git log -1 --format='%h %s')"
    echo ""
    
    # Run analysis
    analyze_commits
    echo ""
    
    # Check for missing updates
    local exit_code=0
    check_missing_updates || exit_code=$?
    echo ""
    
    # Suggest fixes
    suggest_fixes
    echo ""
    
    # Generate report if requested
    if [[ "$GENERATE_REPORT" == "true" ]]; then
        generate_report
        echo ""
    fi
    
    # Summary
    header "Analysis Complete"
    if [[ $exit_code -eq 0 ]]; then
        success "Repository appears to be properly synchronized"
    else
        error "Issues found that require attention"
        log "Run with --verbose for detailed information"
        log "Use suggested fixes to resolve issues"
    fi
    
    exit $exit_code
}

# Run main function
main "$@"