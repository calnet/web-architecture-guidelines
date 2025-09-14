#!/bin/bash

# Consolidated Validation Script
# Replaces: unified-validation.sh, validate-comprehensive.sh, pre-merge-validation.sh, and setup-validation.sh
# This single script handles all validation needs with different modes

set -euo pipefail

# Load common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

cd "$ROOT_DIR"

# Configuration
VERBOSE=false
STRICT_MODE=false
REPORT_FILE=""
MODE="full"  # full, quick, pre-merge, setup

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
        -m|--mode)
            MODE="$2"
            shift 2
            ;;
        --quick)
            MODE="quick"
            shift
            ;;
        --pre-merge)
            MODE="pre-merge"
            shift
            ;;
        --setup)
            MODE="setup"
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -v, --verbose     Show detailed output"
            echo "  -s, --strict      Enable strict mode (fail on warnings)"
            echo "  -r, --report FILE Generate report to file"
            echo "  -m, --mode MODE   Validation mode: full, quick, pre-merge, setup"
            echo "      --quick       Quick validation mode"
            echo "      --pre-merge   Pre-merge validation mode"
            echo "      --setup       Setup validation mode"
            echo "  -h, --help        Show this help"
            echo ""
            echo "Modes:"
            echo "  full      - Complete validation (default)"
            echo "  quick     - Fast essential checks only"
            echo "  pre-merge - Pre-commit/merge validation"
            echo "  setup     - Initial setup validation"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Initialize counters
init_counters

# Start validation
log_info "Consolidated Validation Script - Mode: $MODE"
echo "============================================="

if [ "$REPORT_FILE" != "" ]; then
    exec > >(tee "$REPORT_FILE")
fi

# Core validation functions
validate_structure() {
    log_step "Validating repository structure"
    run_check "README.md exists" "[ -f README.md ]" "$VERBOSE"
    run_check "VERSION file exists" "[ -f VERSION ]" "$VERBOSE"
    run_check "package.json exists" "[ -f package.json ]" "$VERBOSE"
    run_check "scripts directory exists" "[ -d scripts ]" "$VERBOSE"
    run_check "docs directory exists" "[ -d docs ]" "$VERBOSE"
}

validate_versions() {
    log_step "Validating version consistency"
    if [ -f "$SCRIPT_DIR/validate-versions.sh" ]; then
        if "$SCRIPT_DIR/validate-versions.sh" >/dev/null 2>&1; then
            increment_passed
            [ "$VERBOSE" = "true" ] && log_success "Version validation passed"
        else
            increment_failed
            [ "$VERBOSE" = "true" ] && log_error "Version validation failed"
        fi
    else
        increment_warning
        [ "$VERBOSE" = "true" ] && log_warning "validate-versions.sh not found"
    fi
}

validate_dates() {
    log_step "Validating date consistency"
    if [ -f "$SCRIPT_DIR/validate-dates.sh" ]; then
        if "$SCRIPT_DIR/validate-dates.sh" >/dev/null 2>&1; then
            increment_passed
            [ "$VERBOSE" = "true" ] && log_success "Date validation passed"
        else
            increment_failed
            [ "$VERBOSE" = "true" ] && log_error "Date validation failed"
        fi
    else
        increment_warning
        [ "$VERBOSE" = "true" ] && log_warning "validate-dates.sh not found"
    fi
}

validate_templates() {
    log_step "Validating templates"
    if [ -f "$SCRIPT_DIR/validate-templates.sh" ]; then
        if "$SCRIPT_DIR/validate-templates.sh" >/dev/null 2>&1; then
            increment_passed
            [ "$VERBOSE" = "true" ] && log_success "Template validation passed"
        else
            increment_failed
            [ "$VERBOSE" = "true" ] && log_error "Template validation failed"
        fi
    else
        increment_warning
        [ "$VERBOSE" = "true" ] && log_warning "validate-templates.sh not found"
    fi
}

