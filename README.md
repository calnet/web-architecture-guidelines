# Web Application Architecture Guidelines

Comprehensive guidelines for building well-architected, secure, scalable, and
maintainable web applications.

**Version:** 1.3.5 - Major script consolidation and repository cleanup with
streamlined automation and enhanced AI-powered workflows

## Overview

This repository contains architecture guidelines and instructions optimized for
AI agents and development teams to build high-quality web applications following
industry best practices. It includes an advanced **AI-Powered Code Review
workflow system** with automated workflows, custom commands, comprehensive
monitoring, and production-ready deployment capabilities.

## Structure

```text
docs/                                  # Unified Documentation Content & React Site
├── src/                               # React documentation site components
│   ├── components/                    # React components for documentation site
│   └── App.tsx                        # Main React application
├── ai-agents/                         # AI agent-specific instructions
│   ├── AI_AGENT_INTEGRATION_GUIDE.md # Universal AI agent integration guide
│   ├── claude-architecture-instructions.md    # Claude instructions
│   ├── chatgpt-architecture-instructions.md   # ChatGPT/GPT-4 instructions
│   ├── copilot-architecture-instructions.md   # GitHub Copilot instructions
│   ├── gemini-architecture-instructions.md    # Google Gemini instructions
│   └── anthropic-api-architecture-instructions.md # Anthropic API instructions
├── architecture/                      # System architecture documentation
│   ├── decisions/                     # Architecture Decision Records (ADRs)
│   └── system-architecture.md         # Overall system architecture
├── templates/                         # Documentation templates by category
│   ├── README.md                      # Template index and usage guide
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
├── copy-docs.sh                      # Content synchronization script
├── package.json                      # React site dependencies
├── vite.config.ts                    # Vite build configuration
└── index.html                        # Entry point for React documentation site
```

## Quick Start

### Interactive Documentation Site

**Comprehensive React-based documentation website** with complete routing for all repository content:

```bash
# Navigate to documentation site
cd docs/

# Install dependencies
npm install

# Start development server (view at http://localhost:5173)
npm run dev

# Build for production
npm run build
```

**Features:**
- 📚 **Complete Content Access** - All 55+ markdown files accessible through intuitive navigation
- 🗂️ **Organized Categories** - 10 logical navigation sections covering all documentation types
- 🔍 **Dynamic Content Loading** - Full markdown rendering with syntax highlighting
- 📱 **Responsive Design** - Optimized for desktop and mobile viewing
- 🚀 **Static Hosting Ready** - Deployable to GitHub Pages, Netlify, or any static host

### AI-Powered Code Review System

**Complete automated code review workflow** with AI-powered analysis, comprehensive architecture documentation, and zero critical errors.

```bash
# Quick setup of AI-Powered Code Review system
./setup-enhanced-workflow.sh

# Configure ANTHROPIC_API_KEY
npm run workflow:config

# Test the workflow system
npm run workflow:test

# Monitor performance
npm run workflow:monitor
```text

**Features:**

- 🤖 **Automated Code Reviews** - Intelligent PR analysis with custom Claude
  commands
- 🔒 **Security Scanning** - OWASP Top 10 compliance and vulnerability
  assessment
- ⚡ **Performance Analysis** - Core Web Vitals and optimization
  recommendations
- 📋 **Documentation Audits** - Quality validation and compliance checking
- 🛠️ **Quick Fixes** - Automated resolution of common issues
- 📊 **Performance Monitoring** - Real-time workflow health and optimization

**Custom Commands Available:**

- `/architecture-review` - Comprehensive architectural analysis
- `/security-scan` - Security vulnerability assessment
- `/performance-check` - Performance optimization review
- `/documentation-audit` - Documentation quality validation
- `/quick-fix` - Quick fix implementation

### For AI Agents

1. Choose the appropriate instruction file for your AI agent
2. Use it as a system prompt or reference guide
3. Adapt recommendations based on project context

### For Development Teams

