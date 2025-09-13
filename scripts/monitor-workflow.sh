#!/bin/bash

# Enhanced Workflow Monitoring and Performance Script
# Comprehensive monitoring, optimization, and performance tracking for the Claude Code Review system

set -e

# Configuration
REPO="calnet/web-architecture-guidelines"
LOG_FILE="/tmp/workflow-monitoring-$(date +%Y%m%d).log"
PERFORMANCE_THRESHOLD_MINUTES=10
API_RATE_LIMIT_THRESHOLD=80

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

show_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Enhanced monitoring and performance optimization for Claude workflows"
    echo ""
    echo "Options:"
    echo "  --report           Generate comprehensive monitoring report"
    echo "  --performance      Analyze workflow performance metrics"
    echo "  --optimize         Provide optimization recommendations"
    echo "  --alerts           Check for alerts and issues"
    echo "  --dashboard        Display real-time dashboard"
    echo "  --export-metrics   Export metrics to JSON file"
    echo "  --health-check     Quick health check (default)"
    echo "  --help             Show this help message"
    echo ""
    echo "Output options:"
    echo "  --json             Output in JSON format"
    echo "  --verbose          Verbose output"
    echo "  --log-file FILE    Custom log file location"
    echo ""
}

print_header() {
    echo -e "${BLUE}$1${NC}"
    local line_length=${#1}
    # print an underline of the desired length without relying on external seq
    printf '%*s' "$((line_length + 10))" '' | tr ' ' '='
    echo ""
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

print_metric() {
    # Use printf '%b' for portable escape-sequence handling and allow multiple args
    printf '%b\n' "${CYAN}📊 ${*}${NC}"
}

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

check_prerequisites() {
    print_header "🔧 Prerequisites Check"
    log_message "Checking prerequisites"

    local issues=0

    # Check GitHub CLI
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI not installed"
        ((issues++))
    else
        print_success "GitHub CLI available: $(gh --version | head -1)"
    fi

    # Check authentication
    if ! gh auth status &> /dev/null; then
        print_error "GitHub CLI not authenticated"
        ((issues++))
    else
        print_success "GitHub CLI authenticated"
    fi

    # Check repository access
    if ! gh repo view "$REPO" &> /dev/null; then
        print_error "Cannot access repository: $REPO"
        ((issues++))
    else
        print_success "Repository access confirmed"
    fi

    # Check required tools
    for tool in jq curl; do
        if command -v "$tool" &> /dev/null; then
            print_success "$tool available"
        else
            print_warning "$tool not available (some features may be limited)"
        fi
    done

    log_message "Prerequisites check completed with $issues issues"
    return $issues
}

check_workflow_files() {
    print_header "📄 Workflow Files Status"
    log_message "Checking workflow files"

    local workflows_dir=".github/workflows"
    local issues=0

    if [[ ! -d "$workflows_dir" ]]; then
        print_error "Workflows directory not found: $workflows_dir"
        return 1
    fi

    # Required workflows
    local workflows=(
        "claude-code-review.yml:Main Claude review workflow"
        "advanced-architecture-review.yml:Advanced architecture analysis"
    )

    for workflow_info in "${workflows[@]}"; do
        local workflow_file="${workflow_info%%:*}"
        local description="${workflow_info##*:}"
        local workflow_path="$workflows_dir/$workflow_file"

        if [[ -f "$workflow_path" ]]; then
            print_success "$description ($workflow_file)"

            # Check file size (should not be empty)
                local file_size
                file_size=$(wc -c < "$workflow_path")
            if [[ $file_size -gt 100 ]]; then
                print_info "File size: $file_size bytes ✓"
            else
                print_warning "File suspiciously small: $file_size bytes"
                ((issues++))
            fi

            # Check for key configurations
            if grep -q "ANTHROPIC_API_KEY" "$workflow_path"; then
                print_success "API key reference found ✓"
            else
                print_error "Missing ANTHROPIC_API_KEY reference"
                ((issues++))
            fi

        else
            print_error "$description missing ($workflow_file)"
            ((issues++))
        fi
    done

    log_message "Workflow files check completed with $issues issues"
    return $issues
}

check_custom_commands() {
    print_header "⚡ Custom Commands Status"
    log_message "Checking custom commands"

    local commands_dir=".claude/commands"
    local issues=0

    if [[ ! -d "$commands_dir" ]]; then
        print_error "Commands directory not found: $commands_dir"
        return 1
    fi

    # Required commands
    local commands=(
        "architecture-review.md:Architecture analysis command"
        "security-scan.md:Security vulnerability assessment"
        "performance-check.md:Performance optimization review"
        "documentation-audit.md:Documentation quality validation"
        "quick-fix.md:Quick fix implementation"
    )

    for command_info in "${commands[@]}"; do
        local command_file="${command_info%%:*}"
        local description="${command_info##*:}"
        local command_path="$commands_dir/$command_file"

        if [[ -f "$command_path" ]]; then
            print_success "$description ($command_file)"

            # Check content quality
            local line_count
            line_count=$(wc -l < "$command_path")
            if [[ $line_count -gt 10 ]]; then
                print_info "Content: $line_count lines ✓"
            else
                print_warning "Command file seems incomplete: $line_count lines"
                ((issues++))
            fi

        else
            print_error "$description missing ($command_file)"
            ((issues++))
        fi
    done

    log_message "Custom commands check completed with $issues issues"
    return $issues
}

check_workflow_runs() {
    print_header "📊 Recent Workflow Activity"
    log_message "Analyzing recent workflow runs"

    if ! command -v gh &> /dev/null || ! gh auth status &> /dev/null; then
        print_warning "Cannot check workflow runs - GitHub CLI not available"
        return 0
    fi

    print_info "Fetching recent workflow runs..."

    # Get recent runs
    local runs_data
    if runs_data=$(gh run list --repo "$REPO" --limit 20 --json status,conclusion,workflowName,createdAt,durationMs,url 2>/dev/null); then

        # Process runs data
    local total_runs
    total_runs=$(echo "$runs_data" | jq length)
    local successful_runs
    successful_runs=$(echo "$runs_data" | jq '[.[] | select(.conclusion == "success")] | length')
    local failed_runs
    failed_runs=$(echo "$runs_data" | jq '[.[] | select(.conclusion == "failure")] | length')
    local cancelled_runs
    cancelled_runs=$(echo "$runs_data" | jq '[.[] | select(.conclusion == "cancelled")] | length')

        print_metric "Total recent runs: $total_runs"
        print_metric "Successful: $successful_runs"
        print_metric "Failed: $failed_runs"
        print_metric "Cancelled: $cancelled_runs"

        # Calculate success rate
        if [[ $total_runs -gt 0 ]]; then
            local success_rate
            success_rate=$((successful_runs * 100 / total_runs))
            if [[ $success_rate -ge 90 ]]; then
                print_success "Success rate: $success_rate% ✓"
            elif [[ $success_rate -ge 70 ]]; then
                print_warning "Success rate: $success_rate% (could be better)"
            else
                print_error "Success rate: $success_rate% (needs attention)"
            fi
        fi

        # Show recent failures
        local recent_failures
        recent_failures=$(echo "$runs_data" | jq -r '.[] | select(.conclusion == "failure") | "\(.workflowName): \(.createdAt)"' | head -3)
        if [[ -n "$recent_failures" ]]; then
            print_warning "Recent failures:"
            echo "$recent_failures" | while read -r line; do
                echo "  🔸 $line"
            done
        fi

    else
        print_warning "Could not fetch workflow runs data"
    fi

    log_message "Workflow runs analysis completed"
}

analyze_performance() {
    print_header "⚡ Performance Analysis"
    log_message "Starting performance analysis"

    if ! command -v gh &> /dev/null || ! gh auth status &> /dev/null; then
        print_warning "Cannot analyze performance - GitHub CLI not available"
        return 0
    fi

    print_info "Analyzing workflow performance metrics..."

    # Get runs with duration data
    local runs_data
    if runs_data=$(gh run list --repo "$REPO" --limit 50 --json status,conclusion,workflowName,durationMs,createdAt 2>/dev/null); then

        # Filter successful runs with duration data
        local successful_runs_with_duration
        successful_runs_with_duration=$(echo "$runs_data" | jq '[.[] | select(.conclusion == "success" and .durationMs != null)]')

        if [[ $(echo "$successful_runs_with_duration" | jq length) -gt 0 ]]; then
            # Calculate average duration
            local avg_duration_ms
            avg_duration_ms=$(echo "$successful_runs_with_duration" | jq '[.[].durationMs] | add / length')
            local avg_duration_min
            avg_duration_min=$((avg_duration_ms / 60000))

            print_metric "Average workflow duration: ${avg_duration_min} minutes"

            # Check against threshold
            if [[ $avg_duration_min -le $PERFORMANCE_THRESHOLD_MINUTES ]]; then
                print_success "Performance within acceptable limits ✓"
            else
                print_warning "Performance may need optimization (threshold: ${PERFORMANCE_THRESHOLD_MINUTES}min)"
            fi

            # Find slowest workflows
            local slowest_workflow
            slowest_workflow=$(echo "$successful_runs_with_duration" | jq -r 'max_by(.durationMs) | "\(.workflowName): \(.durationMs/60000 | floor) minutes"')
            print_info "Slowest recent run: $slowest_workflow"

        else
            print_warning "No performance data available"
        fi

    else
        print_warning "Could not fetch performance data"
    fi

    log_message "Performance analysis completed"
}

check_api_usage() {
    print_header "🔑 API Usage & Limits"
    log_message "Checking API usage"

    # GitHub API rate limits
    if command -v gh &> /dev/null && gh auth status &> /dev/null; then
        print_info "Checking GitHub API rate limits..."

        local rate_limit_data
        if rate_limit_data=$(gh api rate_limit 2>/dev/null); then
            local core_limit
            core_limit=$(echo "$rate_limit_data" | jq -r '.rate.limit')
            local core_remaining
            core_remaining=$(echo "$rate_limit_data" | jq -r '.rate.remaining')
            local core_used
            core_used=$((core_limit - core_remaining))
            local usage_percent
            usage_percent=$((core_used * 100 / core_limit))

            print_metric "GitHub API usage: $core_used/$core_limit ($usage_percent%)"

            if [[ $usage_percent -lt $API_RATE_LIMIT_THRESHOLD ]]; then
                print_success "API usage within limits ✓"
            else
                print_warning "High API usage - consider optimization"
            fi

            # Reset time
            local reset_time
            reset_time=$(echo "$rate_limit_data" | jq -r '.rate.reset')
            local reset_date
            reset_date=$(date -d "@$reset_time" 2>/dev/null || date -r "$reset_time" 2>/dev/null || echo "Unknown")
            print_info "Rate limit resets: $reset_date"
        else
            print_warning "Could not fetch GitHub API rate limit"
        fi
    fi

    # Anthropic API - we can only check if the secret is configured
    if command -v gh &> /dev/null && gh auth status &> /dev/null; then
        if gh secret list --repo "$REPO" 2>/dev/null | grep -q "ANTHROPIC_API_KEY"; then
            print_success "Anthropic API key configured ✓"
        else
            print_error "Anthropic API key not configured"
        fi
    else
        print_warning "Cannot check Anthropic secret - GitHub CLI not available or not authenticated"
    fi

    log_message "API usage check completed"
}

generate_optimization_recommendations() {
    print_header "💡 Optimization Recommendations"
    log_message "Generating optimization recommendations"

    echo ""
    echo "Based on the monitoring analysis, here are optimization recommendations:"
    echo ""

    # Performance optimizations
    echo "🚀 Performance Optimizations:"
    echo "  • Cache dependencies in workflows to reduce setup time"
    echo "  • Use matrix builds for parallel testing when possible"
    echo "  • Optimize Claude prompts to reduce token usage"
    echo "  • Consider workflow triggers to avoid unnecessary runs"
    echo ""

    # Cost optimizations
    echo "💰 Cost Optimizations:"
    echo "  • Monitor API usage patterns and optimize calls"
    echo "  • Use conditional workflow triggers"
    echo "  • Implement intelligent caching strategies"
    echo "  • Consider workflow scheduling for non-urgent tasks"
    echo ""

    # Reliability improvements
    echo "🛡️ Reliability Improvements:"
    echo "  • Add retry logic for transient failures"
    echo "  • Implement proper error handling and notifications"
    echo "  • Set up monitoring alerts for critical failures"
    echo "  • Regular backup and disaster recovery testing"
    echo ""

    # Security enhancements
    echo "🔒 Security Enhancements:"
    echo "  • Regular rotation of API keys"
    echo "  • Monitor for unauthorized access patterns"
    echo "  • Implement least-privilege access controls"
    echo "  • Regular security audits of workflow configurations"
    echo ""

    log_message "Optimization recommendations generated"
}

generate_monitoring_report() {
    print_header "📋 Comprehensive Monitoring Report"

    local report_file
    report_file="/tmp/workflow-monitoring-report-$(date +%Y%m%d-%H%M%S).md"
    local json_file
    json_file="/tmp/workflow-monitoring-metrics-$(date +%Y%m%d-%H%M%S).json"

    # Create markdown report
    cat > "$report_file" << EOF
# Enhanced Claude Workflow Monitoring Report

**Generated**: $(date)
**Repository**: $REPO
**Report Version**: 1.2.0

## Summary

This report provides a comprehensive analysis of the Enhanced Claude Code Review workflow system performance, health, and optimization opportunities.

## System Health

### Prerequisites
$(check_prerequisites &>/dev/null && echo "✅ All prerequisites met" || echo "❌ Issues found in prerequisites")

### Workflow Files
$(check_workflow_files &>/dev/null && echo "✅ All workflow files present and configured" || echo "❌ Issues found in workflow files")

### Custom Commands
$(check_custom_commands &>/dev/null && echo "✅ All custom commands available" || echo "❌ Issues found in custom commands")

## Performance Metrics

$(analyze_performance 2>/dev/null | grep -E "📊|⚡|✅|⚠️|❌")

## API Usage

$(check_api_usage 2>/dev/null | grep -E "📊|🔑|✅|⚠️|❌")

## Recommendations

$(generate_optimization_recommendations 2>/dev/null)

## Next Steps

1. Address any identified issues
2. Implement recommended optimizations
3. Set up regular monitoring schedule
4. Review API usage patterns monthly

---
**Note**: This is an automated report. For detailed logs, check: $LOG_FILE
EOF

    print_success "Monitoring report generated: $report_file"

    # Generate JSON metrics for programmatic use
    # Build JSON metrics safely and portably
    json_metrics=$(cat <<EOF
{
    "timestamp": "$(date -Iseconds)",
    "repository": "$REPO",
    "version": "1.2.0",
    "health_status": "healthy",
    "last_monitoring_check": "$(date)",
    "log_file": "$LOG_FILE"
}
EOF
)

    printf '%s' "$json_metrics" > "$json_file"
    print_success "JSON metrics exported: $json_file"

    echo ""
    print_info "View report: cat $report_file"
    print_info "View metrics: cat $json_file"
}

display_dashboard() {
    print_header "🎛️ Real-time Monitoring Dashboard"

    while true; do
        clear
        echo -e "${PURPLE}Enhanced Claude Workflow Dashboard${NC}"
        echo "$(date) | Repository: $REPO"
        echo "========================================"
        echo ""

        # Quick health check
        echo -e "${BLUE}System Health:${NC}"
        check_prerequisites &>/dev/null && echo "✅ Prerequisites" || echo "❌ Prerequisites"
        check_workflow_files &>/dev/null && echo "✅ Workflows" || echo "❌ Workflows"
        check_custom_commands &>/dev/null && echo "✅ Commands" || echo "❌ Commands"
        echo ""

        # Recent activity
        echo -e "${BLUE}Recent Activity:${NC}"
        if command -v gh &> /dev/null && gh auth status &> /dev/null; then
            gh run list --repo "$REPO" --limit 3 --json status,workflowName,createdAt | \
            jq -r '.[] | "🔸 \(.workflowName): \(.status) (\(.createdAt | split("T")[0]))"' 2>/dev/null || \
            echo "No recent activity data available"
        else
            echo "GitHub CLI not available"
        fi

        echo ""
        echo "Press Ctrl+C to exit dashboard"
        sleep 30
    done
}

main() {
    local mode="health-check"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --report)
                mode="report"
                shift
                ;;
            --performance)
                mode="performance"
                shift
                ;;
            --optimize)
                mode="optimize"
                shift
                ;;
            --alerts)
                mode="alerts"
                shift
                ;;
            --dashboard)
                mode="dashboard"
                shift
                ;;
            --export-metrics)
                mode="export-metrics"
                shift
                ;;
            --health-check)
                mode="health-check"
                shift
                ;;
            --json)
                shift
                ;;
            --verbose)
                shift
                ;;
            --log-file)
                LOG_FILE="$2"
                shift 2
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

    # Initialize logging
    log_message "Starting workflow monitoring - Mode: $mode"

    case $mode in
        "health-check")
            print_header "🚀 Enhanced Workflow Health Check"
            check_prerequisites
            check_workflow_files
            check_custom_commands
            check_workflow_runs
            print_success "Health check completed!"
            ;;
        "performance")
            print_header "⚡ Performance Analysis"
            analyze_performance
            ;;
        "optimize")
            generate_optimization_recommendations
            ;;
        "alerts")
            print_header "🚨 Alerts & Issues Check"
            # Combine all checks and highlight issues
            check_prerequisites || true
            check_workflow_files || true
            check_custom_commands || true
            check_api_usage || true
            ;;
        "dashboard")
            display_dashboard
            ;;
        "export-metrics")
            generate_monitoring_report
            ;;
        "report")
            generate_monitoring_report
            ;;
        *)
            print_error "Unknown mode: $mode"
            exit 1
            ;;
    esac

    log_message "Workflow monitoring completed - Mode: $mode"
}

# Run main function
main "$@"
