#!/bin/bash

# ANTHROPIC_API_KEY Configuration Script
# Provides instructions and validation for setting up the Anthropic API key repository secret

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
REPO="calnet/web-architecture-guidelines"
SECRET_NAME="ANTHROPIC_API_KEY"

show_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Configure and validate ANTHROPIC_API_KEY repository secret"
    echo ""
    echo "Options:"
    echo "  --validate     Only validate if secret is configured"
    echo "  --help         Show this help message"
    echo ""
    echo "This script provides:"
    echo "  1. Instructions for setting up the API key"
    echo "  2. Validation of secret configuration"
    echo "  3. Testing of workflow access to the secret"
    echo ""
}

print_header() {
    echo -e "${BLUE}$1${NC}"
    echo "========================================"
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

validate_secret() {
    print_header "🔍 Validating ANTHROPIC_API_KEY Secret Configuration"

    # Check if gh CLI is available and authenticated
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI not installed. Please install it to validate secrets."
        return 1
    fi

    if ! gh auth status &> /dev/null; then
        print_error "GitHub CLI not authenticated. Please run 'gh auth login'."
        return 1
    fi

    # Check repository access
    if ! gh repo view "$REPO" &> /dev/null; then
        print_error "Cannot access repository $REPO. Check permissions."
        return 1
    fi

    # Attempt to list secrets (requires admin access)
    print_info "Checking secret configuration..."

    if gh secret list --repo "$REPO" | grep -q "$SECRET_NAME"; then
        print_success "ANTHROPIC_API_KEY secret is configured in repository"

        # Check when it was last updated
        local last_updated
        last_updated=$(gh secret list --repo "$REPO" | grep "$SECRET_NAME" | awk '{print $3" "$4}')
        print_info "Last updated: $last_updated"

        return 0
    else
        print_warning "ANTHROPIC_API_KEY secret not found in repository"
        return 1
    fi
}

setup_instructions() {
    print_header "📋 ANTHROPIC_API_KEY Setup Instructions"

    echo ""
    echo "To configure the ANTHROPIC_API_KEY repository secret:"
    echo ""
    echo "## Method 1: Using GitHub CLI (Recommended)"
    echo ""
    echo "1. Obtain your Anthropic API key from: https://console.anthropic.com/"
    echo ""
    echo "2. Set the repository secret using GitHub CLI:"
    echo "   gh secret set $SECRET_NAME --repo $REPO"
    echo "   # You'll be prompted to enter your API key"
    echo ""
    echo "3. Verify the secret was set:"
    echo "   gh secret list --repo $REPO | grep $SECRET_NAME"
    echo ""

    echo "## Method 2: Using GitHub Web Interface"
    echo ""
    echo "1. Navigate to: https://github.com/$REPO/settings/secrets/actions"
    echo ""
    echo "2. Click 'New repository secret'"
    echo ""
    echo "3. Set:"
    echo "   - Name: $SECRET_NAME"
    echo "   - Value: [Your Anthropic API key]"
    echo ""
    echo "4. Click 'Add secret'"
    echo ""

    echo "## API Key Requirements"
    echo ""
    echo "The API key should:"
    echo "- Have access to Claude 3.5 Sonnet model"
    echo "- Have sufficient usage limits for code review operations"
    echo "- Be stored securely and never committed to code"
    echo ""

    echo "## Validation"
    echo ""
    echo "After setting up the secret, run:"
    echo "  $0 --validate"
    echo ""
    echo "Or test with a workflow:"
    echo "  ./scripts/test-workflow.sh --validate-secret"
    echo ""
}

test_workflow_access() {
    print_header "🧪 Testing Workflow Access to Secret"

    print_info "Checking workflow files for secret usage..."

    local workflows_dir=".github/workflows"
    local secret_usage_found=false

    if [[ -d "$workflows_dir" ]]; then
        # Check workflow files for ANTHROPIC_API_KEY usage
        for workflow in "$workflows_dir"/*.yml "$workflows_dir"/*.yaml; do
            if [[ -f "$workflow" ]]; then
                if grep -q "ANTHROPIC_API_KEY" "$workflow"; then
                    local workflow_name
                    workflow_name=$(basename "$workflow")
                    print_info "Found secret usage in: $workflow_name"
                    secret_usage_found=true

                    # Check specific usage patterns
                    if grep -q "secrets.ANTHROPIC_API_KEY" "$workflow"; then
                        print_success "Correct secret reference found in $workflow_name"
                    else
                        print_warning "Non-standard secret reference in $workflow_name"
                    fi
                fi
            fi
        done

        if [[ "$secret_usage_found" == "true" ]]; then
            print_success "Workflow files properly configured to use ANTHROPIC_API_KEY"
        else
            print_warning "No workflow files found using ANTHROPIC_API_KEY"
        fi
    else
        print_error "No .github/workflows directory found"
        return 1
    fi

    # Check for environment variable usage
    print_info "Checking environment variable configuration..."

    if grep -r "ANTHROPIC_API_KEY" "$workflows_dir" | grep -q "env:"; then
        print_success "Environment variable properly configured in workflows"
    else
        print_warning "Environment variable configuration not found"
    fi
}

generate_test_workflow() {
    print_header "🔧 Generating Secret Validation Test Workflow"

    local test_file="/tmp/test-anthropic-secret.yml"

    cat > "$test_file" << 'EOF'
name: Test ANTHROPIC_API_KEY Secret

on:
  workflow_dispatch:

env:
  ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}

jobs:
  test-secret:
    runs-on: ubuntu-latest

    steps:
      - name: Test secret availability
        run: |
          if [[ -z "$ANTHROPIC_API_KEY" ]]; then
            echo "❌ ANTHROPIC_API_KEY secret not available"
            exit 1
          else
            echo "✅ ANTHROPIC_API_KEY secret is available"
            echo "Secret length: ${#ANTHROPIC_API_KEY} characters"
            echo "First 10 characters: ${ANTHROPIC_API_KEY:0:10}..."
          fi

      - name: Validate secret format
        run: |
          # Anthropic API keys typically start with 'sk-ant-'
          if [[ "$ANTHROPIC_API_KEY" =~ ^sk-ant- ]]; then
            echo "✅ API key has correct format"
          else
            echo "⚠️ API key may not have expected format"
          fi
EOF

    print_success "Test workflow generated at: $test_file"
    print_info "To use this test workflow:"
    echo "  1. Copy to .github/workflows/test-secret.yml"
    echo "  2. Commit and push to trigger manual test"
    echo "  3. Go to Actions tab and run 'Test ANTHROPIC_API_KEY Secret'"
    echo ""
    echo "Copy command:"
    echo "  cp $test_file .github/workflows/test-secret.yml"
}

main() {
    local validate_only=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --validate)
                validate_only=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    if [[ "$validate_only" == "true" ]]; then
        validate_secret
        exit $?
    fi

    print_header "🔐 ANTHROPIC_API_KEY Configuration Helper"
    echo ""

    # Check current status
    if validate_secret; then
        print_success "Secret is already configured!"
        echo ""
        test_workflow_access
    else
        print_info "Secret needs to be configured."
        echo ""
        setup_instructions
    fi

    echo ""
    generate_test_workflow

    echo ""
    print_header "📖 Additional Resources"
    echo ""
    echo "- Anthropic Console: https://console.anthropic.com/"
    echo "- GitHub Secrets Documentation: https://docs.github.com/en/actions/security-guides/encrypted-secrets"
    echo "- Claude API Documentation: https://docs.anthropic.com/claude/reference/getting-started-with-the-api"
    echo ""

    print_success "Configuration helper completed!"
}

# Run main function
main "$@"
