import { useEffect, useState } from 'react'
import { useParams } from 'react-router-dom'
import ReactMarkdown from 'react-markdown'
import remarkGfm from 'remark-gfm'
import rehypeHighlight from 'rehype-highlight'

// Generate index page content for each category
function generateIndexPage(category: string): string {
    const sectionData: Record<string, { title: string; description: string; items: Array<{ title: string; path: string; description: string }> }> = {
        'getting-started': {
            title: 'Getting Started',
            description: 'Essential documentation and guides to help you get started with this project.',
            items: [
                { title: 'README', path: '/docs/getting-started/readme', description: 'Main project overview and quick start guide' },
                { title: 'Git Commands', path: '/docs/getting-started/git-commands', description: 'Essential Git commands and repository setup instructions' },
                { title: 'Claude Guide', path: '/docs/getting-started/claude-guide', description: 'Specific instructions for working with Claude AI assistant' },
                { title: 'Integration Script', path: '/docs/getting-started/integration-automation', description: 'Automated integration tools and scripts' },
                { title: 'Integration Guide', path: '/docs/getting-started/project-integration', description: 'Complete guide for integrating this architecture into your projects' },
                { title: 'External Links', path: '/docs/getting-started/external-links', description: 'Curated links to external documentation and resources' },
                { title: 'Implementation Guide', path: '/docs/getting-started/implementation-guide', description: 'Comprehensive implementation and workflow setup guide' },
                { title: 'Docs Directory', path: '/docs/getting-started/docs-readme', description: 'Documentation directory overview and structure' },
            ]
        },
        'templates': {
            title: 'Templates',
            description: 'Ready-to-use templates for documentation, architecture, and development standards.',
            items: [
                { title: 'API Specification', path: '/docs/templates/api', description: 'Template for API documentation and specifications' },
                { title: 'Architecture ADR', path: '/docs/templates/architecture', description: 'Architecture Decision Record template' },
                { title: 'System Architecture Doc', path: '/docs/templates/system-architecture', description: 'System architecture documentation template' },
                { title: 'Coding Standards', path: '/docs/templates/development', description: 'Development and coding standards template' },
                { title: 'Setup Guide', path: '/docs/templates/setup-guide', description: 'Environment setup guide template' },
                { title: 'User Guides', path: '/docs/templates/user-guides', description: 'User manual and guide templates' },
                { title: 'Admin Manual', path: '/docs/templates/admin-manual', description: 'Administrator manual template' },
                { title: 'Template Overview', path: '/docs/templates/overview', description: 'Template usage guide and overview' },
            ]
        },
        'architecture': {
            title: 'Architecture',
            description: 'System architecture documentation, guidelines, and decision records.',
            items: [
                { title: 'System Architecture', path: '/docs/architecture/system', description: 'Complete system architecture documentation' },
                { title: 'Security Guidelines', path: '/docs/architecture/security', description: 'Security architecture and best practices' },
                { title: 'Performance Guidelines', path: '/docs/architecture/performance', description: 'Performance optimization and monitoring guidelines' },
                { title: 'Technology Stack ADR', path: '/docs/architecture/adr-001', description: 'Technology stack decisions and rationale' },
                { title: 'Database Patterns ADR', path: '/docs/architecture/adr-002', description: 'Database schema and pattern decisions' },
                { title: 'Authentication ADR', path: '/docs/architecture/adr-003', description: 'Authentication strategy and implementation' },
            ]
        },
        'ai-agents': {
            title: 'AI Agents',
            description: 'Configuration and instructions for various AI development assistants.',
            items: [
                { title: 'Integration Guide', path: '/docs/ai-agents/integration-guide', description: 'Universal AI agent integration guide and best practices' },
                { title: 'Anthropic API', path: '/docs/ai-agents/anthropic', description: 'Anthropic API integration and usage instructions' },
                { title: 'ChatGPT', path: '/docs/ai-agents/chatgpt', description: 'ChatGPT configuration and architectural guidelines' },
                { title: 'GitHub Copilot', path: '/docs/ai-agents/copilot', description: 'GitHub Copilot setup and best practices' },
                { title: 'Gemini', path: '/docs/ai-agents/gemini', description: 'Google Gemini AI integration guide' },
                { title: 'Claude', path: '/docs/ai-agents/claude', description: 'Claude AI assistant configuration and instructions' },
            ]
        },
        'project-management': {
            title: 'Project Management',
            description: 'Project management documentation including changelogs, reports, and analysis.',
            items: [
                { title: 'Changelog', path: '/docs/project-management/changelog', description: 'Version history and release notes' },
                { title: 'Quality Gate Report', path: '/docs/project-management/quality-gate', description: 'Quality assurance and compliance reporting' },
                { title: 'Error Check Report', path: '/docs/project-management/error-check', description: 'Validation and error reporting documentation' },
                { title: 'Workflow Guide', path: '/docs/project-management/workflow-readme', description: 'Workflow system usage and maintenance guide' },
                { title: 'Conflict Analysis', path: '/docs/project-management/conflict-analysis', description: 'Repository merge conflict analysis' },
                { title: 'Merge Summary', path: '/docs/project-management/merge-summary', description: 'Repository merge completion documentation' },
            ]
        },
        'configuration': {
            title: 'Configuration',
            description: 'System configuration guides and setup documentation.',
            items: [
                { title: 'GitHub Actions Setup', path: '/docs/configuration/github-actions', description: 'GitHub Actions secrets and workflow configuration' },
                { title: 'Quality Gate Setup', path: '/docs/configuration/quality-gate', description: 'Quality gate configuration and validation setup' },
                { title: 'Version Management', path: '/docs/configuration/version-management', description: 'Version management and release documentation' },
                { title: 'Enhanced Version System', path: '/docs/configuration/enhanced-version', description: 'Advanced version management system features' },
                { title: 'Template Compatibility', path: '/docs/configuration/template-compatibility', description: 'Template version compatibility and migration guide' },
                { title: 'Validation System', path: '/docs/configuration/validation-system', description: 'Validation framework and quality checking system' },
                { title: 'Next Steps Guide', path: '/docs/configuration/next-steps', description: 'Future development and enhancement roadmap' },
            ]
        },
        'claude-commands': {
            title: 'Claude Commands',
            description: 'Custom Claude commands for code review and analysis.',
            items: [
                { title: 'Architecture Review', path: '/docs/claude-commands/architecture-review', description: 'Comprehensive architectural analysis command' },
                { title: 'Documentation Audit', path: '/docs/claude-commands/documentation-audit', description: 'Documentation quality and completeness review' },
                { title: 'Performance Check', path: '/docs/claude-commands/performance-check', description: 'Application performance analysis command' },
                { title: 'Quick Fix', path: '/docs/claude-commands/quick-fix', description: 'Immediate actionable fixes command' },
                { title: 'Security Scan', path: '/docs/claude-commands/security-scan', description: 'Security vulnerability assessment command' },
            ]
        },
        'github-templates': {
            title: 'GitHub Templates',
            description: 'GitHub issue and pull request templates for consistent project management.',
            items: [
                { title: 'Bug Report', path: '/docs/github-templates/bug-report', description: 'Bug report issue template' },
                { title: 'Feature Request', path: '/docs/github-templates/feature-request', description: 'Feature request issue template' },
                { title: 'Pull Request', path: '/docs/github-templates/pull-request', description: 'Pull request template' },
            ]
        },
        'examples': {
            title: 'Examples',
            description: 'Example configuration files and implementation samples.',
            items: [
                { title: 'Docker Compose', path: '/docs/examples/docker', description: 'Docker Compose configuration example' },
                { title: 'Package.json', path: '/docs/examples/package', description: 'Node.js package.json configuration example' },
                { title: 'TypeScript Config', path: '/docs/examples/typescript', description: 'TypeScript configuration example' },
            ]
        },
        'scripts': {
            title: 'Scripts & Tools',
            description: 'Automation scripts and development tools for maintaining project quality.',
            items: [
                { title: 'Validation Scripts', path: '/docs/scripts/validation', description: 'Comprehensive validation and quality check scripts' },
                { title: 'Template Tools', path: '/docs/scripts/templates', description: 'Template compliance and management tools' },
                { title: 'Performance Testing', path: '/docs/scripts/performance-testing', description: 'Performance testing guide and tools' },
            ]
        }
    }

    const section = sectionData[category]
    if (!section) {
        return `# ${category}\n\nSection not found.`
    }

    let content = `# ${section.title}\n\n${section.description}\n\n## Available Documentation\n\n`

    section.items.forEach(item => {
        content += `### [${item.title}](${item.path})\n\n${item.description}\n\n`
    })

    return content
}

