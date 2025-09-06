#!/bin/bash

# GitHub Workflows Creation Script
# Creates GitHub workflow files for enhanced Claude Code Review system

set -e

# Load common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/workflow-utils.sh"

# Script-specific configuration
WORKFLOWS_DIR=".github/workflows"

show_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Creates GitHub workflow files for the enhanced Claude Code Review system."
    echo ""
    show_common_help
    echo "Created workflows:"
    echo "  - claude-code-review.yml: Main Claude code review workflow"
    echo "  - advanced-architecture-review.yml: Advanced multi-stage workflow"
    echo ""
}

create_main_workflow() {
    local workflow_file="$WORKFLOWS_DIR/claude-code-review.yml"
    
    print_header "📄 Creating main Claude code review workflow..."
    
    backup_file "$workflow_file"
    
    if is_dry_run; then
        print_info "DRY RUN: Would create $workflow_file"
        return 0
    fi
    
    cat > "$workflow_file" << 'EOF'
name: Enhanced Claude Code Review

on:
  pull_request:
    types: [opened, synchronize, reopened]
    branches: [main, develop]
  issue_comment:
    types: [created]
  schedule:
    - cron: '0 9 * * 1'  # Weekly comprehensive review on Mondays at 9 AM

env:
  ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}

jobs:
  claude-review:
    if: github.event_name == 'pull_request' || (github.event_name == 'issue_comment' && contains(github.event.comment.body, '@claude'))
    runs-on: ubuntu-latest
    
    permissions:
      contents: read
      pull-requests: write
      issues: write
      
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
          
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Run security validation
        run: npm run lint:security
        continue-on-error: true
        
      - name: Run architecture validation
        run: npm run lint:architecture
        continue-on-error: true
        
      - name: Run performance validation
        run: npm run lint:performance
        continue-on-error: true
        
      - name: Enhanced Claude Code Review
        uses: anthropics/claude-code-action@v1
        with:
          anthropic-api-key: ${{ secrets.ANTHROPIC_API_KEY }}
          github-token: ${{ secrets.GITHUB_TOKEN }}
          model: 'claude-3-5-sonnet-20241022'
          max-tokens: 4000
          system-prompt: |
            You are an expert software architect and code reviewer specializing in web application development. 

            ## Your Role
            Provide comprehensive, actionable code reviews focusing on:
            - Architecture compliance with established patterns
            - Security best practices and vulnerability identification
            - Performance optimization opportunities
            - Code maintainability and readability
            - Documentation quality and completeness

            ## Review Standards
            - Reference the project's Web Architecture Guidelines
            - Identify deviations from documented standards
            - Suggest specific improvements with examples
            - Prioritize critical security and performance issues
            - Provide constructive, educational feedback

            ## Output Format
            Structure your reviews with:
            1. **Summary**: Brief overview of changes and overall assessment
            2. **Critical Issues**: Security vulnerabilities, breaking changes
            3. **Architecture**: Compliance with established patterns
            4. **Performance**: Optimization opportunities
            5. **Maintainability**: Code quality improvements
            6. **Documentation**: Missing or inadequate documentation
            7. **Recommendations**: Specific action items

            Keep feedback concise, actionable, and focused on the most impactful improvements.
          
          include-file-context: true
          review-changed-files-only: true
          
      - name: Custom Command Detection
        if: github.event_name == 'issue_comment'
        run: |
          COMMENT_BODY="${{ github.event.comment.body }}"
          
          if echo "$COMMENT_BODY" | grep -q "/architecture-review"; then
            echo "CUSTOM_COMMAND=architecture-review" >> $GITHUB_ENV
          elif echo "$COMMENT_BODY" | grep -q "/security-scan"; then
            echo "CUSTOM_COMMAND=security-scan" >> $GITHUB_ENV
          elif echo "$COMMENT_BODY" | grep -q "/performance-check"; then
            echo "CUSTOM_COMMAND=performance-check" >> $GITHUB_ENV
          elif echo "$COMMENT_BODY" | grep -q "/documentation-audit"; then
            echo "CUSTOM_COMMAND=documentation-audit" >> $GITHUB_ENV
          elif echo "$COMMENT_BODY" | grep -q "/quick-fix"; then
            echo "CUSTOM_COMMAND=quick-fix" >> $GITHUB_ENV
          fi
          
      - name: Execute Custom Command
        if: env.CUSTOM_COMMAND != ''
        run: |
          if [ -f ".claude/commands/${CUSTOM_COMMAND}.md" ]; then
            echo "Executing custom command: $CUSTOM_COMMAND"
            cat .claude/commands/${CUSTOM_COMMAND}.md
          fi

  comprehensive-audit:
    if: github.event_name == 'schedule'
    runs-on: ubuntu-latest
    
    permissions:
      contents: read
      issues: write
      
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Run comprehensive validation
        run: npm run validate:all
        
      - name: Weekly Architecture Audit
        uses: anthropics/claude-code-action@v1
        with:
          anthropic-api-key: ${{ secrets.ANTHROPIC_API_KEY }}
          github-token: ${{ secrets.GITHUB_TOKEN }}
          model: 'claude-3-5-sonnet-20241022'
          max-tokens: 8000
          system-prompt: |
            Perform a comprehensive weekly audit of the codebase focusing on:
            
            ## Architecture Evolution
            - Identify architectural drift from documented patterns
            - Assess technical debt accumulation
            - Review consistency across modules
            
            ## Security Posture
            - Comprehensive security vulnerability assessment
            - Review of security controls and configurations
            - Assessment of dependency security status
            
            ## Performance Trends
            - Identify performance degradation patterns
            - Review optimization opportunities
            - Assess scalability considerations
            
            ## Documentation Currency
            - Validate documentation accuracy
            - Identify documentation gaps
            - Assess template compliance
            
            Create a detailed issue with findings and recommendations for the development team.
          
          create-issue: true
          issue-title: "Weekly Architecture and Security Audit - $(date '+%Y-%m-%d')"
