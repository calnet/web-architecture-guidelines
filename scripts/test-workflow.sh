#!/bin/bash

# Enhanced Workflow Testing Script
# Creates comprehensive tests for the enhanced Claude Code Review system

set -e

# Configuration
REPO="calnet/web-architecture-guidelines"
TEST_BRANCH="test/workflow-validation-$(date +%Y%m%d-%H%M%S)"
CLEANUP_ON_SUCCESS=true
VALIDATE_SECRET=false
DRY_RUN=false
SKIP_PR_CREATION=false

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Cleanup function
cleanup() {
    local exit_code=$?
    
    if [[ "$CLEANUP_ON_SUCCESS" == "true" && $exit_code -eq 0 && "$DRY_RUN" == "false" ]]; then
        echo -e "${BLUE}🧹 Cleaning up test artifacts...${NC}"
        
        # Delete test branch
        if git branch -a | grep -q "$TEST_BRANCH"; then
            git checkout main >/dev/null 2>&1 || git checkout develop >/dev/null 2>&1
            git branch -D "$TEST_BRANCH" >/dev/null 2>&1 || true
            git push origin --delete "$TEST_BRANCH" >/dev/null 2>&1 || true
        fi
        
        # Remove test files
        rm -f TEST_*.md test_*.py test_*.json >/dev/null 2>&1 || true
        
        echo -e "${GREEN}✅ Cleanup completed${NC}"
    elif [[ $exit_code -ne 0 ]]; then
        echo -e "${YELLOW}⚠️ Test failed - preserving artifacts for debugging${NC}"
        echo -e "${BLUE}Test branch: $TEST_BRANCH${NC}"
    fi
}

trap cleanup EXIT

show_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Enhanced workflow testing for Claude Code Review system"
    echo ""
    echo "Options:"
    echo "  --validate-secret    Test ANTHROPIC_API_KEY secret configuration"
    echo "  --dry-run           Validate configuration without creating PR"
    echo "  --skip-pr           Skip PR creation (for local testing)"
    echo "  --no-cleanup        Preserve test artifacts on success"
    echo "  --help              Show this help message"
    echo ""
    echo "Test scenarios:"
    echo "  1. Workflow file validation"
    echo "  2. Custom command testing"
    echo "  3. Secret configuration validation"
    echo "  4. Documentation compliance testing"
    echo "  5. Performance and security validation"
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

validate_workflow_files() {
    print_header "🔍 Validating Workflow Files"
    
    local workflows_dir=".github/workflows"
    local validation_passed=true
    
    if [[ ! -d "$workflows_dir" ]]; then
        print_error "Workflows directory not found: $workflows_dir"
        return 1
    fi
    
    # Check main workflow files exist
    local required_workflows=(
        "claude-code-review.yml"
        "advanced-architecture-review.yml"
    )
    
    for workflow in "${required_workflows[@]}"; do
        local workflow_path="$workflows_dir/$workflow"
        if [[ -f "$workflow_path" ]]; then
            print_success "Found workflow: $workflow"
            
            # Validate YAML syntax
            if command -v yamllint &> /dev/null; then
                if yamllint "$workflow_path" &> /dev/null; then
                    print_success "YAML syntax valid: $workflow"
                else
                    print_warning "YAML syntax issues in: $workflow"
                    validation_passed=false
                fi
            else
                print_info "yamllint not available, skipping YAML validation"
            fi
            
            # Check for required secrets
            if grep -q "ANTHROPIC_API_KEY" "$workflow_path"; then
                print_success "ANTHROPIC_API_KEY reference found in $workflow"
            else
                print_warning "ANTHROPIC_API_KEY not found in $workflow"
                validation_passed=false
            fi
            
            # Check for proper GitHub token usage
            if grep -q "GITHUB_TOKEN" "$workflow_path"; then
                print_success "GITHUB_TOKEN reference found in $workflow"
            else
                print_warning "GITHUB_TOKEN not found in $workflow"
            fi
            
        else
            print_error "Missing required workflow: $workflow"
            validation_passed=false
        fi
    done
    
    return $([[ "$validation_passed" == "true" ]])
}

validate_custom_commands() {
    print_header "🎯 Validating Custom Commands"
    
    local commands_dir=".claude/commands"
    local validation_passed=true
    
    if [[ ! -d "$commands_dir" ]]; then
        print_error "Custom commands directory not found: $commands_dir"
        return 1
    fi
    
    # Check required command files exist
    local required_commands=(
        "architecture-review.md"
        "security-scan.md"
        "performance-check.md"
        "documentation-audit.md"
        "quick-fix.md"
    )
    
    for command in "${required_commands[@]}"; do
        local command_path="$commands_dir/$command"
        if [[ -f "$command_path" ]]; then
            print_success "Found command: $command"
            
            # Check file is not empty
            if [[ -s "$command_path" ]]; then
                print_success "Command file has content: $command"
            else
                print_warning "Command file is empty: $command"
                validation_passed=false
            fi
            
            # Check for basic markdown structure
            if grep -q "^#" "$command_path"; then
                print_success "Markdown structure found in: $command"
            else
                print_warning "No markdown headers in: $command"
            fi
            
        else
            print_error "Missing required command: $command"
            validation_passed=false
        fi
    done
    
    return $([[ "$validation_passed" == "true" ]])
}

