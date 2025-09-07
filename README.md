# Web Application Architecture Guidelines

Comprehensive guidelines for building well-architected, secure, scalable, and maintainable web applications.

*Version 1.1.0 - Enhanced documentation quality with improved markdownlint compliance*

## Overview

This repository contains architecture guidelines and instructions optimized for AI agents and development teams to build high-quality web applications following industry best practices.

## Structure

```
docs/
├── ai-agents/                          # AI agent-specific instructions
│   ├── claude/                         # Claude-specific instructions
│   │   ├── claude-architecture-instructions-v1.md
│   │   └── claude-architecture-instructions-v2.md
│   ├── chatgpt-architecture-instructions.md
│   ├── copilot-architecture-instructions.md
│   ├── gemini-architecture-instructions.md
│   └── anthropic-api-architecture-instructions.md
├── external-documentation-links.md     # Curated external resources
├── integration-automation-script.md     # Automated integration script documentation
├── project-integration-guide.md        # How to extend these guidelines
└── templates/                          # Documentation templates (organized by category)
    ├── README.md                       # Template index and usage guide
    ├── architecture/                   # Architecture documentation templates
    │   ├── adr-template.md            # Architecture Decision Records
    │   └── system-architecture-document.md # System documentation
    ├── api/                           # API documentation templates
    │   └── api-specification.md       # REST API documentation
    ├── user-guides/                   # User documentation templates
    │   ├── user-manual-template.md    # End-user documentation
    │   └── admin-manual-template.md   # Administrator documentation
    └── development/                   # Development team templates
        ├── setup-guide-template.md   # Environment setup
        └── coding-standards-template.md # Code quality standards
```

## Quick Start

### For AI Agents
1. Choose the appropriate instruction file for your AI agent
2. Use it as a system prompt or reference guide
3. Adapt recommendations based on project context

### For Development Teams
1. Use the [Integration Automation Script](docs/integration-automation-script.md) for automated setup
2. Review the [Project Integration Guide](docs/project-integration-guide.md) for manual integration
3. Use [documentation templates](docs/templates/) for your project
4. Reference [external documentation](docs/external-documentation-links.md) as needed

### For Project-Specific Implementation
1. Fork or reference this repository
2. Follow the integration guide to extend guidelines for your project
3. Maintain separation between base and project-specific guidelines

## AI Agent Instructions

### [Claude](docs/ai-agents/claude/)
- **V1**: Foundational architecture guidance
- **V2**: Enhanced with advanced patterns, performance optimization, and modern practices

### [ChatGPT](docs/ai-agents/chatgpt-architecture-instructions.md)
System role optimized for ChatGPT's interaction patterns with comprehensive technology recommendations.

### [GitHub Copilot](docs/ai-agents/copilot-architecture-instructions.md)
Code generation focused guidelines with security-first patterns and framework integration examples.

### [Gemini](docs/ai-agents/gemini-architecture-instructions.md)
Advanced analytical approach with multi-dimensional architecture strategy and emerging technology integration.

### [Anthropic API](docs/ai-agents/anthropic-api-architecture-instructions.md)
Specialized guidance for building applications that integrate with Anthropic's API services.

## Documentation Templates

### [Template Index](docs/templates/)
Comprehensive templates organized by category for consistent, professional documentation across all projects.

#### 🏗️ **Architecture Templates**
- **[ADR Template](docs/templates/architecture/adr-template.md)** - Architecture Decision Records
- **[System Architecture](docs/templates/architecture/system-architecture-document.md)** - Complete system documentation

#### 🔌 **API Templates**
- **[API Specification](docs/templates/api/api-specification.md)** - REST API documentation with examples

#### 👥 **User Guide Templates**
- **[User Manual](docs/templates/user-guides/user-manual-template.md)** - End-user documentation
- **[Admin Manual](docs/templates/user-guides/admin-manual-template.md)** - Administrator documentation

#### 💻 **Development Templates**
- **[Setup Guide](docs/templates/development/setup-guide-template.md)** - Development environment setup
- **[Coding Standards](docs/templates/development/coding-standards-template.md)** - Code quality guidelines

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

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Make your changes and add tests
4. Commit with conventional commit messages
5. Submit a pull request

### Commit Message Format
```
type(scope): description

[optional body]

[optional footer]
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

## Versioning

This project follows semantic versioning. Major updates to guidelines warrant version increments.

- **Major**: Breaking changes to core principles
- **Minor**: New guidelines or significant enhancements
- **Patch**: Bug fixes and minor improvements

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

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

*Continuously updated to reflect current best practices and emerging technologies.*