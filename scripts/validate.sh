#!/bin/bash

# Simple validation script for workflows

set -e

MODE="${1:-full}"
if [ "$1" = "--mode" ] && [ -n "$2" ]; then
    MODE="$2"
fi

echo "ℹ️  Validation Script - Mode: $MODE"
echo "======================================"

PASSED=0
FAILED=0

# Basic file checks
echo "🔄 Checking repository structure"
for file in README.md VERSION package.json; do
    if [ -f "$file" ]; then
        PASSED=$((PASSED + 1))
    else
        FAILED=$((FAILED + 1))
        echo "❌ $file missing"
    fi
done

for dir in scripts docs; do
    if [ -d "$dir" ]; then
        PASSED=$((PASSED + 1))
    else
        FAILED=$((FAILED + 1))
        echo "❌ $dir missing"
    fi
done

# Simple version check
echo "🔄 Version validation"
if [ -f "VERSION" ] && [ -s "VERSION" ]; then
    PASSED=$((PASSED + 1))
else
    FAILED=$((FAILED + 1))
    echo "❌ Version validation failed"
fi

# Additional checks for full mode
if [ "$MODE" = "full" ]; then
    echo "🔄 Additional validations"
    for dir in docs/ai-agents docs/templates docs/architecture; do
        if [ -d "$dir" ]; then
            PASSED=$((PASSED + 1))
        else
            FAILED=$((FAILED + 1))
            echo "❌ $dir missing"
        fi
    done
fi

echo ""
echo "Summary: $PASSED passed, $FAILED failed"

if [ $FAILED -gt 0 ]; then
    exit 1
else
    exit 0
fi