validate_architecture() {
    log_step "Validating architecture"
    if [ -f "$SCRIPT_DIR/validate-architecture.sh" ]; then
        if "$SCRIPT_DIR/validate-architecture.sh" >/dev/null 2>&1; then
            increment_passed
            [ "$VERBOSE" = "true" ] && log_success "Architecture validation passed"
        else
            increment_failed
            [ "$VERBOSE" = "true" ] && log_error "Architecture validation failed"
        fi
    else
        increment_warning
        [ "$VERBOSE" = "true" ] && log_warning "validate-architecture.sh not found"
    fi
}

validate_security() {
    log_step "Validating security"
    if [ -f "$SCRIPT_DIR/validate-security.sh" ]; then
        if "$SCRIPT_DIR/validate-security.sh" >/dev/null 2>&1; then
            increment_passed
            [ "$VERBOSE" = "true" ] && log_success "Security validation passed"
        else
            increment_failed
            [ "$VERBOSE" = "true" ] && log_error "Security validation failed"
        fi
    else
        increment_warning
        [ "$VERBOSE" = "true" ] && log_warning "validate-security.sh not found"
    fi
}

validate_performance() {
    log_step "Validating performance"
    if [ -f "$SCRIPT_DIR/validate-performance.sh" ]; then
        if "$SCRIPT_DIR/validate-performance.sh" >/dev/null 2>&1; then
            increment_passed
            [ "$VERBOSE" = "true" ] && log_success "Performance validation passed"
        else
            increment_failed
            [ "$VERBOSE" = "true" ] && log_error "Performance validation failed"
        fi
    else
        increment_warning
        [ "$VERBOSE" = "true" ] && log_warning "validate-performance.sh not found"
    fi
}

validate_cross_references() {
    log_step "Validating cross-references"
    if [ -f "$SCRIPT_DIR/validate-cross-references-enhanced.sh" ]; then
        if "$SCRIPT_DIR/validate-cross-references-enhanced.sh" >/dev/null 2>&1; then
            increment_passed
            [ "$VERBOSE" = "true" ] && log_success "Cross-reference validation passed"
        else
            increment_failed
            [ "$VERBOSE" = "true" ] && log_error "Cross-reference validation failed"
        fi
    else
        increment_warning
        [ "$VERBOSE" = "true" ] && log_warning "validate-cross-references-enhanced.sh not found"
    fi
}

validate_docs_structure() {
    log_step "Validating documentation structure"
    if [ -f "$SCRIPT_DIR/validate-docs-structure.sh" ]; then
        if "$SCRIPT_DIR/validate-docs-structure.sh" >/dev/null 2>&1; then
            increment_passed
            [ "$VERBOSE" = "true" ] && log_success "Documentation structure validation passed"
        else
            increment_failed
            [ "$VERBOSE" = "true" ] && log_error "Documentation structure validation failed"
        fi
    else
        increment_warning
        [ "$VERBOSE" = "true" ] && log_warning "validate-docs-structure.sh not found"
    fi
}

# Mode-specific validation
case $MODE in
    "quick")
        validate_structure
        validate_versions
        ;;
    "pre-merge")
        validate_structure
        validate_versions
        validate_dates
        validate_templates
        validate_cross_references
        ;;
    "setup")
        validate_structure
        validate_versions
        validate_templates
        validate_docs_structure
        ;;
    "full")
        validate_structure
        validate_versions
        validate_dates
        validate_templates
        validate_architecture
        validate_security
        validate_performance
        validate_cross_references
        validate_docs_structure
        ;;
    *)
        log_error "Unknown mode: $MODE"
        exit 1
        ;;
esac

# Generate summary
generate_summary

# Handle strict mode
if [ "$STRICT_MODE" = "true" ] && [ $WARNING_CHECKS -gt 0 ]; then
    log_error "Strict mode enabled and warnings found"
    exit 1
fi

# Exit with appropriate code
if [ $FAILED_CHECKS -gt 0 ]; then
    exit 1
else
    exit 0
fi