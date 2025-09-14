# Documentation & Interactive React Site

This directory serves a dual purpose:
1. **Documentation Source**: Contains all architecture guidelines, templates, and AI agent instructions
2. **Interactive React Site**: React-based web application for browsing the documentation

## Documentation Content

The following directories contain comprehensive web architecture documentation:

### AI Agent Instructions
- `ai-agents/` - Specialized instructions for different AI agents (Claude, ChatGPT, Copilot, Gemini)

### Templates
- `templates/` - Ready-to-use documentation templates for architecture, APIs, user guides, and development

### Guidelines
- `external-documentation-links.md` - Curated external resources
- `project-integration-guide.md` - How to extend these guidelines
- `security.md`, `performance.md` - Specialized guidance

## Interactive React Site

### Development

**Prerequisites:**
- Node.js (version 18 or higher)
- npm or yarn

**Setup:**
```bash
# Install dependencies
npm install

# Start development server
npm run dev
```

The site will be available at `http://localhost:5173`

**Building for Production:**
```bash
# Build the site
npm run build

# Preview the production build
npm run preview
```

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