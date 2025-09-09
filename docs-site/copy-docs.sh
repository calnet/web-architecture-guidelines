#!/bin/bash

# Script to copy documentation files to public directory for serving

echo "Copying documentation files to public directory..."

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Create public/docs if it doesn't exist
mkdir -p "$SCRIPT_DIR/public/docs"
mkdir -p "$SCRIPT_DIR/public/.claude"
mkdir -p "$SCRIPT_DIR/public/.github"

echo "Working from repository root: $REPO_ROOT"

# Copy main documentation files
cp "$REPO_ROOT/README.md" "$SCRIPT_DIR/public/"
cp "$REPO_ROOT/git-commands-and-setup.md" "$SCRIPT_DIR/public/"
cp "$REPO_ROOT/CLAUDE.md" "$SCRIPT_DIR/public/"
cp "$REPO_ROOT/LICENSE" "$SCRIPT_DIR/public/"

# Copy Enhanced Claude workflow documentation
if [ -f "$REPO_ROOT/IMPLEMENTATION_GUIDE.md" ]; then
    cp "$REPO_ROOT/IMPLEMENTATION_GUIDE.md" "$SCRIPT_DIR/public/"
fi
if [ -f "$REPO_ROOT/WORKFLOW_README.md" ]; then
    cp "$REPO_ROOT/WORKFLOW_README.md" "$SCRIPT_DIR/public/"
fi
if [ -f "$REPO_ROOT/CHANGELOG.md" ]; then
    cp "$REPO_ROOT/CHANGELOG.md" "$SCRIPT_DIR/public/"
fi

# Copy .claude directory (Enhanced Claude commands)
if [ -d "$REPO_ROOT/.claude" ]; then
    rsync -av --delete "$REPO_ROOT/.claude/" "$SCRIPT_DIR/public/.claude/"
fi

# Copy .github workflows directory  
if [ -d "$REPO_ROOT/.github" ]; then
    rsync -av --delete "$REPO_ROOT/.github/" "$SCRIPT_DIR/public/.github/"
fi

# Copy docs directory (ensuring we don't overwrite but sync)
rsync -av --delete "$REPO_ROOT/docs/" "$SCRIPT_DIR/public/docs/"

# Copy examples directory
if [ -d "$REPO_ROOT/examples" ]; then
    rsync -av --delete "$REPO_ROOT/examples/" "$SCRIPT_DIR/public/examples/"
fi

# Copy scripts directory
if [ -d "$REPO_ROOT/scripts" ]; then
    rsync -av --delete "$REPO_ROOT/scripts/" "$SCRIPT_DIR/public/scripts/"
fi

# Copy tools directory
if [ -d "$REPO_ROOT/tools" ]; then
    rsync -av --delete "$REPO_ROOT/tools/" "$SCRIPT_DIR/public/tools/"
fi

echo "Documentation files copied successfully!"
echo "Files available in public directory:"
echo "- README.md"
echo "- git-commands-and-setup.md"
echo "- CLAUDE.md"
echo "- LICENSE"
echo "- IMPLEMENTATION_GUIDE.md (Enhanced Claude workflow guide)"
echo "- WORKFLOW_README.md (Usage and maintenance)"
echo "- CHANGELOG.md (Version 1.2.0 changes)"
echo "- .claude/ (Custom Claude commands)"
echo "- .github/ (Automated workflows)"
echo "- docs/ (complete documentation structure)"
if [ -d "$REPO_ROOT/examples" ]; then
    echo "- examples/ (configuration examples)"
fi
if [ -d "$REPO_ROOT/scripts" ]; then
    echo "- scripts/ (validation and workflow scripts)"
fi
if [ -d "$REPO_ROOT/tools" ]; then
    echo "- tools/ (compliance checker)"
fi
