# Project Integration Guide

## Overview

This guide explains how to extend the base architecture guidelines for specific projects while maintaining separation and consistency across your organization.

## Architecture Philosophy

### Base Guidelines Principle

- **Universal Standards**: Core principles that apply to all projects
- **Project Extensions**: Specific adaptations for individual project needs
- **Clean Separation**: Project-specific guidelines reference but don't modify base guidelines
- **Collaborative Evolution**: Feedback from projects improves base guidelines over time

### Integration Strategy

```
Base Guidelines (This Repository)
├── Core Principles & Patterns
├── Technology Recommendations
├── Security Standards
├── Testing Strategies
└── Documentation Templates (Organized by Category)
    ├── Architecture Templates (ADR, System Architecture)
    ├── API Templates (REST API Specifications)
    ├── User Guide Templates (User Manual, Admin Manual)
    └── Development Templates (Setup Guide, Coding Standards)

Project-Specific Repository
├── README.md (references base guidelines)
├── docs/
│   ├── architecture/
│   │   ├── decisions/                  # ADRs using base template
│   │   ├── system-architecture.md     # Using base template
│   │   └── diagrams/
│   ├── api/
│   │   └── api-specification.md       # Using base template
│   ├── user-guides/
│   │   ├── user-manual.md             # Using base template
│   │   └── admin-manual.md            # Using base template
│   ├── development/
│   │   ├── setup-guide.md             # Using base template
│   │   ├── coding-standards.md        # Extending base template
│   │   └── deployment-guide.md
│   └── project-extensions.md
├── .github/
│   └── workflows/                     # Based on base CI/CD templates
└── config/
    └── quality-standards.json
```

## Implementation Steps

### 1. Project Initialization

**Step 1: Reference Base Guidelines**
Create a `ARCHITECTURE.md` file in your project root:

```markdown
# Project Architecture

## Base Guidelines
This project follows the [Organization Architecture Guidelines](https://github.com/calnet/web-architecture-guidelines).

## Documentation Structure
We use the standardized template structure from the base guidelines:

### 📁 Documentation Organization
```

docs/
├── architecture/           # Technical architecture (using base templates)
├── api/                   # API documentation (using base templates)
├── user-guides/           # User documentation (using base templates)
└── development/           # Development guides (using base templates)

```

## Project-Specific Extensions
- [Technology Stack Decisions](#technology-stack)
- [Deviations from Base Guidelines](#deviations-from-base-guidelines)

## Technology Stack
Based on the base guidelines, this project uses:
- **Backend**: Node.js + TypeScript + NestJS
  - Rationale: Team expertise, enterprise patterns needed
  - Extension: Added GraphQL for flexible API queries
- **Frontend**: React + Next.js + TypeScript
  - Rationale: SSR requirements, team preference
  - Extension: Added Framer Motion for animations
- **Database**: PostgreSQL + Prisma
  - Rationale: ACID compliance, JSON support needed
  - Extension: Added Read replicas for analytics queries

## Deviations from Base Guidelines
| Guideline | Base Recommendation | Project Choice | Rationale |
|-----------|-------------------|----------------|-----------|
| Testing Framework | Jest | Vitest | Faster execution, better TypeScript support |
| State Management | Redux Toolkit | Zustand | Simpler for our use case |
```

### 2. Implement Template Structure

**Copy and Customize Templates:**

```bash
# Create project documentation structure
mkdir -p docs/{architecture,api,user-guides,development}

# Copy relevant templates from base guidelines
cp base-guidelines/docs/templates/architecture/adr-template.md \
   docs/architecture/adr-template.md

cp base-guidelines/docs/templates/architecture/system-architecture-document.md \
   docs/architecture/system-architecture.md

cp base-guidelines/docs/templates/api/api-specification.md \
   docs/api/api-specification.md

cp base-guidelines/docs/templates/user-guides/user-manual-template.md \
   docs/user-guides/user-manual.md

cp base-guidelines/docs/templates/user-guides/admin-manual-template.md \
   docs/user-guides/admin-manual.md

cp base-guidelines/docs/templates/development/setup-guide-template.md \
   docs/development/setup-guide.md

cp base-guidelines/docs/templates/development/coding-standards-template.md \
   docs/development/coding-standards.md
```

