# Development Environment Setup Guide Template

**Template Version**: 1.3.4
**Last Updated**: 2025-09-06 @ 22:12
**Target Audience**: Developers  

## Prerequisites

Before starting, ensure you have the following installed:

- **Node.js**: Version 18.x or higher
- **Git**: Latest version  
- **Code Editor**: VS Code (recommended) or your preferred editor
- **Docker**: For local development services
- **Operating System**: Windows 10+, macOS 10.15+, or Linux

## Quick Start

### 1. Repository Setup

```bash
# Clone the repository
git clone [repository-url]
cd [project-name]

# Install dependencies
npm install

# Copy environment configuration
cp .env.example .env.local
```text

### 2. Environment Configuration

Edit `.env.local` with your local settings:

```env
# Database
DATABASE_URL="postgresql://user:password@localhost:5432/dbname"

# API Keys
API_KEY="your-api-key-here"
JWT_SECRET="your-jwt-secret"

# Development settings
NODE_ENV="development"
LOG_LEVEL="debug"
```text

### 3. Database Setup

```bash
# Start local database (Docker)
docker-compose up -d postgres

# Run migrations
npm run db:migrate

# Seed development data
npm run db:seed
```text

### 4. Start Development Server

```bash
# Start the development server
npm run dev

# Or start with debugging
npm run dev:debug
```text

### 5. Verify Installation

- Navigate to `http://localhost:3000`
- You should see the application homepage
- Check that all features are working correctly

## Detailed Setup Instructions

### IDE Configuration

#### VS Code Setup

**Install recommended extensions:**

```bash
code --install-extension esbenp.prettier-vscode
code --install-extension bradlc.vscode-tailwindcss
code --install-extension ms-vscode.vscode-typescript-next
code --install-extension ms-vscode.vscode-eslint
code --install-extension GitLens.gitlens
```text

**Workspace settings (`.vscode/settings.json`):**

```json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "typescript.preferences.importModuleSpecifier": "relative",
  "files.exclude": {
    "**/node_modules": true,
    "**/dist": true,
    "**/.git": true
  }
}
```text

#### IntelliJ IDEA Setup

1. **Import project**
   - Open IntelliJ IDEA
   - Import project as existing source
   - Select project root directory

2. **Configure Node.js**
   - Go to Settings > Languages & Frameworks > Node.js
   - Set Node interpreter path
   - Enable TypeScript service

3. **Install recommended plugins**
   - JavaScript and TypeScript
   - Prettier
   - ESLint
   - GitToolBox

### Git Configuration

```bash
# Set up Git hooks
npm run prepare

# Configure commit message template
git config commit.template .gitmessage.txt

# Set up Git aliases (optional)
git config alias.co checkout
git config alias.br branch
git config alias.ci commit
git config alias.st status
git config alias.logs "log --oneline --graph --decorate"
```text

### Development Services

#### Docker Services

**docker-compose.yml:**

```yaml
version: '3.8'
services:
  postgres:
    image: postgres:14
    environment:
      POSTGRES_DB: myapp_dev
      POSTGRES_USER: developer
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
  
  redis:
    image: redis:7
    ports:
      - "6379:6379"
    
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.5.0
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    ports:
      - "9200:9200"

volumes:
  postgres_data:
```text

**Start services:**

```bash
docker-compose up -d
```text

### Testing Setup

#### Test Configuration

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:coverage

# Run end-to-end tests
npm run test:e2e

# Run specific test file
npm test -- user.test.ts
```text

#### Test Environment Variables

Create `.env.test`:

```env
NODE_ENV=test
DATABASE_URL="postgresql://user:password@localhost:5432/testdb"
JWT_SECRET="test-jwt-secret"
LOG_LEVEL="error"
```text

## Development Workflow

### Branch Strategy

```text
main              ← Production-ready code
├── develop       ← Integration branch
    ├── feature/  ← Feature branches
    ├── bugfix/   ← Bug fix branches
    └── hotfix/   ← Emergency fixes
```text

### Feature Development Process

1. **Create feature branch**

   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/user-authentication
   ```text

2. **Implement changes**
   - Write code following coding standards
   - Add comprehensive tests
   - Update documentation
   - Commit frequently with meaningful messages

3. **Pre-pull request checklist**

   ```bash
   # Run quality checks
   npm run lint
   npm run type-check
   npm run test
   npm run build
   ```text

4. **Create pull request**
   - Use PR template
   - Provide clear description
   - Link related issues
   - Request appropriate reviewers

### Commit Guidelines

**Conventional commit format:**

```yaml
type(scope): description

[optional body]

[optional footer]
```text

**Examples:**

```bash
feat(auth): add OAuth2 integration
fix(api): resolve user creation bug
docs(readme): update setup instructions
test(user): add unit tests for user service
refactor(db): optimize query performance
```text

**Commit types:**

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Code Review Process

1. **Create feature branch** from `develop`
2. **Implement changes** with tests
3. **Run quality checks** locally
4. **Create pull request** with detailed description
5. **Address review feedback** promptly
6. **Merge after approval** and passing CI/CD

## Quality Checks

### Automated Quality Gates

#### Pre-commit Hooks

Automated checks run before each commit:

- **Code formatting** (Prettier)
- **Linting** (ESLint)
- **Type checking** (TypeScript)
- **Unit tests** (Jest)
- **Security scanning** (npm audit)

#### CI/CD Pipeline Checks

- **Build verification**
- **Full test suite**
- **Code coverage thresholds**
- **Security vulnerability scanning**
- **Performance regression tests**

### Manual Quality Checks

```bash
# Lint code
npm run lint

# Fix linting issues automatically
npm run lint:fix

# Type check
npm run type-check

# Format code
npm run format

# Security audit
npm audit

# Performance analysis
npm run analyze

# Build verification
npm run build
```text