validate_secret_configuration() {
    print_header "🔐 Validating Secret Configuration"
    
    if [[ "$VALIDATE_SECRET" != "true" ]]; then
        print_info "Secret validation skipped (use --validate-secret to enable)"
        return 0
    fi
    
    # Run the secret configuration script
    if [[ -f "scripts/configure-anthropic-secret.sh" ]]; then
        print_info "Running secret validation..."
        if ./scripts/configure-anthropic-secret.sh --validate; then
            print_success "Secret configuration validated"
            return 0
        else
            print_warning "Secret configuration needs attention"
            return 1
        fi
    else
        print_error "Secret configuration script not found"
        return 1
    fi
}

test_npm_scripts() {
    print_header "📦 Testing NPM Scripts"
    
    local validation_passed=true
    
    # Check if package.json exists
    if [[ ! -f "package.json" ]]; then
        print_error "package.json not found"
        return 1
    fi
    
    # Test required npm scripts
    local required_scripts=(
        "lint:all"
        "lint:architecture"
        "lint:security"
        "lint:performance"
        "validate:all"
        "versions:validate"
    )
    
    for script in "${required_scripts[@]}"; do
        if npm run "$script" --silent > /dev/null 2>&1; then
            print_success "NPM script working: $script"
        else
            print_warning "NPM script failed: $script"
            validation_passed=false
        fi
    done
    
    return $([[ "$validation_passed" == "true" ]])
}

create_test_scenarios() {
    print_header "📝 Creating Test Scenarios"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "Dry run mode - skipping test file creation"
        return 0
    fi
    
    # Test 1: Documentation change
    cat > TEST_DOCUMENTATION.md << 'TEST_EOF'
# Test Documentation

This is a test documentation file to validate the workflow system.

## Purpose
- Test documentation template compliance
- Validate @claude review functionality  
- Check custom slash command integration

## Architecture Compliance
This document should trigger review against our documentation templates.

## Security Considerations
No security implications for this test document.

## Performance Impact
Minimal performance impact expected.

---
- **Version**: 1.2.0
- **Last Updated**: September 2025
- **Template Version**: 1.2.0
TEST_EOF
    
    # Test 2: Architecture documentation
    cat > TEST_ARCHITECTURE.md << 'TEST_EOF'
# Test Architecture Document

## System Overview
This is a test architecture document to validate workflow triggers.

## Components
- Frontend: React application
- Backend: Node.js API
- Database: PostgreSQL
- Cache: Redis

## Security Architecture
- Authentication: JWT tokens
- Authorization: RBAC
- Data encryption: AES-256

## Performance Considerations
- CDN for static assets
- Database indexing strategy
- Caching layers

---
- **Version**: 1.2.0
- **Template Version**: 1.2.0
TEST_EOF
    
    # Test 3: Configuration file
    cat > test_config.json << 'TEST_EOF'
{
  "version": "1.2.0",
  "environment": "test",
  "features": {
    "claude_review": true,
    "custom_commands": true,
    "monitoring": true
  },
  "test_metadata": {
    "created": "2025-09-06",
    "purpose": "workflow validation"
  }
}
TEST_EOF

    print_success "Test scenarios created"
}

run_comprehensive_validation() {
    print_header "🔍 Running Comprehensive Validation"
    
    local overall_success=true
    
    # Run all validation functions
    if ! validate_workflow_files; then
        overall_success=false
    fi
    
    if ! validate_custom_commands; then
        overall_success=false
    fi
    
    if ! validate_secret_configuration; then
        overall_success=false
    fi
    
    if ! test_npm_scripts; then
        overall_success=false
    fi
    
    return $([[ "$overall_success" == "true" ]])
}