**Create Project-Specific Documentation Structure:**

```
docs/
├── README.md                          # Project documentation index
├── architecture/
│   ├── decisions/                     # ADRs using base template
│   │   ├── adr-001-database-choice.md
│   │   ├── adr-002-frontend-framework.md
│   │   └── adr-003-authentication-strategy.md
│   ├── system-architecture.md         # Complete system docs
│   ├── diagrams/                      # Architecture diagrams
│   │   ├── system-context.puml
│   │   ├── container-diagram.puml
│   │   └── deployment-diagram.puml
│   └── patterns/                      # Project-specific patterns
├── api/
│   ├── api-specification.md           # REST API documentation
│   ├── graphql-schema.md              # GraphQL documentation
│   └── webhooks.md                    # Webhook documentation
├── user-guides/
│   ├── user-manual.md                 # End-user documentation
│   ├── admin-manual.md                # Administrator documentation
│   ├── quick-start.md                 # Getting started guide
│   └── troubleshooting.md             # Common issues and solutions
├── development/
│   ├── setup-guide.md                 # Environment setup
│   ├── coding-standards.md            # Project-specific standards
│   ├── testing-guide.md               # Testing procedures
│   ├── deployment-guide.md            # Deployment procedures
│   └── contributing.md                # Contribution guidelines
└── project-extensions.md              # Project-specific deviations
```

### 3. Technology Integration

**Package.json Extension Example:**

```json
{
  "name": "project-name",
  "scripts": {
    "lint": "eslint . --config @org/eslint-config-base",
    "test": "vitest --config ./vitest.config.ts",
    "test:base-compliance": "npm run lint && npm run test:unit && npm run test:integration",
    "docs:templates": "npm run docs:copy-templates && npm run docs:validate"
  },
  "devDependencies": {
    "@org/eslint-config-base": "^1.0.0",
    "@org/prettier-config": "^1.0.0",
    "@org/documentation-templates": "^1.0.0"
  }
}
```

### 4. Quality Gates Integration

**Create `.github/workflows/base-compliance.yml`:**

```yaml
name: Base Guidelines Compliance

on:
  pull_request:
    branches: [main, develop]

jobs:
  compliance-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Check code quality
        run: |
          npm run lint
          npm run type-check
          npm run test:coverage
      
      - name: Validate documentation structure
        run: |
          npm run docs:validate-structure
          npm run docs:validate-templates
      
      - name: Validate architecture compliance
        run: |
          npm run validate:architecture
          npm run validate:security
          npm run validate:performance
      
      - name: Generate compliance report
        run: npm run generate:compliance-report
        
      - name: Upload compliance report
        uses: actions/upload-artifact@v3
        with:
          name: compliance-report
          path: reports/compliance-report.html
```

## Template Usage Patterns

### 1. Architecture Documentation Extensions

**Pattern: Extended ADR Template**

```markdown
# ADR-001: Database Technology Selection

## Base Guideline Reference
- **Aligns with**: [Database selection criteria from base guidelines]
- **Template Used**: [Base ADR template v1.0]

## Context Extension
**Project**: E-commerce Platform
**Stakeholders**: Backend team, DevOps, Product team

## Decision
Based on base guidelines recommendation for PostgreSQL, with project-specific extensions:
- **Primary Database**: PostgreSQL 14
- **Extension**: Added read replicas for analytics workload
- **Extension**: TimescaleDB for time-series metrics data

## Project-Specific Considerations
- High transaction volume (10k+ orders/hour)
- Complex reporting requirements
- Real-time analytics needs

## Implementation
**Phase 1**: Implement base PostgreSQL setup (following base setup guide)
**Phase 2**: Add read replicas for analytics
**Phase 3**: Integrate TimescaleDB for metrics

## Compliance Verification
- [x] Security review completed using base security checklist
- [x] Performance benchmarks met (base SLA requirements)
- [x] Documentation updated following base template
- [x] Base guideline alignment verified
```

