#!/bin/bash

# Script to copy documentation files to public directory for serving

echo "Copying documentation files to public directory..."

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Create public/docs if it doesn't exist
mkdir -p "$SCRIPT_DIR/public/docs"

echo "Working from repository root: $REPO_ROOT"

# Copy main documentation files
cp "$REPO_ROOT/README.md" "$SCRIPT_DIR/public/"
cp "$REPO_ROOT/git-commands-and-setup.md" "$SCRIPT_DIR/public/"
cp "$REPO_ROOT/CLAUDE.md" "$SCRIPT_DIR/public/"
cp "$REPO_ROOT/LICENSE" "$SCRIPT_DIR/public/"

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
echo "- docs/ (complete documentation structure)"
if [ -d "$REPO_ROOT/examples" ]; then
    echo "- examples/ (configuration examples)"
fi
if [ -d "$REPO_ROOT/scripts" ]; then
    echo "- scripts/ (validation scripts)"
fi
if [ -d "$REPO_ROOT/tools" ]; then
    echo "- tools/ (compliance checker)"
fi