### Code Quality Metrics

- **Test Coverage**: Minimum 80% line coverage
- **TypeScript**: Strict mode enabled
- **ESLint**: Zero warnings in production code
- **Bundle Size**: Monitor and optimize for performance
- **Performance**: Lighthouse CI for frontend performance

## Troubleshooting

### Common Issues

#### Node.js Version Mismatch

**Error**: `The engine "node" is incompatible with this module`

**Solution**:

```bash
# Using Node Version Manager (nvm)
nvm install 18
nvm use 18

# Or using fnm
fnm install 18
fnm use 18

# Verify version
node --version
```text

#### Port Already in Use

**Error**: `Port 3000 is already in use`

**Solutions**:

```bash
# Option 1: Kill process using port
lsof -ti:3000 | xargs kill -9

# Option 2: Use different port
PORT=3001 npm run dev

# Option 3: Find and kill specific process
ps aux | grep node
kill -9 [process-id]
```text

#### Database Connection Failed

**Error**: `Connection refused` or `ECONNREFUSED`

**Solutions**:

1. **Ensure Docker is running**

   ```bash
   docker --version
   docker ps
   ```text

2. **Start database service**

   ```bash
   docker-compose up -d postgres
   ```text

3. **Check connection string**
   - Verify `.env.local` database URL
   - Ensure credentials match docker-compose.yml

4. **Reset database**

   ```bash
   docker-compose down
   docker-compose up -d postgres
   npm run db:migrate
   ```text

#### Module Not Found

**Error**: `Cannot find module` or `Module not found`

**Solutions**:

```bash
# Clear node modules and reinstall
rm -rf node_modules package-lock.json
npm install

# Clear npm cache
npm cache clean --force

# Check for case sensitivity issues (especially on Windows)
# Ensure import paths match actual file names exactly
```text

#### TypeScript Compilation Errors

**Error**: Various TypeScript compilation issues

**Solutions**:

```bash
# Clear TypeScript cache
npx tsc --build --clean

# Restart TypeScript service in VS Code
# Ctrl+Shift+P -> "TypeScript: Restart TS Server"

# Check tsconfig.json configuration
# Ensure all paths are correctly configured

# Update TypeScript and related packages
npm update typescript @types/node
```text

#### Docker Issues

**Error**: Docker service won't start

**Solutions**:

```bash
# Check Docker daemon status
docker info

# Restart Docker service
# On Windows: Restart Docker Desktop
# On macOS: Restart Docker Desktop
# On Linux: sudo systemctl restart docker

# Clear Docker cache
docker system prune -a

# Reset Docker completely (last resort)
docker system prune -a --volumes
```text

### Performance Issues

#### Slow Development Server

**Symptoms**: Long startup times, slow hot reload

**Solutions**:

- **Exclude unnecessary files** from watching

  ```javascript
  // webpack.config.js or vite.config.js
  watchOptions: {
    ignored: /node_modules/
  }
  ```text

- **Increase Node.js memory**

  ```bash
  export NODE_OPTIONS="--max-old-space-size=8192"
  npm run dev
  ```text

- **Use SSD storage** for better I/O performance
- **Close unnecessary applications** to free up resources

#### Large Bundle Size

**Symptoms**: Slow page loads, large JavaScript bundles

**Solutions**:

```bash
# Analyze bundle size
npm run analyze

# Implement code splitting
# Use dynamic imports for large dependencies

# Optimize images and assets
# Use appropriate image formats (WebP, AVIF)

# Remove unused dependencies
npx depcheck
```text

### Getting Help

#### Self-Service Resources

- **Documentation**: Check project README and docs/
- **Issue Tracker**: Search existing GitHub issues
- **Stack Overflow**: Search for similar problems
- **Official Documentation**: Framework and library docs

#### Team Support

- **Team Chat**: [Slack/Discord channel]
- **Code Review**: Ask for help in pull requests
- **Pair Programming**: Schedule sessions with team members
- **Office Hours**: Regular help sessions with senior developers

#### External Resources

- **Community Forums**: Framework-specific communities
- **GitHub Discussions**: Project-specific discussions
- **Technical Blogs**: Industry best practices and solutions
- **Video Tutorials**: Step-by-step learning resources

## Additional Resources

### Development Tools

- **API Testing**: Postman, Insomnia, REST Client
- **Database Tools**: pgAdmin, MongoDB Compass, Redis CLI
- **Debugging**: Browser DevTools, Node.js debugger, VS Code debugger
- **Performance**: Lighthouse, WebPageTest, Chrome DevTools

### Learning Resources

- **Style Guide**: [Link to coding standards]
- **API Documentation**: [Link to API docs]
- **Architecture Overview**: [Link to architecture docs]
- **Deployment Guide**: [Link to deployment docs]
- **Team Onboarding**: [Link to team-specific documentation]

### Useful Commands Reference

```bash
# Development
npm run dev              # Start development server
npm run dev:debug        # Start with debugging enabled
npm run build            # Production build
npm run preview          # Preview production build

# Testing
npm test                 # Run all tests
npm run test:watch       # Watch mode
npm run test:coverage    # With coverage report
npm run test:e2e         # End-to-end tests

# Code Quality
npm run lint             # Lint code
npm run lint:fix         # Fix linting issues
npm run format           # Format code
npm run type-check       # TypeScript checking

# Database
npm run db:migrate       # Run migrations
npm run db:seed          # Seed database
npm run db:reset         # Reset database
npm run db:studio        # Open database studio

# Docker
docker-compose up -d     # Start services
docker-compose down      # Stop services
docker-compose logs      # View logs
docker-compose ps        # List running services
```text

---
*Template Version: 1.3.4****************  
*Last Updated: [Date]*