function DocumentationPage() {
    const { category, slug } = useParams<{ category: string; slug?: string }>()
    const [content, setContent] = useState<string>('')
    const [loading, setLoading] = useState<boolean>(true)
    const [error, setError] = useState<string>('')

    useEffect(() => {
        const loadDocument = async () => {
            if (!category) return

            setLoading(true)
            setError('')

            try {
                let filePath = ''

                // If no slug provided, show index page for the category
                if (!slug) {
                    filePath = `index-${category}`
                } else {
                    // Map routes to actual file paths
                    switch (category) {
                        case 'getting-started':
                            if (slug === 'readme') {
                                filePath = '/README.md'
                            } else if (slug === 'git-commands') {
                                filePath = '/git-commands-and-setup.md'
                            } else if (slug === 'claude-guide') {
                                filePath = '/CLAUDE.md'
                            } else if (slug === 'integration-automation') {
                                filePath = '/docs/integration-automation-script.md'
                            } else if (slug === 'project-integration') {
                                filePath = '/docs/project-integration-guide.md'
                            } else if (slug === 'external-links') {
                                filePath = '/docs/external-documentation-links.md'
                            } else if (slug === 'implementation-guide') {
                                filePath = '/IMPLEMENTATION_GUIDE.md'
                            } else if (slug === 'docs-readme') {
                                filePath = '/docs/README.md'
                            }
                            break
                        case 'templates':
                            if (slug === 'api') {
                                filePath = '/docs/templates/api/api-specification.md'
                            } else if (slug === 'architecture') {
                                filePath = '/docs/templates/architecture/adr-template.md'
                            } else if (slug === 'system-architecture') {
                                filePath = '/docs/templates/architecture/system-architecture-document.md'
                            } else if (slug === 'development') {
                                filePath = '/docs/templates/development/coding-standards-template.md'
                            } else if (slug === 'setup-guide') {
                                filePath = '/docs/templates/development/setup-guide-template.md'
                            } else if (slug === 'user-guides') {
                                filePath = '/docs/templates/user-guides/user-manual-template.md'
                            } else if (slug === 'admin-manual') {
                                filePath = '/docs/templates/user-guides/admin-manual-template.md'
                            } else if (slug === 'overview') {
                                filePath = '/docs/templates/README.md'
                            }
                            break
                        case 'architecture':
                            if (slug === 'system') {
                                filePath = '/docs/architecture/system-architecture.md'
                            } else if (slug === 'security') {
                                filePath = '/docs/security.md'
                            } else if (slug === 'performance') {
                                filePath = '/docs/performance.md'
                            } else if (slug === 'adr-001') {
                                filePath = '/docs/architecture/decisions/adr-001-technology-stack.md'
                            } else if (slug === 'adr-002') {
                                filePath = '/docs/architecture/decisions/adr-002-database-schema-patterns.md'
                            } else if (slug === 'adr-003') {
                                filePath = '/docs/architecture/decisions/adr-003-authentication-strategy.md'
                            }
                            break
                        case 'ai-agents':
                            if (slug === 'integration-guide') {
                                filePath = '/docs/ai-agents/AI_AGENT_INTEGRATION_GUIDE.md'
                            } else if (slug === 'anthropic') {
                                filePath = '/docs/ai-agents/anthropic-api-architecture-instructions.md'
                            } else if (slug === 'chatgpt') {
                                filePath = '/docs/ai-agents/chatgpt-architecture-instructions.md'
                            } else if (slug === 'copilot') {
                                filePath = '/docs/ai-agents/copilot-architecture-instructions.md'
                            } else if (slug === 'gemini') {
                                filePath = '/docs/ai-agents/gemini-architecture-instructions.md'
                            } else if (slug === 'claude') {
                                filePath = '/docs/ai-agents/claude-architecture-instructions.md'
                            }
                            break
                        case 'project-management':
                            if (slug === 'changelog') {
                                filePath = '/CHANGELOG.md'
                            } else if (slug === 'quality-gate') {
                                filePath = '/QUALITY_GATE_REPORT.md'
                            } else if (slug === 'error-check') {
                                filePath = '/ERROR_CHECK_REPORT.md'
                            } else if (slug === 'workflow-readme') {
                                filePath = '/WORKFLOW_README.md'
                            } else if (slug === 'conflict-analysis') {
                                filePath = '/CONFLICT_ANALYSIS.md'
                            } else if (slug === 'merge-summary') {
                                filePath = '/MERGE_COMPLETION_SUMMARY.md'
                            }
                            break
                        case 'configuration':
                            if (slug === 'github-actions') {
                                filePath = '/docs/github-actions-secrets-setup.md'
                            } else if (slug === 'quality-gate') {
                                filePath = '/docs/quality-gate-setup.md'
                            } else if (slug === 'version-management') {
                                filePath = '/docs/version-management-guide.md'
                            } else if (slug === 'enhanced-version') {
                                filePath = '/docs/ENHANCED_VERSION_SYSTEM.md'
                            } else if (slug === 'template-compatibility') {
                                filePath = '/docs/TEMPLATE_COMPATIBILITY.md'
                            } else if (slug === 'validation-system') {
                                filePath = '/docs/VALIDATION_SYSTEM.md'
                            } else if (slug === 'next-steps') {
                                filePath = '/docs/NEXT_STEPS_GUIDE.md'
                            }
                            break
                        case 'claude-commands':
                            if (slug === 'architecture-review') {
                                filePath = '/.claude/commands/architecture-review.md'
                            } else if (slug === 'documentation-audit') {
                                filePath = '/.claude/commands/documentation-audit.md'
                            } else if (slug === 'performance-check') {
                                filePath = '/.claude/commands/performance-check.md'
                            } else if (slug === 'quick-fix') {
                                filePath = '/.claude/commands/quick-fix.md'
                            } else if (slug === 'security-scan') {
                                filePath = '/.claude/commands/security-scan.md'
                            }
                            break
                        case 'github-templates':
                            if (slug === 'bug-report') {
                                filePath = '/.github/ISSUE_TEMPLATE/bug_report.md'
                            } else if (slug === 'feature-request') {
                                filePath = '/.github/ISSUE_TEMPLATE/feature_request.md'
                            } else if (slug === 'pull-request') {
                                filePath = '/.github/PULL_REQUEST_TEMPLATE.md'
                            }
                            break
                        case 'examples':
                            if (slug === 'docker') {
                                filePath = '/examples/docker-compose.yml'
                            } else if (slug === 'package') {
                                filePath = '/examples/package.json'
                            } else if (slug === 'typescript') {
                                filePath = '/examples/tsconfig.json'
                            }
                            break
                        case 'scripts':
                            if (slug === 'validation') {
                                // Show a combined view of validation scripts
                                filePath = 'validation-overview'
                            } else if (slug === 'templates') {
                                filePath = '/tools/template-compliance-checker.ts'
                            } else if (slug === 'performance-testing') {
                                filePath = '/scripts/performance-testing-guide.md'
                            }
                            break
                    }
                }

                if (!filePath) {
                    throw new Error('Document not found')
                }

                if (filePath === 'validation-overview') {
                    // Special case for validation overview
                    setContent(`# Validation Scripts Overview

This project includes comprehensive validation scripts to ensure quality and consistency.

## Available Scripts

- **validate-architecture.sh** - Validates system architecture documentation
- **validate-security.sh** - Checks security compliance and best practices  
- **validate-performance.sh** - Verifies performance guidelines and optimization
- **validate-templates.sh** - Ensures template completeness and consistency
- **validate-docs-structure.sh** - Validates documentation structure and links

## Running Validation

\`\`\`bash
# Run all validations
npm run validate

# Run individual validations
./scripts/validate-architecture.sh
./scripts/validate-security.sh
./scripts/validate-performance.sh
./scripts/validate-templates.sh
./scripts/validate-docs-structure.sh
\`\`\`

All scripts are designed to exit with status 0 on success and non-zero on failure, making them suitable for CI/CD pipelines.`)
                } else if (filePath.startsWith('index-')) {
                    // Generate index page for category
                    const categoryName = filePath.replace('index-', '')
                    setContent(generateIndexPage(categoryName))
                } else {
                    const response = await fetch(filePath)
                    if (!response.ok) {
                        throw new Error(`Failed to load document: ${response.statusText}`)
                    }
                    const text = await response.text()

                    // Handle different file types
                    if (filePath.endsWith('.json') || filePath.endsWith('.yml') || filePath.endsWith('.yaml') ||
                        filePath.endsWith('.ts') || filePath.endsWith('.js') || filePath.endsWith('.env') ||
                        filePath.includes('.env.')) {
                        // Extract filename from path for example files
                        const fileName = filePath.split('/').pop() || filePath
                        let language = 'text'

                        if (filePath.endsWith('.json')) {
                            language = 'json'
                        } else if (filePath.endsWith('.yml') || filePath.endsWith('.yaml')) {
                            language = 'yaml'
                        } else if (filePath.endsWith('.ts')) {
                            language = 'typescript'
                        } else if (filePath.endsWith('.js')) {
                            language = 'javascript'
                        } else if (filePath.endsWith('.env') || filePath.includes('.env.')) {
                            language = 'bash'
                        }

                        setContent(`# ${fileName}

\`\`\`${language}
${text}
\`\`\``)
                    } else {
                        setContent(text)
                    }
                }
            } catch (err) {
                setError(err instanceof Error ? err.message : 'Failed to load document')
            } finally {
                setLoading(false)
            }
        }

        loadDocument()
    }, [category, slug])

    if (loading) {
        return <div className="loading">Loading documentation...</div>
    }

    if (error) {
        return <div className="error">Error: {error}</div>
    }

    return (
        <div className="markdown-content">
            <ReactMarkdown
                remarkPlugins={[remarkGfm]}
                rehypePlugins={[rehypeHighlight]}
            >
                {content}
            </ReactMarkdown>
        </div>
    )
}

export default DocumentationPage
