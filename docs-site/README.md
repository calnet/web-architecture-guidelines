# Documentation Site

This is a React-based interactive documentation site for the Web Architecture Guidelines.

## Features

- **Interactive Navigation**: Browse documentation with a modern, responsive interface
- **Real-time Search**: Find content quickly across all documentation
- **Responsive Design**: Works well on desktop, tablet, and mobile devices
- **Automated Content Sync**: Automatically syncs with the main docs folder

## Development

### Prerequisites

- Node.js (version 18 or higher)
- npm or yarn

### Setup

1. Install dependencies:
   ```bash
   npm install
   ```

2. Copy documentation files:
   ```bash
   npm run copy-docs
   ```

3. Start development server:
   ```bash
   npm run dev
   ```

The site will be available at `http://localhost:5173`

### Building for Production

1. Build the site:
   ```bash
   npm run build
   ```

2. Preview the production build:
   ```bash
   npm run preview
   ```

### Scripts

- `npm run copy-docs`: Copies documentation from the main `docs/` folder to `public/`
- `npm run dev`: Starts development server with hot reload
- `npm run build`: Builds the site for production
- `npm run preview`: Serves the production build locally

## Architecture

The site is built with:

- **React 19**: Modern React with latest features
- **TypeScript**: Type-safe development
- **Vite**: Fast build tool and dev server
- **React Router**: Client-side routing
- **React Markdown**: Markdown rendering with syntax highlighting

## Content Management

The documentation content is automatically synchronized from the main `docs/` folder using the `copy-docs.sh` script. This ensures the React site always reflects the latest documentation while maintaining a single source of truth.

The script copies:
- All documentation files from `docs/`
- Root-level files (README, CLAUDE.md, etc.)
- Configuration examples
- Scripts and tools
- GitHub workflows

## Integration with Main Repository

This React site works seamlessly with the consolidated documentation structure:

1. **Single Source of Truth**: Content comes from the main `docs/` folder
2. **No Duplication**: The React site serves as a frontend for existing documentation
3. **Automatic Updates**: Running `npm run dev` or `npm run build` automatically syncs content
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