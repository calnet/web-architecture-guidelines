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
