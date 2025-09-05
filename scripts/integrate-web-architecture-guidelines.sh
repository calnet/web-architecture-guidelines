#!/bin/bash

# Integration Automation Script
# Automates applying the Web Architecture Guidelines to projects

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration defaults
PROJECT_NAME=""
ORGANIZATION=""
PACKAGE_MANAGER="npm"
SETUP_CI=true
NON_INTERACTIVE=false
DRY_RUN=false
AUTO_CONFIRM=false

# Script metadata
SCRIPT_VERSION="1.0.0"
BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header() {
    echo -e "${BLUE}🔧 $1${NC}"
}

# Function to show help
show_help() {
    cat << EOF
Integration Automation Script v${SCRIPT_VERSION}

USAGE:
    $0 [OPTIONS]

DESCRIPTION:
    Automates applying the Web Architecture Guidelines to projects.
    Ensures consistent implementation of best practices across development workflow.

OPTIONS:
    --help                  Show this help message
    --version              Show script version
    --dry-run              Preview changes without making modifications
    --non-interactive      Skip all prompts and use provided or default values
    --yes                  Automatically confirm all operations
    --project-name NAME    Specify the project name
    --org ORGANIZATION     Set the organization name
    --pkg MANAGER          Choose package manager (npm, yarn, pnpm)
    --setup-ci BOOL        Enable/disable CI/CD workflow setup (true/false)

EXAMPLES:
    # Preview mode (no modifications)
    $0 --dry-run

    # Interactive mode
    $0

    # Non-interactive with custom settings
    $0 --non-interactive --yes \\
       --project-name "Acme Dashboard" \\
       --org "Acme, Inc." \\
       --pkg pnpm \\
       --setup-ci true

EOF
}

# Function to show version
show_version() {
    echo "Integration Automation Script v${SCRIPT_VERSION}"
}

# Function to parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help)
                show_help
                exit 0
                ;;
            --version)
                show_version
                exit 0
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --non-interactive)
                NON_INTERACTIVE=true
                shift
                ;;
            --yes)
                AUTO_CONFIRM=true
                shift
                ;;
            --project-name)
                PROJECT_NAME="$2"
                shift 2
                ;;
            --org)
                ORGANIZATION="$2"
                shift 2
                ;;
            --pkg)
                case $2 in
                    npm|yarn|pnpm)
                        PACKAGE_MANAGER="$2"
                        ;;
                    *)
                        print_error "Invalid package manager: $2. Use npm, yarn, or pnpm"
                        exit 1
                        ;;
                esac
                shift 2
                ;;
            --setup-ci)
                case $2 in
                    true|false)
                        SETUP_CI="$2"
                        ;;
                    *)
                        print_error "Invalid value for --setup-ci: $2. Use true or false"
                        exit 1
                        ;;
                esac
                shift 2
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Function to prompt for user input
prompt_input() {
    local prompt="$1"
    local default="$2"
    local result
    
    if [[ "$NON_INTERACTIVE" == "true" ]]; then
        result="$default"
    else
        read -p "$prompt [$default]: " result
        result="${result:-$default}"
    fi
    
    echo "$result"
}

# Function to confirm action
confirm_action() {
    local message="$1"
    
    if [[ "$AUTO_CONFIRM" == "true" || "$NON_INTERACTIVE" == "true" ]]; then
        return 0
    fi
    
    while true; do
        read -p "$message (y/n): " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Function to create backup
create_backup() {
    local file="$1"
    
    if [[ -f "$file" ]]; then
        mkdir -p "$BACKUP_DIR/$(dirname "$file")"
        cp "$file" "$BACKUP_DIR/$file.bak.$(date +%Y-%m-%d-%H-%M-%S)"
        print_success "Backed up: $file"
    fi
}

# Function to detect project configuration
detect_project_config() {
    print_header "Detecting project configuration..."
    
    # Detect package manager
    if [[ -f "package-lock.json" ]]; then
        DETECTED_PKG="npm"
    elif [[ -f "yarn.lock" ]]; then
        DETECTED_PKG="yarn"
    elif [[ -f "pnpm-lock.yaml" ]]; then
        DETECTED_PKG="pnpm"
    else
        DETECTED_PKG="npm"
    fi
    
    print_info "Detected package manager: $DETECTED_PKG"
    
    # Detect if CI/CD is already configured
    if [[ -d ".github/workflows" ]]; then
        print_info "GitHub Actions workflows detected"
    fi
    
    # Detect existing documentation structure
    if [[ -d "docs" ]]; then
        print_info "Documentation directory exists"
    fi
}

# Function to gather project information
gather_project_info() {
    print_header "Gathering project information..."
    
    if [[ -z "$PROJECT_NAME" ]]; then
        PROJECT_NAME=$(prompt_input "Enter project name" "$(basename "$(pwd)")")
    fi
    
    if [[ -z "$ORGANIZATION" ]]; then
        ORGANIZATION=$(prompt_input "Enter organization name" "Your Organization")
    fi
    
    if [[ "$NON_INTERACTIVE" == "false" ]]; then
        PACKAGE_MANAGER=$(prompt_input "Choose package manager (npm/yarn/pnpm)" "$DETECTED_PKG")
    fi
    
    print_info "Configuration:"
    print_info "  Project: $PROJECT_NAME"
    print_info "  Organization: $ORGANIZATION"
    print_info "  Package Manager: $PACKAGE_MANAGER"
    print_info "  Setup CI/CD: $SETUP_CI"
}

# Function to create documentation structure
create_docs_structure() {
    print_header "Creating documentation structure..."
    
    local dirs=(
        "docs/architecture"
        "docs/architecture/decisions"
        "docs/architecture/diagrams"
        "docs/api"
        "docs/user-guides"
        "docs/development"
    )
    
    for dir in "${dirs[@]}"; do
        if [[ "$DRY_RUN" == "true" ]]; then
            print_info "Would create: $dir"
        else
            mkdir -p "$dir"
            print_success "Created: $dir"
        fi
    done
}

# Function to copy and customize templates
copy_templates() {
    print_header "Copying and customizing templates..."
    
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local guidelines_dir="$(dirname "$script_dir")"
    
    local templates=(
        "docs/templates/architecture/adr-template.md:docs/architecture/adr-template.md"
        "docs/templates/architecture/system-architecture-document.md:docs/architecture/system-architecture.md"
        "docs/templates/api/api-specification.md:docs/api/api-specification.md"
        "docs/templates/user-guides/user-manual-template.md:docs/user-guides/user-manual.md"
        "docs/templates/user-guides/admin-manual-template.md:docs/user-guides/admin-manual.md"
        "docs/templates/development/setup-guide-template.md:docs/development/setup-guide.md"
        "docs/templates/development/coding-standards-template.md:docs/development/coding-standards.md"
    )
    
    for template in "${templates[@]}"; do
        local source="${template%:*}"
        local dest="${template#*:}"
        local full_source="$guidelines_dir/$source"
        
        if [[ -f "$full_source" ]]; then
            if [[ "$DRY_RUN" == "true" ]]; then
                print_info "Would copy: $source -> $dest"
            else
                create_backup "$dest"
                cp "$full_source" "$dest"
                
                # Customize template with project information
                sed -i.tmp "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" "$dest" 2>/dev/null || true
                sed -i.tmp "s/{{ORGANIZATION}}/$ORGANIZATION/g" "$dest" 2>/dev/null || true
                rm -f "$dest.tmp" 2>/dev/null || true
                
                print_success "Copied and customized: $dest"
            fi
        else
            print_warning "Template not found: $full_source"
        fi
    done
}

# Function to setup CI/CD workflows
setup_cicd() {
    if [[ "$SETUP_CI" != "true" ]]; then
        return 0
    fi
    
    print_header "Setting up CI/CD workflows..."
    
    local workflow_dir=".github/workflows"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "Would create: $workflow_dir"
        print_info "Would setup validation workflows"
    else
        mkdir -p "$workflow_dir"
        
        # Create basic validation workflow
        cat > "$workflow_dir/validate-project.yml" << EOF
name: Project Validation

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  validate-docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Validate documentation structure
        run: |
          # Check required directories exist
          test -d docs/architecture || (echo "Missing docs/architecture directory" && exit 1)
          test -d docs/api || (echo "Missing docs/api directory" && exit 1)
          test -d docs/user-guides || (echo "Missing docs/user-guides directory" && exit 1)
          test -d docs/development || (echo "Missing docs/development directory" && exit 1)
          
          echo "✅ Documentation structure validation passed"

  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: '$PACKAGE_MANAGER'
      
      - name: Install dependencies
        run: $PACKAGE_MANAGER install
      
      - name: Build project
        run: $PACKAGE_MANAGER run build
        continue-on-error: true
EOF
        
        print_success "Created: $workflow_dir/validate-project.yml"
    fi
}

# Function to create project extensions documentation
create_project_extensions() {
    print_header "Creating project extensions documentation..."
    
    local extensions_file="docs/project-extensions.md"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "Would create: $extensions_file"
    else
        create_backup "$extensions_file"
        
        cat > "$extensions_file" << EOF
# Project Extensions

This document outlines project-specific deviations and extensions from the base Web Architecture Guidelines.

## Project Information

- **Project Name**: $PROJECT_NAME
- **Organization**: $ORGANIZATION
- **Package Manager**: $PACKAGE_MANAGER
- **Last Updated**: $(date '+%Y-%m-%d')

## Architecture Decisions

Document any project-specific architectural decisions that deviate from base guidelines:

### [Decision Title]
- **Date**: YYYY-MM-DD
- **Decision**: Brief description
- **Rationale**: Why this decision was made
- **Impact**: How this affects the overall architecture

## Custom Templates

List any customized or additional templates used in this project:

- **Template**: Brief description of customization
- **Location**: Path to customized template
- **Rationale**: Why customization was needed

## Technology Stack Additions

Document any technologies added beyond the base guidelines:

### [Technology Name]
- **Purpose**: What problem it solves
- **Integration**: How it integrates with base architecture
- **Maintenance**: Who maintains this addition

## Compliance Notes

Any areas where the project cannot fully comply with base guidelines:

- **Area**: What guideline cannot be followed
- **Reason**: Technical or business reason
- **Mitigation**: How risks are addressed
- **Review Date**: When to revisit this decision

## Integration Script History

- **Script Version**: $SCRIPT_VERSION
- **Applied Date**: $(date '+%Y-%m-%d %H:%M:%S')
- **Configuration**: Package Manager: $PACKAGE_MANAGER, CI/CD: $SETUP_CI
EOF
        
        print_success "Created: $extensions_file"
    fi
}

# Function to show preview of changes
show_preview() {
    print_header "Preview of changes to be made:"
    
    echo "📁 Directory structure:"
    echo "  docs/"
    echo "    ├── architecture/"
    echo "    │   ├── decisions/"
    echo "    │   ├── diagrams/"
    echo "    │   ├── adr-template.md"
    echo "    │   └── system-architecture.md"
    echo "    ├── api/"
    echo "    │   └── api-specification.md"
    echo "    ├── user-guides/"
    echo "    │   ├── user-manual.md"
    echo "    │   └── admin-manual.md"
    echo "    ├── development/"
    echo "    │   ├── setup-guide.md"
    echo "    │   └── coding-standards.md"
    echo "    └── project-extensions.md"
    
    if [[ "$SETUP_CI" == "true" ]]; then
        echo "    .github/"
        echo "      └── workflows/"
        echo "          └── validate-project.yml"
    fi
    
    echo ""
    echo "📝 Template customizations:"
    echo "  - Project Name: $PROJECT_NAME"
    echo "  - Organization: $ORGANIZATION"
    echo ""
    echo "🔧 Configuration:"
    echo "  - Package Manager: $PACKAGE_MANAGER"
    echo "  - CI/CD Setup: $SETUP_CI"
    
    if [[ "$DRY_RUN" == "false" ]]; then
        echo ""
        echo "💾 Backup location: $BACKUP_DIR"
    fi
}

# Function to validate script execution environment
validate_environment() {
    print_header "Validating environment..."
    
    # Check if we're in a project directory
    if [[ ! -f "package.json" && ! -f "*.csproj" && ! -f "pom.xml" && ! -f "Cargo.toml" ]]; then
        print_warning "No project configuration file detected. Continuing anyway..."
    fi
    
    # Check for git repository
    if [[ ! -d ".git" ]]; then
        print_warning "Not in a git repository. Some features may not work as expected."
    fi
    
    print_success "Environment validation completed"
}

# Function to generate summary report
generate_summary() {
    print_header "Integration Summary"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "DRY RUN MODE - No changes were made"
        print_info "To apply these changes, run the script without --dry-run"
    else
        print_success "Integration completed successfully!"
        print_info "Next steps:"
        print_info "1. Review the generated documentation structure"
        print_info "2. Customize templates for your project needs"
        print_info "3. Update project-extensions.md with project-specific information"
        print_info "4. Commit the changes to version control"
        
        if [[ -d "$BACKUP_DIR" ]]; then
            print_info "5. Backup files available in: $BACKUP_DIR"
        fi
    fi
}

# Main execution function
main() {
    echo "🚀 Web Architecture Guidelines Integration Script v${SCRIPT_VERSION}"
    echo ""
    
    # Parse command line arguments
    parse_args "$@"
    
    # Validate environment
    validate_environment
    
    # Detect existing project configuration
    detect_project_config
    
    # Gather project information
    gather_project_info
    
    # Show preview of changes
    show_preview
    
    # Confirm before proceeding (unless in non-interactive mode)
    if [[ "$DRY_RUN" == "false" && "$NON_INTERACTIVE" == "false" ]]; then
        echo ""
        if ! confirm_action "Proceed with integration?"; then
            print_info "Integration cancelled by user"
            exit 0
        fi
    fi
    
    # Execute integration steps
    create_docs_structure
    copy_templates
    setup_cicd
    create_project_extensions
    
    # Generate summary
    generate_summary
}

# Execute main function with all arguments
main "$@"