# GitHub Actions Secrets Setup Guide

This document describes the repository secrets required for the GitHub Actions
workflows to function properly.

## Required Secrets

### CLAUDE_API_KEY

**Purpose:** Enables the Claude Code Review workflow to use Anthropic's Claude
API for automated code analysis and review generation.

**How to obtain:**
1. Visit [Anthropic Console](https://console.anthropic.com/)
2. Sign up/log in to your account
3. Navigate to API Keys section
4. Create a new API key
5. Copy the generated key (starts with `sk-ant-`)

**How to configure:**
1. Go to repository **Settings** → **Secrets and variables** → **Actions**
2. Click **"New repository secret"**
3. Name: `CLAUDE_API_KEY`
4. Value: Your Anthropic API key (e.g., `sk-ant-...`)
5. Click **"Add secret"**

**Required permissions:** The API key needs access to Claude models (typically
Claude 3 Sonnet or Claude 3.5 Sonnet for code review tasks).

### GITHUB_TOKEN

**Status:** ✅ Automatically provided by GitHub Actions
**Purpose:** Allows workflows to interact with the GitHub API (create comments,
update pull requests, etc.)

**Note:** This secret is automatically available in all GitHub Actions
workflows. No manual configuration required.

## Workflow Dependencies

### claude-code-review.yml

**Required secrets:**
- `CLAUDE_API_KEY` - For Anthropic API access
- `GITHUB_TOKEN` - Automatically provided

**Configuration status check:**
- ✅ `GITHUB_TOKEN` - Auto-configured
- ❌ `CLAUDE_API_KEY` - Requires manual setup

## Troubleshooting

### Claude Code Review Workflow Failing

**Error:** `"anthropic_api_key": ""`
**Solution:** Configure the `CLAUDE_API_KEY` secret as described above.

**Error:** `Failed to check permissions for Copilot`
**Solution:** This is a known issue with bot accounts. The workflow should
continue despite this warning once the API key is configured.

### Permission Errors

**Error:** `User does not have write access`
**Solution:** Ensure the workflow has proper permissions configured:

```yaml
permissions:
  contents: read
  pull-requests: write
  issues: write
  checks: write
  statuses: write
  actions: read
  id-token: write
```

## Security Best Practices

1. **API Key Security:**
   - Never commit API keys to code
   - Use GitHub Secrets for all sensitive values
   - Rotate API keys regularly
   - Monitor API usage in Anthropic Console

2. **Access Control:**
   - Only repository administrators can add/modify secrets
   - Secrets are not visible in workflow logs
   - Secrets are only available to workflows in the same repository

3. **Environment Separation:**
   - Use different API keys for different environments
   - Consider using Environment-specific secrets for production workflows

## Verification

After configuring secrets, verify the setup:

1. Create or update a pull request to trigger the claude-code-review workflow
2. Check the workflow run in the **Actions** tab
3. Verify that the workflow completes successfully
4. Look for automated code review comments on the pull request

## API Usage and Costs

**Anthropic API Usage:**
- Code review workflows consume API tokens
- Usage depends on code change size and complexity
- Monitor usage in Anthropic Console
- Consider rate limiting for high-volume repositories

**Estimated costs:**
- Small PRs (< 100 lines): ~$0.01-0.05
- Medium PRs (100-500 lines): ~$0.05-0.20
- Large PRs (> 500 lines): ~$0.20-1.00

*Costs are estimates and may vary based on model used and API pricing.*