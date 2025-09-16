#!/bin/bash

# Common utility functions for all scripts
# This centralizes shared functionality to reduce duplication

# Colors for output
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export CYAN='\033[0;36m'
export NC='\033[0m' # No Color

# Common paths
export SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_step() {
    echo -e "${CYAN}🔄 $1${NC}"
}

# Counter functions
init_counters() {
    export TOTAL_CHECKS=0
    export PASSED_CHECKS=0
    export FAILED_CHECKS=0
    export WARNING_CHECKS=0
}

increment_total() {
    ((TOTAL_CHECKS++)) || true
}

increment_passed() {
    ((PASSED_CHECKS++)) || true
    ((TOTAL_CHECKS++)) || true
}

increment_failed() {
    ((FAILED_CHECKS++)) || true
    ((TOTAL_CHECKS++)) || true
}

increment_warning() {
    ((WARNING_CHECKS++)) || true
    ((TOTAL_CHECKS++)) || true
}

# Common validation function
run_check() {
    local check_name="$1"
    local check_command="$2"
    local verbose="${3:-false}"
    
    if [ "$verbose" = "true" ]; then
        log_step "Running: $check_name"
    fi
    
    if eval "$check_command" >/dev/null 2>&1; then
        increment_passed
        if [ "$verbose" = "true" ]; then
            log_success "$check_name passed"
        fi
        return 0
    else
        increment_failed
        if [ "$verbose" = "true" ]; then
            log_error "$check_name failed"
        fi
        return 1
    fi
}

# Version management functions
get_main_version() {
    if [ -f "$ROOT_DIR/VERSION" ]; then
        cat "$ROOT_DIR/VERSION" | tr -d '\n'
    else
        echo "0.0.0"
    fi
}

# Report generation
generate_summary() {
    echo ""
    echo "=================================="
    echo "Summary:"
    echo "  Total checks: $TOTAL_CHECKS"
    echo "  Passed: $PASSED_CHECKS"
    echo "  Failed: $FAILED_CHECKS"
    echo "  Warnings: $WARNING_CHECKS"
    echo "=================================="
    
    if [ $FAILED_CHECKS -gt 0 ]; then
        return 1
    else
        return 0
    fi
}