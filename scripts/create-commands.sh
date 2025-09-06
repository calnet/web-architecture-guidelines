#!/bin/bash

# Claude Custom Commands Creation Script
# Creates custom slash commands for enhanced Claude Code Review system

set -e

# Load common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/workflow-utils.sh"

# Script-specific configuration
COMMANDS_DIR=".claude/commands"

show_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Creates custom Claude command files for specialized code reviews."
    echo ""
    show_common_help
    echo "Created commands:"
    echo "  - architecture-review.md: Comprehensive architecture analysis"
    echo "  - security-scan.md: Security vulnerability assessment"
    echo "  - performance-check.md: Performance optimization review"
    echo "  - documentation-audit.md: Documentation quality validation"
    echo "  - quick-fix.md: Quick fix implementation"
    echo ""
}

create_architecture_review_command() {
    local command_file="$COMMANDS_DIR/architecture-review.md"
    
    print_header "📄 Creating architecture review command..."
    
    backup_file "$command_file"
    
    if is_dry_run; then
        print_info "DRY RUN: Would create $command_file"
        return 0
    fi
    
    cat > "$command_file" << 'EOF'
# Architecture Review Command

**Usage**: `/architecture-review "Review description"`

## Purpose
Perform comprehensive architectural analysis focusing on system design, patterns, and compliance with established guidelines.

## Command Behavior
When triggered, this command instructs Claude to conduct a thorough architectural review with the following focus areas:

### 1. Architectural Pattern Compliance
- Clean Architecture principles
- Layered architecture implementation
- Hexagonal architecture patterns
- Microservices design principles
- Domain-driven design adherence

### 2. System Design Analysis
- Component interaction and dependencies
- Data flow and information architecture
- Integration patterns and APIs
- Scalability and extensibility considerations
- Separation of concerns evaluation

### 3. Code Organization Review
- Module structure and organization
- Package and namespace design
- File and directory organization
- Interface and contract definitions
- Dependency injection patterns

### 4. Quality Attributes Assessment
- Maintainability metrics
- Testability evaluation
- Performance implications
- Security architecture review
- Reliability and fault tolerance

### 5. Documentation Alignment
- Architecture Decision Records (ADRs)
- System architecture documentation
- API documentation completeness
- Deployment and operational documentation

## Expected Output Format

```markdown
## Architecture Review Summary

### Overall Assessment
[Brief summary of architectural health and compliance]

### Critical Issues
- **Issue 1**: Description and impact
- **Issue 2**: Description and impact

### Architecture Compliance
| Pattern | Status | Comments |
|---------|--------|----------|
| Clean Architecture | ✅/⚠️/❌ | Details |
| Domain Design | ✅/⚠️/❌ | Details |

### Recommendations
1. **High Priority**: [Specific recommendation with examples]
2. **Medium Priority**: [Specific recommendation with examples]
3. **Low Priority**: [Specific recommendation with examples]

### Code Examples
[Specific code improvements with before/after examples]

### Documentation Updates
- [ ] Update ADR for [specific decision]
- [ ] Enhance API documentation for [component]
- [ ] Create diagram for [system interaction]
```

## Usage Examples

### Basic Architecture Review
```
/architecture-review "Review the new user authentication module"
```

### Focused Component Review
```
/architecture-review "Analyze the data access layer architecture and patterns"
```

### Integration Review
```
/architecture-review "Evaluate the API gateway integration architecture"
```

## Integration with Guidelines
This command specifically references and validates against:
- Web Architecture Guidelines established patterns
- Project-specific architectural decisions
- Industry best practices and standards
- Team coding standards and conventions

## Success Criteria
- ✅ Identifies architectural deviations
- ✅ Provides specific improvement recommendations
- ✅ References relevant documentation
- ✅ Includes actionable code examples
- ✅ Assesses long-term maintainability impact
EOF

    validate_file_creation "$command_file" "Architecture review command"
}

