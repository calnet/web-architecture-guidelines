#!/bin/bash

# Unified Validation Script
# Consolidates all validation checks into a single comprehensive script
# This reduces redundancy and provides a unified interface for validation

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$ROOT_DIR"

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

# Configuration
VERBOSE=false
STRICT_MODE=false
REPORT_FILE=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -s|--strict)
            STRICT_MODE=true
            shift
            ;;
        -r|--report)
            REPORT_FILE="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  -v, --verbose    Enable verbose output"
            echo "  -s, --strict     Enable strict mode (exit on first failure)"
            echo "  -r, --report     Generate report to specified file"
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
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
}

error() {
    echo -e "${RED}[FAIL]${NC} $1"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
    if [[ "$STRICT_MODE" == "true" ]]; then
        exit 1
    fi
}

warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    WARNING_CHECKS=$((WARNING_CHECKS + 1))
}

header() {
    echo -e "${CYAN}=== $1 ===${NC}"
}

# Validation function that runs a script and captures output
run_validation() {
    local script_name="$1"
    local script_path="$SCRIPT_DIR/$script_name"
    local description="$2"
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if [[ ! -f "$script_path" ]]; then
        error "$description: Script not found ($script_path)"
        return 1
    fi
    
    if [[ "$VERBOSE" == "true" ]]; then
        log "Running: $description"
    fi
    
    if "$script_path" > /tmp/validation_output.log 2>&1; then
        success "$description"
        if [[ "$VERBOSE" == "true" ]]; then
            cat /tmp/validation_output.log
        fi
        return 0
    else
        error "$description: Check failed"
        if [[ "$VERBOSE" == "true" ]] || [[ "$STRICT_MODE" == "true" ]]; then
            cat /tmp/validation_output.log
        fi
        return 1
    fi
}

# Main validation sequence
main() {
    header "Web Architecture Guidelines - Unified Validation"
    log "Starting comprehensive validation process"
    echo ""
    
    # 1. Documentation Structure
    header "Documentation Structure Validation"
    run_validation "validate-docs-structure.sh" "Documentation structure"
    echo ""
    
    # 2. Architecture Compliance  
    header "Architecture Compliance"
    run_validation "validate-architecture.sh" "Architecture standards"
    echo ""
    
    # 3. Template Validation
    header "Template Validation"
    run_validation "validate-templates.sh" "Template compliance"
    echo ""
    
    # 4. Security Standards
    header "Security Validation"
    run_validation "validate-security.sh" "Security standards"
    echo ""
    
    # 5. Performance Standards
    header "Performance Validation"
    run_validation "validate-performance.sh" "Performance standards"
    echo ""
    
    # 6. Cross-Reference Validation
    header "Cross-Reference Validation"
    run_validation "validate-cross-references-enhanced.sh" "Cross-reference integrity"
    echo ""
    
    # 7. Version Consistency
    header "Version Validation"
    run_validation "validate-versions.sh" "Version consistency"
    echo ""
    
    # 8. Date Consistency
    header "Date Validation"
    run_validation "validate-dates.sh" "Date consistency"
    echo ""
    
    # 9. Comprehensive Project Check
    header "Comprehensive Project Validation"
    run_validation "check-project-errors-strict.sh" "Project error check"
    echo ""
    
    # Summary
    header "Validation Summary"
    echo "Total checks run: $TOTAL_CHECKS"
    echo -e "${GREEN}Passed: $PASSED_CHECKS${NC}"
    echo -e "${RED}Failed: $FAILED_CHECKS${NC}"
    echo -e "${YELLOW}Warnings: $WARNING_CHECKS${NC}"
    
    # Calculate success rate
    if [[ $TOTAL_CHECKS -gt 0 ]]; then
        SUCCESS_RATE=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))
        echo "Success Rate: ${SUCCESS_RATE}%"
    fi
    
    # Generate report if requested
    if [[ -n "$REPORT_FILE" ]]; then
        generate_report
    fi
    
    # Exit with appropriate code
    if [[ $FAILED_CHECKS -gt 0 ]]; then
        log "Validation completed with failures"
        exit 1
    else
        log "All validations passed successfully"
        exit 0
    fi
}

# Generate detailed report
generate_report() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    cat > "$REPORT_FILE" << EOF
# Validation Report

**Generated:** $timestamp  
**Repository:** web-architecture-guidelines  
**Version:** $(cat VERSION 2>/dev/null || echo "unknown")

## Summary

- **Total Checks:** $TOTAL_CHECKS
- **Passed:** $PASSED_CHECKS
- **Failed:** $FAILED_CHECKS  
- **Warnings:** $WARNING_CHECKS
- **Success Rate:** $((PASSED_CHECKS * 100 / TOTAL_CHECKS))%

## Validation Categories

1. ✅ Documentation Structure
2. ✅ Architecture Compliance
3. ✅ Template Validation
4. ✅ Security Standards
5. ✅ Performance Standards
6. ✅ Cross-Reference Integrity
7. ✅ Version Consistency
8. ✅ Date Consistency
9. ✅ Comprehensive Project Check

## Status

$(if [[ $FAILED_CHECKS -eq 0 ]]; then echo "🎉 All validations passed"; else echo "⚠️ Some validations failed"; fi)

EOF
    
    log "Report generated: $REPORT_FILE"
}

# Run main function
main "$@"