#!/bin/bash

# Automated Version Bumping Script
# Automatically bumps version based on conventional commit messages and git tags

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$ROOT_DIR"

# Default values
BUMP_TYPE=""
DRY_RUN=false
CREATE_TAG=true
GENERATE_CHANGELOG=true

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Automatically bump version based on conventional commits"
    echo ""
    echo "Options:"
    echo "  -t, --type TYPE     Force version bump type (major|minor|patch)"
    echo "  -d, --dry-run       Show what would be done without making changes"
    echo "  --no-tag            Don't create git tag"
    echo "  --no-changelog      Don't generate changelog"
    echo "  -h, --help          Show this help"
    echo ""
    echo "If no type is specified, analyzes commits since last tag to determine bump type:"
    echo "  - BREAKING CHANGE: major bump"
    echo "  - feat: minor bump" 
    echo "  - fix: patch bump"
    echo "  - Other: patch bump"
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

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--type)
            BUMP_TYPE="$2"
            shift 2
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        --no-tag)
            CREATE_TAG=false
            shift
            ;;
        --no-changelog)
            GENERATE_CHANGELOG=false
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            ;;
    esac
done

# Validate bump type if provided
if [[ -n "$BUMP_TYPE" ]] && [[ "$BUMP_TYPE" != "major" ]] && [[ "$BUMP_TYPE" != "minor" ]] && [[ "$BUMP_TYPE" != "patch" ]]; then
    error "Invalid bump type: $BUMP_TYPE. Must be major, minor, or patch"
fi

# Get current version
if [ ! -f "VERSION" ]; then
    error "VERSION file not found!"
fi

CURRENT_VERSION=$(cat VERSION | tr -d '\n')
log "Current version: $CURRENT_VERSION"

# Parse current version
if ! [[ $CURRENT_VERSION =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
    error "Invalid version format in VERSION file: $CURRENT_VERSION"
fi

MAJOR=${BASH_REMATCH[1]}
MINOR=${BASH_REMATCH[2]}
PATCH=${BASH_REMATCH[3]}

# Get last tag to determine commit range for analysis
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
if [[ -z "$LAST_TAG" ]]; then
    warn "No previous tags found, analyzing all commits"
    COMMIT_RANGE="HEAD"
else
    log "Last tag: $LAST_TAG"
    COMMIT_RANGE="$LAST_TAG..HEAD"
fi

# Analyze commits to determine bump type if not provided
if [[ -z "$BUMP_TYPE" ]]; then
    log "Analyzing commits since $LAST_TAG to determine version bump..."
    
    # Check for breaking changes
    if git log "$COMMIT_RANGE" --grep="BREAKING CHANGE" --oneline | grep -q .; then
        BUMP_TYPE="major"
        log "Found BREAKING CHANGE commits -> major bump"
    # Check for new features
    elif git log "$COMMIT_RANGE" --grep="^feat" --oneline | grep -q .; then
        BUMP_TYPE="minor"
        log "Found feat commits -> minor bump"
    # Check for fixes or other changes
    elif git log "$COMMIT_RANGE" --oneline | grep -q .; then
        BUMP_TYPE="patch"
        log "Found commits -> patch bump"
    else
        warn "No commits found since last tag"
        exit 0
    fi
fi

# Calculate new version
case $BUMP_TYPE in
    major)
        NEW_MAJOR=$((MAJOR + 1))
        NEW_MINOR=0
        NEW_PATCH=0
        ;;
    minor)
        NEW_MAJOR=$MAJOR
        NEW_MINOR=$((MINOR + 1))
        NEW_PATCH=0
        ;;
    patch)
        NEW_MAJOR=$MAJOR
        NEW_MINOR=$MINOR
        NEW_PATCH=$((PATCH + 1))
        ;;
esac

NEW_VERSION="$NEW_MAJOR.$NEW_MINOR.$NEW_PATCH"

log "Version bump: $CURRENT_VERSION -> $NEW_VERSION ($BUMP_TYPE)"

if [[ "$DRY_RUN" == "true" ]]; then
    warn "DRY RUN MODE - No changes will be made"
    log "Would update version from $CURRENT_VERSION to $NEW_VERSION"
    if [[ "$CREATE_TAG" == "true" ]]; then
        log "Would create git tag: v$NEW_VERSION"
    fi
    if [[ "$GENERATE_CHANGELOG" == "true" ]]; then
        log "Would generate changelog entry"
    fi
    exit 0
fi

# Update VERSION file
echo "$NEW_VERSION" > VERSION
log "Updated VERSION file"

# Update all version references using existing sync script
log "Synchronizing versions across repository..."
./scripts/sync-versions.sh

# Update timestamp in all versioned files
TIMESTAMP=$(date '+%Y-%m-%d @ %H:%M')
log "Updating timestamps to: $TIMESTAMP"

# Update timestamps in all files with version markers
find docs -name "*.md" -exec grep -l "Last Updated" {} \; | while read file; do
    sed -i "s/\*\*Last Updated\*\*: [^*]*/\*\*Last Updated\*\*: $TIMESTAMP/" "$file"
    sed -i "s/- \*\*Last Updated\*\*: [^*]*/- \*\*Last Updated\*\*: $TIMESTAMP/" "$file"
done

# Generate changelog if requested
if [[ "$GENERATE_CHANGELOG" == "true" ]]; then
    log "Generating changelog entry..."
    ./scripts/generate-changelog.sh "$NEW_VERSION" "$COMMIT_RANGE"
fi

# Create git tag if requested
if [[ "$CREATE_TAG" == "true" ]]; then
    log "Creating git tag: v$NEW_VERSION"
    git tag -a "v$NEW_VERSION" -m "Release version $NEW_VERSION"
fi

success "Version bumped successfully!"
success "New version: $NEW_VERSION"

# Validate the changes
log "Validating version consistency..."
if ./scripts/validate-versions.sh > /dev/null 2>&1; then
    success "Version validation passed!"
else
    error "Version validation failed after update"
fi

log "Changes made:"
log "  - Updated VERSION file: $CURRENT_VERSION -> $NEW_VERSION"
log "  - Synchronized all version references"
log "  - Updated timestamps in versioned files"
if [[ "$GENERATE_CHANGELOG" == "true" ]]; then
    log "  - Generated changelog entry"
fi
if [[ "$CREATE_TAG" == "true" ]]; then
    log "  - Created git tag: v$NEW_VERSION"
fi

log ""
log "Next steps:"
log "  1. Review changes: git diff"
log "  2. Commit changes: git add . && git commit -m 'chore: bump version to $NEW_VERSION'"
if [[ "$CREATE_TAG" == "true" ]]; then
    log "  3. Push with tags: git push && git push --tags"
else
    log "  3. Push changes: git push"
fi