EOF

    validate_file_creation "$workflow_file" "Main Claude workflow"
}

create_advanced_workflow() {
    local workflow_file="$WORKFLOWS_DIR/advanced-architecture-review.yml"
    
    print_header "📄 Creating advanced architecture review workflow..."
    
    backup_file "$workflow_file"
    
    if is_dry_run; then
        print_info "DRY RUN: Would create $workflow_file"
        return 0
    fi
    
    cat > "$workflow_file" << 'EOF'
name: Advanced Architecture Review

on:
  pull_request:
    types: [opened, synchronize]
    branches: [main]
    paths:
      - 'docs/architecture/**'
      - 'docs/templates/**'
      - '**/*.md'
      - 'scripts/**'
  workflow_dispatch:
    inputs:
      review_type:
        description: 'Type of architecture review'
        required: true
        default: 'comprehensive'
        type: choice
        options:
          - comprehensive
          - security-focused
          - performance-focused
          - documentation-audit

env:
  ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}

jobs:
  pre-review-validation:
    runs-on: ubuntu-latest
    outputs:
      should-review: ${{ steps.check.outputs.should-review }}
      review-scope: ${{ steps.scope.outputs.scope }}
      
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
          
      - name: Check if review needed
        id: check
        run: |
          # Check if significant architectural changes
          if git diff --name-only HEAD~1 HEAD | grep -E "(architecture|docs|templates)" > /dev/null; then
            echo "should-review=true" >> $GITHUB_OUTPUT
          else
            echo "should-review=false" >> $GITHUB_OUTPUT
          fi
          
      - name: Determine review scope
        id: scope
        run: |
          SCOPE="standard"
          
          # Check for high-impact changes
          if git diff --name-only HEAD~1 HEAD | grep -E "(system-architecture|security)" > /dev/null; then
            SCOPE="comprehensive"
          elif git diff --name-only HEAD~1 HEAD | grep -E "(templates)" > /dev/null; then
            SCOPE="template-focused"
          elif git diff --name-only HEAD~1 HEAD | grep -E "(performance)" > /dev/null; then
            SCOPE="performance-focused"
          fi
          
          echo "scope=$SCOPE" >> $GITHUB_OUTPUT

  architecture-compliance:
    needs: pre-review-validation
    if: needs.pre-review-validation.outputs.should-review == 'true'
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        review-area: [architecture, security, performance, documentation, accessibility]
        
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Run area-specific validation
        run: |
          case "${{ matrix.review-area }}" in
            architecture)
              npm run lint:architecture
              ;;
            security)
              npm run lint:security
              ;;
            performance)
              npm run lint:performance
              ;;
            documentation)
              npm run docs:validate-structure
              ;;
            accessibility)
              echo "Accessibility validation (placeholder)"
              ;;
          esac
          
      - name: Specialized Claude Review
        uses: anthropics/claude-code-action@v1
        with:
          anthropic-api-key: ${{ secrets.ANTHROPIC_API_KEY }}
          github-token: ${{ secrets.GITHUB_TOKEN }}
          model: 'claude-3-5-sonnet-20241022'
          max-tokens: 6000
          system-prompt: |
            You are conducting a specialized ${{ matrix.review-area }} review for a web architecture guidelines repository.

            ## Focus Area: ${{ matrix.review-area }}
            
            ### 1. Architecture Compliance Assessment
            - Evaluate adherence to documented architectural patterns
            - Identify deviations from established guidelines
            - Assess impact on overall system architecture
            
            ### 2. Security-First Analysis
            - Comprehensive security vulnerability assessment
            - Review security controls and configurations
            - Evaluate compliance with security best practices
            
            ### 3. Performance Optimization Review
            - Identify performance optimization opportunities
            - Assess scalability implications
            - Review resource utilization patterns
            
            ### 4. Developer Experience Validation
            - Evaluate documentation clarity and completeness
            - Assess ease of implementation and maintenance
            - Review template usability and effectiveness
            
            ### 5. Accessibility & Inclusivity
            - Validate accessibility compliance considerations
            - Review inclusive design principles
            - Assess barrier-free implementation patterns
            
            ## Review Guidelines
            - Provide specific, actionable recommendations
            - Reference relevant sections of architecture guidelines
            - Prioritize critical issues that could impact system stability
            - Include code examples where appropriate
            - Focus on maintainability and long-term sustainability
            
            Generate a detailed review focusing specifically on ${{ matrix.review-area }} aspects.

  integration-review:
    needs: [pre-review-validation, architecture-compliance]
    if: needs.pre-review-validation.outputs.should-review == 'true'
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Cross-reference validation
        run: npm run check:cross-references-enhanced
        
      - name: Integration Assessment
        uses: anthropics/claude-code-action@v1
        with:
          anthropic-api-key: ${{ secrets.ANTHROPIC_API_KEY }}
          github-token: ${{ secrets.GITHUB_TOKEN }}
          model: 'claude-3-5-sonnet-20241022'
          max-tokens: 4000
          system-prompt: |
            Conduct a final integration review to ensure all components work together cohesively.
            
            ## Integration Focus Areas
            1. **Cross-Component Compatibility**: Ensure changes don't break existing integrations
            2. **Documentation Synchronization**: Verify all references are updated consistently
            3. **Template Coherence**: Ensure template changes maintain consistency across the system
            4. **Workflow Impact**: Assess impact on existing development workflows
            5. **Version Compatibility**: Verify backward compatibility and migration paths
            
            ## Deliverables
            - Summary of integration risks and mitigations
            - Recommendations for deployment strategy
            - Identification of any required follow-up tasks
            - Assessment of overall change impact
            
            Provide a comprehensive integration assessment with specific recommendations.
          
          create-issue: false
EOF

    validate_file_creation "$workflow_file" "Advanced architecture workflow"
}

main() {
    print_header "🚀 Creating GitHub Workflows for Enhanced Claude Code Review System"
    echo ""
    
    # Parse command line arguments
    parse_common_args "$@"
    
    # Validate prerequisites
    if ! validate_prerequisites "GitHub Workflows Creation"; then
        exit 1
    fi
    
    # Ensure workflows directory exists
    ensure_directory "$WORKFLOWS_DIR"
    
    # Create workflow files
    create_main_workflow
    create_advanced_workflow
    
    echo ""
    print_success "GitHub workflows creation completed!"
    
    if ! is_dry_run; then
        echo ""
        print_info "Next steps:"
        print_info "1. Configure repository secrets (ANTHROPIC_API_KEY)"
        print_info "2. Test workflows with a sample PR"
        print_info "3. Monitor workflow execution and adjust as needed"
        print_info "4. Run: scripts/create-commands.sh to create custom commands"
    fi
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi