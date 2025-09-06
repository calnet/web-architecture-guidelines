#!/bin/bash

# Workflow Testing Script
# Creates comprehensive tests for the enhanced Claude Code Review system

set -e

# Configuration
REPO="calnet/web-architecture-guidelines"
TEST_BRANCH="test/workflow-validation-$(date +%Y%m%d-%H%M%S)"
CLEANUP_ON_SUCCESS=true

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Cleanup function
cleanup() {
    local exit_code=$?
    
    if [[ "$CLEANUP_ON_SUCCESS" == "true" && $exit_code -eq 0 ]]; then
        echo -e "${BLUE}🧹 Cleaning up test artifacts...${NC}"
        
        # Delete test branch
        if git branch -a | grep -q "$TEST_BRANCH"; then
            git checkout main >/dev/null 2>&1 || git checkout develop >/dev/null 2>&1
            git branch -D "$TEST_BRANCH" >/dev/null 2>&1 || true
            git push origin --delete "$TEST_BRANCH" >/dev/null 2>&1 || true
        fi
        
        # Remove test files
        rm -f TEST_*.md test_*.py test_*.json >/dev/null 2>&1 || true
        
        echo -e "${GREEN}✅ Cleanup completed${NC}"
    elif [[ $exit_code -ne 0 ]]; then
        echo -e "${YELLOW}⚠️ Test failed - preserving artifacts for debugging${NC}"
        echo -e "${BLUE}Test branch: $TEST_BRANCH${NC}"
    fi
}

trap cleanup EXIT

echo -e "${BLUE}🧪 Testing Enhanced Workflow System${NC}"
echo "===================================="

# Check prerequisites
echo -e "${BLUE}📋 Checking prerequisites...${NC}"
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI not installed${NC}"
    exit 1
fi

if ! gh auth status &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI not authenticated${NC}"
    exit 1
fi

if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo -e "${RED}❌ Not in a git repository${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites verified${NC}"

# Create test branch
echo -e "${BLUE}🌿 Creating test branch: $TEST_BRANCH${NC}"
git checkout -b "$TEST_BRANCH"

# Create test files for different scenarios
echo -e "${BLUE}📝 Creating test files...${NC}"

# Test 1: Documentation change
cat > TEST_DOCUMENTATION.md << 'TEST_EOF'
# Test Documentation

This is a test documentation file to validate the workflow system.

## Purpose
- Test documentation template compliance
- Validate @claude review functionality
- Check custom slash command integration

## Architecture Compliance
This document should trigger review against our documentation templates.

## Security Considerations
No security implications for this test document.

## Performance Impact
Minimal performance impact expected.
