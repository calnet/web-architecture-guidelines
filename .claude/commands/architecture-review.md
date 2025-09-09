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
```text

## Usage Examples

### Basic Architecture Review

```text
/architecture-review "Review the new user authentication module"
```text

### Focused Component Review

```text
/architecture-review "Analyze the data access layer architecture and patterns"
```text

### Integration Review

```text
/architecture-review "Evaluate the API gateway integration architecture"
```text

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