create_security_scan_command() {
    local command_file="$COMMANDS_DIR/security-scan.md"
    
    print_header "📄 Creating security scan command..."
    
    backup_file "$command_file"
    
    if is_dry_run; then
        print_info "DRY RUN: Would create $command_file"
        return 0
    fi
    
    cat > "$command_file" << 'EOF'
# Security Scan Command

**Usage**: `/security-scan "Security focus area"`

## Purpose
Conduct comprehensive security vulnerability assessment and compliance validation against established security standards.

## Command Behavior
When triggered, this command instructs Claude to perform a thorough security analysis covering:

### 1. OWASP Top 10 Compliance
- **A01: Broken Access Control**
  - Authentication and authorization mechanisms
  - Role-based access control implementation
  - Session management security
  
- **A02: Cryptographic Failures**
  - Data encryption at rest and in transit
  - Key management practices
  - Cryptographic algorithm selection
  
- **A03: Injection Attacks**
  - SQL injection prevention
  - Cross-site scripting (XSS) protection
  - Command injection vulnerabilities
  
- **A04: Insecure Design**
  - Security-by-design principles
  - Threat modeling implementation
  - Secure development lifecycle

### 2. Security Controls Assessment
- Input validation and sanitization
- Output encoding and escaping
- Security headers configuration
- CORS policy implementation
- Rate limiting and DoS protection

### 3. Authentication & Authorization
- Multi-factor authentication support
- Password policy enforcement
- JWT token security
- OAuth/OIDC implementation
- Privilege escalation prevention

### 4. Data Protection
- Personal data handling (GDPR/CCPA compliance)
- Data classification and labeling
- Secure data storage practices
- Data transmission security
- Backup and recovery security

### 5. Infrastructure Security
- Container security (if applicable)
- Cloud security configuration
- Network security controls
- Monitoring and logging
- Incident response capabilities

## Expected Output Format

```markdown
## Security Assessment Report

### Executive Summary
[High-level security posture assessment]

### Critical Vulnerabilities
| Severity | Issue | Impact | Recommendation |
|----------|-------|--------|----------------|
| High | [Vulnerability] | [Impact] | [Fix] |
| Medium | [Vulnerability] | [Impact] | [Fix] |

### OWASP Top 10 Compliance
- [A01] Broken Access Control: ✅/⚠️/❌
- [A02] Cryptographic Failures: ✅/⚠️/❌
- [A03] Injection: ✅/⚠️/❌
- [Continue for all 10...]

### Security Controls Review
- Authentication: [Assessment]
- Authorization: [Assessment]
- Input Validation: [Assessment]
- Data Protection: [Assessment]

### Recommended Actions
1. **Immediate** (Fix within 24 hours)
   - [Critical security fixes]
   
2. **Short-term** (Fix within 1 week)
   - [Important security improvements]
   
3. **Long-term** (Plan for next sprint)
   - [Security enhancements]

### Code Examples
[Before/after examples showing security improvements]

### Compliance Checklist
- [ ] OWASP compliance verified
- [ ] Security headers configured
- [ ] Input validation implemented
- [ ] Authentication mechanisms secured
```

## Usage Examples

### General Security Review
```
/security-scan "Comprehensive security assessment of the user management system"
```

### Focused Vulnerability Assessment
```
/security-scan "Check the API endpoints for injection vulnerabilities"
```

### Compliance Review
```
/security-scan "OWASP Top 10 compliance validation for the payment module"
```

## Security Standards Reference
This command validates against:
- OWASP Application Security Verification Standard (ASVS)
- NIST Cybersecurity Framework
- ISO 27001 security controls
- CIS Critical Security Controls
- PCI DSS (if applicable)
- SOC 2 Type II requirements

## Integration Points
- Automated security testing tools
- Dependency vulnerability scanning
- Static Application Security Testing (SAST)
- Dynamic Application Security Testing (DAST)
- Infrastructure as Code security scanning

## Success Criteria
- ✅ Identifies security vulnerabilities
- ✅ Provides OWASP compliance assessment
- ✅ Offers specific remediation steps
- ✅ Includes security code examples
- ✅ References industry standards
- ✅ Prioritizes fixes by risk level
EOF

    validate_file_creation "$command_file" "Security scan command"
}

