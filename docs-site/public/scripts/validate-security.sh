#!/bin/bash

echo "🔒 Validating security compliance..."

ERRORS=0

# Function to check for security configuration
check_security_config() {
    local config="$1"
    local files=("${@:2}")
    
    for file in "${files[@]}"; do
        if [ -f "$file" ] && grep -qi "$config" "$file"; then
            echo "✅ $config configured in $file"
            return 0
        fi
    done
    
    echo "❌ $config not found in configuration files"
    return 1
}

# Check for security documentation
if [ -f "docs/security.md" ] || grep -qi "security" "ARCHITECTURE.md" 2>/dev/null || grep -qi "security" "docs/architecture/system-architecture.md" 2>/dev/null; then
    echo "✅ Security documentation found"
else
    echo "❌ No security documentation found"
    ERRORS=$((ERRORS + 1))
fi

# Check for environment variable security
if [ -f ".env.example" ]; then
    echo "✅ Environment variable template found"
    
    # Check for required security variables
    check_security_config "JWT_SECRET\|SESSION_SECRET" ".env.example" || ERRORS=$((ERRORS + 1))
    check_security_config "CORS_ORIGIN\|CORS" ".env.example" || ERRORS=$((ERRORS + 1))
    
    # Check for insecure defaults
    if grep -q "password\|secret.*=.*['\"].*['\"]" ".env.example" && ! grep -q "change.*production\|replace.*production" ".env.example"; then
        echo "⚠️  Environment variables contain default secrets (ensure they're marked for production change)"
    fi
else
    echo "❌ No .env.example file found"
    ERRORS=$((ERRORS + 1))
fi

# Check for HTTPS configuration
CONFIG_FILES=("next.config.js" "server.js" "app.js" "index.js" "package.json" ".env.example")
if check_security_config "https\|ssl\|tls\|HTTPS\|SSL\|TLS" "${CONFIG_FILES[@]}"; then
    echo "✅ HTTPS/SSL configuration found"
elif grep -qi "secure.*true\|httpOnly.*true" "${CONFIG_FILES[@]}" 2>/dev/null; then
    echo "✅ Secure cookie configuration found"
else
    echo "⚠️  No explicit HTTPS/SSL configuration found"
fi

# Check for security headers configuration
SECURITY_HEADER_FILES=("next.config.js" "server.js" "app.js" "index.js" ".env.example")
if check_security_config "helmet\|security.*headers\|HELMET\|CSP\|HSTS\|X_FRAME_OPTIONS" "${SECURITY_HEADER_FILES[@]}"; then
    echo "✅ Security headers configuration found"
else
    echo "⚠️  No security headers configuration found (consider adding helmet.js or similar)"
fi

# Check for input validation
if [ -d "src" ] || [ -d "lib" ] || [ -d "pages" ]; then
    if find . -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" | xargs grep -l "validation\|validate\|sanitize\|joi\|yup\|zod" > /dev/null 2>&1; then
        echo "✅ Input validation libraries found in codebase"
    else
        echo "⚠️  No explicit input validation found (ensure user inputs are validated)"
    fi
fi

# Check for authentication configuration
if check_security_config "auth\|passport\|jwt\|oauth" "${CONFIG_FILES[@]}" ".env.example"; then
    echo "✅ Authentication configuration found"
else
    echo "❌ No authentication configuration found"
    ERRORS=$((ERRORS + 1))
fi

# Check for dependency security
if [ -f "package.json" ]; then
    echo "✅ Package.json found"
    
    # Check for security audit scripts
    if grep -q "audit\|security" "package.json"; then
        echo "✅ Security audit scripts configured"
    else
        echo "⚠️  No security audit scripts found (add 'npm audit' to CI/CD)"
    fi
    
    # Check for known vulnerable dependencies (basic check)
    if [ -f "package-lock.json" ] && command -v npm > /dev/null; then
        echo "Running npm audit..."
        if npm audit --audit-level=moderate > /dev/null 2>&1; then
            echo "✅ No high/critical vulnerabilities found"
        else
            echo "⚠️  Security vulnerabilities detected - run 'npm audit' for details"
        fi
    fi
fi

# Check for secrets in repository
echo "Checking for potential secrets in repository..."
if find . -type f -name "*.js" -o -name "*.ts" -o -name "*.json" -o -name "*.md" | xargs grep -l "api_key\|apikey\|password.*=\|secret.*=" 2>/dev/null | grep -v ".env.example" | grep -v "node_modules" > /dev/null; then
    echo "⚠️  Potential secrets found in repository files (review carefully)"
else
    echo "✅ No obvious secrets found in repository"
fi

# Summary
echo ""
if [ $ERRORS -eq 0 ]; then
    echo "🎉 Security validation passed!"
    exit 0
else
    echo "💥 Found $ERRORS security compliance issues"
    exit 1
fi