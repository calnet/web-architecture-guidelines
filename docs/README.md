# Documentation & Interactive React Site

This directory serves as the unified documentation hub for the Web Application Architecture Guidelines, providing both comprehensive documentation and an interactive browsing experience.

## Dual Architecture

### 1. Documentation Source
Contains all architecture guidelines, templates, AI agent instructions, and supporting documentation organized in a logical structure for direct access and editing.

### 2. Interactive React Site
Full-featured React-based documentation website with comprehensive routing, navigation, and content management capabilities.

## Documentation Content Structure

### AI Agent Instructions (`ai-agents/`)
- **claude-architecture-instructions.md** - Main Claude AI instructions
- **chatgpt-architecture-instructions.md** - ChatGPT/GPT-4 specific guidance
- **copilot-architecture-instructions.md** - GitHub Copilot instructions
- **gemini-architecture-instructions.md** - Google Gemini guidance
- **anthropic-api-architecture-instructions.md** - Anthropic API integration
- **AI_AGENT_INTEGRATION_GUIDE.md** - Universal integration framework
- **claude/** - Alternative Claude instruction versions

### Architecture Documentation (`architecture/`)
- **system-architecture.md** - Complete system architecture overview
- **decisions/** - Architecture Decision Records (ADRs)
  - **adr-001-technology-stack.md** - Technology selection rationale
  - **adr-002-database-schema-patterns.md** - Database design patterns
  - **adr-003-authentication-strategy.md** - Authentication approach

### Documentation Templates (`templates/`)
- **architecture/** - Architecture documentation templates
  - **adr-template.md** - Architecture Decision Record template
  - **system-architecture-document.md** - System documentation template
- **api/** - API documentation templates
  - **api-specification.md** - REST API specification template
- **user-guides/** - User documentation templates
  - **user-manual-template.md** - End-user documentation template
  - **admin-manual-template.md** - Administrator manual template
- **development/** - Development team templates
  - **setup-guide-template.md** - Environment setup template
  - **coding-standards-template.md** - Code quality standards template

### Configuration & Guidelines
- **external-documentation-links.md** - Curated external resources
- **project-integration-guide.md** - How to extend these guidelines
- **security.md** - Security architecture guidelines
- **performance.md** - Performance optimization guidelines
- **github-actions-secrets-setup.md** - CI/CD configuration guide
- **quality-gate-setup.md** - Quality assurance configuration
- **version-management-guide.md** - Version control guidelines

## Interactive React Site

The React-based documentation site provides comprehensive access to all repository content through an intuitive interface with full routing and navigation capabilities.

### Key Features

#### Complete Content Coverage
- **All 55+ markdown files** are accessible through dedicated routes
- **10 navigation categories** organize content logically
- **Dynamic content loading** for all documentation types
- **Comprehensive file path mapping** ensures no content is orphaned

#### Navigation Categories
1. **Getting Started** (8 files) - Project overview, setup guides, integration instructions
2. **Templates** (8 files) - All documentation templates organized by category
3. **Architecture** (6 files) - System architecture, ADRs, security, performance guidelines
4. **AI Agents** (6 files) - Instructions for Claude, ChatGPT, Copilot, Gemini, and integration guides
5. **Configuration** (7 files) - GitHub Actions, quality gates, version management setup
6. **Project Management** (6 files) - Changelog, quality reports, workflow guides, merge documentation
7. **Claude Commands** (5 files) - Custom Claude code review and analysis commands
8. **GitHub Templates** (3 files) - Issue and pull request templates
9. **Scripts Documentation** (2 files) - Performance testing and validation tools
10. **Additional Resources** - Implementation guides, workflow documentation

#### Technical Architecture
- **HashRouter Implementation** - Ensures compatibility with all static hosting environments
- **Dynamic Content Loading** - Markdown files processed with syntax highlighting and GitHub-flavored markdown
- **Responsive Design** - Full mobile and desktop compatibility
- **Copy Script Integration** - Automated content synchronization from repository root

### Development Setup

**Prerequisites:**
- Node.js (version 18 or higher)
- npm or yarn package manager

**Local Development:**
```bash
# Navigate to docs directory
cd docs/

# Install dependencies
npm install

# Start development server
npm run dev
```

The development server will be available at `http://localhost:5173`

**Production Build:**
```bash
# Build the optimized site
npm run build

# Preview the production build locally
npm run preview
```

### Deployment Configuration

The site is configured for static hosting with:
- **Base path configuration** in `vite.config.ts`
- **HashRouter** for client-side routing compatibility
- **Automated content copying** via `copy-docs.sh` script
- **GitHub Pages ready** deployment setup

### Content Management

The site automatically includes:
- **Repository root files** (README, CLAUDE.md, LICENSE, etc.)
- **All documentation** from the docs/ directory structure
- **Enhanced workflow files** (IMPLEMENTATION_GUIDE, WORKFLOW_README)
- **Project management files** (CHANGELOG, quality reports, conflict analysis)
- **Custom Claude commands** from .claude/commands/
- **GitHub templates** from .github/ISSUE_TEMPLATE/
- **Scripts and tools** from scripts/ and tools/ directories

### Architecture

The React site is built with:
- **React 19**: Modern React with latest features
- **TypeScript**: Type-safe development
- **Vite**: Fast build tool and dev server
- **React Router**: Client-side routing
- **React Markdown**: Markdown rendering with syntax highlighting

### Content Management

The `copy-docs.sh` script automatically synchronizes content:
- Documentation files from this directory
- Root-level files (README, CLAUDE.md, etc.)
- Configuration examples
- Scripts and tools
- GitHub workflows

This ensures the React site always reflects the latest documentation while maintaining a single source of truth.

### Scripts

- `npm run copy-docs`: Copies documentation to `public/` directory
- `npm run dev`: Starts development server with hot reload
- `npm run build`: Builds the site for production
- `npm run preview`: Serves the production build locally

## Integration with Repository

This unified approach provides:

1. **Single Source of Truth**: All documentation lives in one place
2. **No Duplication**: The React site serves as a frontend for existing documentation
3. **Automatic Updates**: Building the site automatically syncs content
4. **Version Consistency**: Uses the same version numbers as the main repository

## Deployment

The site can be deployed to any static hosting service:

1. Build the site: `npm run build`
2. Deploy the `dist/` folder to your hosting service

Popular options include:
- GitHub Pages
- Netlify
- Vercel
- AWS S3 + CloudFront