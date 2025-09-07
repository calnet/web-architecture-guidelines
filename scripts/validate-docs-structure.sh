#!/bin/bash

echo "🔍 Validating documentation structure..."

# Function to check if directory exists
check_directory() {
    if [ ! -d "$1" ]; then
        echo "❌ Missing directory: $1"
        return 1
    else
        echo "✅ Directory exists: $1"
        return 0
    fi
}

# Function to check if file exists
check_file() {
    if [ ! -f "$1" ]; then
        echo "❌ Missing file: $1"
        return 1
    else
        echo "✅ File exists: $1"
        return 0
    fi
}

# Check required directories
ERRORS=0

check_directory "docs/ai-agents" || ERRORS=$((ERRORS + 1))
check_directory "docs/templates" || ERRORS=$((ERRORS + 1))
check_directory "docs/templates/architecture" || ERRORS=$((ERRORS + 1))
check_directory "docs/templates/api" || ERRORS=$((ERRORS + 1))
check_directory "docs/templates/user-guides" || ERRORS=$((ERRORS + 1))
check_directory "docs/templates/development" || ERRORS=$((ERRORS + 1))

# Check required files
check_file "docs/external-documentation-links.md" || ERRORS=$((ERRORS + 1))
check_file "docs/project-integration-guide.md" || ERRORS=$((ERRORS + 1))
check_file "docs/templates/README.md" || ERRORS=$((ERRORS + 1))

# Check AI agent instruction files
check_file "docs/ai-agents/claude-architecture-instructions.md" || ERRORS=$((ERRORS + 1))
check_file "docs/ai-agents/chatgpt-architecture-instructions.md" || ERRORS=$((ERRORS + 1))
check_file "docs/ai-agents/copilot-architecture-instructions.md" || ERRORS=$((ERRORS + 1))
check_file "docs/ai-agents/gemini-architecture-instructions.md" || ERRORS=$((ERRORS + 1))
check_file "docs/ai-agents/anthropic-api-architecture-instructions.md" || ERRORS=$((ERRORS + 1))

# Check template files
check_file "docs/templates/architecture/adr-template.md" || ERRORS=$((ERRORS + 1))
check_file "docs/templates/architecture/system-architecture-document.md" || ERRORS=$((ERRORS + 1))
check_file "docs/templates/api/api-specification.md" || ERRORS=$((ERRORS + 1))
check_file "docs/templates/user-guides/user-manual-template.md" || ERRORS=$((ERRORS + 1))
check_file "docs/templates/user-guides/admin-manual-template.md" || ERRORS=$((ERRORS + 1))
check_file "docs/templates/development/setup-guide-template.md" || ERRORS=$((ERRORS + 1))
check_file "docs/templates/development/coding-standards-template.md" || ERRORS=$((ERRORS + 1))

# Summary
echo ""
if [ $ERRORS -eq 0 ]; then
    echo "🎉 All documentation structure validation checks passed!"
    exit 0
else
    echo "💥 Found $ERRORS errors in documentation structure"
    exit 1
fi