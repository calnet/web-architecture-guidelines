# Documentation Audit Command

**Usage**: `/documentation-audit "Documentation scope"`

## Purpose

Evaluate documentation quality, completeness, and alignment with established
templates and standards.

## Command Behavior

When triggered, this command instructs Claude to perform comprehensive
documentation analysis:

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
```text

## Usage Examples

### Comprehensive Documentation Review

```text
/documentation-audit "Complete review of all project documentation for accuracy
and completeness"
```text

### API Documentation Focus

```text
/documentation-audit "Audit API documentation for completeness and developer
experience"
```text

### Template Compliance Check

```text
/documentation-audit "Validate compliance with established documentation
templates"
```text

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
