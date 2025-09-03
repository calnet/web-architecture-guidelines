#!/bin/bash

echo "📋 Copying templates from base guidelines..."

# Function to copy template and preserve structure
copy_template() {
    local source=$1
    local dest=$2
    local template_name=$3
    
    if [ -f "$source" ]; then
        mkdir -p "$(dirname "$dest")"
        cp "$source" "$dest"
        echo "✅ Copied $template_name to $dest"
    else
        echo "❌ Source template not found: $source"
        return 1
    fi
}

# Create project documentation structure
mkdir -p docs/{architecture,api,user-guides,development}
mkdir -p docs/architecture/decisions
mkdir -p docs/architecture/diagrams

# Copy relevant templates from base guidelines
copy_template "docs/templates/architecture/adr-template.md" "docs/architecture/adr-template.md" "ADR template"
copy_template "docs/templates/architecture/system-architecture-document.md" "docs/architecture/system-architecture.md" "System architecture template"
copy_template "docs/templates/api/api-specification.md" "docs/api/api-specification.md" "API specification template"
copy_template "docs/templates/user-guides/user-manual-template.md" "docs/user-guides/user-manual.md" "User manual template"
copy_template "docs/templates/user-guides/admin-manual-template.md" "docs/user-guides/admin-manual.md" "Admin manual template"
copy_template "docs/templates/development/setup-guide-template.md" "docs/development/setup-guide.md" "Setup guide template"
copy_template "docs/templates/development/coding-standards-template.md" "docs/development/coding-standards.md" "Coding standards template"

echo "🎉 Template copying completed!"