# Quality Gate Setup Guide

## Overview

This repository implements a comprehensive quality gate system that prevents problematic changes from being merged. The system includes both critical checks that block PRs and warning checks that provide advisory feedback.

## Quality Gate Architecture

### Critical Checks (Must Pass)
These checks **block PR merging** if they fail:
- ✅ **Security Validation** - Critical security compliance
- ✅ **Architecture Compliance** - Core architecture principles  
- ✅ **Template Validation** - Template structure and completeness
- ✅ **Dependency Security** - High/critical vulnerability scanning
- ✅ **File System Integrity** - Required files and structure

### Warning Checks (Advisory)
These checks provide feedback but **do not block** PRs:
- ⚠️ **Performance Validation** - Optimization recommendations
- ⚠️ **Cross-Reference Validation** - Documentation link accuracy
- ⚠️ **External Link Validation** - External resource accessibility
- ⚠️ **Secrets Scanning** - Potential credential detection

## GitHub Branch Protection Setup

### Required Status Checks

To enforce the quality gate, configure the following required status checks in your GitHub repository:

**Repository Settings → Branches → Add Rule or Edit Existing Rule**

#### Required Status Checks to Enable:

```text
✅ Quality Gate Status
✅ Critical Quality Checks
✅ Base Guidelines Compliance / compliance-check
✅ Documentation Validation / validate-structure
✅ AI-Powered Code Review / ai-review (optional but recommended)
```

#### Branch Protection Rule Configuration:

```yaml
Branch name pattern: main
☑️ Restrict pushes that create files larger than 100 MB
☑️ Require a pull request before merging
  ☑️ Require approvals (minimum 1)
  ☑️ Dismiss stale PR approvals when new commits are pushed
  ☑️ Require review from code owners
☑️ Require status checks to pass before merging
  ☑️ Require branches to be up to date before merging
  Required status checks:
    - Quality Gate Status
    - Critical Quality Checks  
    - compliance-check
    - validate-structure
☑️ Require conversation resolution before merging
☑️ Require linear history (optional)
☑️ Include administrators (recommended)
```

### Setup Instructions

#### 1. Via GitHub UI

1. Navigate to **Settings → Branches**
2. Click **Add rule** or edit existing rule for `main`
3. Configure the settings above
4. Add the required status checks listed

#### 2. Via GitHub CLI

```bash
# Enable branch protection with required status checks
gh api repos/:owner/:repo/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["Quality Gate Status","Critical Quality Checks","compliance-check","validate-structure"]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":1,"dismiss_stale_reviews":true}' \
  --field restrictions=null
```

#### 3. Via Terraform (for infrastructure-as-code)

```hcl
resource "github_branch_protection" "main" {
  repository_id = github_repository.repo.node_id
  pattern       = "main"

  required_status_checks {
    strict = true
    contexts = [
      "Quality Gate Status",
      "Critical Quality Checks", 
      "compliance-check",
      "validate-structure"
    ]
  }

  required_pull_request_reviews {
    required_approving_review_count = 1
    dismiss_stale_reviews          = true
    require_code_owner_reviews     = true
  }

  enforce_admins = true
}
```

## Local Development Workflow

### Pre-commit Validation

Run these commands locally before creating PRs:

```bash
# Quick critical check
npm run check:critical

# Comprehensive validation
npm run validate:all

# Fix version synchronization if needed
npm run versions:sync

# Generate compliance report
npm run compliance:report
```

### Understanding Check Results

#### ✅ All Checks Pass
```bash
✅ PROJECT STATUS: GOOD
No critical issues found.
```
**Action**: PR is ready for review and merge.

#### ❌ Critical Failures  
```bash
❌ PROJECT STATUS: CRITICAL FAILURE
Critical errors must be fixed before PR can be merged.
```
**Action**: Fix critical issues before proceeding. PR will be blocked.

#### ⚠️ Warnings Only
```bash
✅ PROJECT STATUS: GOOD  
No critical issues found. 2 warnings detected for improvement.
```
**Action**: PR can be merged, but consider addressing warnings.

## Workflow Integration

### Automatic Triggers

The quality gate runs automatically on:
- **Pull Request Creation**
- **Pull Request Updates** (new commits)
- **Pushes to main/develop branches**

### Manual Triggers