create_performance_check_command() {
    local command_file="$COMMANDS_DIR/performance-check.md"
    
    print_header "📄 Creating performance check command..."
    
    backup_file "$command_file"
    
    if is_dry_run; then
        print_info "DRY RUN: Would create $command_file"
        return 0
    fi
    
    cat > "$command_file" << 'EOF'
# Performance Check Command

**Usage**: `/performance-check "Performance focus area"`

## Purpose
Analyze application performance characteristics and identify optimization opportunities across all layers of the system.

## Command Behavior
When triggered, this command instructs Claude to conduct comprehensive performance analysis:

### 1. Frontend Performance
- **Core Web Vitals**
  - Largest Contentful Paint (LCP)
  - First Input Delay (FID)
  - Cumulative Layout Shift (CLS)
  
- **Loading Performance**
  - Bundle size optimization
  - Code splitting effectiveness
  - Lazy loading implementation
  - Resource optimization (images, fonts, etc.)
  
- **Runtime Performance**
  - JavaScript execution efficiency
  - Memory usage patterns
  - DOM manipulation optimization
  - Event handling efficiency

### 2. Backend Performance
- **API Performance**
  - Response time optimization
  - Throughput analysis
  - Concurrent request handling
  - Rate limiting effectiveness
  
- **Database Performance**
  - Query optimization
  - Index effectiveness
  - Connection pooling
  - Transaction efficiency
  
- **Caching Strategy**
  - Cache hit ratios
  - Cache invalidation strategy
  - CDN utilization
  - Application-level caching

### 3. Infrastructure Performance
- **Resource Utilization**
  - CPU usage patterns
  - Memory consumption
  - I/O performance
  - Network utilization
  
- **Scalability Analysis**
  - Horizontal scaling readiness
  - Load balancing effectiveness
  - Auto-scaling configuration
  - Performance under load

### 4. Monitoring & Observability
- Performance metrics collection
- Application Performance Monitoring (APM)
- Real User Monitoring (RUM)
- Synthetic monitoring setup

## Expected Output Format

```markdown
## Performance Analysis Report

### Performance Summary
[Overall performance assessment and key metrics]

### Critical Performance Issues
| Priority | Component | Issue | Impact | Solution |
|----------|-----------|-------|--------|----------|
| High | [Component] | [Issue] | [Impact] | [Fix] |
| Medium | [Component] | [Issue] | [Impact] | [Fix] |

### Core Web Vitals Assessment
- **LCP**: [Current] / [Target] - [Status]
- **FID**: [Current] / [Target] - [Status]  
- **CLS**: [Current] / [Target] - [Status]

### Performance Metrics
| Metric | Current | Target | Status |
|--------|---------|--------|--------|
| Page Load Time | [value] | [target] | ✅/⚠️/❌ |
| API Response Time | [value] | [target] | ✅/⚠️/❌ |
| Database Query Time | [value] | [target] | ✅/⚠️/❌ |

### Optimization Recommendations
1. **Immediate Wins** (Low effort, high impact)
   - [Specific optimizations with code examples]
   
2. **Short-term Improvements** (Medium effort, medium impact)
   - [Optimization strategies and implementation]
   
3. **Long-term Optimizations** (High effort, high impact)
   - [Architectural improvements and refactoring]

### Code Examples
[Before/after performance optimization examples]

### Monitoring Setup
- [ ] Performance budget defined
- [ ] Monitoring tools configured
- [ ] Alerting thresholds set
- [ ] Performance CI/CD gates established
```

## Usage Examples

### General Performance Review
```
/performance-check "Analyze overall application performance and identify bottlenecks"
```

### Database Performance Focus
```
/performance-check "Review database query performance and optimization opportunities"
```

### Frontend Performance Analysis
```
/performance-check "Evaluate Core Web Vitals and frontend loading performance"
```

## Performance Standards
This command evaluates against:
- Google Core Web Vitals thresholds
- Industry standard response time benchmarks
- Accessibility performance guidelines
- Mobile performance best practices
- Progressive Web App performance criteria

## Tools Integration
Compatible with performance monitoring tools:
- Google PageSpeed Insights
- Lighthouse CI
- WebPageTest
- New Relic / DataDog / AppDynamics
- Synthetic monitoring services

## Performance Budget Guidelines
- Page load time: < 3 seconds
- API response time: < 200ms (95th percentile)
- Database queries: < 100ms average
- Bundle size: < 250KB gzipped
- Images: WebP format, lazy loaded
- Fonts: preloaded, font-display: swap

## Success Criteria
- ✅ Identifies performance bottlenecks
- ✅ Provides specific optimization recommendations
- ✅ Includes measurable performance targets
- ✅ References industry benchmarks
- ✅ Offers code-level improvements
- ✅ Suggests monitoring and alerting setup
EOF

    validate_file_creation "$command_file" "Performance check command"
}

