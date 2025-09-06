#!/bin/bash

# Documentation Creation Script
# Creates documentation files for the enhanced Claude Code Review system

set -e

# Load common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/workflow-utils.sh"

show_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Creates documentation files for the enhanced Claude Code Review system."
    echo ""
    show_common_help
    echo "Created documentation:"
    echo "  - CLAUDE.md: Enhanced Claude instructions"
    echo "  - IMPLEMENTATION_GUIDE.md: Complete implementation guide"
    echo "  - WORKFLOW_README.md: Usage and maintenance documentation"
    echo ""
}

create_enhanced_claude_md() {
    local claude_file="CLAUDE.md"
    
    print_header "📄 Creating enhanced CLAUDE.md..."
    
    backup_file "$claude_file"
    
    if is_dry_run; then
        print_info "DRY RUN: Would update $claude_file"
        return 0
    fi
    
    # Read existing CLAUDE.md and enhance it
    local existing_content=""
    if [[ -f "$claude_file" ]]; then
        existing_content=$(cat "$claude_file")
    fi
    
    cat > "$claude_file" << 'EOF'
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a documentation-only repository containing web application architecture guidelines optimized for AI agents and development teams. The repository focuses on providing comprehensive instruction sets for various AI agents and documentation templates for building high-quality web applications.

## Enhanced Claude Code Review System

This repository includes an advanced Claude Code Review workflow system with the following components:

### GitHub Workflows
- **claude-code-review.yml**: Main automated review workflow
- **advanced-architecture-review.yml**: Multi-stage comprehensive analysis

### Custom Commands Available
When reviewing code or responding to comments, you can use these specialized commands:

#### `/architecture-review`
Perform comprehensive architectural analysis focusing on:
- Clean Architecture principles adherence
- System design patterns validation
- Component interaction assessment
- Code organization review
- Quality attributes evaluation

#### `/security-scan`
Conduct thorough security vulnerability assessment covering:
- OWASP Top 10 compliance
- Security controls assessment
- Authentication & authorization review
- Data protection validation
- Infrastructure security analysis

#### `/performance-check`
Analyze application performance characteristics including:
- Frontend performance (Core Web Vitals)
- Backend performance (API, database)
- Infrastructure performance
- Monitoring & observability setup

#### `/documentation-audit`
Evaluate documentation quality and completeness:
- Template compliance checking
- Content quality assessment
- Accessibility & usability review
- Maintenance & currency validation

#### `/quick-fix`
Provide immediate, actionable fixes for:
- Code quality issues
- Documentation corrections
- Configuration problems
- Minor security & performance improvements

### Review Standards and Guidelines

When conducting code reviews, follow these enhanced standards:

#### 1. Security by Design
- **Authentication**: Verify robust authentication mechanisms
- **Authorization**: Ensure proper access controls
- **Input Validation**: Check for comprehensive input sanitization
- **Data Protection**: Validate encryption and secure data handling
- **OWASP Compliance**: Assess against OWASP Top 10 vulnerabilities

#### 2. Performance First
- **Core Web Vitals**: Evaluate LCP, FID, and CLS metrics
- **API Performance**: Check response times and throughput
- **Database Optimization**: Review query efficiency and indexing
- **Caching Strategy**: Validate caching implementation
- **Resource Optimization**: Assess bundle sizes and loading strategies

#### 3. Developer Experience
- **Code Clarity**: Ensure readable and maintainable code
- **Documentation**: Verify comprehensive and current documentation
- **Testing**: Check test coverage and quality
- **Tooling**: Validate development tool configuration
- **Error Handling**: Review error handling and logging

#### 4. Maintainability
- **Architecture Patterns**: Ensure consistent pattern usage
- **Code Organization**: Validate logical structure and separation
- **Dependency Management**: Check for appropriate dependencies
- **Technical Debt**: Identify and prioritize debt reduction
- **Refactoring Opportunities**: Suggest improvements

#### 5. Accessibility
- **WCAG Compliance**: Verify accessibility standards adherence
- **Semantic HTML**: Check for proper semantic structure
- **Keyboard Navigation**: Ensure keyboard accessibility
- **Screen Reader Support**: Validate assistive technology compatibility
- **Color Contrast**: Check visual accessibility requirements

#### 6. Living Documentation
- **Architecture Decision Records**: Validate ADR completeness
- **API Documentation**: Check OpenAPI/Swagger accuracy
- **User Guides**: Ensure user-facing documentation currency
- **Development Guides**: Verify setup and contribution guides

## Repository Structure

```
docs/
├── ai-agents/                          # AI agent-specific instructions
│   ├── claude/                         # Claude-specific instructions (V1 and V2)
│   ├── chatgpt-architecture-instructions.md
│   ├── copilot-architecture-instructions.md
│   ├── gemini-architecture-instructions.md
│   └── anthropic-api-architecture-instructions.md
├── external-documentation-links.md     # Curated external resources
├── project-integration-guide.md        # How to extend these guidelines
└── templates/                          # Documentation templates organized by category
    ├── README.md                       # Template index and usage guide
    ├── architecture/                   # ADRs and system documentation
    ├── api/                           # API specification templates
    ├── user-guides/                   # User and admin manual templates
    └── development/                   # Setup guides and coding standards

.github/workflows/                      # Enhanced Claude workflows
├── claude-code-review.yml             # Main review workflow
└── advanced-architecture-review.yml   # Advanced multi-stage workflow

.claude/commands/                       # Custom Claude commands
├── architecture-review.md             # Architecture analysis command
├── security-scan.md                   # Security assessment command
├── performance-check.md               # Performance optimization command
├── documentation-audit.md             # Documentation review command
└── quick-fix.md                       # Quick fix command

scripts/                               # Workflow management scripts
├── create-workflows.sh                # Workflow creation script
├── create-commands.sh                 # Commands creation script
├── create-monitoring.sh               # Monitoring scripts creation
├── create-docs.sh                     # Documentation creation script
├── monitor-workflow.sh                # Health monitoring script
└── test-workflow.sh                   # Comprehensive testing script
```

## Core Architecture

This repository follows a documentation-first approach with these key principles:

### Content Organization
- **Separation of concerns**: AI agent instructions are separate from generic templates
- **Versioning**: Multiple versions of instructions (e.g., Claude V1/V2) for different complexity needs
- **Categorization**: Templates organized by functional area (architecture, API, user guides, development)
- **Modularity**: Workflow system broken into focused, manageable components

### Quality Assurance
- **GitHub Actions workflow** (`.github/workflows/validate-docs.yml`) provides automated validation
- **Enhanced Claude workflows** provide intelligent code review and analysis
- **Link checking**: Validates all markdown links are accessible
- **Markdown linting**: Ensures consistent formatting and style
- **Structure validation**: Verifies required directories and files exist
- **Cross-reference validation**: Ensures internal links and references are accurate

### Workflow Integration
- **Automated Reviews**: Every PR receives intelligent Claude analysis
- **Custom Commands**: Specialized analysis through slash commands
- **Health Monitoring**: Continuous system health and performance tracking
- **Comprehensive Testing**: Automated validation of workflow functionality

## Common Development Tasks

### Documentation Validation
The repository uses GitHub Actions for automated validation. Enhanced workflows provide:

```bash
# Automated validation runs on every PR
# Manual health check:
scripts/monitor-workflow.sh --report

# Comprehensive testing:
scripts/test-workflow.sh
```

### Enhanced Code Review Process
1. **Automatic Triggers**: Workflows activate on PR creation/updates
2. **Manual Triggers**: Use `@claude` mentions for on-demand reviews
3. **Specialized Analysis**: Leverage custom commands for focused reviews
4. **Continuous Monitoring**: Health checks ensure system reliability

### Content Updates
When updating documentation:

1. **Maintain structure**: Follow the established directory organization
2. **Update cross-references**: Ensure links between documents remain valid
3. **Follow semantic versioning**: Use conventional commits for changes
4. **Test externally**: Verify external links in `external-documentation-links.md` are still valid
5. **Validate templates**: Run template compliance checks after changes

### Commit Conventions
The repository follows conventional commit format:
- `feat`: New guidelines or significant enhancements
- `fix`: Bug fixes and minor improvements  
- `docs`: Documentation updates
- `ci`: GitHub workflow changes
- `refactor`: Code/structure improvements without functionality changes
- `test`: Test additions or modifications

Example: `feat: enhance documentation templates and integration guide with structured categories`

## File Modification Guidelines

### When working with AI agent instructions:
- **Maintain consistency**: Keep instruction format similar across different agents
- **Version appropriately**: Create new versions for major changes rather than breaking existing ones
- **Cross-reference**: Update the main README.md when adding new agent instructions
- **Test commands**: Validate custom commands work as expected

### When working with templates:
- **Preserve structure**: Maintain the placeholder text and example format
- **Update index**: Modify `docs/templates/README.md` when adding new templates
- **Keep scalable**: Ensure templates work for both startup and enterprise projects
- **Validate compliance**: Run template validation scripts after changes

### When updating external links:
- **Verify accessibility**: Test all links before committing
- **Maintain categorization**: Follow the established organization in `external-documentation-links.md`
- **Add context**: Include brief descriptions for why resources are valuable
- **Monitor regularly**: Set up automated link checking where possible

### When modifying workflows:
- **Test thoroughly**: Use `scripts/test-workflow.sh` for comprehensive validation
- **Monitor health**: Check system health with `scripts/monitor-workflow.sh`
- **Document changes**: Update implementation guides and README files
- **Validate secrets**: Ensure required API keys and secrets are configured

## Important Files

- **README.md**: Main entry point explaining repository purpose and usage
- **CLAUDE.md**: This file - enhanced instructions for Claude Code reviews
- **docs/project-integration-guide.md**: Critical for understanding how to extend guidelines
- **docs/external-documentation-links.md**: Curated list of external resources requiring regular maintenance
- **git-commands-and-setup.md**: Repository setup and maintenance procedures
- **IMPLEMENTATION_GUIDE.md**: Complete guide for the enhanced workflow system
- **WORKFLOW_README.md**: Usage and maintenance documentation for workflows

## Quality Standards

- **No build/test commands**: This is a documentation-only repository
- **Markdown consistency**: All documentation uses GitHub-flavored markdown
- **Link integrity**: All internal and external links must be valid
- **Professional formatting**: Templates are ready for immediate professional use
- **Comprehensive coverage**: Instructions cover all major aspects of web application architecture
- **Accessibility compliance**: Documentation follows WCAG 2.1 AA guidelines
- **Version control**: Proper branching and commit message conventions

## Enhanced Workflow Monitoring

### Health Checks
- **Daily**: Run `scripts/monitor-workflow.sh` for system health
- **Weekly**: Review workflow performance and success rates
- **Monthly**: Comprehensive audit and optimization review

### Performance Metrics
- **Success Rate**: Target >95% workflow success rate
- **Response Time**: Target <5 minutes average execution time
- **API Limits**: Monitor GitHub and Anthropic API usage
- **Error Rates**: Track and investigate workflow failures

### Troubleshooting
- **Authentication Issues**: Verify ANTHROPIC_API_KEY secret configuration
- **Workflow Failures**: Check logs in GitHub Actions and run health checks
- **Command Issues**: Validate custom command files exist and are properly formatted
- **Performance Problems**: Monitor API rate limits and optimize prompts

## Repository Maintenance

- **Monthly**: Review and update external documentation links
- **Quarterly**: Review AI agent instructions for new capabilities  
- **Bi-annually**: Comprehensive template review and updates
- **Annually**: Major version review and workflow optimization

This repository serves as a comprehensive foundation for web application architecture guidance that evolves with industry best practices and AI agent capabilities, enhanced with intelligent automation and monitoring.
EOF

    validate_file_creation "$claude_file" "Enhanced CLAUDE.md"
}

