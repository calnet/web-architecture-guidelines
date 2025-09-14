#!/bin/bash

# Common utilities for workflow scripts
# This file provides shared functions and configurations used by all modular workflow scripts

# Color definitions
export GREEN='\033[0;32m'
export BLUE='\033[0;34m'
export YELLOW='\033[1;33m'
export RED='\033[0;31m'
export NC='\033[0m' # No Color

# Script configuration
export SCRIPT_VERSION="1.1.0"
export REPO_NAME="calnet/web-architecture-guidelines"

# Utility functions
print_header() {
    echo -e "${BLUE}$1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️ $1${NC}"
}

# Check if directory exists, create if it doesn't
ensure_directory() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        print_success "Created directory: $dir"
    fi
}

# Backup existing file if it exists
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        local backup="${file}.backup-$(date +%Y%m%d-%H%M%S)"
        cp "$file" "$backup"
        print_info "Backed up existing file: $backup"
    fi
}

# Validate script prerequisites
validate_prerequisites() {
    local script_name="$1"
    
    print_header "🔍 Validating prerequisites for $script_name..."
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not in a git repository"
        return 1
    fi
    
    # Check if required directories exist
    if [[ ! -d ".git" ]]; then
        print_error "Not in the root of a git repository"
        return 1
    fi
    
    print_success "Prerequisites validated"
    return 0
}

# Get current date for timestamps
get_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Check if running in dry-run mode
is_dry_run() {
    [[ "${DRY_RUN:-false}" == "true" ]]
}

# Execute command with dry-run support
execute_with_dry_run() {
    local description="$1"
    shift
    
    if is_dry_run; then
        print_info "DRY RUN: Would execute: $description"
        print_info "Command: $*"
    else
        print_info "Executing: $description"
        "$@"
    fi
}

# Show help for common options
show_common_help() {
    echo "Common Options:"
    echo "  --dry-run    Show what would be created without making changes"
    echo "  --help       Show this help message"
    echo "  --version    Show script version"
    echo ""
}

# Parse common command line arguments
parse_common_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                export DRY_RUN=true
                print_info "Running in dry-run mode"
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            --version)
                echo "Script version: $SCRIPT_VERSION"
                exit 0
                ;;
            *)
                # Unknown option, let individual scripts handle it
                break
                ;;
        esac
    done
}

# Validate file was created successfully
validate_file_creation() {
    local file="$1"
    local description="$2"
    
    if is_dry_run; then
        print_info "DRY RUN: Would validate: $file"
        return 0
    fi
    
    if [[ -f "$file" ]]; then
        print_success "Created: $description ($file)"
        return 0
    else
        print_error "Failed to create: $description ($file)"
        return 1
    fi
}