create_documentation_audit_command() {
    local command_file="$COMMANDS_DIR/documentation-audit.md"
    
    print_header "📄 Creating documentation audit command..."
    
    backup_file "$command_file"
    
    if is_dry_run; then
        print_info "DRY RUN: Would create $command_file"
        return 0
    fi
    
    cat > "$command_file" << 'EOF'
# Documentation Audit Command

**Usage**: `/documentation-audit "Documentation scope"`

## Purpose
Evaluate documentation quality, completeness, and alignment with established templates and standards.

## Command Behavior
When triggered, this command instructs Claude to perform comprehensive documentation analysis:

### 1. Template Compliance
- **Architecture Documents**
  - ADR (Architecture Decision Record) compliance
  - System architecture documentation completeness
  - Diagram accuracy and currency
  
- **API Documentation**
  - OpenAPI/Swagger specification completeness
  - Endpoint documentation accuracy
  - Example requests/responses
  - Error handling documentation
  
- **User Documentation**
  - User manual completeness
  - Admin manual accuracy
  - Setup and installation guides
  - Troubleshooting documentation

### 2. Content Quality Assessment
- **Clarity and Readability**
  - Language clarity and consistency
  - Technical accuracy
  - Logical organization and flow
  - Appropriate detail level for audience
  
- **Completeness Analysis**
  - Missing sections identification
  - Outdated information detection
  - Cross-reference validation
  - Example and code snippet coverage

### 3. Accessibility & Usability
- **Document Accessibility**
  - Heading structure (H1-H6 hierarchy)
  - Alt text for images and diagrams
  - Color contrast in diagrams
  - Screen reader compatibility
  
- **Navigation & Discovery**
  - Table of contents accuracy
  - Internal linking effectiveness
  - Search-friendly structure
  - Related document connections

### 4. Maintenance & Currency
- **Version Control**
  - Document versioning practices
  - Change tracking and history
  - Review and approval processes
  - Update frequency and timeliness
  
- **Living Documentation**
  - Automation integration
  - Generated content accuracy
  - Sync with code changes
  - Feedback incorporation mechanisms

## Expected Output Format

```markdown
## Documentation Audit Report

### Executive Summary
[Overall documentation health and key findings]

### Template Compliance Assessment
| Document Type | Compliance | Missing Elements | Status |
|---------------|------------|------------------|--------|
| ADR Templates | [%] | [List] | ✅/⚠️/❌ |
| API Docs | [%] | [List] | ✅/⚠️/❌ |
| User Guides | [%] | [List] | ✅/⚠️/❌ |

### Content Quality Scores
- **Clarity**: [Score/10] - [Assessment]
- **Completeness**: [Score/10] - [Assessment]
- **Accuracy**: [Score/10] - [Assessment]
- **Usability**: [Score/10] - [Assessment]

### Critical Issues
1. **Missing Documentation**
   - [List of missing required documents]
   
2. **Outdated Content**
   - [List of outdated sections with last update dates]
   
3. **Accessibility Issues**
   - [List of accessibility compliance problems]

### Recommendations
1. **Immediate Actions** (High priority)
   - [Specific improvements needed]
   
2. **Short-term Improvements** (Medium priority)
   - [Documentation enhancements]
   
3. **Long-term Strategy** (Low priority)
   - [Process and framework improvements]

### Template Improvements
[Specific suggestions for template enhancements]

### Automation Opportunities
- [ ] Auto-generated API documentation
- [ ] Link validation automation
- [ ] Documentation testing integration
- [ ] Version synchronization automation
```

## Usage Examples

### Comprehensive Documentation Review
```
/documentation-audit "Complete review of all project documentation for accuracy and completeness"
```

### API Documentation Focus
```
/documentation-audit "Audit API documentation for completeness and developer experience"
```

### Template Compliance Check
```
/documentation-audit "Validate compliance with established documentation templates"
```

## Documentation Standards
This command evaluates against:
- Web Architecture Guidelines documentation templates
- Industry documentation best practices
- WCAG accessibility guidelines for documents
- Technical writing standards
- API documentation standards (OpenAPI)

## Quality Metrics
- Template compliance: >90%
- Link validation: 100% working links
- Content freshness: <90 days since last review
- Accessibility compliance: WCAG 2.1 AA
- User feedback incorporation: Regular review cycles

## Integration Points
- Documentation generation tools
- Link checking automation
- Version control integration
- Feedback collection systems
- Analytics and usage tracking

## Success Criteria
- ✅ Identifies documentation gaps
- ✅ Validates template compliance
- ✅ Assesses content quality and accuracy
- ✅ Provides specific improvement recommendations
- ✅ Suggests automation opportunities
- ✅ Evaluates accessibility compliance
EOF

    validate_file_creation "$command_file" "Documentation audit command"
}

