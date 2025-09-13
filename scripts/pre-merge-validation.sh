#!/bin/bash

# Pre-merge validation script
# Runs comprehensive validation before allowing commits/merges
# Version: 1.3.3

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$ROOT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
VERBOSE=false
REPORT_ONLY=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose)
            VERBOSE=true
            shift
            ;;
        --report)
            REPORT_ONLY=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --verbose    Show detailed output"
            echo "  --report     Generate report only, don't fail"
            echo "  --help       Show this help"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

header() {
    echo -e "${BLUE}🔍 $1${NC}"
    echo "=================================="
}

run_validation() {
    local name="$1"
    local command="$2"
    local critical="${3:-false}"

    if [[ "$VERBOSE" == "true" ]]; then
        log "Running $name..."
    fi

    if eval "$command" > "/tmp/validation-$name.log" 2>&1; then
        if [[ "$VERBOSE" == "true" ]]; then
            success "$name: PASSED"
        fi
        return 0
    else
        local exit_code=$?
        error "$name: FAILED"
        
        if [[ "$VERBOSE" == "true" ]]; then
            echo "Last few lines of output:"
            tail -5 "/tmp/validation-$name.log" | sed 's/^/   /'
        fi
        
        return $exit_code
    fi
}

main() {
    header "Pre-merge Validation"
    
    # Create temp directory for logs
    mkdir -p /tmp
    
    local failures=0
    local total_checks=0
    
    # Critical validations (must pass)
    echo -e "${RED}🚨 CRITICAL CHECKS${NC}"
    echo "-------------------"
    
    total_checks=$((total_checks + 1))
    if ! run_validation "strict-errors" "./scripts/check-project-errors-strict.sh"; then
        failures=$((failures + 1))
    fi
    
    total_checks=$((total_checks + 1))
    if ! run_validation "architecture" "./scripts/validate-architecture.sh"; then
        failures=$((failures + 1))
    fi
    
    total_checks=$((total_checks + 1))
    if ! run_validation "security" "./scripts/validate-security.sh"; then
        failures=$((failures + 1))
    fi
    
    total_checks=$((total_checks + 1))
    if ! run_validation "templates" "./scripts/validate-templates.sh"; then
        failures=$((failures + 1))
    fi
    
    echo ""
    
    # Non-critical validations (warnings only)
    echo -e "${YELLOW}⚠️ ADVISORY CHECKS${NC}"
    echo "-------------------"
    
    total_checks=$((total_checks + 1))
    if ! run_validation "performance" "./scripts/validate-performance.sh"; then
        warn "Performance validation failed (non-blocking)"
    fi
    
    total_checks=$((total_checks + 1))
    if ! run_validation "cross-references" "./scripts/validate-cross-references-enhanced.sh"; then
        warn "Cross-reference validation failed (non-blocking)"
    fi
    
    total_checks=$((total_checks + 1))
    if ! run_validation "docs-structure" "./scripts/validate-docs-structure.sh"; then
        warn "Documentation structure validation failed (non-blocking)"
    fi
    
    echo ""
    
    # Summary
    header "Validation Summary"
    echo "Total checks: $total_checks"
    echo "Critical failures: $failures"
    echo "Advisory warnings: See above"
    
    # Generate report
    local report_file="validation-report.log"
    {
        echo "Pre-merge Validation Report"
        echo "Generated: $(date)"
        echo "================================"
        echo ""
        echo "Critical Failures: $failures"
        echo "Total Checks: $total_checks"
        echo ""
        echo "Detailed Logs:"
        for log_file in /tmp/validation-*.log; do
            if [[ -f "$log_file" ]]; then
                echo ""
                echo "=== $(basename "$log_file") ==="
                cat "$log_file"
            fi
        done
    } > "$report_file"
    
    log "Full report saved to: $report_file"
    
    # Exit with appropriate code
    if [[ "$REPORT_ONLY" == "true" ]]; then
        exit 0
    elif [[ $failures -eq 0 ]]; then
        success "All critical validations passed!"
        exit 0
    else
        error "$failures critical validation(s) failed!"
        exit 1
    fi
}

# Run main function
main "$@"