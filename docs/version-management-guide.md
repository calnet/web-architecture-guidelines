# Version Management Guide

This document provides comprehensive guidance on the repository's centralized version management system.

## Overview

The Web Architecture Guidelines repository uses a centralized version management system to ensure consistency across all documentation, templates, and configuration files. The system maintains synchronization between multiple package.json files, documentation sites, template versions, and metadata across the entire repository.

## Version Management Structure

### Source of Truth
- **Root VERSION file**: Contains the authoritative version number for the entire repository
- Located at: `./VERSION`
- Format: Semantic versioning (e.g., `1.1.0`)

### Managed Files

#### Package Files
- `package.json` - Main repository package file
- `examples/package.json` - Example project configuration
- `docs-site/package.json` - Documentation site package file
- `docs-site/public/examples/package.json` - Public example project configuration

#### Template Version Files
- `docs/.template-version` - Main templates version marker
- `docs/templates/VERSION` - Templates directory version
- `docs-site/public/docs/.template-version` - Public templates version marker
- `docs-site/public/docs/templates/VERSION` - Public templates directory version

#### Documentation Files with Version Metadata
- `docs/architecture/system-architecture.md`
- `docs/security.md`
- `docs/performance.md`
- `docs-site/public/docs/architecture/system-architecture.md`

#### Template Files
All `.md` files in:
- `docs/templates/` (and subdirectories)
- `docs-site/public/docs/templates/` (and subdirectories)

#### AI Agent Instruction Files (Optional)
- Files in `docs/ai-agents/` and `docs-site/public/docs/ai-agents/`
- Only synchronized if they contain explicit version markers (e.g., "Version: 1.1.0")

## Commands

### NPM Scripts

```bash
# Validate version consistency across all files
npm run versions:validate

# Synchronize all versions to match root VERSION file
npm run versions:sync

# List all version-managed files and their current versions
npm run versions:list
```

### Direct Script Execution

```bash
# Validation
./scripts/validate-versions.sh

# Synchronization
./scripts/sync-versions.sh

# File listing
./scripts/list-version-files.sh
```

## Usage Workflows

### 1. Version Update Process

When updating the repository version:

1. **Update the root VERSION file**:
   ```bash
   echo "1.2.0" > VERSION
   ```

2. **Synchronize all files**:
   ```bash
   npm run versions:sync
   ```

3. **Validate consistency**:
   ```bash
   npm run versions:validate
   ```

4. **Commit changes**:
   ```bash
   git add .
   git commit -m "chore: update version to 1.2.0"
   ```

### 2. Development Workflow Integration

Before committing changes:
```bash
# Check for version inconsistencies
npm run versions:validate

# If inconsistencies found, sync versions
npm run versions:sync
```

### 3. CI/CD Integration

The repository includes GitHub Actions workflow validation:

```yaml
# .github/workflows/validate-docs.yml
validate-versions:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - name: Validate version consistency
      run: |
        chmod +x ./scripts/validate-versions.sh
        ./scripts/validate-versions.sh
```

## Supported Version Formats

### Package.json Files
```json
{
  "version": "1.1.0"
}
```

### Template Files
```markdown
**Template Version**: 1.2.0
```
or
```markdown
*Template Version: 1.2.0**
```

### Documentation Files
```markdown
**Version**: 1.2.0
```

### AI Agent Instructions (Optional)
```markdown
Version: 1.1.0
```

## Error Handling

### Common Issues and Solutions

#### Version Mismatch
**Problem**: `validate-versions.sh` reports version mismatches
**Solution**: Run `npm run versions:sync` to align all versions

#### Missing Files
**Problem**: Warning messages about missing version files
**Solution**: Files may not exist in all environments (e.g., docs-site may not be present in all setups)

#### Permission Errors
**Problem**: Scripts fail with permission denied
**Solution**: 
```bash
chmod +x ./scripts/validate-versions.sh
chmod +x ./scripts/sync-versions.sh
chmod +x ./scripts/list-version-files.sh
```

### Script Safety Features

- **Idempotent**: Safe to run multiple times
- **Non-destructive**: Only updates version numbers, preserves all other content
- **Validation**: Comprehensive checking before and after operations
- **Rollback**: Version changes can be reverted by updating VERSION file and re-syncing

## Troubleshooting

### Debugging Version Issues

1. **List all version-managed files**:
   ```bash
   npm run versions:list
   ```

2. **Check specific file**:
   ```bash
   grep -r "version" package.json
   ```

3. **Manual validation**:
   ```bash
   cat VERSION
   grep '"version":' package.json
   ```

### Advanced Usage

#### Exclude Specific Files
To temporarily exclude files from version management, modify the scripts to skip certain patterns:

```bash
# In sync-versions.sh, comment out specific file patterns
# for package_file in "package.json" "examples/package.json"...
```

#### Custom Version Patterns
For AI agent instructions or other files, add custom patterns to the scripts:

```bash
# In sync-versions.sh, add new sed patterns
sed -i "s/Custom Version: [0-9][0-9.]*[0-9]/Custom Version: $MAIN_VERSION/g" "$file"
```

## Best Practices

1. **Always validate after sync**: Run `versions:validate` after `versions:sync`
2. **Commit version changes separately**: Keep version updates in dedicated commits
3. **Use conventional commit messages**: `chore: update version to X.Y.Z`
4. **Test in development**: Validate version management in development branches
5. **Monitor CI/CD**: Ensure version validation passes in automated workflows

## Integration with Project Workflow

The version management system integrates with:
- **Git workflows**: Pre-commit hooks can include version validation
- **Release processes**: Automated version bumping during releases
- **Documentation generation**: Template versions for generated documentation
- **Dependency management**: Ensuring consistency across multiple package.json files

## Maintenance

### Regular Tasks
- **Monthly**: Review and validate version consistency
- **Before releases**: Ensure all versions are synchronized
- **After major changes**: Validate version alignment

### Script Maintenance
The version management scripts are located in `./scripts/` and should be updated when:
- New version-managed files are added
- File path structures change
- New version format patterns are introduced

---

For additional support, refer to the main project documentation or create an issue in the repository.

---

**Document Information**:

- **Version**: 1.2.0
- **Last Updated**: 2025-09-06 @ 18:49
- **Review Schedule**: Quarterly
- **Maintained by**: Architecture Team