create_quick_fix_command() {
    local command_file="$COMMANDS_DIR/quick-fix.md"
    
    print_header "📄 Creating quick fix command..."
    
    backup_file "$command_file"
    
    if is_dry_run; then
        print_info "DRY RUN: Would create $command_file"
        return 0
    fi
    
    cat > "$command_file" << 'EOF'
# Quick Fix Command

**Usage**: `/quick-fix "Issue description"`

## Purpose
Provide immediate, actionable fixes for common code quality, formatting, and minor functionality issues.

## Command Behavior
When triggered, this command instructs Claude to identify and provide quick fixes for:

### 1. Code Quality Issues
- **Formatting Problems**
  - Inconsistent indentation
  - Missing semicolons or proper syntax
  - Code style violations
  - Import organization
  
- **Simple Logic Issues**
  - Unused variables and imports
  - Basic conditional logic improvements
  - Simple refactoring opportunities
  - Variable naming improvements

### 2. Documentation Fixes
- **Inline Documentation**
  - Missing or incorrect comments
  - JSDoc/docstring improvements
  - README updates
  - Code example corrections
  
- **Quick Content Updates**
  - Typo corrections
  - Link fixes
  - Format standardization
  - Example code updates

### 3. Configuration Issues
- **Build Configuration**
  - Package.json script fixes
  - Basic webpack/build config issues
  - Environment variable corrections
  - Dependency version conflicts
  
- **Linting & Formatting**
  - ESLint rule fixes
  - Prettier configuration
  - TypeScript configuration adjustments
  - Git hooks setup

### 4. Minor Security & Performance
- **Low-Risk Security Fixes**
  - Basic input validation
  - Simple XSS prevention
  - Environment variable usage
  - Dependency updates
  
- **Simple Performance Improvements**
  - Basic optimization opportunities
  - Inefficient loop fixes
  - Simple caching additions
  - Resource loading improvements

## Expected Output Format

```markdown
## Quick Fix Report

### Issues Identified
[Brief summary of fixable issues found]

### Immediate Fixes
1. **[Issue Type]**: [Description]
   ```[language]
   // Before
   [current code]
   
   // After  
   [fixed code]
   ```
   **Impact**: [Brief explanation of improvement]

2. **[Issue Type]**: [Description]
   [Similar format for each fix]

### File-by-File Changes
#### `filename.ext`
```diff
- [lines to remove]
+ [lines to add]
```

### Applied Standards
- [List of coding standards applied]
- [List of best practices implemented]

### Verification Steps
1. [Steps to verify fixes work]
2. [Commands to run for testing]
3. [Expected outcomes]

### Additional Recommendations
- [Suggestions for further improvements]
- [Related issues that might need attention]
```

## Usage Examples

### Code Quality Fix
```
/quick-fix "Fix formatting and style issues in the user service module"
```

### Documentation Update
```
/quick-fix "Update inline documentation and fix typos in README"
```

### Configuration Correction
```
/quick-fix "Fix package.json scripts and dependency issues"
```

### Security Enhancement
```
/quick-fix "Add basic input validation to API endpoints"
```

## Fix Categories

### ✅ Suitable for Quick Fix
- Formatting and style issues
- Simple logic improvements
- Documentation updates
- Configuration corrections
- Import/export organization
- Variable naming improvements
- Basic security enhancements
- Simple performance optimizations

### ❌ Not Suitable for Quick Fix
- Major architectural changes
- Complex business logic modifications
- Database schema changes
- API breaking changes
- Security vulnerabilities requiring design changes
- Performance issues requiring profiling
- Complex refactoring operations

## Quality Assurance
Each quick fix includes:
- Clear before/after code examples
- Explanation of the improvement
- Verification steps
- Impact assessment
- Related best practices reference

## Integration with Development Workflow
- Compatible with existing linting tools
- Follows established coding standards
- Maintains backward compatibility
- Includes appropriate testing suggestions
- Documents changes for review

## Success Criteria
- ✅ Provides immediately actionable fixes
- ✅ Includes clear before/after examples
- ✅ Explains the reasoning for each change
- ✅ Offers verification steps
- ✅ Maintains code quality standards
- ✅ Suggests related improvements
EOF

    validate_file_creation "$command_file" "Quick fix command"
}

main() {
    print_header "🚀 Creating Claude Custom Commands for Enhanced Code Review System"
    echo ""
    
    # Parse command line arguments
    parse_common_args "$@"
    
    # Validate prerequisites
    if ! validate_prerequisites "Custom Commands Creation"; then
        exit 1
    fi
    
    # Ensure commands directory exists
    ensure_directory "$COMMANDS_DIR"
    
    # Create command files
    create_architecture_review_command
    create_security_scan_command
    create_performance_check_command
    create_documentation_audit_command
    create_quick_fix_command
    
    echo ""
    print_success "Claude custom commands creation completed!"
    
    if ! is_dry_run; then
        echo ""
        print_info "Next steps:"
        print_info "1. Test commands by using them in PR comments"
        print_info "2. Customize command prompts based on team needs"
        print_info "3. Monitor command effectiveness and iterate"
        print_info "4. Run: scripts/create-monitoring.sh to create monitoring scripts"
    fi
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi