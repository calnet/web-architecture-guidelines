#!/bin/bash

# Consolidated Workflow Management Script
# Replaces: test-workflow.sh, monitor-workflow.sh, workflow-utils.sh, configure-anthropic-secret.sh
# This single script handles all workflow operations

set -euo pipefail

# Load common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

cd "$ROOT_DIR"

# Configuration
VERBOSE=false
DRY_RUN=false
OPERATION="test"  # test, monitor, config, utils

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
        --test)
            OPERATION="test"
            shift
            ;;
        --monitor)
            OPERATION="monitor"
            shift
            ;;
        --config)
            OPERATION="config"
            shift
            ;;
        --validate-secret)
            OPERATION="validate-secret"
            shift
            ;;
        --report)
            OPERATION="report"
            shift
            ;;
        --performance)
            OPERATION="performance"
            shift
            ;;
        --dashboard)
            OPERATION="dashboard"
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -v, --verbose           Show detailed output"
            echo "  -n, --dry-run          Show what would be done without making changes"
            echo "  -o, --operation OP     Operation: test, monitor, config, validate-secret"
            echo "      --test             Test workflow functionality (default)"
            echo "      --monitor          Monitor workflow health"
            echo "      --config           Configure workflow secrets"
            echo "      --validate-secret  Validate API secret configuration"
            echo "      --report           Generate workflow report"
            echo "      --performance      Check workflow performance"
            echo "      --dashboard        Show workflow dashboard"
            echo "  -h, --help             Show this help"
            echo ""
            echo "Operations:"
            echo "  test           - Test workflow functionality and API connectivity"
            echo "  monitor        - Monitor workflow health and performance"
            echo "  config         - Configure required workflow secrets"
            echo "  validate-secret- Validate Anthropic API secret configuration"
            echo "  report         - Generate comprehensive workflow report"
            echo "  performance    - Analyze workflow performance metrics"
            echo "  dashboard      - Display workflow status dashboard"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

log_info "Workflow Management - Operation: $OPERATION"
echo "==========================================="

# Initialize counters
init_counters

# Workflow operation functions
test_workflow() {
    log_step "Testing workflow functionality"
    
    # Check GitHub Actions workflows exist
    if [ -d ".github/workflows" ]; then
        increment_passed
        [ "$VERBOSE" = "true" ] && log_success "GitHub workflows directory exists"
    else
        increment_failed
        [ "$VERBOSE" = "true" ] && log_error "GitHub workflows directory missing"
        return 1
    fi
    
    # Check for main workflow files
    local workflows=("claude-code-review.yml" "advanced-architecture-review.yml")
    for workflow in "${workflows[@]}"; do
        if [ -f ".github/workflows/$workflow" ]; then
            increment_passed
            [ "$VERBOSE" = "true" ] && log_success "Workflow file exists: $workflow"
        else
            increment_failed
            [ "$VERBOSE" = "true" ] && log_error "Workflow file missing: $workflow"
        fi
    done
    
    # Check Claude commands
    if [ -d ".claude/commands" ]; then
        increment_passed
        [ "$VERBOSE" = "true" ] && log_success "Claude commands directory exists"
        
        local commands=("architecture-review.md" "security-scan.md" "performance-check.md")
        for command in "${commands[@]}"; do
            if [ -f ".claude/commands/$command" ]; then
                increment_passed
                [ "$VERBOSE" = "true" ] && log_success "Command file exists: $command"
            else
                increment_failed
                [ "$VERBOSE" = "true" ] && log_error "Command file missing: $command"
            fi
        done
    else
        increment_failed
        [ "$VERBOSE" = "true" ] && log_error "Claude commands directory missing"
    fi
    
    # Test API connectivity (if not dry run)
    if [ "$DRY_RUN" = "false" ]; then
        test_anthropic_api
    else
        log_info "Skipping API test in dry-run mode"
    fi
}

test_anthropic_api() {
    log_step "Testing Anthropic API connectivity"
    
    # Check if secret is configured (for GitHub Actions)
    if command -v gh >/dev/null 2>&1; then
        if gh secret list | grep -q "ANTHROPIC_API_KEY"; then
            increment_passed
            [ "$VERBOSE" = "true" ] && log_success "ANTHROPIC_API_KEY secret is configured"
        else
            increment_failed
            [ "$VERBOSE" = "true" ] && log_error "ANTHROPIC_API_KEY secret not configured"
        fi
    else
        increment_warning
        [ "$VERBOSE" = "true" ] && log_warning "GitHub CLI not available, cannot check secrets"
    fi
    
    # Check environment variable
    if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
        increment_passed
        [ "$VERBOSE" = "true" ] && log_success "ANTHROPIC_API_KEY environment variable is set"
    else
        increment_warning
        [ "$VERBOSE" = "true" ] && log_warning "ANTHROPIC_API_KEY environment variable not set"
    fi
}