create_test_pr() {
    if [[ "$SKIP_PR_CREATION" == "true" || "$DRY_RUN" == "true" ]]; then
        print_info "Skipping PR creation"
        return 0
    fi
    
    print_header "🔄 Creating Test PR"
    
    # Create and switch to test branch
    print_info "Creating test branch: $TEST_BRANCH"
    git checkout -b "$TEST_BRANCH"
    
    # Add test files
    git add TEST_*.md test_*.json
    git commit -m "test: add workflow validation test files

This commit creates test files to validate the Enhanced Claude Code Review workflow system:

- Documentation test files to trigger documentation reviews
- Architecture test files to trigger architecture analysis  
- Configuration test files to trigger security and performance checks

The test files include proper version markers and template compliance.

This is an automated test - files will be cleaned up after validation."
    
    # Push test branch
    print_info "Pushing test branch..."
    git push origin "$TEST_BRANCH"
    
    # Create test PR
    print_info "Creating test PR..."
    gh pr create \
        --title "test: Enhanced Claude Workflow System Validation" \
        --body "## Test PR for Enhanced Claude Code Review Workflow

This is an automated test PR to validate the Enhanced Claude Code Review workflow system.

### Test Coverage
- [x] Workflow file validation
- [x] Custom command availability  
- [x] NPM script functionality
- [x] Documentation template compliance
- [x] Architecture analysis triggers
- [x] Security and performance validation

### Expected Behavior
1. **Automatic Review**: Claude should automatically review this PR
2. **Custom Commands**: Test slash commands like \`/architecture-review\`
3. **Validation Scripts**: All validation scripts should pass
4. **Template Compliance**: Documentation should meet template standards

### Test Files
- \`TEST_DOCUMENTATION.md\` - Documentation compliance test
- \`TEST_ARCHITECTURE.md\` - Architecture review test  
- \`test_config.json\` - Configuration validation test

This PR will be automatically cleaned up after validation." \
        --head "$TEST_BRANCH" \
        --base "main"
    
    local pr_url=$(gh pr view --json url -q .url)
    print_success "Test PR created: $pr_url"
    
    print_info "Test instructions:"
    echo "1. Monitor the PR for automatic Claude reviews"
    echo "2. Test custom commands by commenting: @claude /architecture-review"
    echo "3. Check GitHub Actions for workflow execution"
    echo "4. Validate all checks pass successfully"
    echo ""
    echo "PR URL: $pr_url"
}

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --validate-secret)
                VALIDATE_SECRET=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --skip-pr)
                SKIP_PR_CREATION=true
                shift
                ;;
            --no-cleanup)
                CLEANUP_ON_SUCCESS=false
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

    print_header "🧪 Enhanced Workflow System Testing"
    echo ""

    # Check prerequisites
    print_header "📋 Checking Prerequisites"
    
    local prerequisites_ok=true
    
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI not installed"
        prerequisites_ok=false
    else
        print_success "GitHub CLI available"
    fi

    if ! gh auth status &> /dev/null; then
        print_error "GitHub CLI not authenticated"
        prerequisites_ok=false
    else
        print_success "GitHub CLI authenticated"
    fi

    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        print_error "Not in a git repository"
        prerequisites_ok=false
    else
        print_success "Git repository detected"
    fi
    
    # Check Node.js and npm
    if ! command -v node &> /dev/null; then
        print_warning "Node.js not available (some tests may be skipped)"
    else
        print_success "Node.js available: $(node --version)"
    fi
    
    if ! command -v npm &> /dev/null; then
        print_warning "npm not available (some tests may be skipped)"
    else
        print_success "npm available: $(npm --version)"
    fi
    
    if [[ "$prerequisites_ok" != "true" ]]; then
        print_error "Prerequisites not met"
        exit 1
    fi

    print_success "All prerequisites verified"
    echo ""
    
    # Run comprehensive validation
    if run_comprehensive_validation; then
        print_success "All validations passed!"
    else
        print_error "Some validations failed"
        exit 1
    fi
    
    echo ""
    
    # Create test scenarios and PR if not dry run
    if [[ "$DRY_RUN" == "false" && "$SKIP_PR_CREATION" == "false" ]]; then
        create_test_scenarios
        
        echo ""
        create_test_pr
    elif [[ "$DRY_RUN" == "true" ]]; then
        print_info "Dry run completed - all validations passed"
        print_info "Run without --dry-run to create actual test PR"
    else
        print_info "Local validation completed successfully"
    fi
    
    echo ""
    print_header "📊 Test Summary"
    echo ""
    print_success "Enhanced workflow system is properly configured!"
    
    if [[ "$DRY_RUN" == "false" && "$SKIP_PR_CREATION" == "false" ]]; then
        echo ""
        print_info "Next steps:"
        echo "1. Monitor the test PR for Claude reviews"
        echo "2. Test custom commands in PR comments"
        echo "3. Verify all GitHub Actions workflows execute"
        echo "4. Check workflow performance and optimize if needed"
    fi
    
    echo ""
    print_info "Additional testing commands:"
    echo "  ./scripts/configure-anthropic-secret.sh --validate"
    echo "  ./scripts/monitor-workflow.sh --report"
    echo "  npm run validate:all"
    
    echo ""
    print_success "Testing completed successfully!"
}

# Run main function
main "$@"