**Pattern: System Architecture with Template Structure**

```markdown
# E-commerce Platform System Architecture

## Template Compliance
**Based on**: [Base System Architecture Document Template v1.0]
**Customizations**: Added e-commerce specific sections
**Review Date**: [Date]

## Document Information
[Following base template structure...]

## Business Context
[Using base template sections with project-specific content...]

## Architecture Overview
### Base Compliance
✅ Follows Clean Architecture principles (from base guidelines)
✅ Implements security-by-design (base security framework)
✅ Uses recommended technology stack (base tech recommendations)

### Project-Specific Extensions
- **Microservices Architecture**: Based on base patterns
- **Event-Driven Design**: Using base event sourcing patterns
- **High Availability**: 99.9% uptime requirement (exceeds base 99.5%)
```

### 2. API Documentation Extensions

**Pattern: Extended API Specification**

```markdown
# E-commerce API Specification

## Template Compliance
**Based on**: [Base API Specification Template v1.0]
**Extensions**: Added e-commerce specific endpoints
**API Version**: v2.0

## Base Template Structure
[Following base template organization...]

## Project-Specific Endpoints

### E-commerce Extensions
Beyond the base CRUD operations, we've added:

#### POST /api/v2/orders/checkout
Process order checkout with payment integration

**Request Body**:
```json
{
  "items": [...],
  "payment": {...},
  "shipping": {...}
}
```

**Response**:

```json
{
  "orderId": "string",
  "status": "pending|confirmed|failed",
  "paymentStatus": "processing|completed|failed"
}
```

## Base Compliance

✅ Follows base error format specification
✅ Uses base authentication patterns
✅ Implements base rate limiting approach
✅ Includes base pagination structure

```

### 3. Development Guide Extensions

**Pattern: Setup Guide with Project Specifics**
```markdown
# Development Environment Setup

## Template Compliance
**Based on**: [Base Setup Guide Template v1.0]
**Project Extensions**: E-commerce specific services
**Last Updated**: 2025-09-06 @ 18:49

## Prerequisites
Before starting, complete the [Base Development Environment Setup](../git-commands-and-setup.md).

## Base Setup Compliance
✅ Node.js 18+ (base requirement)
✅ Docker (base requirement)
✅ Git configuration (base standards)
✅ IDE setup (base configuration)

## Project-Specific Setup

### Additional Services Required
Beyond base PostgreSQL and Redis:

```bash
# E-commerce specific services
docker-compose up -d elasticsearch  # Product search
docker-compose up -d stripe-cli     # Payment testing
docker-compose up -d mailhog        # Email testing
```

### Environment Variables

Extends base `.env.local` with:

```env
# Base variables (from base template)
DATABASE_URL="postgresql://..."
JWT_SECRET="..."

# Project-specific variables
STRIPE_SECRET_KEY="sk_test_..."
ELASTICSEARCH_URL="http://localhost:9200"
EMAIL_SERVICE="mailhog"
```

### Verification Steps

After completing base setup:

1. ✅ Base application loads (base verification)
2. ✅ Database connects (base verification)
3. 🆕 Product search works (project-specific)
4. 🆕 Payment processing works (project-specific)
5. 🆕 Email notifications work (project-specific)

```

## Documentation Template Integration

### 1. Template Versioning and Updates

**Track Template Usage:**
```markdown
## Documentation Metadata

| Document | Base Template | Version | Last Updated | Customizations |
|----------|---------------|---------|--------------|----------------|
| System Architecture | system-architecture-document.md | v1.0 | 2024-01-15 | Added e-commerce sections |
| API Specification | api-specification.md | v1.0 | 2024-01-10 | Added payment endpoints |
| User Manual | user-manual-template.md | v1.0 | 2024-01-05 | Added checkout workflow |
| Setup Guide | setup-guide-template.md | v1.0 | 2024-01-01 | Added e-commerce services |
```

**Update Notification Process:**

```bash
# Script to check for template updates
#!/bin/bash
echo "Checking for base template updates..."

# Compare template versions
BASE_TEMPLATE_VERSION=$(curl -s $BASE_REPO/docs/templates/VERSION)
LOCAL_TEMPLATE_VERSION=$(cat docs/.template-version)

if [ "$BASE_TEMPLATE_VERSION" != "$LOCAL_TEMPLATE_VERSION" ]; then
    echo "📋 Template updates available!"
    echo "Current: $LOCAL_TEMPLATE_VERSION"
    echo "Latest: $BASE_TEMPLATE_VERSION"
    echo "Run 'npm run docs:update-templates' to update"
fi
```

### 2. Automated Template Synchronization

**Template Update Workflow:**

```yaml
# .github/workflows/sync-templates.yml
name: Sync Documentation Templates

on:
  schedule:
    - cron: '0 9 * * 1'  # Weekly on Monday
  workflow_dispatch:

jobs:
  sync-templates:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Check for template updates
        run: |
          # Download latest templates
          curl -o /tmp/templates.zip $BASE_REPO/archive/main.zip
          
          # Compare versions and create PR if updates available
          if [ "$(diff docs/templates/ /tmp/templates/)" ]; then
            echo "templates_updated=true" >> $GITHUB_OUTPUT
          fi
      
      - name: Create update PR
        if: steps.check.outputs.templates_updated == 'true'
        uses: peter-evans/create-pull-request@v5
        with:
          title: 'docs: update documentation templates'
          body: |
            ## Template Updates Available
            
            This PR updates documentation templates to the latest version.
            
            ### Changes
            - Updated templates from base guidelines
            - Preserved project-specific customizations
            - Updated template metadata
            
            ### Action Required
            - [ ] Review template changes
            - [ ] Update customized sections if needed
            - [ ] Test documentation generation
```

## Collaboration Workflow

### 1. Feedback Loop to Base Guidelines

**Monthly Architecture Reviews:**

```markdown
## Architecture Review Process

### Template Feedback Collection
1. **Monthly Review Meeting**
   - Review template usage effectiveness
   - Identify missing sections or improvements
   - Discuss template maintenance burden
   - Propose template enhancements

2. **Template Usage Metrics**
   - Track which templates are most/least used
   - Measure time-to-documentation for new features
   - Assess documentation quality improvements
   - Monitor template compliance rates

3. **Quarterly Template Updates**
   - Consolidate feedback from all projects
   - Update base templates with proven patterns
   - Deprecate unused template sections
   - Add new template categories as needed
```

### 2. Cross-Project Knowledge Sharing

**Template Improvement Framework:**

```markdown
## Template Knowledge Sharing

### Successful Template Patterns
- **Pattern**: Extended API template with webhook documentation
- **Project**: E-commerce platform
- **Benefit**: Reduced integration time by 50%
- **Recommendation**: Add to base API template

### Template Customization Library
- **Reusable Sections**: Industry-specific template additions
- **Component Library**: Common documentation components
- **Style Guide**: Consistent formatting and branding
- **Example Gallery**: Real-world template implementations

### Communication Channels
- **Template Slack Channel**: Daily template questions and tips
- **Monthly Template Office Hours**: Help with complex customizations
- **Quarterly Template Conference**: Share advanced implementations
- **Template Wiki**: Searchable knowledge base
```

### 3. Template Compliance Monitoring

**Automated Template Validation:**

```typescript
// template-compliance-checker.ts
interface TemplateCompliance {
  templateName: string;
  baseVersion: string;
  projectVersion: string;
  complianceScore: number;
  missingRequiredSections: string[];
  customizations: string[];
}

async function validateTemplateCompliance(
  projectPath: string
): Promise<TemplateCompliance[]> {
  const templates = await scanProjectTemplates(projectPath);
  const baseTemplates = await fetchBaseTemplates();
  
  return templates.map(template => {
    const baseTemplate = baseTemplates.find(t => t.name === template.name);
    const compliance = calculateCompliance(template, baseTemplate);
    
    return {
      templateName: template.name,
      baseVersion: baseTemplate?.version || 'unknown',
      projectVersion: template.version,
      complianceScore: compliance.score,
      missingRequiredSections: compliance.missingSections,
      customizations: compliance.customizations
    };
  });
}

// Usage in CI/CD
export async function generateComplianceReport(
  projectPath: string
): Promise<void> {
  const compliance = await validateTemplateCompliance(projectPath);
  
  const report = {
    overall: compliance.every(t => t.complianceScore >= 0.8),
    templates: compliance,
    recommendations: generateRecommendations(compliance)
  };
  
  await generateHTMLReport(report);
  await uploadToArtifacts(report);
}
```

## Continuous Improvement Process

### 1. Template Evolution

**Template Lifecycle Management:**

```markdown
## Template Version Control

### Version Schema
- **Major (1.0 → 2.0)**: Breaking changes to template structure
- **Minor (1.0 → 1.1)**: New sections or significant improvements
- **Patch (1.0.0 → 1.0.1)**: Bug fixes and minor clarifications

### Update Process
1. **Proposal**: Submit template improvement proposal
2. **Review**: Architecture review board evaluation
3. **Pilot**: Test in 1-2 projects before global rollout
4. **Feedback**: Collect usage feedback and metrics
5. **Rollout**: Gradual adoption across all projects
6. **Monitoring**: Track adoption and effectiveness

### Deprecation Policy
- **6-month notice** for major template changes
- **Migration guides** for breaking changes
- **Backward compatibility** when possible
- **Support period** for legacy templates

### Centralized Version Management

**Version Synchronization:**

The repository includes automated tools to maintain version consistency across all documentation:

```bash
# Validate all versions are aligned
npm run versions:validate

# Synchronize all versions to match the root VERSION file
npm run versions:sync
```

**Version Files Managed:**

- Root `VERSION` file (source of truth)
- `package.json` version
- Template version files (`docs/.template-version`, `docs/templates/VERSION`)
- Document metadata versions (architecture, security, performance docs)
- Individual template versions

**CI/CD Integration:**

The validation workflow includes version consistency checks:

```yaml
# .github/workflows/validate-docs.yml
validate-versions:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - name: Validate version consistency
      run: |
        chmod +x ./scripts/validate-versions.sh
        ./scripts/validate-versions.sh
```

**Best Practices:**

- Update the root `VERSION` file when making significant changes
- Run `npm run versions:sync` after version updates
- Include version validation in local development workflow
- All template and document versions should stay aligned

```

### 2. Metrics and Success Measurement

**Template Effectiveness Metrics:**

```markdown
## Template Success Metrics

### Adoption Metrics
- **Template Usage Rate**: % of projects using each template
- **Time to Documentation**: Average time to create quality docs
- **Compliance Score**: Average compliance with base templates
- **Update Velocity**: How quickly projects adopt template updates

### Quality Metrics
- **Documentation Completeness**: % of required sections completed
- **User Satisfaction**: Developer and user feedback scores
- **Maintenance Burden**: Time spent updating documentation
- **Error Reduction**: Fewer documentation-related issues

### Business Impact
- **Onboarding Speed**: New developer time-to-productivity
- **Support Ticket Reduction**: Fewer docs-related support requests
- **Audit Compliance**: Easier regulatory and security audits
- **Knowledge Retention**: Reduced impact of team member turnover
```

This integration guide ensures that projects can effectively utilize the organized template structure while maintaining consistency and contributing to continuous improvement across the organization. The categorized templates make it easier to find the right documentation format and maintain professional standards across all projects.

---

**Document Information**:

- **Version**: 1.3.3
- **Last Updated**: 2025-09-06 @ 18:49
- **Review Schedule**: Quarterly
- **Maintained by**: Architecture Team
