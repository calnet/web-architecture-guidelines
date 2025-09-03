#!/bin/bash

echo "🔍 Validating template completeness..."

# Function to validate template structure
validate_template() {
    local template_file="$1"
    local template_name="$2"
    local required_sections=("${@:3}")
    
    if [ ! -f "$template_file" ]; then
        echo "❌ Template not found: $template_file"
        return 1
    fi
    
    echo "Checking template: $template_name"
    
    # Check for basic template structure
    if ! grep -q "^#" "$template_file"; then
        echo "❌ Missing title in $template_file"
        return 1
    fi
    
    # Check for required sections
    local missing_sections=()
    for section in "${required_sections[@]}"; do
        if ! grep -qi "$section" "$template_file"; then
            missing_sections+=("$section")
        fi
    done
    
    if [ ${#missing_sections[@]} -gt 0 ]; then
        echo "⚠️  Missing sections in $template_name: ${missing_sections[*]}"
    else
        echo "✅ Template structure valid: $template_name"
    fi
    
    # Check for template metadata
    if grep -q "Template" "$template_file" || grep -q "template" "$template_file"; then
        echo "✅ Template metadata found in $template_name"
    else
        echo "⚠️  No template metadata found in $template_name"
    fi
    
    return 0
}

# Validate each template with required sections
validate_template "docs/templates/architecture/adr-template.md" "ADR Template" "Status" "Context" "Decision" "Consequences"
validate_template "docs/templates/architecture/system-architecture-document.md" "System Architecture" "Overview" "Architecture" "Components" "Security"
validate_template "docs/templates/api/api-specification.md" "API Specification" "Authentication" "Endpoints" "Error Handling" "Rate Limiting"
validate_template "docs/templates/user-guides/user-manual-template.md" "User Manual" "Getting Started" "Features" "Troubleshooting"
validate_template "docs/templates/user-guides/admin-manual-template.md" "Admin Manual" "Administration" "Configuration" "Monitoring"
validate_template "docs/templates/development/setup-guide-template.md" "Setup Guide" "Prerequisites" "Installation" "Configuration" "Verification"
validate_template "docs/templates/development/coding-standards-template.md" "Coding Standards" "Code Style" "Best Practices" "Testing"

echo ""
echo "🎉 Template validation completed!"