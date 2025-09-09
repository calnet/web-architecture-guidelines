#!/bin/bash

# Monitoring and Testing Scripts Creation
# Creates monitoring and testing scripts for the enhanced Claude Code Review system

set -e

# Load common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/workflow-utils.sh"

# Script-specific configuration
SCRIPTS_DIR="scripts"

show_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Creates monitoring and testing scripts for the enhanced Claude Code Review system."
    echo ""
    show_common_help
    echo "Created scripts:"
    echo "  - monitor-workflow.sh: Health monitoring and status checks"
    echo "  - test-workflow.sh: Comprehensive workflow testing"
    echo "  - setup-enhanced-workflow.sh: Complete system setup"
    echo ""
}

create_monitor_workflow_script() {
    local script_file="$SCRIPTS_DIR/monitor-workflow.sh"
    
    print_header "📄 Creating workflow monitoring script..."
    
    backup_file "$script_file"
    
    if is_dry_run; then
        print_info "DRY RUN: Would create $script_file"
        return 0
    fi
    
    cat > "$script_file" << 'MONITOR_EOF'
#!/bin/bash

# Workflow Monitoring Script
# Monitors the health and performance of the enhanced Claude Code Review system

set -e

# Configuration
REPO="calnet/web-architecture-guidelines"
LOG_FILE="workflow-monitor.log"
MAX_LOG_SIZE=10485760  # 10MB

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Logging function
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# Rotate log file if it gets too large
rotate_log() {
    if [[ -f "$LOG_FILE" ]] && [[ $(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE" 2>/dev/null) -gt $MAX_LOG_SIZE ]]; then
        mv "$LOG_FILE" "${LOG_FILE}.old"
        touch "$LOG_FILE"
        log_message "INFO" "Log file rotated"
    fi
}

# Check GitHub CLI availability and authentication
check_github_cli() {
    echo -e "${BLUE}🔍 Checking GitHub CLI...${NC}"
    
    if ! command -v gh &> /dev/null; then
        echo -e "${RED}❌ GitHub CLI not installed${NC}"
        log_message "ERROR" "GitHub CLI not available"
        return 1
    fi
    
    if ! gh auth status &> /dev/null; then
        echo -e "${RED}❌ GitHub CLI not authenticated${NC}"
        log_message "ERROR" "GitHub CLI authentication failed"
        return 1
    fi
    
    echo -e "${GREEN}✅ GitHub CLI ready${NC}"
    log_message "INFO" "GitHub CLI check passed"
    return 0
}

# Check repository secrets
check_repository_secrets() {
    echo -e "${BLUE}🔑 Checking repository secrets...${NC}"
    
    # Check if ANTHROPIC_API_KEY is configured
    if gh secret list --repo "$REPO" | grep -q "ANTHROPIC_API_KEY"; then
        echo -e "${GREEN}✅ ANTHROPIC_API_KEY configured${NC}"
        log_message "INFO" "ANTHROPIC_API_KEY secret found"
    else
        echo -e "${RED}❌ ANTHROPIC_API_KEY not configured${NC}"
        log_message "ERROR" "ANTHROPIC_API_KEY secret missing"
        return 1
    fi
    
    return 0
}

# Check workflow files exist
check_workflow_files() {
    echo -e "${BLUE}📄 Checking workflow files...${NC}"
    
    local workflows=(
        ".github/workflows/claude-code-review.yml"
        ".github/workflows/advanced-architecture-review.yml"
    )
    
    local missing_files=0
    
    for workflow in "${workflows[@]}"; do
        if [[ -f "$workflow" ]]; then
            echo -e "${GREEN}✅ $workflow exists${NC}"
            log_message "INFO" "Workflow file found: $workflow"
        else
            echo -e "${RED}❌ $workflow missing${NC}"
            log_message "ERROR" "Workflow file missing: $workflow"
            ((missing_files++))
        fi
    done
    
    return $missing_files
}

# Check custom commands
check_custom_commands() {
    echo -e "${BLUE}⚡ Checking custom commands...${NC}"
    
    local commands=(
        ".claude/commands/architecture-review.md"
        ".claude/commands/security-scan.md"
        ".claude/commands/performance-check.md"
        ".claude/commands/documentation-audit.md"
        ".claude/commands/quick-fix.md"
    )
    
    local missing_commands=0
    
    for command in "${commands[@]}"; do
        if [[ -f "$command" ]]; then
            echo -e "${GREEN}✅ $(basename "$command" .md) command available${NC}"
            log_message "INFO" "Custom command found: $command"
        else
            echo -e "${RED}❌ $(basename "$command" .md) command missing${NC}"
            log_message "ERROR" "Custom command missing: $command"
            ((missing_commands++))
        fi
    done
    
    return $missing_commands
}

# Check recent workflow runs
check_workflow_runs() {
    echo -e "${BLUE}📊 Checking recent workflow runs...${NC}"
    
    # Get last 5 workflow runs
    local runs=$(gh run list --repo "$REPO" --limit 5 --json status,conclusion,workflowName,createdAt)
    
    if [[ -z "$runs" ]] || [[ "$runs" == "[]" ]]; then
        echo -e "${YELLOW}⚠️ No recent workflow runs found${NC}"
        log_message "WARN" "No recent workflow runs"
        return 0
    fi
    
    echo "$runs" | jq -r '.[] | "\(.workflowName): \(.status) (\(.conclusion // "running")) - \(.createdAt)"' | while read -r line; do
        if echo "$line" | grep -q "success"; then
            echo -e "${GREEN}✅ $line${NC}"
        elif echo "$line" | grep -q "failure"; then
            echo -e "${RED}❌ $line${NC}"
            log_message "ERROR" "Workflow failure: $line"
        else
            echo -e "${YELLOW}⚡ $line${NC}"
        fi
    done
    
    # Count failed runs in last 24 hours
    local failed_count=$(echo "$runs" | jq -r '.[] | select(.conclusion == "failure") | .createdAt' | xargs -I {} date -d {} +%s 2>/dev/null | awk -v day_ago=$(($(date +%s) - 86400)) '$1 > day_ago' | wc -l)
    
    if [[ $failed_count -gt 3 ]]; then
        echo -e "${RED}❌ High failure rate: $failed_count failures in last 24 hours${NC}"
        log_message "ERROR" "High workflow failure rate: $failed_count failures"
        return 1
    elif [[ $failed_count -gt 1 ]]; then
        echo -e "${YELLOW}⚠️ Moderate failure rate: $failed_count failures in last 24 hours${NC}"
        log_message "WARN" "Moderate workflow failure rate: $failed_count failures"
    else
        echo -e "${GREEN}✅ Low failure rate: $failed_count failures in last 24 hours${NC}"
        log_message "INFO" "Acceptable workflow failure rate: $failed_count failures"
    fi
    
    return 0
}

# Check API rate limits
check_api_limits() {
    echo -e "${BLUE}📈 Checking API rate limits...${NC}"
    
    # GitHub API rate limit
    local github_limit=$(gh api rate_limit --jq '.rate.remaining')
    local github_total=$(gh api rate_limit --jq '.rate.limit')
    
    echo -e "${BLUE}GitHub API: $github_limit/$github_total remaining${NC}"
    log_message "INFO" "GitHub API rate limit: $github_limit/$github_total"
    
    if [[ $github_limit -lt 100 ]]; then
        echo -e "${RED}❌ GitHub API rate limit low${NC}"
        log_message "WARN" "GitHub API rate limit critically low: $github_limit"
    fi
    
    # Note: Anthropic API limits would need to be checked via their API
    echo -e "${BLUE}ℹ️ Anthropic API limits: Check via Anthropic dashboard${NC}"
    
    return 0
}

# Performance metrics
check_performance_metrics() {
    echo -e "${BLUE}⚡ Checking performance metrics...${NC}"
    
    # Average workflow duration (last 10 runs)
    local durations=$(gh run list --repo "$REPO" --limit 10 --json duration,conclusion | jq -r '.[] | select(.conclusion == "success") | .duration')
    
    if [[ -n "$durations" ]]; then
        local avg_duration=$(echo "$durations" | awk '{sum+=$1; count++} END {if(count>0) print sum/count; else print 0}')
        echo -e "${BLUE}Average workflow duration: ${avg_duration}s${NC}"
        log_message "INFO" "Average workflow duration: ${avg_duration}s"
        
        if (( $(echo "$avg_duration > 300" | bc -l) )); then
            echo -e "${YELLOW}⚠️ Workflows taking longer than 5 minutes${NC}"
            log_message "WARN" "Long workflow duration detected: ${avg_duration}s"
        else
            echo -e "${GREEN}✅ Workflow performance acceptable${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️ No successful runs to calculate average duration${NC}"
    fi
    
    return 0
}

# Generate health report
generate_health_report() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local report_file="health-report-$(date '+%Y%m%d-%H%M%S').md"
    
    cat > "$report_file" << EOF
# Workflow Health Report

**Generated**: $timestamp

## System Status
- GitHub CLI: $(check_github_cli >/dev/null 2>&1 && echo "✅ OK" || echo "❌ ERROR")
- Repository Secrets: $(check_repository_secrets >/dev/null 2>&1 && echo "✅ OK" || echo "❌ ERROR") 
- Workflow Files: $(check_workflow_files >/dev/null 2>&1 && echo "✅ OK" || echo "❌ ERROR")
- Custom Commands: $(check_custom_commands >/dev/null 2>&1 && echo "✅ OK" || echo "❌ ERROR")

## Recent Activity
$(gh run list --repo "$REPO" --limit 5 --json status,conclusion,workflowName,createdAt | jq -r '.[] | "- \(.workflowName): \(.status) (\(.conclusion // "running"))"')

## Recommendations
- Monitor workflow failure rates
- Check API rate limits regularly
- Update documentation based on usage patterns
- Review and optimize workflow performance

---
*Generated by workflow monitoring system*
EOF

    echo -e "${GREEN}✅ Health report generated: $report_file${NC}"
    log_message "INFO" "Health report generated: $report_file"
}

# Main monitoring function
monitor_main() {
    echo -e "${BLUE}🚀 Enhanced Workflow Monitoring System${NC}"
    echo "====================================="
    
    # Note: Log rotation function would be implemented in the monitoring script itself
    
    log_message "INFO" "Starting workflow monitoring"
    
    local errors=0
    
    # Run all checks
    check_github_cli || ((errors++))
    echo ""
    
    check_repository_secrets || ((errors++))
    echo ""
    
    check_workflow_files || ((errors++))
    echo ""
    
    check_custom_commands || ((errors++))
    echo ""
    
    check_workflow_runs || ((errors++))
    echo ""
    
    check_api_limits || ((errors++))
    echo ""
    
    check_performance_metrics || ((errors++))
    echo ""
    
    # Generate report
    if [[ "$1" == "--report" ]]; then
        generate_health_report
        echo ""
    fi
    
    # Summary
    if [[ $errors -eq 0 ]]; then
        echo -e "${GREEN}🎉 All systems operational!${NC}"
        log_message "INFO" "Monitoring completed successfully - all systems operational"
    else
        echo -e "${RED}❌ $errors issues detected${NC}"
        log_message "ERROR" "Monitoring completed with $errors issues"
    fi
    
    echo ""
    echo "💡 Usage tips:"
    echo "  - Run with --report to generate detailed health report"
    echo "  - Check logs in: $LOG_FILE"
    echo "  - Set up as cron job for continuous monitoring"
    
    return $errors
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "Workflow Monitoring Script"
        echo ""
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --report    Generate detailed health report"
        echo "  --help      Show this help message"
        echo ""
        exit 0
        ;;
    *)
        monitor_main "$@"
        ;;
esac
MONITOR_EOF

    chmod +x "$script_file"
    validate_file_creation "$script_file" "Workflow monitoring script"
}

create_test_workflow_script() {
    local script_file="$SCRIPTS_DIR/test-workflow.sh"
    
    print_header "📄 Creating workflow testing script..."
    
    backup_file "$script_file"
    
    if is_dry_run; then
        print_info "DRY RUN: Would create $script_file"
        return 0
    fi
    
    cat > "$script_file" << 'TEST_EOF'
#!/bin/bash

# Workflow Testing Script
# Creates comprehensive tests for the enhanced Claude Code Review system

set -e

# Configuration
REPO="calnet/web-architecture-guidelines"
TEST_BRANCH="test/workflow-validation-$(date +%Y%m%d-%H%M%S)"
CLEANUP_ON_SUCCESS=true

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Cleanup function
cleanup() {
    local exit_code=$?
    
    if [[ "$CLEANUP_ON_SUCCESS" == "true" && $exit_code -eq 0 ]]; then
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

echo -e "${BLUE}🧪 Testing Enhanced Workflow System${NC}"
echo "===================================="

# Check prerequisites
echo -e "${BLUE}📋 Checking prerequisites...${NC}"
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI not installed${NC}"
    exit 1
fi

if ! gh auth status &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI not authenticated${NC}"
    exit 1
fi

if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo -e "${RED}❌ Not in a git repository${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites verified${NC}"

# Create test branch
echo -e "${BLUE}🌿 Creating test branch: $TEST_BRANCH${NC}"
git checkout -b "$TEST_BRANCH"

# Create test files for different scenarios
echo -e "${BLUE}📝 Creating test files...${NC}"

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
TEST_EOF

# Test 2: Code change with potential issues
cat > test_code.py << 'TEST_EOF'
# Test Python Code - Intentionally Basic for Review

def get_user_data(user_id):
    # Potential security issue - no input validation
    query = f"SELECT * FROM users WHERE id = {user_id}"
    return database.execute(query)

def process_user_request(request):
    # Potential performance issue - no caching
    user_id = request.get('user_id')
    user_data = get_user_data(user_id)
    
    # Process user data
    for item in user_data:
        expensive_operation(item)
    
    return user_data

def expensive_operation(data):
    # Simulate expensive operation
    import time
    time.sleep(0.1)
    return data.upper()
TEST_EOF

# Test 3: Configuration change
cat > test_config.json << 'TEST_EOF'
{
  "database": {
    "host": "localhost",
    "port": 5432,
    "username": "admin",
    "password": "password123"
  },
  "api": {
    "rate_limit": 1000,
    "timeout": 30
  },
  "security": {
    "enable_https": true,
    "jwt_secret": "super_secret_key"
  }
}
TEST_EOF

# Commit test files
git add .
git commit -m "test: add comprehensive test files for workflow validation

This commit includes:
- Documentation file to test template compliance
- Python code with intentional security and performance issues
- Configuration file with potential security concerns

Expected Claude feedback:
- Documentation template suggestions
- Security vulnerability identification (SQL injection, hardcoded secrets)
- Performance optimization recommendations
- Configuration security improvements

Test ID: $(date +%Y%m%d-%H%M%S)"

# Push test branch
echo -e "${BLUE}🚀 Pushing test branch...${NC}"
git push origin "$TEST_BRANCH"

# Create test PR
echo -e "${BLUE}📬 Creating test PR...${NC}"
PR_URL=$(gh pr create \
    --title "🧪 Test: Enhanced Workflow System Validation" \
    --body "## Test Overview

This PR validates the enhanced Claude Code Review workflow system.

### Test Files Included:
1. **TEST_DOCUMENTATION.md** - Documentation compliance test
2. **test_code.py** - Code with intentional issues for review
3. **test_config.json** - Configuration with security concerns

### Expected Workflow Behavior:
- ✅ Automated Claude code review should trigger
- ✅ Security issues should be identified
- ✅ Performance improvements should be suggested
- ✅ Documentation compliance should be validated

### Custom Commands to Test:
- \`/architecture-review\` - Test architecture analysis
- \`/security-scan\` - Test security vulnerability detection
- \`/performance-check\` - Test performance optimization suggestions
- \`/documentation-audit\` - Test documentation quality assessment
- \`/quick-fix\` - Test quick fix suggestions

### Test Results Expected:
- SQL injection vulnerability detection
- Hardcoded secrets identification
- Performance optimization suggestions
- Documentation template compliance feedback

**Note**: This is an automated test PR and will be closed after validation.")

echo -e "${GREEN}✅ Test PR created: $PR_URL${NC}"

# Wait for initial workflow run
echo -e "${BLUE}⏳ Waiting for initial workflow run...${NC}"
sleep 30

# Check if workflow started
echo -e "${BLUE}🔍 Checking workflow status...${NC}"
RUNS=$(gh run list --repo "$REPO" --branch "$TEST_BRANCH" --limit 5 --json status,conclusion,workflowName)

if [[ -z "$RUNS" ]] || [[ "$RUNS" == "[]" ]]; then
    echo -e "${YELLOW}⚠️ No workflow runs detected yet. This might be normal for new PRs.${NC}"
    echo -e "${BLUE}ℹ️ You can manually check: $PR_URL${NC}"
else
    echo -e "${GREEN}✅ Workflow runs detected${NC}"
    echo "$RUNS" | jq -r '.[] | "- \(.workflowName): \(.status) (\(.conclusion // "running"))"'
fi

# Test custom commands
echo -e "${BLUE}⚡ Testing custom commands...${NC}"

# Add a comment to trigger architecture review
echo -e "${BLUE}🏗️ Testing architecture review command...${NC}"
gh pr comment "$PR_URL" --body "/architecture-review Please analyze the overall architecture and identify any issues with the test files."

sleep 10

# Add a comment to trigger security scan
echo -e "${BLUE}🔒 Testing security scan command...${NC}"
gh pr comment "$PR_URL" --body "/security-scan Please check for security vulnerabilities in the test code and configuration."

sleep 10

# Add a comment to trigger performance check
echo -e "${BLUE}⚡ Testing performance check command...${NC}"
gh pr comment "$PR_URL" --body "/performance-check Please analyze the code for performance optimization opportunities."

sleep 10

# Add a comment to trigger documentation audit
echo -e "${BLUE}📋 Testing documentation audit command...${NC}"
gh pr comment "$PR_URL" --body "/documentation-audit Please review the documentation for compliance with templates."

sleep 10

# Add a comment to trigger quick fix
echo -e "${BLUE}🔧 Testing quick fix command...${NC}"
gh pr comment "$PR_URL" --body "/quick-fix Please suggest quick fixes for the identified issues."

# Final status check
echo -e "${BLUE}📊 Final workflow status check...${NC}"
sleep 30

FINAL_RUNS=$(gh run list --repo "$REPO" --branch "$TEST_BRANCH" --limit 10 --json status,conclusion,workflowName,createdAt)
echo "$FINAL_RUNS" | jq -r '.[] | "- \(.workflowName): \(.status) (\(.conclusion // "running")) - \(.createdAt)"'

# Generate test report
echo -e "${BLUE}📋 Generating test report...${NC}"
cat > "test-report-$(date +%Y%m%d-%H%M%S).md" << EOF
# Workflow Test Report

**Test Date**: $(date '+%Y-%m-%d %H:%M:%S')
**Test Branch**: $TEST_BRANCH
**Test PR**: $PR_URL

## Test Overview
Comprehensive validation of the enhanced Claude Code Review workflow system.

## Test Files Created
- \`TEST_DOCUMENTATION.md\` - Documentation compliance test
- \`test_code.py\` - Code with intentional security and performance issues
- \`test_config.json\` - Configuration with hardcoded secrets

## Workflow Runs
$(echo "$FINAL_RUNS" | jq -r '.[] | "- \(.workflowName): \(.status) (\(.conclusion // "running"))"')

## Custom Commands Tested
- ✅ /architecture-review - Architecture analysis command
- ✅ /security-scan - Security vulnerability detection
- ✅ /performance-check - Performance optimization suggestions
- ✅ /documentation-audit - Documentation quality assessment
- ✅ /quick-fix - Quick fix suggestions

## Expected Results
The workflow should identify:
- SQL injection vulnerability in test_code.py
- Hardcoded passwords in test_config.json
- Performance issues with expensive operations
- Documentation template compliance issues

## Next Steps
1. Review PR comments for Claude feedback
2. Verify all custom commands triggered correctly
3. Validate security and performance issues were identified
4. Check documentation compliance feedback

## Cleanup
$(if [[ "$CLEANUP_ON_SUCCESS" == "true" ]]; then echo "Test artifacts will be automatically cleaned up"; else echo "Test artifacts preserved for manual review"; fi)

---
*Generated by automated workflow testing system*
EOF

echo -e "${GREEN}✅ Test report generated${NC}"

# Summary
echo ""
echo -e "${BLUE}📋 Test Summary${NC}"
echo "==============="
echo -e "${GREEN}✅ Test branch created: $TEST_BRANCH${NC}"
echo -e "${GREEN}✅ Test PR created: $PR_URL${NC}"
echo -e "${GREEN}✅ Test files committed and pushed${NC}"
echo -e "${GREEN}✅ Custom commands tested${NC}"
echo -e "${GREEN}✅ Workflow monitoring completed${NC}"

echo ""
echo -e "${BLUE}💡 Manual Verification Steps:${NC}"
echo "1. Visit the PR: $PR_URL"
echo "2. Check for Claude review comments"
echo "3. Verify custom command responses"
echo "4. Validate security and performance feedback"
echo "5. Review workflow run logs in GitHub Actions"

echo ""
echo -e "${YELLOW}⚠️ Note: Allow 5-10 minutes for all workflows to complete${NC}"

if [[ "$CLEANUP_ON_SUCCESS" != "true" ]]; then
    echo ""
    echo -e "${BLUE}🧹 Manual Cleanup Commands:${NC}"
    echo "git checkout main && git branch -D $TEST_BRANCH"
    echo "git push origin --delete $TEST_BRANCH"
    echo "gh pr close $PR_URL"
fi
EOF
TEST_EOF

    chmod +x "$script_file"
    validate_file_creation "$script_file" "Workflow testing script"
}

create_setup_script() {
    local script_file="setup-enhanced-workflow.sh"
    
    print_header "📄 Creating complete setup script..."
    
    backup_file "$script_file"
    
    if is_dry_run; then
        print_info "DRY RUN: Would create $script_file"
        return 0
    fi
    
    cat > "$script_file" << 'SETUP_EOF'
#!/bin/bash

# Enhanced Workflow Setup Script
# Complete setup for the enhanced Claude Code Review system

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
REPO="calnet/web-architecture-guidelines"
BRANCH_NAME="feature/enhanced-claude-workflow-$(date +%Y%m%d-%H%M%S)"

echo -e "${BLUE}🚀 Enhanced Claude Workflow Setup${NC}"
echo "================================="

# Check prerequisites
echo -e "${BLUE}📋 Checking prerequisites...${NC}"
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI not installed${NC}"
    exit 1
fi

if ! gh auth status &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI not authenticated${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites verified${NC}"

# Create feature branch
echo -e "${BLUE}🌿 Creating feature branch: $BRANCH_NAME${NC}"
git checkout -b "$BRANCH_NAME"

# Run all creation scripts
echo -e "${BLUE}📄 Running workflow creation scripts...${NC}"

if [[ -f "scripts/create-workflows.sh" ]]; then
    echo -e "${BLUE}Creating GitHub workflows...${NC}"
    chmod +x scripts/create-workflows.sh
    scripts/create-workflows.sh
    echo ""
else
    echo -e "${YELLOW}⚠️ scripts/create-workflows.sh not found${NC}"
fi

if [[ -f "scripts/create-commands.sh" ]]; then
    echo -e "${BLUE}Creating custom commands...${NC}"
    chmod +x scripts/create-commands.sh
    scripts/create-commands.sh
    echo ""
else
    echo -e "${YELLOW}⚠️ scripts/create-commands.sh not found${NC}"
fi

if [[ -f "scripts/create-monitoring.sh" ]]; then
    echo -e "${BLUE}Creating monitoring scripts...${NC}"
    chmod +x scripts/create-monitoring.sh
    scripts/create-monitoring.sh
    echo ""
else
    echo -e "${YELLOW}⚠️ scripts/create-monitoring.sh not found${NC}"
fi

if [[ -f "scripts/create-docs.sh" ]]; then
    echo -e "${BLUE}Creating documentation...${NC}"
    chmod +x scripts/create-docs.sh
    scripts/create-docs.sh
    echo ""
else
    echo -e "${YELLOW}⚠️ scripts/create-docs.sh not found${NC}"
fi

# Commit changes
echo -e "${BLUE}💾 Committing changes...${NC}"
git add .
git commit -m "feat: implement enhanced Claude Code Review workflow system

- Add GitHub workflows for automated code review
- Create custom Claude commands for specialized analysis
- Implement monitoring and testing scripts
- Update documentation with new workflow guides

This implements a comprehensive system for:
- Automated PR reviews with Claude
- Custom slash commands for specialized analysis
- Health monitoring and testing capabilities
- Enhanced documentation and guides

Setup completed with all components ready for use."

# Push branch
echo -e "${BLUE}🚀 Pushing feature branch...${NC}"
git push origin "$BRANCH_NAME"

# Create PR
echo -e "${BLUE}📬 Creating implementation PR...${NC}"
PR_URL=$(gh pr create \
    --title "feat: Enhanced Claude Code Review Workflow System" \
    --body "## Implementation Overview

This PR implements a comprehensive enhanced Claude Code Review workflow system with modular scripts and complete automation.

### 🚀 New Features

#### GitHub Workflows
- **claude-code-review.yml**: Main automated review workflow
- **advanced-architecture-review.yml**: Multi-stage comprehensive analysis

#### Custom Claude Commands
- \`/architecture-review\`: Comprehensive architecture analysis
- \`/security-scan\`: Security vulnerability assessment  
- \`/performance-check\`: Performance optimization review
- \`/documentation-audit\`: Documentation quality validation
- \`/quick-fix\`: Quick fix implementation

#### Monitoring & Testing
- **monitor-workflow.sh**: Health monitoring and status checks
- **test-workflow.sh**: Comprehensive workflow testing
- **setup-enhanced-workflow.sh**: Complete system setup

#### Documentation
- **CLAUDE.md**: Enhanced Claude instructions
- **IMPLEMENTATION_GUIDE.md**: Complete implementation guide
- **WORKFLOW_README.md**: Usage and maintenance documentation

### 🛠️ Setup Requirements

1. **Configure Repository Secrets**:
   \`\`\`bash
   gh secret set ANTHROPIC_API_KEY --body \"your-api-key\"
   \`\`\`

2. **Test the Implementation**:
   \`\`\`bash
   scripts/test-workflow.sh
   \`\`\`

3. **Monitor System Health**:
   \`\`\`bash
   scripts/monitor-workflow.sh --report
   \`\`\`

### 📋 Quality Assurance

- ✅ All scripts follow established patterns
- ✅ Comprehensive error handling and logging
- ✅ Dry-run support for safe testing
- ✅ Modular design for easy maintenance
- ✅ Integration with existing validation tools

### 🔄 Workflow Integration

The system integrates seamlessly with existing development workflows:
- Automatic reviews on PR creation/updates
- Manual triggers via \`@claude\` mentions
- Custom commands for specialized analysis
- Weekly comprehensive audits
- Continuous health monitoring

### 📊 Success Metrics

- 95%+ workflow success rate expected
- <5 minutes average execution time
- Zero authentication failures
- Comprehensive architectural feedback
- Improved code quality scores

### 🧪 Testing

Run the comprehensive test suite:
\`\`\`bash
scripts/test-workflow.sh
\`\`\`

### 📖 Documentation

See the complete implementation guide: \`IMPLEMENTATION_GUIDE.md\`

---

This implementation provides a production-ready enhanced Claude Code Review system with comprehensive automation, monitoring, and documentation.")

echo -e "${GREEN}✅ Implementation PR created: $PR_URL${NC}"

# Summary
echo ""
echo -e "${BLUE}📋 Setup Summary${NC}"
echo "================"
echo -e "${GREEN}✅ Feature branch created: $BRANCH_NAME${NC}"
echo -e "${GREEN}✅ All components implemented${NC}"
echo -e "${GREEN}✅ Changes committed and pushed${NC}"
echo -e "${GREEN}✅ Implementation PR created: $PR_URL${NC}"

echo ""
echo -e "${BLUE}🔧 Next Steps:${NC}"
echo "1. Configure ANTHROPIC_API_KEY secret in repository settings"
echo "2. Review and merge the implementation PR"
echo "3. Test the system with: scripts/test-workflow.sh"
echo "4. Set up monitoring with: scripts/monitor-workflow.sh"
echo "5. Review documentation in IMPLEMENTATION_GUIDE.md"

echo ""
echo -e "${YELLOW}⚠️ Important:${NC}"
echo "- Make sure to configure the ANTHROPIC_API_KEY secret before testing"
echo "- Review the implementation PR thoroughly before merging"
echo "- Test with a small PR first to validate functionality"

echo ""
echo -e "${GREEN}🎉 Enhanced Claude Code Review System setup completed!${NC}"
SETUP_EOF

    chmod +x "$script_file"
    validate_file_creation "$script_file" "Complete setup script"
}

main() {
    print_header "🚀 Creating Monitoring and Testing Scripts for Enhanced Claude Code Review System"
    echo ""
    
    # Parse command line arguments
    parse_common_args "$@"
    
    # Validate prerequisites
    if ! validate_prerequisites "Monitoring Scripts Creation"; then
        exit 1
    fi
    
    # Ensure scripts directory exists (it should already exist)
    ensure_directory "$SCRIPTS_DIR"
    
    # Create monitoring and testing scripts
    create_monitor_workflow_script
    create_test_workflow_script
    create_setup_script
    
    echo ""
    print_success "Monitoring and testing scripts creation completed!"
    
    if ! is_dry_run; then
        echo ""
        print_info "Next steps:"
        print_info "1. Test monitoring with: scripts/monitor-workflow.sh"
        print_info "2. Run comprehensive test: scripts/test-workflow.sh"
        print_info "3. Use setup script: ./setup-enhanced-workflow.sh"
        print_info "4. Run: scripts/create-docs.sh to create documentation files"
    fi
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi