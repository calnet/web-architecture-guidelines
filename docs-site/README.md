# Web Architecture Guidelines Documentation Site

An interactive React-based documentation website for the Web Architecture Guidelines repository.

## Features

- 📱 **Responsive Design** - Works on all device sizes
- 🎨 **Modern UI** - Clean, professional interface with syntax highlighting
- 📖 **Markdown Rendering** - Supports GitHub Flavored Markdown with code highlighting
- 🔍 **Easy Navigation** - Sidebar navigation and breadcrumb routing
- ⚡ **Fast Loading** - Optimized build with code splitting
- 🛠️ **Live Updates** - Automatically syncs with documentation changes
- 🤖 **Enhanced Claude Integration** - Complete workflow system documentation
- 📊 **Performance Monitoring** - Real-time workflow health and optimization guides

## Quick Start

### Development

```bash
# Install dependencies
npm install

# Start development server (includes documentation sync)
npm run dev

# Open http://localhost:3000 in your browser
```

### Production Build

```bash
# Build for production
npm run build

# Preview production build
npm run preview

# Serve production build on port 3000
npm run serve
```

### Documentation Sync

The site automatically copies documentation files from the parent repository:

```bash
# Manually sync documentation files
npm run copy-docs
```

This copies:

- `README.md`, `git-commands-and-setup.md`, `CLAUDE.md`, `LICENSE`
- `IMPLEMENTATION_GUIDE.md`, `WORKFLOW_README.md`, `CHANGELOG.md` - Enhanced Claude workflow documentation
- `docs/` - Complete documentation structure
- `examples/` - Configuration examples  
- `scripts/` - Validation and workflow management scripts
- `tools/` - Compliance checker
- `.claude/commands/` - Custom Claude commands for automated reviews
- `.github/workflows/` - GitHub Actions workflows for automated analysis

## Project Structure

```
docs-site/
├── public/              # Static files (auto-synced docs)
├── src/
│   ├── components/
│   │   ├── HomePage.tsx           # Landing page
│   │   ├── Navigation.tsx         # Top navigation bar
│   │   ├── Sidebar.tsx           # Documentation sidebar
│   │   └── DocumentationPage.tsx # Markdown content renderer
│   ├── App.tsx          # Main application
│   ├── main.tsx         # React entry point
│   └── index.css        # Global styles
├── copy-docs.sh         # Documentation sync script
└── package.json         # Project configuration
```

## Navigation Structure

The site organizes documentation into logical sections:

### 🚀 Getting Started

- README - Project overview and Enhanced Claude workflow system setup
- Git Commands - Version control setup guide
- Implementation Guide - Complete Enhanced Claude workflow implementation
- Workflow README - Usage and maintenance documentation

### 📋 Templates  

- API Specification - OpenAPI/REST templates
- Architecture ADR - Decision record templates
- Coding Standards - Development guidelines
- User Guides - Documentation templates

### 🏗️ Architecture

- System Architecture - Clean architecture patterns
- Security Guidelines - Security best practices  
- Performance Guidelines - Optimization strategies
- ADR Examples - Architecture decision records

### 🤖 AI Agents & Enhanced Claude System

- Anthropic API - Claude integration instructions
- ChatGPT - OpenAI integration patterns
- GitHub Copilot - VS Code integration setup
- Gemini - Google AI integration guide
- Claude - Advanced Claude configurations
- **Enhanced Claude Commands** - 5 custom commands for automated code reviews:
  - `/architecture-review` - Comprehensive architectural analysis
  - `/security-scan` - Security vulnerability assessment
  - `/performance-check` - Performance optimization review
  - `/documentation-audit` - Documentation quality validation
  - `/quick-fix` - Quick fix implementation

### 💻 Examples

- Docker Compose - Container orchestration
- Package.json - Node.js project configuration
- TypeScript Config - TypeScript setup examples

### 🛠️ Scripts & Tools

- Validation Scripts - Quality assurance automation
- **Enhanced Workflow Scripts** - Complete workflow management system:
  - setup-enhanced-workflow.sh - Complete system setup
  - test-workflow.sh - Comprehensive workflow testing
  - monitor-workflow.sh - Performance monitoring & optimization
  - configure-anthropic-secret.sh - ANTHROPIC_API_KEY configuration
- Template Compliance Checker - Documentation validation

### ⚙️ GitHub Workflows

- **claude-code-review.yml** - Main automated review workflow
- **advanced-architecture-review.yml** - Multi-stage comprehensive analysis

## Technology Stack

- **Framework**: React 19 with TypeScript
- **Build Tool**: Vite 7
- **Routing**: React Router DOM
- **Markdown**: react-markdown with syntax highlighting
- **Styling**: Custom CSS with responsive design
- **Code Highlighting**: rehype-highlight
- **GitHub Flavored Markdown**: remark-gfm

## Build Optimizations

The production build includes:

- **Code Splitting** - Separate chunks for vendor, router, and markdown libraries
- **Tree Shaking** - Removes unused code
- **Asset Optimization** - Compressed CSS and JS
- **Source Maps** - For debugging in production

## Development Workflow

1. **Start Development**: `npm run dev` automatically syncs docs and starts server
2. **Make Changes**: Edit React components or documentation files
3. **Hot Reload**: Changes appear instantly in browser
4. **Build & Deploy**: `npm run build` creates optimized production bundle

## Deployment

The built site is static and can be deployed to:

- Netlify, Vercel, GitHub Pages
- AWS S3 + CloudFront
- Any static hosting provider

The `base: './'` configuration ensures it works in subdirectories.

## Browser Support

- Modern browsers (Chrome, Firefox, Safari, Edge)
- ES2020+ support required
- Responsive design works on all devices

---

**Part of**: [Web Architecture Guidelines](../README.md)  
**License**: MIT