1. Use the [Integration Automation
  Script](docs/integration-automation-script.md) for automated setup
2. Review the [Project Integration Guide](docs/project-integration-guide.md)
  for manual integration
3. Use [documentation templates](docs/templates/) for your project

### Interactive Documentation Site

**New in v1.3.5**: Major script consolidation and repository cleanup with
streamlined automation systems.

**Script Consolidation Achievements:**
- **Reduced script count by 29%**: From 41 scripts to 29 scripts  
- **Eliminated npm script redundancy**: From 88 to 58 npm scripts (34% reduction)
- **Unified validation system**: 4 validation scripts → 1 consolidated `validate.sh`
- **Streamlined version management**: 5 version scripts → 1 unified `version-manager.sh`  
- **Integrated workflow management**: 4 workflow scripts → 1 consolidated `workflow-manager.sh`
- **Shared utilities**: Created `scripts/lib/common.sh` for consistent functionality

**Enhanced in v1.3.4**: React-based interactive documentation site with modern
interface and real-time search.

```bash
# Navigate to docs folder and start the React site
cd docs

# Install dependencies
npm install

# Start development server
npm run dev
# Site available at http://localhost:5173

# Build for production
npm run build
```

**Features:**

- 🔍 **Real-time Search** - Find content quickly across all documentation
- 📱 **Responsive Design** - Works well on desktop, tablet, and mobile
- 🔄 **Auto-sync** - Automatically syncs with main documentation content
- ⚡ **Fast Navigation** - Modern SPA with instant page loads
- 🎯 **Interactive Interface** - Browse documentation with intuitive navigation

The React site serves as a modern frontend for all documentation while
maintaining a single source of truth.

### GitHub Actions Setup

For automated code review and CI/CD workflows:

1. Follow the [GitHub Actions Secrets Setup
  Guide](docs/github-actions-secrets-setup.md)
2. Configure required API keys and secrets
3. Enable automated workflows for continuous quality assurance
4. Reference [external documentation](docs/external-documentation-links.md)
  as needed

### For Project-Specific Implementation

1. Fork or reference this repository
2. Follow the integration guide to extend guidelines for your project
3. Maintain separation between base and project-specific guidelines

## AI Agent Instructions

### [Claude](docs/ai-agents/claude-architecture-instructions.md)

Comprehensive web application architecture instructions with integrated
AI-powered code review capabilities:

- **[Main Instructions](docs/ai-agents/claude-architecture-instructions.md)**:
  Complete unified guidance (v1.3.4)
- **Features**: Advanced patterns, performance optimization, modern practices,
  and custom review commands

### [ChatGPT](docs/ai-agents/chatgpt-architecture-instructions.md)

System role optimized for ChatGPT's interaction patterns with comprehensive
technology recommendations.

### [GitHub Copilot](docs/ai-agents/copilot-architecture-instructions.md)

Code generation focused guidelines with security-first patterns and framework
integration examples.

### [Gemini](docs/ai-agents/gemini-architecture-instructions.md)

Advanced analytical approach with multi-dimensional architecture strategy and
emerging technology integration.

### [Anthropic API](docs/ai-agents/anthropic-api-architecture-instructions.md)

Specialized guidance for building applications that integrate with Anthropic's
API services.

## Documentation Templates

### [Template Index](docs/templates/)

Comprehensive templates organized by category for consistent, professional
documentation across all projects.

#### 🏗️ **Architecture Templates**

- **[ADR Template](docs/templates/architecture/adr-template.md)** - Architecture
  Decision Records
- **[System
  Architecture](docs/templates/architecture/system-architecture-document.md)** -
  Complete system documentation

#### 🔌 **API Templates**

- **[API Specification](docs/templates/api/api-specification.md)** - REST API
  documentation with examples

#### 👥 **User Guide Templates**

- **[User Manual](docs/templates/user-guides/user-manual-template.md)** -
  End-user documentation
- **[Admin Manual](docs/templates/user-guides/admin-manual-template.md)** -
  Administrator documentation

#### 💻 **Development Templates**

- **[Setup Guide](docs/templates/development/setup-guide-template.md)** -
  Development environment setup
- **[Coding
  Standards](docs/templates/development/coding-standards-template.md)** - Code
  quality guidelines

### Template Features

- **Complete structure** with comprehensive sections
- **Placeholder text** showing what content to include
- **Real examples** demonstrating best practices
- **Professional formatting** ready for immediate use
- **Scalable design** from startup to enterprise projects

## Core Principles

- **Security by Design**: Built-in security from conception
- **Performance First**: Optimized for scale and efficiency
- **Developer Experience**: Tools and practices that enhance productivity
- **Maintainability**: Long-term sustainability and evolution
- **Accessibility**: Inclusive design for all users
- **Documentation**: Living documentation that evolves with code

## Technology Stack Coverage

### Backend

- Node.js, Python, C#, Java, Go, Rust
- REST APIs, GraphQL, gRPC
- Microservices and monolithic architectures

### Frontend

- React, Vue.js, Angular, Svelte
- Progressive Web Apps (PWA)
- Mobile-first responsive design

### Infrastructure

- Cloud platforms (AWS, Azure, GCP)
- Containerization (Docker, Kubernetes)
- CI/CD pipelines and GitOps

### Databases

- PostgreSQL, MongoDB, Redis
- Database optimization and scaling
- Data modeling and migrations

## Quality Standards

- **Type Safety**: TypeScript and strong typing practices
- **Testing**: TDD, unit, integration, and E2E testing
- **Code Quality**: Linting, formatting, and review processes
- **Security**: Authentication, authorization, and data protection
- **Performance**: Optimization strategies and monitoring

## Project Validation

### Enhanced Workflow System Validation

The repository includes comprehensive validation tools and the new AI-Powered
Code Review system:

```bash
# Unified Validation System (Consolidated from 4 scripts)
npm run validate:full           # Comprehensive validation suite
npm run validate:quick          # Fast essential checks  
npm run validate:pre-merge      # Pre-commit validation
npm run validate:setup          # Setup validation

# Version Management System (Consolidated from 5 scripts)
npm run versions:sync           # Synchronize all versions
npm run versions:list           # List version-managed files
npm run versions:discover       # Discover version files
npm run versions:maintain       # Maintain version consistency
npm run versions:validate       # Validate version consistency

# Workflow Management (Consolidated from 4 scripts)
npm run workflow:test           # Test workflow system
npm run workflow:monitor        # Monitor performance and health
npm run workflow:config         # Configure API secrets
npm run workflow:validate-secret # Validate secret configuration

# Repository Maintenance
npm run cleanup:dry-run         # Preview cleanup operations
npm run cleanup:run             # Execute repository cleanup
npm run analysis:changes        # Detect and analyze changes
```text

### Validation Coverage

- ✅ **Unified Validation System** - Consolidated from 4 validation scripts into single interface with multiple modes
- ✅ **Streamlined Version Management** - Consolidated from 5 scripts into unified version operations system  
- ✅ **Integrated Workflow Management** - Consolidated from 4 scripts into single workflow operations hub
- ✅ **Enhanced Claude Workflow System** - Automated code review capabilities
- ✅ **GitHub Actions Workflows** - claude-code-review.yml, quality-gate.yml 
  and advanced-architecture-review.yml
- ✅ **Custom Claude Commands** - 5 specialized analysis commands
- ✅ **Version Management** - Automated version synchronization across 97+ files
- ✅ **Performance Monitoring** - Real-time workflow health and optimization
- ✅ **Repository Cleanup System** - Automated redundancy detection and removal
- ✅ Documentation structure integrity
- ✅ Architecture compliance (9 core principles)
- ✅ Security best practices and vulnerability scanning
- ✅ Performance considerations and optimization
- ✅ Template completeness and compliance
- ✅ Link validation (internal and external)
- ✅ Dependency security audit
- ✅ File system integrity