create_implementation_guide() {
    local guide_file="IMPLEMENTATION_GUIDE.md"
    
    print_header "📄 Creating implementation guide..."
    
    backup_file "$guide_file"
    
    if is_dry_run; then
        print_info "DRY RUN: Would create $guide_file"
        return 0
    fi
    
    cat > "$guide_file" << 'EOF'
# Enhanced Claude Code Review Workflow Implementation Guide

## Overview

This guide provides complete instructions for implementing and using the enhanced Claude Code Review workflow system. The system includes automated workflows, custom commands, monitoring tools, and comprehensive documentation.

## Architecture

The enhanced workflow system consists of four main components:

### 1. GitHub Workflows
- **claude-code-review.yml**: Main automated review workflow
- **advanced-architecture-review.yml**: Advanced multi-stage analysis workflow

### 2. Custom Claude Commands
- **architecture-review**: Comprehensive architecture analysis
- **security-scan**: Security vulnerability assessment
- **performance-check**: Performance optimization review
- **documentation-audit**: Documentation quality validation
- **quick-fix**: Quick fix implementation

### 3. Monitoring & Testing
- **monitor-workflow.sh**: Health monitoring and status checks
- **test-workflow.sh**: Comprehensive workflow testing
- **setup-enhanced-workflow.sh**: Complete system setup

### 4. Enhanced Documentation
- **CLAUDE.md**: Enhanced Claude instructions
- **IMPLEMENTATION_GUIDE.md**: This comprehensive guide
- **WORKFLOW_README.md**: Usage and maintenance documentation

## Installation

### Prerequisites

1. **GitHub CLI**: Install and authenticate GitHub CLI
   ```bash
   # Install GitHub CLI (if not already installed)
   # macOS: brew install gh
   # Ubuntu: apt install gh
   # Windows: winget install GitHub.cli
   
   # Authenticate
   gh auth login
   ```

2. **Repository Access**: Ensure you have admin access to configure secrets

3. **Anthropic API Key**: Obtain an API key from Anthropic

### Quick Setup

Use the automated setup script for complete installation:

```bash
# Clone the repository (if not already done)
git clone https://github.com/calnet/web-architecture-guidelines.git
cd web-architecture-guidelines

# Run the complete setup
./setup-enhanced-workflow.sh
```

### Manual Setup

If you prefer manual installation or need to set up components individually:

#### Step 1: Create GitHub Workflows
```bash
scripts/create-workflows.sh
```

#### Step 2: Create Custom Commands
```bash
scripts/create-commands.sh
```

#### Step 3: Create Monitoring Scripts
```bash
scripts/create-monitoring.sh
```

#### Step 4: Create Documentation
```bash
scripts/create-docs.sh
```

#### Step 5: Configure Repository Secrets
```bash
# Set the Anthropic API key
gh secret set ANTHROPIC_API_KEY --body "your-anthropic-api-key-here"

# Verify secret is set
gh secret list
```

### Verification

Test the complete installation:

```bash
# Run comprehensive test
scripts/test-workflow.sh

# Check system health
scripts/monitor-workflow.sh --report
```

## Configuration

### Repository Secrets

The system requires the following repository secrets:

| Secret | Purpose | Required |
|--------|---------|----------|
| `ANTHROPIC_API_KEY` | Claude API access | Yes |
| `GITHUB_TOKEN` | Automatic (GitHub provides) | Yes |

Configure secrets via GitHub UI or CLI:

```bash
# Via GitHub CLI
gh secret set ANTHROPIC_API_KEY --body "your-api-key"

# Via GitHub UI
# Settings > Secrets and variables > Actions > New repository secret
```

### Workflow Configuration

Workflows are configured through YAML files in `.github/workflows/`:

#### Main Workflow (`claude-code-review.yml`)
- **Triggers**: PR creation, updates, issue comments with `@claude`
- **Model**: claude-3-5-sonnet-20241022
- **Max Tokens**: 4000 for PR reviews, 8000 for comprehensive audits
- **Features**: Custom command detection, security validation, performance checks

#### Advanced Workflow (`advanced-architecture-review.yml`)  
- **Triggers**: PRs to main branch, manual dispatch
- **Strategy**: Matrix build for parallel analysis
- **Focus Areas**: Architecture, security, performance, documentation, accessibility
- **Integration**: Cross-reference validation and integration assessment

### Custom Commands Configuration

Commands are defined in `.claude/commands/` and can be customized by editing the markdown files:

```bash
# Edit command behavior
vi .claude/commands/security-scan.md

# Test command after changes
gh pr comment [PR-URL] --body "/security-scan Test the updated command"
```

## Usage

### Automatic Reviews

The system automatically reviews code on:
- Pull request creation
- Pull request updates  
- Push to watched branches

No manual intervention required - Claude will post review comments automatically.

### Manual Reviews

Trigger reviews manually by commenting on PRs or issues:

```bash
# General review
@claude Please review this PR

# With specific focus
@claude Please review this PR focusing on security
```

### Custom Commands

Use specialized commands for focused analysis:

#### Architecture Review
```bash
/architecture-review "Review the new user authentication module"
```

#### Security Scan
```bash  
/security-scan "Check the API endpoints for OWASP compliance"
```

#### Performance Check
```bash
/performance-check "Analyze database query optimizations"
```

#### Documentation Audit
```bash
/documentation-audit "Review API documentation completeness"
```

#### Quick Fix
```bash
/quick-fix "Fix formatting and style issues in user service"
```

### Scheduled Reviews

The system performs weekly comprehensive audits:
- **Schedule**: Mondays at 9 AM UTC
- **Scope**: Full codebase analysis
- **Output**: Detailed issue with findings and recommendations
- **Integration**: Creates GitHub issues for tracking

## Monitoring

### Health Checks

Monitor system health regularly:

```bash
# Basic health check
scripts/monitor-workflow.sh

# Detailed health report
scripts/monitor-workflow.sh --report
```

### Performance Metrics

The monitoring system tracks:
- **Workflow Success Rate**: Target >95%
- **Average Execution Time**: Target <5 minutes
- **API Rate Limits**: GitHub and Anthropic usage
- **Failure Patterns**: Analysis of common issues

### Alerts and Notifications

Set up monitoring alerts:

```bash
# Add to crontab for regular monitoring
crontab -e
# Add: 0 */6 * * * /path/to/scripts/monitor-workflow.sh --report
```

## Troubleshooting

### Common Issues

#### Authentication Failures
```bash
# Check GitHub CLI auth
gh auth status

# Re-authenticate if needed
gh auth login

# Verify API key secret
gh secret list | grep ANTHROPIC_API_KEY
```

#### Workflow Not Triggering
```bash
# Check workflow files exist
ls -la .github/workflows/

# Verify workflow syntax
gh workflow list

# Check recent runs
gh run list --limit 10
```

#### Custom Commands Not Working
```bash
# Verify command files exist
ls -la .claude/commands/

# Check command file format
cat .claude/commands/architecture-review.md

# Test with manual trigger
gh pr comment [PR-URL] --body "@claude /architecture-review test"
```

#### Poor Performance
```bash
# Check API rate limits
gh api rate_limit

# Monitor workflow duration
scripts/monitor-workflow.sh

# Review workflow logs
gh run view [RUN-ID] --log
```

### Debugging

Enable detailed logging:

```bash
# View workflow logs
gh run list --limit 5
gh run view [RUN-ID] --log

# Check system health
scripts/monitor-workflow.sh --report

# Run comprehensive test
scripts/test-workflow.sh
```

### Support

For additional support:
1. Check the monitoring logs: `workflow-monitor.log`
2. Review GitHub Actions logs
3. Validate configuration with health checks
4. Test with minimal PR to isolate issues

## Customization

### Workflow Customization

Modify workflows in `.github/workflows/`:

```yaml
# Adjust model or parameters
- name: Enhanced Claude Code Review
  uses: anthropics/claude-code-action@v1
  with:
    model: 'claude-3-5-sonnet-20241022'  # Change model
    max-tokens: 4000                      # Adjust token limit
```

### Command Customization

Edit command files in `.claude/commands/`:

```markdown
# Modify command behavior
## Purpose
[Updated purpose description]

## Command Behavior
[Updated behavior specification]
```

### Monitoring Customization

Adjust monitoring thresholds in `scripts/monitor-workflow.sh`:

```bash
# Change failure rate threshold
if [[ $failed_count -gt 3 ]]; then  # Adjust from 3 to your preference
```

## Best Practices

### Development Workflow
1. **Create feature branches** for all changes
2. **Use conventional commits** for clear history
3. **Test changes** with dry-run mode first
4. **Monitor health** after deployments
5. **Review feedback** and iterate on prompts

### Security
1. **Protect API keys** - never commit secrets
2. **Limit access** to repository secrets
3. **Monitor usage** to detect anomalies
4. **Regular rotation** of API keys
5. **Audit permissions** regularly

### Performance
1. **Monitor execution times** and optimize prompts
2. **Manage API limits** to avoid rate limiting
3. **Cache results** where appropriate
4. **Optimize workflow triggers** to reduce unnecessary runs
5. **Review costs** regularly

### Maintenance
1. **Update dependencies** regularly
2. **Review and update prompts** based on feedback
3. **Monitor external changes** to APIs and actions
4. **Backup configurations** before changes
5. **Document customizations** for team knowledge

## Integration with Development Workflow

### For Developers
- **Automatic reviews** on every PR with actionable feedback
- **Custom commands** for specialized analysis needs
- **Integration** with existing GitHub workflow
- **Clear feedback** with specific examples and recommendations

### For Architects
- **Consistent enforcement** of architecture principles
- **Automated compliance** checking against guidelines
- **Data-driven insights** into code quality trends
- **Proactive identification** of technical debt

### For DevOps
- **Automated quality gates** in CI/CD pipeline
- **Performance monitoring** and alerting
- **Security validation** as part of deployment process
- **Comprehensive audit trails** for compliance

## Success Metrics

Track these metrics to measure system effectiveness:

### Quality Metrics
- **Issue Detection Rate**: Percentage of real issues identified
- **False Positive Rate**: Percentage of incorrect flagged issues
- **Resolution Time**: Time to address identified issues
- **Developer Satisfaction**: Team feedback on review quality

### Performance Metrics
- **Workflow Success Rate**: >95% target
- **Average Response Time**: <5 minutes target
- **API Usage Efficiency**: Cost per review analysis
- **System Uptime**: >99% availability target

### Adoption Metrics
- **Command Usage**: Frequency of custom commands
- **Developer Engagement**: Interaction with review feedback
- **Process Integration**: Integration with existing workflows
- **Knowledge Transfer**: Team learning from reviews

---

*This implementation guide provides comprehensive instructions for deploying and managing the enhanced Claude Code Review workflow system. For additional support or questions, refer to the monitoring logs and health check outputs.*
EOF

    validate_file_creation "$guide_file" "Implementation guide"
}

