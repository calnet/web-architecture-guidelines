# Version and Date Validation System

This repository includes an automated validation system that ensures version references and "Last Updated" dates remain consistent across all documentation files.

## Overview

The validation system consists of several components:

### Core Scripts

- **`validate-comprehensive.sh`** - Runs complete validation of both versions and dates
- **`validate-versions.sh`** - Validates version consistency across repository files
- **`validate-dates.sh`** - Validates that "Last Updated" dates match file modification dates
- **`sync-versions.sh`** - Automatically synchronizes version references
- **`sync-dates.sh`** - Automatically synchronizes "Last Updated" dates
- **`setup-validation.sh`** - Initial setup and configuration

### Automation

- **GitHub Actions** - Automatic validation on PR and push
- **Pre-commit hooks** - Local validation before commits
- **Manual triggers** - On-demand validation and auto-fix

## Quick Start

### 1. Setup (One-time)

```bash
# Run the setup script to configure everything
./scripts/setup-validation.sh
```

This script will:
- Make all validation scripts executable
- Configure git hooks
- Test the validation system
- Attempt auto-fixes if needed

### 2. Daily Usage

The system runs automatically, but you can also run validation manually:

```bash
# Full validation (recommended)
./scripts/validate-comprehensive.sh

# Individual validations
./scripts/validate-versions.sh
./scripts/validate-dates.sh
```

### 3. Fix Issues

If validation fails, you can auto-fix most issues:

```bash
# Fix version inconsistencies
./scripts/sync-versions.sh

# Fix date inconsistencies
./scripts/sync-dates.sh

# Fix both
./scripts/sync-versions.sh && ./scripts/sync-dates.sh
```

## How It Works

### Version Validation

The system checks that version numbers are consistent across:

- **Root VERSION file** - Master version source
- **package.json files** - Version field in package files
- **Documentation files** - Various version patterns:
  - `**Version**: 1.3.5
  - `**Template Version**: 1.3.5
  - `**Instruction Version**: 1.3.5
  - `*Template Version: 1.3.5***`
- **Template version files** - `.template-version` and `VERSION` files

### Date Validation

The system ensures "Last Updated" dates match actual file modification dates:

- **Supported formats**:
  - `2025-09-14 @ 12:05` (precise timestamp)
  - `14 September 2025 @ 13:41` (new standard format)
  - `2025-09-14` (ISO date)
- **Pattern detection**:
  - `**Last Updated**: 2025-09-14 @ 22:11
  - `*Last Updated: DATE*`
  - `Last Updated: DATE`

### File Discovery

The system automatically discovers files that should be validated:

- All markdown (`.md`) files
- All `package.json` files
- Specific version control files (`.template-version`, `VERSION`)
- Excludes `node_modules`, `.git`, and other ignored directories

## GitHub Actions Integration

### Automatic Validation

The system runs automatically on:
- Pull requests to `main` branch
- Pushes to `main` and `develop` branches

### Manual Triggers

You can manually trigger validation with auto-fix:

1. Go to **Actions** → **Version and Date Validation**
2. Click **Run workflow**
3. Check **"Automatically fix version and date inconsistencies"**
4. Click **Run workflow**

### Validation Reports

Failed validations generate detailed reports with:
- Specific files and line numbers with issues
- Expected vs. actual values
- Suggested fix commands

## Pre-commit Hooks

The pre-commit hook runs validation before each commit:

```bash
# Normal commit (validation runs automatically)
git commit -m "Your commit message"

# Skip validation if needed (not recommended)
git commit --no-verify -m "Your commit message"
```

If validation fails:
1. The commit is blocked
2. Error details are displayed
3. Fix commands are suggested
4. You can fix and retry, or skip with `--no-verify`

## Configuration

### Disabling Validation

To temporarily disable validation:

```bash
# Disable git hooks
git config core.hooksPath ""

# Re-enable git hooks
git config core.hooksPath .githooks
```

### Customizing Date Formats

The system supports multiple date formats. You can:

- Use precise timestamps for frequently updated files
- Use month/year for stable documentation
- Use ISO dates for formal documentation

The sync script automatically preserves the existing format when updating dates.

## Troubleshooting

### Common Issues

**"Scripts not executable"**
```bash
chmod +x ./scripts/*.sh
chmod +x .githooks/pre-commit
```

**"Git hooks not working"**
```bash
git config core.hooksPath .githooks
```

**"Validation fails after fixing"**
- Check that all files are saved
- Ensure no uncommitted changes interfere
- Run validation with verbose output

### Getting Help

1. **Check logs** - Validation scripts save detailed logs to `/tmp/`
2. **Run setup again** - `./scripts/setup-validation.sh`
3. **Manual inspection** - Check specific files mentioned in error messages
4. **Clean state** - Ensure working directory is clean

### Bypassing Validation

While not recommended, you can bypass validation:

```bash
# Bypass pre-commit hook
git commit --no-verify -m "Emergency commit"

# Bypass GitHub Actions (not possible - contact maintainer)
```

## Best Practices

### For Developers

1. **Run validation before pushing**:
   ```bash
   ./scripts/validate-comprehensive.sh
   ```

2. **Use auto-fix for routine updates**:
   ```bash
   ./scripts/sync-versions.sh && ./scripts/sync-dates.sh
   ```

3. **Keep commits focused** - Don't mix version updates with other changes

### For Maintainers

1. **Update VERSION file first** when bumping versions
2. **Use GitHub Actions auto-fix** for bulk updates
3. **Review validation reports** before merging PRs
4. **Keep validation scripts updated** as repository structure evolves

## Script Reference

### validate-comprehensive.sh
Runs both version and date validation. Exit codes:
- `0` - All validation passed
- `1` - Validation failed

### validate-versions.sh
Checks version consistency. Validates ~137 files across repository.

### validate-dates.sh
Checks date accuracy. Validates ~62 files with "Last Updated" dates.

### sync-versions.sh
Automatically fixes version inconsistencies. Creates backups before changes.

### sync-dates.sh
Updates dates to match file modification times. Options:
- Default: Update existing dates only
- `--add-missing`: Add dates to files that don't have them

### setup-validation.sh
One-time setup script. Configures git hooks and tests system.

## Examples

### Typical Workflow

```bash
# 1. Make changes to documentation
vim docs/some-file.md

# 2. Check what validation finds
./scripts/validate-comprehensive.sh

# 3. Fix any issues
./scripts/sync-dates.sh

# 4. Verify fixes
./scripts/validate-comprehensive.sh

# 5. Commit (pre-commit hook runs automatically)
git add .
git commit -m "Update documentation"
```

### Version Bump Workflow

```bash
# 1. Update master version
echo "1.3.5" > VERSION

# 2. Sync all version references
./scripts/sync-versions.sh

# 3. Update dates
./scripts/sync-dates.sh

# 4. Validate everything
./scripts/validate-comprehensive.sh

# 5. Commit
git add .
git commit -m "Bump version to 1.3.4"
```

---

- **Version**: 1.3.5
- **Last Updated**: 2025-09-14 @ 22:11
- **Template Version**: 1.3.5