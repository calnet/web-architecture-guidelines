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
            ]
        },
        'templates': {
            title: 'Templates',
            description: 'Ready-to-use templates for documentation, architecture, and development standards.',
            items: [
                { title: 'API Specification', path: '/docs/templates/api', description: 'Template for API documentation and specifications' },
                { title: 'Architecture ADR', path: '/docs/templates/architecture', description: 'Architecture Decision Record template' },
                { title: 'Coding Standards', path: '/docs/templates/development', description: 'Development and coding standards template' },
                { title: 'User Guides', path: '/docs/templates/user-guides', description: 'User manual and guide templates' },
                { title: 'Admin Manual', path: '/docs/templates/admin-manual', description: 'Administrator manual template' },
            ]
        },
        'architecture': {
            title: 'Architecture',
            description: 'System architecture documentation, guidelines, and decision records.',
            items: [
                { title: 'System Architecture', path: '/docs/architecture/system', description: 'Complete system architecture documentation' },
                { title: 'Security Guidelines', path: '/docs/architecture/security', description: 'Security architecture and best practices' },
                { title: 'Performance Guidelines', path: '/docs/architecture/performance', description: 'Performance optimization and monitoring guidelines' },
                { title: 'ADR Examples', path: '/docs/architecture/decisions', description: 'Architecture Decision Record examples' },
            ]
        },
        'ai-agents': {
            title: 'AI Agents',
            description: 'Configuration and instructions for various AI development assistants.',
            items: [
                { title: 'Anthropic API', path: '/docs/ai-agents/anthropic', description: 'Anthropic API integration and usage instructions' },
                { title: 'ChatGPT', path: '/docs/ai-agents/chatgpt', description: 'ChatGPT configuration and architectural guidelines' },
                { title: 'GitHub Copilot', path: '/docs/ai-agents/copilot', description: 'GitHub Copilot setup and best practices' },
                { title: 'Gemini', path: '/docs/ai-agents/gemini', description: 'Google Gemini AI integration guide' },
                { title: 'Claude', path: '/docs/ai-agents/claude', description: 'Claude AI assistant configuration and instructions' },
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
                            }
                            break
                        case 'templates':
                            if (slug === 'api') {
                                filePath = '/docs/templates/api/api-specification.md'
                            } else if (slug === 'architecture') {
                                filePath = '/docs/templates/architecture/adr-template.md'
                            } else if (slug === 'development') {
                                filePath = '/docs/templates/development/coding-standards-template.md'
                            } else if (slug === 'user-guides') {
                                filePath = '/docs/templates/user-guides/user-manual-template.md'
                            } else if (slug === 'admin-manual') {
                                filePath = '/docs/templates/user-guides/admin-manual-template.md'
                            }
                            break
                        case 'architecture':
                            if (slug === 'system') {
                                filePath = '/docs/architecture/system-architecture.md'
                            } else if (slug === 'security') {
                                filePath = '/docs/security.md'
                            } else if (slug === 'performance') {
                                filePath = '/docs/performance.md'
                            } else if (slug === 'decisions') {
                                filePath = '/docs/architecture/decisions/adr-001-technology-stack.md'
                            }
                            break
                        case 'ai-agents':
                            if (slug === 'anthropic') {
                                filePath = '/docs/ai-agents/anthropic-api-architecture-instructions.md'
                            } else if (slug === 'chatgpt') {
                                filePath = '/docs/ai-agents/chatgpt-architecture-instructions.md'
                            } else if (slug === 'copilot') {
                                filePath = '/docs/ai-agents/copilot-architecture-instructions.md'
                            } else if (slug === 'gemini') {
                                filePath = '/docs/ai-agents/gemini-architecture-instructions.md'
                            } else if (slug === 'claude') {
                                filePath = '/docs/ai-agents/claude/claude-architecture-instructions-v2.md'
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
