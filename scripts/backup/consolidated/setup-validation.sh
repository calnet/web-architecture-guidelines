#!/bin/bash

# Setup script for version and date validation system
# This script configures git hooks and validates the system is working correctly

set -e

echo "🔧 Setting up Version and Date Validation System"
echo "================================================"
echo ""

# Make all scripts executable
echo "📋 Making scripts executable..."
chmod +x ./scripts/validate-versions.sh
chmod +x ./scripts/validate-dates.sh
chmod +x ./scripts/validate-comprehensive.sh
chmod +x ./scripts/sync-versions.sh
chmod +x ./scripts/sync-dates.sh
chmod +x .githooks/pre-commit

echo "✅ Scripts made executable"
echo ""

# Configure git hooks
echo "🪝 Configuring git hooks..."
if git config core.hooksPath .githooks; then
    echo "✅ Git hooks configured to use .githooks directory"
else
    echo "⚠️  Failed to configure git hooks - you may need to set this manually:"
    echo "   git config core.hooksPath .githooks"
fi
echo ""

# Validate the system
echo "🔍 Testing validation system..."
if ./scripts/validate-comprehensive.sh; then
    echo "✅ Validation system is working correctly"
    SYSTEM_HEALTHY=true
else
    echo "⚠️  Validation system detected issues - this is normal for new setups"
    echo "🔧 Attempting to fix automatically..."
    
    # Try to fix issues
    ./scripts/sync-versions.sh
    ./scripts/sync-dates.sh
    
    echo "🔍 Re-testing after fixes..."
    if ./scripts/validate-comprehensive.sh; then
        echo "✅ Validation system is now working correctly"
        SYSTEM_HEALTHY=true
    else
        echo "❌ Validation system still has issues - manual intervention required"
        SYSTEM_HEALTHY=false
    fi
fi
echo ""

# Summary
echo "📊 Setup Summary"
echo "================"
echo ""

if $SYSTEM_HEALTHY; then
    echo "🎉 Setup completed successfully!"
    echo ""
    echo "📋 Available commands:"
    echo "   ./scripts/validate-comprehensive.sh  - Run full validation"
    echo "   ./scripts/validate-versions.sh       - Check version consistency"
    echo "   ./scripts/validate-dates.sh          - Check date accuracy"
    echo "   ./scripts/sync-versions.sh           - Fix version inconsistencies"
    echo "   ./scripts/sync-dates.sh              - Fix date inconsistencies"
    echo ""
    echo "🪝 Git hooks are configured:"
    echo "   Pre-commit validation will run automatically"
    echo "   Use 'git commit --no-verify' to skip validation if needed"
    echo ""
    echo "🤖 GitHub Actions:"
    echo "   Version and date validation runs on PR and push"
    echo "   Auto-fix can be triggered manually with workflow dispatch"
else
    echo "⚠️  Setup completed with warnings"
    echo ""
    echo "🔧 Manual steps required:"
    echo "   1. Review validation output above"
    echo "   2. Fix any remaining issues manually"
    echo "   3. Run: ./scripts/validate-comprehensive.sh"
    echo ""
    echo "📧 If issues persist, check:"
    echo "   - File permissions on scripts"
    echo "   - Repository structure matches expected layout"
    echo "   - All required files are present"
fi

echo ""
echo "📚 For more information, see:"
echo "   - .github/workflows/version-date-validation.yml"
echo "   - scripts/validate-comprehensive.sh"
echo "   - .githooks/pre-commit"