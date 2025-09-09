#!/bin/bash

# Automated Changelog Generation Script
# Generates changelog entries from conventional commit messages

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$ROOT_DIR"

# Parameters
VERSION="$1"
COMMIT_RANGE="$2"
CHANGELOG_FILE="CHANGELOG.md"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Validate parameters
if [[ -z "$VERSION" ]]; then
    error "Version parameter is required"
fi

if [[ -z "$COMMIT_RANGE" ]]; then
    COMMIT_RANGE="HEAD"
    log "No commit range specified, using HEAD"
fi

log "Generating changelog for version $VERSION"
log "Commit range: $COMMIT_RANGE"

# Create changelog file if it doesn't exist
if [[ ! -f "$CHANGELOG_FILE" ]]; then
    cat > "$CHANGELOG_FILE" << 'EOF'
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

EOF
    log "Created new changelog file"
fi

# Generate temporary changelog entry
TEMP_ENTRY=$(mktemp)
DATE=$(date '+%Y-%m-%d')

echo "## [$VERSION] - $DATE" > "$TEMP_ENTRY"
echo "" >> "$TEMP_ENTRY"

# Categorize commits
FEATURES=$(git log "$COMMIT_RANGE" --oneline --grep="^feat" --format="- %s" | sed 's/^feat[^:]*: /- /' || true)
FIXES=$(git log "$COMMIT_RANGE" --oneline --grep="^fix" --format="- %s" | sed 's/^fix[^:]*: /- /' || true)
DOCS=$(git log "$COMMIT_RANGE" --oneline --grep="^docs" --format="- %s" | sed 's/^docs[^:]*: /- /' || true)
CHORES=$(git log "$COMMIT_RANGE" --oneline --grep="^chore" --format="- %s" | sed 's/^chore[^:]*: /- /' || true)
BREAKING=$(git log "$COMMIT_RANGE" --grep="BREAKING CHANGE" --format="- %s" || true)

# Add sections to changelog entry
ADDED_SECTIONS=false

if [[ -n "$BREAKING" ]]; then
    echo "### ⚠️ BREAKING CHANGES" >> "$TEMP_ENTRY"
    echo "" >> "$TEMP_ENTRY"
    echo "$BREAKING" >> "$TEMP_ENTRY"
    echo "" >> "$TEMP_ENTRY"
    ADDED_SECTIONS=true
fi

if [[ -n "$FEATURES" ]]; then
    echo "### ✨ Features" >> "$TEMP_ENTRY"
    echo "" >> "$TEMP_ENTRY"
    echo "$FEATURES" >> "$TEMP_ENTRY"
    echo "" >> "$TEMP_ENTRY"
    ADDED_SECTIONS=true
fi

if [[ -n "$FIXES" ]]; then
    echo "### 🐛 Bug Fixes" >> "$TEMP_ENTRY"
    echo "" >> "$TEMP_ENTRY"
    echo "$FIXES" >> "$TEMP_ENTRY"
    echo "" >> "$TEMP_ENTRY"
    ADDED_SECTIONS=true
fi

if [[ -n "$DOCS" ]]; then
    echo "### 📚 Documentation" >> "$TEMP_ENTRY"
    echo "" >> "$TEMP_ENTRY"
    echo "$DOCS" >> "$TEMP_ENTRY"
    echo "" >> "$TEMP_ENTRY"
    ADDED_SECTIONS=true
fi

if [[ -n "$CHORES" ]]; then
    echo "### 🔧 Maintenance" >> "$TEMP_ENTRY"
    echo "" >> "$TEMP_ENTRY"
    echo "$CHORES" >> "$TEMP_ENTRY"
    echo "" >> "$TEMP_ENTRY"
    ADDED_SECTIONS=true
fi

# If no categorized commits found, add a general section
if [[ "$ADDED_SECTIONS" == "false" ]]; then
    ALL_COMMITS=$(git log "$COMMIT_RANGE" --oneline --format="- %s" || true)
    if [[ -n "$ALL_COMMITS" ]]; then
        echo "### Changes" >> "$TEMP_ENTRY"
        echo "" >> "$TEMP_ENTRY"
        echo "$ALL_COMMITS" >> "$TEMP_ENTRY"
        echo "" >> "$TEMP_ENTRY"
    else
        echo "### Changes" >> "$TEMP_ENTRY"
        echo "" >> "$TEMP_ENTRY"
        echo "- Version maintenance and updates" >> "$TEMP_ENTRY"
        echo "" >> "$TEMP_ENTRY"
    fi
fi

# Insert the new entry at the top of the changelog (after the header)
{
    # Keep the header
    head -n 6 "$CHANGELOG_FILE"
    echo ""
    # Add new entry
    cat "$TEMP_ENTRY"
    # Add existing entries (skip header)
    tail -n +7 "$CHANGELOG_FILE" | grep -v "^$" | head -n -1 || true
} > "${CHANGELOG_FILE}.tmp"

mv "${CHANGELOG_FILE}.tmp" "$CHANGELOG_FILE"
rm "$TEMP_ENTRY"

success "Changelog entry generated for version $VERSION"
log "Updated $CHANGELOG_FILE"

# Show the generated entry
echo ""
echo "Generated changelog entry:"
echo "========================="
head -n 20 "$CHANGELOG_FILE" | tail -n +7