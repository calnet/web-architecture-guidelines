#!/bin/bash

echo "🏗️ Validating architecture compliance..."

ERRORS=0

# Function to check if architectural principle is documented
check_principle() {
    local principle="$1"
    local file="$2"
    
    if [ -f "$file" ] && grep -qi "$principle" "$file"; then
        echo "✅ $principle documented in $file"
        return 0
    else
        echo "❌ $principle not found in $file"
        return 1
    fi
}

# Check for architectural documentation
if [ -f "ARCHITECTURE.md" ] || [ -f "docs/architecture/system-architecture.md" ]; then
    echo "✅ Architecture documentation found"
    ARCH_FILE="ARCHITECTURE.md"
    [ -f "docs/architecture/system-architecture.md" ] && ARCH_FILE="docs/architecture/system-architecture.md"
    
    # Check for key architectural principles
    check_principle "Clean Architecture\|Layered Architecture\|Hexagonal Architecture" "$ARCH_FILE" || ERRORS=$((ERRORS + 1))
    check_principle "Security\|Security-by-design" "$ARCH_FILE" || ERRORS=$((ERRORS + 1))
    check_principle "Performance\|Scalability" "$ARCH_FILE" || ERRORS=$((ERRORS + 1))
    check_principle "Testing\|Test" "$ARCH_FILE" || ERRORS=$((ERRORS + 1))
    
else
    echo "❌ No architecture documentation found"
    ERRORS=$((ERRORS + 1))
fi

# Check for ADR documentation
if [ -d "docs/architecture/decisions" ] && [ "$(ls -A docs/architecture/decisions 2>/dev/null)" ]; then
    echo "✅ Architecture Decision Records found"
    
    # Check ADR format compliance
    for adr in docs/architecture/decisions/*.md; do
        if [ -f "$adr" ]; then
            if grep -q "Status\|Context\|Decision\|Consequences" "$adr"; then
                echo "✅ $(basename "$adr") follows ADR format"
            else
                echo "❌ $(basename "$adr") missing required ADR sections"
                ERRORS=$((ERRORS + 1))
            fi
        fi
    done
else
    echo "⚠️  No Architecture Decision Records found (recommended for complex projects)"
fi

# Check for technology stack documentation
if grep -qi "technology stack\|tech stack\|dependencies" "$ARCH_FILE" 2>/dev/null; then
    echo "✅ Technology stack documented"
else
    echo "❌ Technology stack not documented"
    ERRORS=$((ERRORS + 1))
fi

# Check for deployment documentation
if [ -f "docs/development/deployment-guide.md" ] || grep -qi "deployment\|infrastructure" "$ARCH_FILE" 2>/dev/null; then
    echo "✅ Deployment strategy documented"
else
    echo "❌ Deployment strategy not documented"
    ERRORS=$((ERRORS + 1))
fi

# Summary
echo ""
if [ $ERRORS -eq 0 ]; then
    echo "🎉 Architecture validation passed!"
    exit 0
else
    echo "💥 Found $ERRORS architecture compliance issues"
    exit 1
fi