monitor_workflow() {
    log_step "Monitoring workflow health"
    
    # Check recent workflow runs (if GitHub CLI available)
    if command -v gh >/dev/null 2>&1; then
        log_step "Checking recent workflow runs"
        
        # Get workflow runs from the last 7 days
        local recent_runs
        if recent_runs=$(gh run list --limit 10 --json status,conclusion,createdAt 2>/dev/null); then
            local total_runs=$(echo "$recent_runs" | jq length)
            local successful_runs=$(echo "$recent_runs" | jq '[.[] | select(.conclusion == "success")] | length')
            local failed_runs=$(echo "$recent_runs" | jq '[.[] | select(.conclusion == "failure")] | length')
            
            log_info "Recent workflow statistics:"
            log_info "  Total runs: $total_runs"
            log_info "  Successful: $successful_runs"
            log_info "  Failed: $failed_runs"
            
            if [ "$total_runs" -gt 0 ]; then
                local success_rate=$((successful_runs * 100 / total_runs))
                if [ "$success_rate" -ge 90 ]; then
                    increment_passed
                    [ "$VERBOSE" = "true" ] && log_success "Workflow success rate: ${success_rate}%"
                elif [ "$success_rate" -ge 70 ]; then
                    increment_warning
                    [ "$VERBOSE" = "true" ] && log_warning "Workflow success rate: ${success_rate}%"
                else
                    increment_failed
                    [ "$VERBOSE" = "true" ] && log_error "Workflow success rate: ${success_rate}%"
                fi
            else
                increment_warning
                [ "$VERBOSE" = "true" ] && log_warning "No recent workflow runs found"
            fi
        else
            increment_warning
            [ "$VERBOSE" = "true" ] && log_warning "Could not fetch workflow run data"
        fi
    else
        increment_warning
        [ "$VERBOSE" = "true" ] && log_warning "GitHub CLI not available for monitoring"
    fi
    
    # Check workflow file syntax
    log_step "Validating workflow file syntax"
    for workflow_file in .github/workflows/*.yml .github/workflows/*.yaml; do
        if [ -f "$workflow_file" ]; then
            if command -v yq >/dev/null 2>&1; then
                if yq eval . "$workflow_file" >/dev/null 2>&1; then
                    increment_passed
                    [ "$VERBOSE" = "true" ] && log_success "Valid YAML: $workflow_file"
                else
                    increment_failed
                    [ "$VERBOSE" = "true" ] && log_error "Invalid YAML: $workflow_file"
                fi
            else
                # Basic YAML check without yq
                if python3 -c "import yaml; yaml.safe_load(open('$workflow_file'))" 2>/dev/null; then
                    increment_passed
                    [ "$VERBOSE" = "true" ] && log_success "Valid YAML: $workflow_file"
                else
                    increment_failed
                    [ "$VERBOSE" = "true" ] && log_error "Invalid YAML: $workflow_file"
                fi
            fi
        fi
    done
}

configure_secrets() {
    log_step "Configuring workflow secrets"
    
    if [ "$DRY_RUN" = "true" ]; then
        log_info "Would configure ANTHROPIC_API_KEY secret"
        return 0
    fi
    
    if ! command -v gh >/dev/null 2>&1; then
        log_error "GitHub CLI is required for secret configuration"
        increment_failed
        return 1
    fi
    
    echo "To configure the ANTHROPIC_API_KEY secret:"
    echo "1. Get your API key from: https://console.anthropic.com/"
    echo "2. Run: gh secret set ANTHROPIC_API_KEY"
    echo "3. Paste your API key when prompted"
    echo ""
    
    read -p "Do you want to configure the secret now? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if gh secret set ANTHROPIC_API_KEY; then
            increment_passed
            log_success "ANTHROPIC_API_KEY secret configured successfully"
        else
            increment_failed
            log_error "Failed to configure ANTHROPIC_API_KEY secret"
        fi
    else
        log_info "Secret configuration skipped"
    fi
}

validate_secret() {
    log_step "Validating API secret configuration"
    
    local secret_configured=false
    
    # Check GitHub secret
    if command -v gh >/dev/null 2>&1; then
        if gh secret list | grep -q "ANTHROPIC_API_KEY"; then
            increment_passed
            [ "$VERBOSE" = "true" ] && log_success "GitHub secret ANTHROPIC_API_KEY is configured"
            secret_configured=true
        else
            increment_failed
            [ "$VERBOSE" = "true" ] && log_error "GitHub secret ANTHROPIC_API_KEY not configured"
        fi
    fi
    
    # Check environment variable
    if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
        increment_passed
        [ "$VERBOSE" = "true" ] && log_success "Environment variable ANTHROPIC_API_KEY is set"
        secret_configured=true
    else
        increment_warning
        [ "$VERBOSE" = "true" ] && log_warning "Environment variable ANTHROPIC_API_KEY not set"
    fi
    
    if [ "$secret_configured" = "false" ]; then
        log_error "No valid API key configuration found"
        log_info "Run: $0 --config to configure the secret"
    fi
}

generate_report() {
    log_step "Generating workflow report"
    
    local report_file="workflow-report-$(date +%Y%m%d-%H%M%S).md"
    
    cat > "$report_file" << EOF
# Workflow Health Report

Generated: $(date)

## Workflow Status

EOF
    
    # Run all checks and append to report
    {
        echo "### Test Results"
        test_workflow
        echo ""
        
        echo "### Monitoring Results"
        monitor_workflow
        echo ""
        
        echo "### Secret Validation"
        validate_secret
        echo ""
        
    } >> "$report_file"
    
    log_success "Report generated: $report_file"
}

# Execute operation
case $OPERATION in
    "test")
        test_workflow
        ;;
    "monitor")
        monitor_workflow
        ;;
    "config")
        configure_secrets
        ;;
    "validate-secret")
        validate_secret
        ;;
    "report")
        generate_report
        ;;
    "performance")
        log_info "Performance monitoring integrated with monitor operation"
        monitor_workflow
        ;;
    "dashboard")
        log_info "Dashboard view:"
        test_workflow
        echo ""
        monitor_workflow
        echo ""
        validate_secret
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