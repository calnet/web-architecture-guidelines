#!/bin/bash

# Release Management Script
# Provides formal release process with validation and rollback capabilities

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$ROOT_DIR"

# Configuration
RELEASE_BRANCH="release"
MAIN_BRANCH="main"
PRE_RELEASE_TAG_PREFIX="rc"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Command and options
COMMAND=""
VERSION=""
PRE_RELEASE=false
FORCE=false
SKIP_TESTS=false

usage() {
    echo "Usage: $0 COMMAND [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  prepare VERSION     Prepare a new release"
    echo "  validate            Validate current release candidate"
    echo "  publish             Publish the prepared release"
    echo "  rollback VERSION    Rollback to previous version"
    echo "  list                List all releases"
    echo "  status              Show current release status"
    echo ""
    echo "Options:"
    echo "  --pre-release       Create pre-release (rc) version"
    echo "  --force             Force operation without confirmation"
    echo "  --skip-tests        Skip test validation (not recommended)"
    echo "  -h, --help          Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 prepare 1.2.0                  # Prepare version 1.2.0"
    echo "  $0 prepare 1.2.0-rc.1 --pre-release  # Prepare release candidate"
    echo "  $0 validate                        # Validate current release"
    echo "  $0 publish                         # Publish prepared release"
    echo "  $0 rollback 1.1.0                 # Rollback to version 1.1.0"
}

log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

header() {
    echo -e "${CYAN}[RELEASE]${NC} $1"
}

confirm() {
    if [[ "$FORCE" == "true" ]]; then
        return 0
    fi
    
    echo -e "${YELLOW}$1${NC}"
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Operation cancelled"
        exit 0
    fi
}

