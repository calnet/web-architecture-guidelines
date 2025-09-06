# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a documentation-only repository containing web application architecture guidelines optimized for AI agents and development teams. The repository focuses on providing comprehensive instruction sets for various AI agents and documentation templates for building high-quality web applications.

## Repository Structure

```
docs/
├── ai-agents/                          # AI agent-specific instructions
│   ├── claude/                         # Claude-specific instructions (V1 and V2)
│   ├── chatgpt-architecture-instructions.md
│   ├── copilot-architecture-instructions.md
│   ├── gemini-architecture-instructions.md
│   └── anthropic-api-architecture-instructions.md
├── external-documentation-links.md     # Curated external resources
├── project-integration-guide.md        # How to extend these guidelines
└── templates/                          # Documentation templates organized by category
    ├── README.md                       # Template index and usage guide
    ├── architecture/                   # ADRs and system documentation
    ├── api/                           # API specification templates
    ├── user-guides/                   # User and admin manual templates
    └── development/                   # Setup guides and coding standards
```

## Core Architecture

This repository follows a documentation-first approach with these key principles:

### Content Organization
- **Separation of concerns**: AI agent instructions are separate from generic templates
- **Versioning**: Multiple versions of instructions (e.g., Claude V1/V2) for different complexity needs
- **Categorization**: Templates organized by functional area (architecture, API, user guides, development)

### Quality Assurance
- **GitHub Actions workflow** (`.github/workflows/validate-docs.yml`) provides automated validation
- **Link checking**: Validates all markdown links are accessible
- **Markdown linting**: Ensures consistent formatting and style
- **Structure validation**: Verifies required directories and files exist

## Common Development Tasks

### Documentation Validation
The repository uses GitHub Actions for automated validation. Locally, you can:

```bash
# The workflow runs automatically on push/PR to main for docs/** changes
# Manual validation can be done by reviewing the GitHub Actions tab
```

### Content Updates
When updating documentation:

1. **Maintain structure**: Follow the established directory organization
2. **Update cross-references**: Ensure links between documents remain valid
3. **Follow semantic versioning**: Use conventional commits for changes
4. **Test externally**: Verify external links in `external-documentation-links.md` are still valid

### Commit Conventions
The repository follows conventional commit format:
- `feat`: New guidelines or significant enhancements
- `fix`: Bug fixes and minor improvements  
- `docs`: Documentation updates
- `ci`: GitHub workflow changes

Example: `feat: enhance documentation templates and integration guide with structured categories`

## File Modification Guidelines

### When working with AI agent instructions:
- **Maintain consistency**: Keep instruction format similar across different agents
- **Version appropriately**: Create new versions for major changes rather than breaking existing ones
- **Cross-reference**: Update the main README.md when adding new agent instructions

### When working with templates:
- **Preserve structure**: Maintain the placeholder text and example format
- **Update index**: Modify `docs/templates/README.md` when adding new templates
- **Keep scalable**: Ensure templates work for both startup and enterprise projects

### When updating external links:
- **Verify accessibility**: Test all links before committing
- **Maintain categorization**: Follow the established organization in `external-documentation-links.md`
- **Add context**: Include brief descriptions for why resources are valuable

## Important Files

- **README.md**: Main entry point explaining repository purpose and usage
- **docs/project-integration-guide.md**: Critical for understanding how to extend guidelines
- **docs/external-documentation-links.md**: Curated list of external resources requiring regular maintenance
- **git-commands-and-setup.md**: Repository setup and maintenance procedures

## Quality Standards

- **No build/test commands**: This is a documentation-only repository
- **Markdown consistency**: All documentation uses GitHub-flavored markdown
- **Link integrity**: All internal and external links must be valid
- **Professional formatting**: Templates are ready for immediate professional use
- **Comprehensive coverage**: Instructions cover all major aspects of web application architecture

## Repository Maintenance

- **Monthly**: Review and update external documentation links
- **Quarterly**: Review AI agent instructions for new capabilities
- **Annually**: Major review and version updates

This repository serves as a comprehensive foundation for web application architecture guidance that evolves with industry best practices and AI agent capabilities.