Use AI-powered analysis on-demand:
- **Comment `@claude` in PRs** for detailed review
- **Use slash commands** for specific analysis:
  - `/architecture-review` - Comprehensive architecture analysis
  - `/security-scan` - Security vulnerability assessment  
  - `/performance-check` - Performance optimization review
  - `/quick-fix` - Immediate actionable fixes

## Troubleshooting

### Common Issues

#### 1. Status Check Not Appearing

**Problem**: Required status check not showing in PR
**Solution**: 
```bash
# Trigger workflow manually
gh workflow run "Quality Gate" --ref your-branch-name

# Check workflow status
gh run list --workflow="Quality Gate"
```

#### 2. Critical Check Failures

**Problem**: Security or architecture validation fails
**Solution**:
```bash
# Run specific validation locally
npm run lint:security
npm run lint:architecture

# Check detailed logs
cat /tmp/security-validation.log
```

#### 3. Dependencies Issues

**Problem**: High/critical vulnerabilities detected  
**Solution**:
```bash
# Check audit results
npm audit

# Attempt automatic fix
npm audit fix

# Manual review for breaking changes
npm audit --audit-level=high
```

#### 4. Template Validation Failures

**Problem**: Template structure issues detected
**Solution**:
```bash
# Validate specific templates
npm run lint:templates

# Check template compliance
npm run compliance:report

# Fix template structure
npm run compliance:enhance
```

### Bypassing Quality Gate (Emergency Only)

For critical hotfixes, administrators can temporarily:

1. **Disable branch protection**:
   ```bash
   gh api repos/:owner/:repo/branches/main/protection --method DELETE
   ```

2. **Merge with admin override** (if enforce_admins=false)

3. **Re-enable protection**:
   ```bash
   # Re-apply protection settings
   ```

⚠️ **Important**: Always re-enable protection immediately after emergency merge.

## Monitoring and Optimization

### Workflow Performance

Monitor quality gate performance:

```bash
# Check workflow health  
npm run workflow:monitor-report

# Performance metrics
npm run workflow:monitor-performance

# Test workflow functionality
npm run workflow:test-dry
```

### Quality Metrics

Track quality improvements over time:
- **Critical Check Pass Rate**: Target >95%
- **PR Block Rate**: Monitor trends
- **Warning Resolution**: Track improvement 
- **Time to Merge**: Measure efficiency

### Optimization

Optimize workflow performance:

```bash
# Run optimization analysis
npm run workflow:optimize

# Update workflow configurations
# Edit .github/workflows/quality-gate.yml
```

## Custom Configuration

### Adjusting Check Strictness

Modify check behavior in `scripts/check-project-errors-strict.sh`:

```bash
# Change warning thresholds
BLOCKING_ERROR_THRESHOLD=5  # Default: 5

# Modify critical check scope
# Add/remove checks from critical section
```

### Adding New Checks

1. **Create check script**:
   ```bash
   ./scripts/validate-new-feature.sh
   ```

2. **Add to quality gate workflow**:
   ```yaml
   - name: New Feature Check
     run: npm run validate:new-feature
   ```

3. **Update package.json**:
   ```json
   "validate:new-feature": "./scripts/validate-new-feature.sh"
   ```

## Best Practices

### For Developers

1. **Run checks locally** before creating PRs
2. **Fix critical issues immediately** - don't skip
3. **Address warnings when convenient** - improve quality gradually
4. **Use AI analysis** for complex changes
5. **Keep PRs focused** - easier to validate

### For Maintainers

1. **Monitor quality trends** - use metrics dashboard
2. **Update checks regularly** - keep validation current  
3. **Document new requirements** - clear guidelines
4. **Review bypass usage** - minimize emergency overrides
5. **Optimize performance** - fast feedback loops

### For Repository Administrators

1. **Enforce branch protection** - no exceptions for main
2. **Regular audit reviews** - quarterly process review
3. **Update status check requirements** - align with quality goals
4. **Monitor system health** - proactive maintenance
5. **Train team on process** - ensure adoption

---

**Version**: 1.3.4
**Last Updated**: 2025-09-13 @ 14:39
**Related Documentation**: [IMPLEMENTATION_GUIDE.md](../IMPLEMENTATION_GUIDE.md), [WORKFLOW_README.md](../WORKFLOW_README.md)