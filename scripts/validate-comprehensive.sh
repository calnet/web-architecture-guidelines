#!/bin/bash

# Comprehensive Version and Date Validation Script
# This script performs complete validation of both version consistency and date accuracy

set -e

# Performance tracking and logging
start_time=$(date +%s)
VALIDATION_LOG="/tmp/comprehensive_validation_$(date +%Y%m%d_%H%M%S).log"

echo "🔍 Comprehensive Version & Date Validation" | tee "$VALIDATION_LOG"
echo "===========================================" | tee -a "$VALIDATION_LOG"
echo "" | tee -a "$VALIDATION_LOG"

VERSION_ERRORS=0
DATE_ERRORS=0
TOTAL_WARNINGS=0
SUCCESS=true

# Run version validation
echo "📋 Step 1: Version Validation" | tee -a "$VALIDATION_LOG"
echo "=============================" | tee -a "$VALIDATION_LOG"
./scripts/validate-versions.sh 2>&1 | tee -a "$VALIDATION_LOG"
VERSION_ERRORS=${PIPESTATUS[0]}
if [ $VERSION_ERRORS -eq 0 ]; then
    echo "✅ Version validation passed" | tee -a "$VALIDATION_LOG"
else
    echo "❌ Version validation failed with exit code: $VERSION_ERRORS" | tee -a "$VALIDATION_LOG"
    SUCCESS=false
fi

echo "" | tee -a "$VALIDATION_LOG"

# Run date validation
echo "📅 Step 2: Date Validation" | tee -a "$VALIDATION_LOG"
echo "==========================" | tee -a "$VALIDATION_LOG"
./scripts/validate-dates.sh 2>&1 | tee -a "$VALIDATION_LOG"
DATE_ERRORS=${PIPESTATUS[0]}
if [ $DATE_ERRORS -eq 0 ]; then
    echo "✅ Date validation passed" | tee -a "$VALIDATION_LOG"
else
    echo "❌ Date validation failed with exit code: $DATE_ERRORS" | tee -a "$VALIDATION_LOG"
    SUCCESS=false
fi

echo "" | tee -a "$VALIDATION_LOG"

# Final summary
end_time=$(date +%s)
duration=$((end_time - start_time))

echo "📊 Comprehensive Validation Summary" | tee -a "$VALIDATION_LOG"
echo "====================================" | tee -a "$VALIDATION_LOG"
echo "   Duration: ${duration}s" | tee -a "$VALIDATION_LOG"

if $SUCCESS; then
    echo "🎉 ALL CHECKS PASSED!" | tee -a "$VALIDATION_LOG"
    echo "   ✅ Version consistency: PASSED" | tee -a "$VALIDATION_LOG"
    echo "   ✅ Date accuracy: PASSED" | tee -a "$VALIDATION_LOG"
    echo "" | tee -a "$VALIDATION_LOG"
    echo "📋 Repository is fully validated and ready for release" | tee -a "$VALIDATION_LOG"
    exit 0
else
    echo "💥 VALIDATION FAILURES DETECTED!" | tee -a "$VALIDATION_LOG"
    echo "   Version errors: $VERSION_ERRORS" | tee -a "$VALIDATION_LOG"
    echo "   Date errors: $DATE_ERRORS" | tee -a "$VALIDATION_LOG"
    echo "" | tee -a "$VALIDATION_LOG"
    echo "🔧 Suggested fixes:" | tee -a "$VALIDATION_LOG"
    
    if [[ $VERSION_ERRORS -ne 0 ]]; then
        echo "   - Run: ./scripts/sync-versions.sh" | tee -a "$VALIDATION_LOG"
    fi
    
    if [[ $DATE_ERRORS -ne 0 ]]; then
        echo "   - Run: ./scripts/sync-dates.sh" | tee -a "$VALIDATION_LOG"
    fi
    
    echo "   - Then re-run: ./scripts/validate-comprehensive.sh" | tee -a "$VALIDATION_LOG"
    echo "" | tee -a "$VALIDATION_LOG"
    echo "📝 Full log saved to: $VALIDATION_LOG" | tee -a "$VALIDATION_LOG"
    exit 1
fi