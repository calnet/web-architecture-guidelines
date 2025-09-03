#!/bin/bash

# Script to check for template updates
echo "Checking for base template updates..."

# Compare template versions
BASE_TEMPLATE_VERSION=$(curl -s $BASE_REPO/docs/templates/VERSION)
LOCAL_TEMPLATE_VERSION=$(cat docs/.template-version 2>/dev/null || echo "unknown")

if [ "$BASE_TEMPLATE_VERSION" != "$LOCAL_TEMPLATE_VERSION" ]; then
    echo "📋 Template updates available!"
    echo "Current: $LOCAL_TEMPLATE_VERSION"
    echo "Latest: $BASE_TEMPLATE_VERSION"
    echo "Run 'npm run docs:update-templates' to update"
    exit 1
else
    echo "✅ Templates are up to date"
    exit 0
fi