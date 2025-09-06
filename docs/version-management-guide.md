# Version Management Guide

This document provides comprehensive guidance on the repository's centralized version management system.

## Overview

The Web Architecture Guidelines repository uses a centralized version management system to ensure consistency across all documentation, templates, and configuration files. The system maintains synchronization between multiple package.json files, documentation sites, template versions, and metadata across the entire repository.

## Version Management Structure

### Source of Truth

- **Root VERSION file**: Contains the authoritative version number for the entire repository
- Located at: `./VERSION`
- Format: Semantic versioning (e.g., `1.1.0`)

### Managed Files

#### Package Files

- `package.json` - Main repository package file
- `examples/package.json` - Example project configuration
- `docs-site/package.json` - Documentation site package file
- `docs-site/public/examples/package.json` - Public example project configuration

#### Template Version Files

- `docs/.template-version` - Main templates version marker
- `docs/templates/VERSION` - Templates directory version
- `docs-site/public/docs/.template-version` - Public templates version marker
- `docs-site/public/docs/templates/VERSION` - Public templates directory version

#### Documentation Files with Version Metadata

- `docs/architecture/system-architecture.md`
- `docs/security.md`
- `docs/performance.md`
- `docs-site/public/docs/architecture/system-architecture.md`

#### Template Files

All `.md` files in:

- `docs/templates/` (and subdirectories)
- `docs-site/public/docs/templates/` (and subdirectories)

#### AI Agent Instruction Files (Optional)

- Files in `docs/ai-agents/` and `docs-site/public/docs/ai-agents/`
- Only synchronized if they contain explicit version markers (e.g., "Version: 1.1.0")

## Commands

### Version Update Process

1. **Version Update Process**
2. **Development Workflow Integration**
3. **CI/CD Integration**

## Usage Workflows

### 1. Version Update Process

### 2. Development Workflow Integration

### 3. CI/CD Integration

## Supported Version Formats

## Error Handling

## Troubleshooting

## Best Practices

## Integration with Project Workflow

## Maintenance