See [ERROR_CHECK_REPORT.md](ERROR_CHECK_REPORT.md) for traditional validation,
[Quality Gate Setup Guide](docs/quality-gate-setup.md) for comprehensive error prevention,
and [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md) for AI-Powered Code
Review workflow documentation.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Make your changes and ensure they pass quality gates
4. **Run validation checks**: `npm run validate:full`
5. **Run pre-merge validation**: `npm run validate:pre-merge`
6. Commit with conventional commit messages
7. Submit a pull request

### Quality Gate Requirements

All PRs must pass the following **critical checks** to be merged:
- ✅ Security validation (`npm run lint:security`)
- ✅ Architecture compliance (`npm run lint:architecture`)
- ✅ Template validation (`npm run lint:templates`)
- ✅ Dependency security (high/critical vulnerabilities)
- ✅ File system integrity

**Warning checks** provide feedback but don't block merging:
- ⚠️ Performance optimization recommendations
- ⚠️ Cross-reference accuracy
- ⚠️ External link accessibility

See [Quality Gate Setup Guide](docs/quality-gate-setup.md) for detailed information.

### Commit Message Format

```yaml
type(scope): description

[optional body]

[optional footer]
```text

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

## Versioning

This project follows semantic versioning with centralized version management to
ensure consistency across all documentation.

### Version Schema

- **Major**: Breaking changes to core principles
- **Minor**: New guidelines or significant enhancements
- **Patch**: Bug fixes and minor improvements

### Enhanced Version Management System

The repository includes a comprehensive, automated version management system
that ensures consistency across all documentation, templates, and configuration
files.

```bash
# Unified Version Management System (Consolidated from 5 scripts)
npm run versions:sync           # Automatically synchronize all versions to root VERSION
npm run versions:list           # Show detailed inventory of all version-managed files  
npm run versions:discover       # Discover all files with version information
npm run versions:maintain       # Add version info to files that should have it
npm run versions:validate       # Comprehensive validation of all version-managed files

# Version Bumping
npm run versions:bump           # Interactive version bump
npm run versions:bump-patch     # Patch version increment
npm run versions:bump-minor     # Minor version increment  
npm run versions:bump-major     # Major version increment
```text

**Comprehensive Coverage**: The system automatically manages versions across:

- **Root Documentation**: All major .md files (README.md, CLAUDE.md, etc.)
- **Documentation Files**:
  All docs/ content with architecture, security, performance guides
- **AI Agent Instructions**:
  Version-tagged instruction sets for different AI agents
- **Template Files**: All documentation templates with template version tracking
- **Package Files**: All package.json files across the repository
- **Configuration**: Template version files and metadata

**Key Features**:

- **Automatic Discovery**:
  Finds all files with version patterns without manual configuration
- **Multiple Version Types**:
  Supports **Version**, **Template Version**, **Instruction Version** patterns
- **Comprehensive Validation**:
  Checks 77+ files for version consistency
- **Enhanced Logging**:
  Detailed logs and performance tracking
- **Zero Manual Maintenance**:
  Add new files and they're automatically included
- Template version files and metadata
- Documentation files with version headers
- Individual template versions (28+ files)
- AI agent instruction files (when versioned)

For detailed guidance, see [Version Management
Guide](docs/version-management-guide.md).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file
for details.

## Support

- **Issues**: [GitHub Issues](../../issues)
- **Discussions**: [GitHub Discussions](../../discussions)
- **Wiki**: [Project Wiki](../../wiki)

## Acknowledgments

Built on industry best practices and lessons learned from:

- Clean Architecture principles
- Domain-Driven Design (DDD)
- Twelve-Factor App methodology
- OWASP security guidelines
- Web Content Accessibility Guidelines (WCAG)

---

*Continuously updated to reflect current best practices and emerging
technologies.*

---

- **Version**: 1.3.5
- **Last Updated**: 16 September 2025
- **Template Version**: 1.3.5
