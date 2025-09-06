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

---

- **Version**: 1.1.0
- **Last Updated**: September 2025
- **Template Version**: 1.1.0