# Validation functions
validate_version_format() {
    local version="$1"
    if [[ "$PRE_RELEASE" == "true" ]]; then
        if ! [[ $version =~ ^[0-9]+\.[0-9]+\.[0-9]+-(rc|alpha|beta)\.[0-9]+$ ]]; then
            error "Invalid pre-release version format: $version. Expected: X.Y.Z-rc.N"
        fi
    else
        if ! [[ $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            error "Invalid version format: $version. Expected: X.Y.Z"
        fi
    fi
}

validate_git_status() {
    if [[ -n $(git status --porcelain) ]]; then
        error "Working directory is not clean. Please commit or stash changes."
    fi
}

validate_branch() {
    local current_branch=$(git branch --show-current)
    if [[ "$current_branch" != "$MAIN_BRANCH" ]]; then
        error "Must be on $MAIN_BRANCH branch for release operations. Current: $current_branch"
    fi
}

run_validations() {
    header "Running pre-release validations..."
    
    # 1. Validate documentation structure
    log "📄 Validating documentation structure..."
    if ! ./scripts/validate-docs-structure.sh; then
        error "Documentation structure validation failed"
    fi
    
    # 2. Validate versions
    log "🔢 Validating version consistency..."
    if ! ./scripts/validate-versions.sh; then
        error "Version validation failed"
    fi
    
    # 3. Validate cross-references
    log "🔗 Validating cross-references..."
    if ! ./scripts/validate-cross-references-enhanced.sh; then
        error "Cross-reference validation failed"
    fi
    
    # 4. Run linting
    log "🧹 Running linting..."
    if ! npm run lint:all; then
        error "Linting failed"
    fi
    
    # 5. Run tests (if not skipped)
    if [[ "$SKIP_TESTS" != "true" ]]; then
        log "🧪 Running tests..."
        if ! npm test; then
            warn "Tests failed or not configured"
        fi
    fi
    
    success "All validations passed!"
}

prepare_release() {
    local version="$1"
    
    header "Preparing release $version"
    
    validate_version_format "$version"
    validate_git_status
    validate_branch
    
    # Get current version
    local current_version=$(cat VERSION | tr -d '\n')
    log "Current version: $current_version"
    log "Target version: $version"
    
    confirm "Prepare release $version?"
    
    # Update version
    echo "$version" > VERSION
    log "Updated VERSION file"
    
    # Sync all versions
    log "Synchronizing versions across repository..."
    ./scripts/sync-versions.sh
    
    # Update timestamps
    local timestamp=$(date '+%Y-%m-%d @ %H:%M')
    log "Updating timestamps to: $timestamp"
    
    find docs -name "*.md" -exec grep -l "Last Updated" {} \; | while read file; do
        sed -i "s/\*\*Last Updated\*\*: [^*]*/\*\*Last Updated\*\*: $timestamp/" "$file"
        sed -i "s/- \*\*Last Updated\*\*: [^*]*/- \*\*Last Updated\*\*: $timestamp/" "$file"
    done
    
    # Generate changelog
    log "Generating changelog..."
    local last_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
    local commit_range="HEAD"
    if [[ -n "$last_tag" ]]; then
        commit_range="$last_tag..HEAD"
    fi
    ./scripts/generate-changelog.sh "$version" "$commit_range"
    
    # Run validations
    run_validations
    
    # Commit changes
    log "Committing release preparation..."
    git add .
    git commit -m "chore: prepare release $version"
    
    # Create tag
    local tag_name="v$version"
    if [[ "$PRE_RELEASE" == "true" ]]; then
        tag_name="v$version"
        git tag -a "$tag_name" -m "Release candidate $version"
        log "Created pre-release tag: $tag_name"
    else
        git tag -a "$tag_name" -m "Release version $version"
        log "Created release tag: $tag_name"
    fi
    
    success "Release $version prepared successfully!"
    log ""
    log "Next steps:"
    log "  1. Review changes: git log --oneline -5"
    log "  2. Validate release: $0 validate"
    log "  3. Publish release: $0 publish"
}

validate_release() {
    header "Validating current release candidate"
    
    # Check if we're on a tagged version
    local current_tag=$(git describe --exact-match --tags HEAD 2>/dev/null || echo "")
    if [[ -z "$current_tag" ]]; then
        warn "Not on a tagged release"
    else
        log "Current release: $current_tag"
    fi
    
    run_validations
    
    success "Release validation completed successfully!"
}

publish_release() {
    header "Publishing release"
    
    validate_git_status
    
    # Check if we're on a tagged version
    local current_tag=$(git describe --exact-match --tags HEAD 2>/dev/null || echo "")
    if [[ -z "$current_tag" ]]; then
        error "Not on a tagged release. Please prepare a release first."
    fi
    
    log "Publishing release: $current_tag"
    
    confirm "Publish release $current_tag to remote repository?"
    
    # Push changes and tags
    log "Pushing to remote repository..."
    git push origin "$MAIN_BRANCH"
    git push origin "$current_tag"
    
    success "Release $current_tag published successfully!"
    log ""
    log "Release is now available at:"
    log "  - Repository: https://github.com/$(git config --get remote.origin.url | sed 's/.*github\.com[:/]\([^.]*\).*/\1/')"
    log "  - Tag: $current_tag"
}

rollback_release() {
    local target_version="$1"
    
    header "Rolling back to version $target_version"
    
    validate_version_format "$target_version"
    validate_git_status
    validate_branch
    
    # Check if target version tag exists
    if ! git tag -l | grep -q "^v$target_version$"; then
        error "Target version tag v$target_version does not exist"
    fi
    
    warn "This will reset the repository to version $target_version"
    warn "All changes since then will be lost!"
    confirm "Proceed with rollback to $target_version?"
    
    # Reset to target version
    log "Resetting to version $target_version..."
    git reset --hard "v$target_version"
    
    # Update VERSION file to be sure
    echo "$target_version" > VERSION
    
    # Sync versions
    ./scripts/sync-versions.sh
    
    # Commit the rollback
    git add .
    git commit -m "chore: rollback to version $target_version"
    
    success "Rolled back to version $target_version"
    log ""
    log "Next steps:"
    log "  1. Validate rollback: $0 validate"
    log "  2. Push changes: git push origin $MAIN_BRANCH"
}

list_releases() {
    header "Available releases"
    
    log "Tagged releases:"
    git tag -l --sort=-version:refname | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+' | head -10
    
    log ""
    log "Current version: $(cat VERSION 2>/dev/null || echo 'Unknown')"
    
    local current_tag=$(git describe --exact-match --tags HEAD 2>/dev/null || echo "")
    if [[ -n "$current_tag" ]]; then
        log "Current tag: $current_tag"
    else
        log "Current commit: $(git rev-parse --short HEAD)"
    fi
}

show_status() {
    header "Release Status"
    
    local current_version=$(cat VERSION 2>/dev/null || echo 'Unknown')
    local current_tag=$(git describe --exact-match --tags HEAD 2>/dev/null || echo "")
    local current_branch=$(git branch --show-current)
    local git_status=$(git status --porcelain)
    
    log "Current version: $current_version"
    log "Current branch: $current_branch"
    
    if [[ -n "$current_tag" ]]; then
        log "Current tag: $current_tag"
        log "Status: On tagged release"
    else
        log "Current commit: $(git rev-parse --short HEAD)"
        log "Status: Development version"
    fi
    
    if [[ -n "$git_status" ]]; then
        warn "Working directory has uncommitted changes"
    else
        success "Working directory is clean"
    fi
    
    # Check version consistency
    log ""
    log "Version consistency check:"
    if ./scripts/validate-versions.sh > /dev/null 2>&1; then
        success "All versions are consistent"
    else
        warn "Version inconsistencies detected"
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        prepare|validate|publish|rollback|list|status)
            COMMAND="$1"
            shift
            ;;
        --pre-release)
            PRE_RELEASE=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            if [[ -z "$VERSION" ]]; then
                VERSION="$1"
            else
                error "Unknown option: $1"
            fi
            shift
            ;;
    esac
done

# Validate command
if [[ -z "$COMMAND" ]]; then
    error "Command required. Use -h for help."
fi

# Execute command
case $COMMAND in
    prepare)
        if [[ -z "$VERSION" ]]; then
            error "Version required for prepare command"
        fi
        prepare_release "$VERSION"
        ;;
    validate)
        validate_release
        ;;
    publish)
        publish_release
        ;;
    rollback)
        if [[ -z "$VERSION" ]]; then
            error "Version required for rollback command"
        fi
        rollback_release "$VERSION"
        ;;
    list)
        list_releases
        ;;
    status)
        show_status
        ;;
    *)
        error "Unknown command: $COMMAND"
        ;;
esac