create_workflow_readme() {
    local readme_file="WORKFLOW_README.md"
    
    print_header "📄 Creating workflow README..."
    
    backup_file "$readme_file"
    
    if is_dry_run; then
        print_info "DRY RUN: Would create $readme_file"
        return 0
    fi
    
    cat > "$readme_file" << 'EOF'
# Enhanced Claude Code Review Workflow

## Quick Start

### 1. Setup (One-time)
```bash
# Configure API key
gh secret set ANTHROPIC_API_KEY --body "your-api-key"

# Test the system  
scripts/test-workflow.sh
```

### 2. Test the Implementation
```bash
# Create a test PR
git checkout -b test/feature-branch
echo "# Test" >> test.md
git add test.md && git commit -m "test: validation"
git push origin test/feature-branch
gh pr create --title "Test PR" --body "Testing workflow"

# Monitor results
scripts/monitor-workflow.sh
```

### 3. Daily Usage

#### Automatic Reviews
- Reviews trigger automatically on PR creation/updates
- No manual intervention required
- Results appear as PR comments

#### Manual Reviews  
```bash
# Comment on any PR or issue
@claude Please review this PR

# With specific focus
@claude Please review focusing on security and performance
```

#### Custom Commands
```bash
# Architecture analysis
/architecture-review "Analyze the new payment processing module"

# Security assessment  
/security-scan "Check for OWASP Top 10 vulnerabilities"

# Performance optimization
/performance-check "Review API response times and database queries"

# Documentation review
/documentation-audit "Validate API documentation completeness"

# Quick fixes
/quick-fix "Fix code style and minor issues"
```

## System Components

### GitHub Workflows
- **claude-code-review.yml**: Main automated review workflow
- **advanced-architecture-review.yml**: Advanced multi-stage analysis

### Custom Commands
Located in `.claude/commands/`:
- `architecture-review.md`: Comprehensive architecture analysis
- `security-scan.md`: Security vulnerability assessment  
- `performance-check.md`: Performance optimization review
- `documentation-audit.md`: Documentation quality validation
- `quick-fix.md`: Quick fix implementation

### Monitoring Scripts
Located in `scripts/`:
- `monitor-workflow.sh`: Health monitoring and status checks
- `test-workflow.sh`: Comprehensive workflow testing

## Usage Examples

### Basic Workflow Usage
1. **Automatic Triggers:** Workflow runs on PR creation, updates, and issue comments
2. **Manual Triggers:** Comment `@claude` in PRs or issues for manual review
3. **Custom Commands:** Use slash commands for specific types of analysis
4. **Scheduled Reviews:** Weekly comprehensive audits run automatically

### Custom Command Examples

#### Architecture Review
```bash
# In PR comment or Claude Code terminal
/architecture-review "Review the new user authentication module for compliance with Clean Architecture principles"
```

#### Security Scan
```bash
/security-scan "Perform OWASP Top 10 assessment on the API endpoints and check for injection vulnerabilities"
```

#### Performance Check
```bash  
/performance-check "Analyze the database queries and API response times for optimization opportunities"
```

#### Documentation Audit
```bash
/documentation-audit "Review the API documentation for completeness and accuracy against OpenAPI standards"
```

#### Quick Fix
```bash
/quick-fix "Fix code formatting, style issues, and simple optimizations in the user service"
```

### Monitoring and Maintenance

#### Daily Health Checks
```bash
# Run monitoring script
scripts/monitor-workflow.sh

# Check for failed runs
gh run list --repo calnet/web-architecture-guidelines --status failure --limit 5

# View detailed logs for failed runs  
gh run view [RUN_ID] --log
```

#### Weekly Maintenance
```bash
# Check for workflow updates
gh workflow list --repo calnet/web-architecture-guidelines

# Review secret expiration
gh secret list --repo calnet/web-architecture-guidelines

# Update dependencies if needed
# Check https://github.com/anthropics/claude-code-action/releases
```

#### Monthly Optimization
1. Review workflow performance metrics
2. Analyze feedback quality and relevance  
3. Update CLAUDE.md based on learnings
4. Optimize custom commands based on usage
5. Update documentation templates as needed

## File Structure
```
.github/workflows/
├── claude-code-review.yml           # Main workflow
└── advanced-architecture-review.yml # Advanced multi-stage workflow

.claude/commands/
├── architecture-review.md           # Comprehensive architecture analysis
├── security-scan.md                 # Security vulnerability assessment
├── performance-check.md             # Performance optimization review
├── documentation-audit.md           # Documentation quality validation
└── quick-fix.md                     # Quick fix implementation

scripts/
├── monitor-workflow.sh              # Health monitoring script
├── test-workflow.sh                 # Comprehensive testing script
├── create-workflows.sh              # Workflow creation script
├── create-commands.sh               # Commands creation script
├── create-monitoring.sh             # Monitoring scripts creation
└── create-docs.sh                   # Documentation creation script

CLAUDE.md                            # Enhanced Claude instructions
IMPLEMENTATION_GUIDE.md              # Complete implementation guide
WORKFLOW_README.md                   # This usage guide
```

## Success Metrics
- ✅ 95%+ workflow success rate
- ✅ <5 minutes average execution time
- ✅ Zero authentication failures
- ✅ Comprehensive architectural feedback
- ✅ Improved code quality scores

## Troubleshooting

### Common Issues

#### Workflow Not Triggering
- Verify ANTHROPIC_API_KEY secret is configured
- Check workflow files exist in `.github/workflows/`
- Ensure PR targets correct branches (main, develop)

#### Authentication Errors
- Verify GitHub CLI is authenticated: `gh auth status`
- Check API key is valid and has sufficient credits
- Ensure repository permissions are correct

#### Custom Commands Not Working
- Verify command files exist in `.claude/commands/`
- Check command syntax in PR comments
- Ensure workflow has been triggered recently

#### Performance Issues
- Monitor API rate limits: `gh api rate_limit`
- Check workflow execution times
- Review and optimize prompts if needed

### Getting Help
- Check system health: `scripts/monitor-workflow.sh --report`
- View workflow logs: `gh run list` and `gh run view [RUN_ID] --log`
- Run comprehensive test: `scripts/test-workflow.sh`

## Integration with Development Workflow

### For Developers
- Automatic reviews on every PR with clear, actionable feedback
- Custom commands for specialized analysis needs
- Integration with existing GitHub workflow
- Educational feedback to improve coding skills

### For Architects
- Consistent enforcement of architecture principles
- Automated compliance checking against established guidelines
- Data-driven insights into code quality trends
- Proactive identification of technical debt and architectural drift

### For DevOps
- Automated pre-deployment quality gates
- Integration with CI/CD pipeline for continuous quality assurance
- Performance and security monitoring capabilities
- Comprehensive audit trails for compliance and tracking

## Next Steps
1. Monitor workflow performance for first week
2. Gather feedback from development team on review quality
3. Optimize prompts based on usage patterns and feedback
4. Expand custom commands as needed for team-specific requirements
5. Integrate with additional tools (JIRA, Slack, etc.) as appropriate

## Support and Maintenance

### Regular Monitoring
- **Daily**: Check workflow health and performance metrics
- **Weekly**: Review success rates and failure patterns
- **Monthly**: Analyze usage patterns and optimize configurations
- **Quarterly**: Update prompts and commands based on team feedback

### Performance Optimization
- Monitor API usage and costs regularly
- Optimize prompts for efficiency and accuracy
- Adjust workflow triggers based on team needs
- Update models and parameters as new versions become available

### Security Considerations
- Rotate API keys regularly for security
- Monitor access logs and usage patterns
- Ensure secrets are properly protected
- Review and audit permissions periodically

---

*For detailed implementation instructions, see IMPLEMENTATION_GUIDE.md*
*For enhanced Claude instructions, see CLAUDE.md*
EOF

    validate_file_creation "$readme_file" "Workflow README"
}

main() {
    print_header "🚀 Creating Documentation for Enhanced Claude Code Review System"
    echo ""
    
    # Parse command line arguments
    parse_common_args "$@"
    
    # Validate prerequisites
    if ! validate_prerequisites "Documentation Creation"; then
        exit 1
    fi
    
    # Create documentation files
    create_enhanced_claude_md
    create_implementation_guide
    create_workflow_readme
    
    echo ""
    print_success "Documentation creation completed!"
    
    if ! is_dry_run; then
        echo ""
        print_info "Created documentation files:"
        print_info "- CLAUDE.md: Enhanced Claude instructions"
        print_info "- IMPLEMENTATION_GUIDE.md: Complete implementation guide"
        print_info "- WORKFLOW_README.md: Usage and maintenance documentation"
        echo ""
        print_info "Next steps:"
        print_info "1. Review and customize the documentation as needed"
        print_info "2. Run the complete setup: ./setup-enhanced-workflow.sh"
        print_info "3. Test the system: scripts/test-workflow.sh"
        print_info "4. Monitor health: scripts/monitor-workflow.sh"
    fi
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi