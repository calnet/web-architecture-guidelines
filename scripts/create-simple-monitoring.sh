#!/bin/bash

# Simple Monitoring Scripts Creation
# Creates monitoring scripts for the enhanced Claude Code Review system

set -e

# Load common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/workflow-utils.sh"

create_simple_monitor_script() {
    local script_file="scripts/monitor-workflow.sh"
    
    print_header "📄 Creating simple monitoring script..."
    
    backup_file "$script_file"
    
    if is_dry_run; then
        print_info "DRY RUN: Would create $script_file"
        return 0
    fi
    
    cat > "$script_file" << 'EOF'
#!/bin/bash

# Simple Workflow Monitoring Script
# Basic health checks for the enhanced Claude Code Review system

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 Enhanced Workflow Monitoring System${NC}"
echo "====================================="

# Check GitHub CLI
echo -e "${BLUE}🔍 Checking GitHub CLI...${NC}"
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI not installed${NC}"
    exit 1
fi

if ! gh auth status &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI not authenticated${NC}"
    exit 1
fi
echo -e "${GREEN}✅ GitHub CLI ready${NC}"

# Check workflow files
echo -e "${BLUE}📄 Checking workflow files...${NC}"
if [[ -f ".github/workflows/claude-code-review.yml" ]]; then
    echo -e "${GREEN}✅ Main workflow exists${NC}"
else
    echo -e "${RED}❌ Main workflow missing${NC}"
fi

if [[ -f ".github/workflows/advanced-architecture-review.yml" ]]; then
    echo -e "${GREEN}✅ Advanced workflow exists${NC}"
else
    echo -e "${RED}❌ Advanced workflow missing${NC}"
fi

# Check custom commands
echo -e "${BLUE}⚡ Checking custom commands...${NC}"
commands=("architecture-review" "security-scan" "performance-check" "documentation-audit" "quick-fix")
for cmd in "${commands[@]}"; do
    if [[ -f ".claude/commands/${cmd}.md" ]]; then
        echo -e "${GREEN}✅ ${cmd} command available${NC}"
    else
        echo -e "${RED}❌ ${cmd} command missing${NC}"
    fi
done

# Check recent workflow runs
echo -e "${BLUE}📊 Checking recent workflow runs...${NC}"
if command -v gh &> /dev/null && gh auth status &> /dev/null; then
    gh run list --limit 5 --json status,conclusion,workflowName,createdAt | \
    jq -r '.[] | "\(.workflowName): \(.status) (\(.conclusion // "running")) - \(.createdAt)"' | \
    head -5 || echo -e "${YELLOW}⚠️ Could not fetch workflow runs${NC}"
else
    echo -e "${YELLOW}⚠️ GitHub CLI not available for workflow status${NC}"
fi

echo ""
echo -e "${GREEN}✅ Monitoring check completed${NC}"
echo ""
echo "💡 Usage tips:"
echo "  - Run this script regularly to check system health"
echo "  - Use 'gh run list' to see detailed workflow history"
echo "  - Check 'gh secret list' to verify API key configuration"
EOF

    chmod +x "$script_file"
    validate_file_creation "$script_file" "Simple monitoring script"
}

main() {
    print_header "🚀 Creating Simple Monitoring Scripts for Enhanced Claude Code Review System"
    echo ""
    
    # Parse command line arguments
    parse_common_args "$@"
    
    # Validate prerequisites
    if ! validate_prerequisites "Simple Monitoring Scripts Creation"; then
        exit 1
    fi
    
    # Create simple monitoring script
    create_simple_monitor_script
    
    echo ""
    print_success "Simple monitoring script creation completed!"
    
    if ! is_dry_run; then
        echo ""
        print_info "Next steps:"
        print_info "1. Test monitoring with: scripts/monitor-workflow.sh"
        print_info "2. Set up regular monitoring (cron job or manual checks)"
        print_info "3. Configure repository secrets for full functionality"
    fi
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi