# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## Repository Overview

This is a documentation-only repository containing web application architecture
guidelines optimized for AI agents and development teams. The repository focuses
on providing comprehensive instruction sets for various AI agents and
documentation templates for building high-quality web applications.

## AI-Powered Code Review System

This repository includes an advanced Claude Code Review workflow system with the
following components:

### GitHub Workflows

- **claude-code-review.yml**: Main automated review workflow
- **advanced-architecture-review.yml**: Multi-stage comprehensive analysis

### Custom Commands Available

When reviewing code or responding to comments, you can use these specialized
commands:

#### `/architecture-review`

Perform comprehensive architectural analysis focusing on:

- Clean Architecture principles adherence
- System design patterns validation
- Component interaction assessment
- Code organization review
- Quality attributes evaluation

#### `/security-scan`

Conduct thorough security vulnerability assessment covering:

- OWASP Top 10 compliance
- Security controls assessment
- Authentication & authorization review
- Data protection validation
- Infrastructure security analysis

#### `/performance-check`

Analyze application performance characteristics including:

- Frontend performance (Core Web Vitals)
- Backend performance (API, database)
- Infrastructure performance
- Monitoring & observability setup

#### `/documentation-audit`

Evaluate documentation quality and completeness:

- Template compliance checking
- Content quality assessment
- Accessibility & usability review
- Maintenance & currency validation

#### `/quick-fix`

Provide immediate, actionable fixes for:

- Code quality issues
- Documentation corrections
- Configuration problems
- Minor security & performance improvements

### Review Standards and Guidelines

When conducting code reviews, follow these enhanced standards:

#### 1. Security by Design

- **Authentication**: Verify robust authentication mechanisms
- **Authorization**: Ensure proper access controls
- **Input Validation**: Check for comprehensive input sanitization
- **Data Protection**: Validate encryption and secure data handling
- **OWASP Compliance**: Assess against OWASP Top 10 vulnerabilities

#### 2. Performance First

- **Core Web Vitals**: Evaluate LCP, FID, and CLS metrics
- **API Performance**: Check response times and throughput
- **Database Optimization**: Review query efficiency and indexing
- **Caching Strategy**: Validate caching implementation
- **Resource Optimization**: Assess bundle sizes and loading strategies

#### 3. Developer Experience

- **Code Clarity**: Ensure readable and maintainable code
- **Documentation**: Verify comprehensive and current documentation
- **Testing**: Check test coverage and quality
- **Tooling**: Validate development tool configuration
- **Error Handling**: Review error handling and logging

#### 4. Maintainability

- **Architecture Patterns**: Ensure consistent pattern usage
- **Code Organization**: Validate logical structure and separation
- **Dependency Management**: Check for appropriate dependencies
- **Technical Debt**: Identify and prioritize debt reduction
- **Refactoring Opportunities**: Suggest improvements

#### 5. Accessibility

- **WCAG Compliance**: Verify accessibility standards adherence
- **Semantic HTML**: Check for proper semantic structure
- **Keyboard Navigation**: Ensure keyboard accessibility
- **Screen Reader Support**: Validate assistive technology compatibility
- **Color Contrast**: Check visual accessibility requirements

#### 6. Living Documentation

- **Architecture Decision Records**: Validate ADR completeness
- **API Documentation**: Check OpenAPI/Swagger accuracy
- **User Guides**: Ensure user-facing documentation currency
- **Development Guides**: Verify setup and contribution guides

## Repository Structure

```text
docs/                                  # Unified Documentation Content & React Site
├── src/                               # React documentation site components
│   ├── components/                    # React UI components for documentation
│   │   ├── DocumentationPage.tsx     # Dynamic content loader with complete file mapping
│   │   ├── Sidebar.tsx               # Navigation with 10 comprehensive categories  
│   │   ├── HomePage.tsx               # Landing page component
│   │   └── Navigation.tsx             # Top navigation component
│   ├── App.tsx                        # Main React application entry
│   ├── main.tsx                       # React application bootstrap (HashRouter)
│   └── index.css                      # Application styles
├── ai-agents/                         # AI agent-specific instructions (6 files routed)
│   ├── AI_AGENT_INTEGRATION_GUIDE.md # Universal AI agent integration guide
│   ├── claude-architecture-instructions.md     # Unified Claude instructions
│   ├── chatgpt-architecture-instructions.md    # ChatGPT/GPT-4 instructions
│   ├── copilot-architecture-instructions.md    # GitHub Copilot instructions
│   ├── gemini-architecture-instructions.md     # Google Gemini instructions
│   └── anthropic-api-architecture-instructions.md # Anthropic API integration
├── architecture/                      # System architecture documentation (6 files routed)
│   ├── decisions/                     # Architecture Decision Records (ADRs)
│   │   ├── adr-001-technology-stack.md
│   │   ├── adr-002-database-schema-patterns.md
│   │   └── adr-003-authentication-strategy.md
│   ├── system-architecture.md         # Overall system architecture document
│   ├── security.md                    # Security guidelines
│   └── performance.md                 # Performance guidelines
├── templates/                         # Documentation templates by category (8 files routed)
│   ├── README.md                      # Template index and usage guide
│   ├── VERSION                        # Template version file
│   ├── architecture/                  # Architecture documentation templates
│   │   ├── adr-template.md           # Architecture Decision Records template
│   │   └── system-architecture-document.md # System documentation template
│   ├── api/                          # API documentation templates
│   │   └── api-specification.md      # REST API documentation template
│   ├── user-guides/                  # User documentation templates
│   │   ├── user-manual-template.md   # End-user documentation template
│   │   └── admin-manual-template.md  # Administrator documentation template
│   └── development/                  # Development team templates
│       ├── setup-guide-template.md   # Environment setup template
│       └── coding-standards-template.md # Code quality standards template
├── external-documentation-links.md   # Curated external resources
├── project-integration-guide.md      # How to extend these guidelines
├── integration-automation-script.md  # Automated integration script
├── github-actions-secrets-setup.md   # GitHub Actions setup guide (configuration category)
├── quality-gate-setup.md             # Quality gate configuration
├── version-management-guide.md       # Version management documentation
├── copy-docs.sh                      # Content synchronization script (enhanced for all files)
├── package.json                      # React site dependencies
├── package-lock.json                 # Lock file for dependencies
├── vite.config.ts                    # Vite build configuration (base: './' + HashRouter)
├── tsconfig.json                     # TypeScript configuration
├── tsconfig.node.json               # Node.js TypeScript configuration
└── index.html                        # Entry point for React documentation site

.github/workflows/                      # AI-Powered Code Review workflows
├── claude-code-review.yml             # Main review workflow
└── advanced-architecture-review.yml   # Advanced multi-stage workflow

.claude/commands/                       # Custom Claude commands (5 files routed)
├── architecture-review.md             # Architecture analysis command
├── security-scan.md                   # Security assessment command
├── performance-check.md               # Performance optimization command
├── documentation-audit.md             # Documentation review command
└── quick-fix.md                       # Quick fix command

scripts/                               # Workflow management scripts (2 files routed)
├── create-workflows.sh                # Workflow creation script
├── create-commands.sh                 # Commands creation script
├── create-monitoring.sh               # Monitoring scripts creation
├── create-docs.sh                     # Documentation creation script
├── monitor-workflow.sh                # Health monitoring script
└── test-workflow.sh                   # Comprehensive testing script

# Repository Root Files (8 files routed in Getting Started category)
├── README.md                          # Main project overview
├── CLAUDE.md                          # This file - Claude-specific instructions
├── git-commands-and-setup.md          # Git setup and repository management
├── IMPLEMENTATION_GUIDE.md            # Enhanced workflow implementation guide
├── WORKFLOW_README.md                 # Workflow usage and maintenance
├── CHANGELOG.md                       # Version history
├── ERROR_CHECK_REPORT.md              # Validation reporting
├── QUALITY_GATE_REPORT.md             # Quality assurance reports
└── ... (additional project management files)
```

## Documentation Site Features

### Comprehensive Content Access
- **All 53+ markdown files** accessible through dedicated routes
- **10 navigation categories** organize content logically:
  1. **Getting Started** (8 files) - Project overview, setup, integration
  2. **Templates** (8 files) - All documentation templates organized by category  
  3. **Architecture** (6 files) - System architecture, ADRs, security, performance
  4. **AI Agents** (6 files) - Instructions for Claude, ChatGPT, Copilot, Gemini
  5. **Configuration** (7 files) - GitHub Actions, quality gates, version management
  6. **Project Management** (6 files) - Changelog, quality reports, workflow guides
  7. **Claude Commands** (5 files) - Custom Claude code review commands
  8. **GitHub Templates** (3 files) - Issue and pull request templates
  9. **Scripts Documentation** (2 files) - Performance testing and validation
  10. **Additional Resources** - Implementation and workflow documentation

### Technical Implementation
- **HashRouter Configuration**: Ensures compatibility with static hosting (GitHub Pages, Netlify)
- **Dynamic Content Loading**: All markdown files processed with syntax highlighting
- **Responsive Design**: Optimized for desktop and mobile viewing
- **Complete File Path Mapping**: Every markdown file has a dedicated route
- **Enhanced Copy Script**: Automatically synchronizes all content for site access

## Core Architecture

This repository follows a documentation-first approach with these key
principles:

### Content Organization

- **Separation of concerns**:
  AI agent instructions are separate from generic templates
- **Categorization**:
  Templates organized by functional area (architecture, API, user guides,
  development)
- **Modularity**: Workflow system broken into focused, manageable components

### Quality Assurance

- **GitHub Actions workflow** (`.github/workflows/validate-docs.yml`) provides
  automated validation
- **AI-Powered Code Review workflows** provide intelligent code review and
  analysis
- **Link checking**: Validates all markdown links are accessible
- **Markdown linting**: Ensures consistent formatting and style
- **Structure validation**: Verifies required directories and files exist
- **Cross-reference validation**:
  Ensures internal links and references are accurate

### Workflow Integration

- **Automated Reviews**: Every PR receives intelligent Claude analysis
- **Custom Commands**: Specialized analysis through slash commands
- **Health Monitoring**: Continuous system health and performance tracking
- **Comprehensive Testing**: Automated validation of workflow functionality

## Common Development Tasks

### Documentation Validation

The repository uses GitHub Actions for automated validation. Enhanced workflows
provide:

```bash
# Automated validation runs on every PR
# Manual health check:
scripts/monitor-workflow.sh --report

# Comprehensive testing:
scripts/test-workflow.sh
```text

### Enhanced Code Review Process

1. **Automatic Triggers**: Workflows activate on PR creation/updates
2. **Manual Triggers**: Use `@claude` mentions for on-demand reviews
3. **Specialized Analysis**: Leverage custom commands for focused reviews
4. **Continuous Monitoring**: Health checks ensure system reliability

### Content Updates

When updating documentation:

1. **Maintain structure**: Follow the established directory organization
2. **Update cross-references**: Ensure links between documents remain valid
3. **Follow semantic versioning**: Use conventional commits for changes
4. **Test externally**: Verify external links in
`external-documentation-links.md` are still valid
5. **Validate templates**: Run template compliance checks after changes

### Commit Conventions

The repository follows conventional commit format:

- `feat`: New guidelines or significant enhancements
- `fix`: Bug fixes and minor improvements  
- `docs`: Documentation updates
- `ci`: GitHub workflow changes
- `refactor`: Code/structure improvements without functionality changes
- `test`: Test additions or modifications

Example: `feat: enhance documentation templates and integration guide with
structured categories`

## File Modification Guidelines

### When working with AI agent instructions

- **Maintain consistency**:
  Keep instruction format similar across different agents
- **Version appropriately**:
  Create new versions for major changes rather than breaking existing ones
- **Cross-reference**:
  Update the main README.md when adding new agent instructions
- **Test commands**: Validate custom commands work as expected

### When working with templates

- **Preserve structure**: Maintain the placeholder text and example format
- **Update index**: Modify `docs/templates/README.md` when adding new templates
- **Keep scalable**:
  Ensure templates work for both startup and enterprise projects
- **Validate compliance**: Run template validation scripts after changes

### When updating external links

- **Verify accessibility**: Test all links before committing
- **Maintain categorization**:
  Follow the established organization in `external-documentation-links.md`
- **Add context**: Include brief descriptions for why resources are valuable
- **Monitor regularly**: Set up automated link checking where possible

### When modifying workflows

- **Test thoroughly**:
  Use `scripts/test-workflow.sh` for comprehensive validation
- **Monitor health**: Check system health with `scripts/monitor-workflow.sh`
- **Document changes**: Update implementation guides and README files
- **Validate secrets**: Ensure required API keys and secrets are configured

## Important Files

- **README.md**: Main entry point explaining repository purpose and usage
- **CLAUDE.md**: This file - enhanced instructions for Claude Code reviews
- **docs/project-integration-guide.md**:
  Critical for understanding how to extend guidelines
- **docs/external-documentation-links.md**:
  Curated list of external resources requiring regular maintenance
- **git-commands-and-setup.md**: Repository setup and maintenance procedures
- **IMPLEMENTATION_GUIDE.md**: Complete guide for the enhanced workflow system
- **WORKFLOW_README.md**: Usage and maintenance documentation for workflows

## Quality Standards

- **No build/test commands**: This is a documentation-only repository
- **Markdown consistency**: All documentation uses GitHub-flavored markdown
- **Link integrity**: All internal and external links must be valid
- **Professional formatting**:
  Templates are ready for immediate professional use
- **Comprehensive coverage**:
  Instructions cover all major aspects of web application architecture
- **Accessibility compliance**: Documentation follows WCAG 2.1 AA guidelines
- **Version control**: Proper branching and commit message conventions

## Enhanced Workflow Monitoring

### Health Checks

- **Daily**: Run `scripts/monitor-workflow.sh` for system health
- **Weekly**: Review workflow performance and success rates
- **Monthly**: Comprehensive audit and optimization review

### Performance Metrics

- **Success Rate**: Target >95% workflow success rate
- **Response Time**: Target <5 minutes average execution time
- **API Limits**: Monitor GitHub and Anthropic API usage
- **Error Rates**: Track and investigate workflow failures

### Troubleshooting

- **Authentication Issues**: Verify ANTHROPIC_API_KEY secret configuration
- **Workflow Failures**: Check logs in GitHub Actions and run health checks
- **Command Issues**:
  Validate custom command files exist and are properly formatted
- **Performance Problems**: Monitor API rate limits and optimize prompts

## Repository Maintenance

- **Monthly**: Review and update external documentation links
- **Quarterly**: Review AI agent instructions for new capabilities  
- **Bi-annually**: Comprehensive template review and updates
- **Annually**: Major version review and workflow optimization

This repository serves as a comprehensive foundation for web application
architecture guidance that evolves with industry best practices and AI agent
capabilities, enhanced with intelligent automation and monitoring.

---

- **Version**: 1.3.4
- **Last Updated**: 14 September 2025 @ 13:41
- **Template Version**: 1.3.4
