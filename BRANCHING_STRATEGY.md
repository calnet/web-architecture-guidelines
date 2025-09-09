# Branching Strategy for Web Architecture Guidelines

## Branch Structure

### Main Branches

- `main` - Production-ready code
- `develop` - Integration branch for features

### Feature Branches

- `feature/docs-site-*` - Documentation site features
- `feature/templates-*` - Template improvements
- `feature/validation-*` - Validation and quality tools
- `feature/architecture-*` - Architecture documentation
- `feature/ai-agents-*` - AI agent configurations

### Support Branches

- `hotfix/` - Critical production fixes
- `release/` - Release preparation
- `chore/` - Maintenance tasks

### Example Workflow

```bash
# Create feature branch from develop
git checkout develop
git pull origin develop
git checkout -b feature/docs-site-sidebar-enhancement

# Work on feature, make commits
git add .
git commit -m "feat(sidebar): add independent scrolling functionality"

# Push feature branch
git push -u origin feature/docs-site-sidebar-enhancement

# Create Pull Request to develop
# After review and merge, delete feature branch
git branch -d feature/docs-site-sidebar-enhancement
git push origin --delete feature/docs-site-sidebar-enhancement
```text

## Commit Message Convention

```yaml
type(scope): description

feat(docs-site): add new navigation component
fix(templates): correct indentation in coding standards
docs(readme): update installation instructions
chore(deps): update React to v19
style(css): improve responsive design
refactor(components): restructure sidebar logic
test(validation): add template compliance tests
```
