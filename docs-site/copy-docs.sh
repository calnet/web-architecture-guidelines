#!/bin/bash

# Script to copy documentation files to public directory for serving

echo "Copying documentation files to public directory..."

# Create public/docs if it doesn't exist
mkdir -p public/docs

# Copy all documentation from parent directory
cd ..

# Copy main documentation files
cp README.md git-commands-and-setup.md CLAUDE.md LICENSE docs-site/public/

# Copy docs directory
cp -r docs docs-site/public/

# Copy examples directory
cp -r examples docs-site/public/

# Copy scripts directory
cp -r scripts docs-site/public/

# Copy tools directory
cp -r tools docs-site/public/

echo "Documentation files copied successfully!"
echo "Files available in public directory:"
echo "- README.md"
echo "- git-commands-and-setup.md"
echo "- CLAUDE.md"
echo "- LICENSE"
echo "- docs/ (complete documentation structure)"
echo "- examples/ (configuration examples)"
echo "- scripts/ (validation scripts)"
echo "- tools/ (compliance checker)"
