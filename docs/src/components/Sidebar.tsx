import { Link, useLocation } from 'react-router-dom'

interface SidebarItem {
    title: string
    path: string
    items?: { title: string; path: string }[]
}

function Sidebar() {
    const location = useLocation()

    const sidebarData: SidebarItem[] = [
        {
            title: 'Getting Started',
            path: '/docs/getting-started',
            items: [
                { title: 'README', path: '/docs/getting-started/readme' },
                { title: 'Git Commands', path: '/docs/getting-started/git-commands' },
                { title: 'Claude Guide', path: '/docs/getting-started/claude-guide' },
                { title: 'Integration Script', path: '/docs/getting-started/integration-automation' },
                { title: 'Integration Guide', path: '/docs/getting-started/project-integration' },
                { title: 'External Links', path: '/docs/getting-started/external-links' },
                { title: 'Implementation Guide', path: '/docs/getting-started/implementation-guide' },
                { title: 'Docs Directory', path: '/docs/getting-started/docs-readme' },
            ]
        },
        {
            title: 'Templates',
            path: '/docs/templates',
            items: [
                { title: 'API Specification', path: '/docs/templates/api' },
                { title: 'Architecture ADR', path: '/docs/templates/architecture' },
                { title: 'System Architecture Doc', path: '/docs/templates/system-architecture' },
                { title: 'Coding Standards', path: '/docs/templates/development' },
                { title: 'Setup Guide', path: '/docs/templates/setup-guide' },
                { title: 'User Guides', path: '/docs/templates/user-guides' },
                { title: 'Admin Manual', path: '/docs/templates/admin-manual' },
                { title: 'Template Overview', path: '/docs/templates/overview' },
            ]
        },
        {
            title: 'Architecture',
            path: '/docs/architecture',
            items: [
                { title: 'System Architecture', path: '/docs/architecture/system' },
                { title: 'Security Guidelines', path: '/docs/architecture/security' },
                { title: 'Performance Guidelines', path: '/docs/architecture/performance' },
                { title: 'Technology Stack ADR', path: '/docs/architecture/adr-001' },
                { title: 'Database Patterns ADR', path: '/docs/architecture/adr-002' },
                { title: 'Authentication ADR', path: '/docs/architecture/adr-003' },
            ]
        },
        {
            title: 'AI Agents',
            path: '/docs/ai-agents',
            items: [
                { title: 'Integration Guide', path: '/docs/ai-agents/integration-guide' },
                { title: 'Anthropic API', path: '/docs/ai-agents/anthropic' },
                { title: 'ChatGPT', path: '/docs/ai-agents/chatgpt' },
                { title: 'GitHub Copilot', path: '/docs/ai-agents/copilot' },
                { title: 'Gemini', path: '/docs/ai-agents/gemini' },
                { title: 'Claude', path: '/docs/ai-agents/claude' },
            ]
        },
        {
            title: 'Project Management',
            path: '/docs/project-management',
            items: [
                { title: 'Changelog', path: '/docs/project-management/changelog' },
                { title: 'Quality Gate Report', path: '/docs/project-management/quality-gate' },
                { title: 'Error Check Report', path: '/docs/project-management/error-check' },
                { title: 'Workflow Guide', path: '/docs/project-management/workflow-readme' },
                { title: 'Conflict Analysis', path: '/docs/project-management/conflict-analysis' },
                { title: 'Merge Summary', path: '/docs/project-management/merge-summary' },
            ]
        },
        {
            title: 'Configuration',
            path: '/docs/configuration',
            items: [
                { title: 'GitHub Actions Setup', path: '/docs/configuration/github-actions' },
                { title: 'Quality Gate Setup', path: '/docs/configuration/quality-gate' },
                { title: 'Version Management', path: '/docs/configuration/version-management' },
                { title: 'Enhanced Version System', path: '/docs/configuration/enhanced-version' },
                { title: 'Template Compatibility', path: '/docs/configuration/template-compatibility' },
                { title: 'Validation System', path: '/docs/configuration/validation-system' },
                { title: 'Next Steps Guide', path: '/docs/configuration/next-steps' },
            ]
        },
        {
            title: 'Claude Commands',
            path: '/docs/claude-commands',
            items: [
                { title: 'Architecture Review', path: '/docs/claude-commands/architecture-review' },
                { title: 'Documentation Audit', path: '/docs/claude-commands/documentation-audit' },
                { title: 'Performance Check', path: '/docs/claude-commands/performance-check' },
                { title: 'Quick Fix', path: '/docs/claude-commands/quick-fix' },
                { title: 'Security Scan', path: '/docs/claude-commands/security-scan' },
            ]
        },
        {
            title: 'GitHub Templates',
            path: '/docs/github-templates',
            items: [
                { title: 'Bug Report', path: '/docs/github-templates/bug-report' },
                { title: 'Feature Request', path: '/docs/github-templates/feature-request' },
                { title: 'Pull Request', path: '/docs/github-templates/pull-request' },
            ]
        },
        {
            title: 'Examples',
            path: '/docs/examples',
            items: [
                { title: 'Docker Compose', path: '/docs/examples/docker' },
                { title: 'Package.json', path: '/docs/examples/package' },
                { title: 'TypeScript Config', path: '/docs/examples/typescript' },
            ]
        },
        {
            title: 'Scripts & Tools',
            path: '/docs/scripts',
            items: [
                { title: 'Validation Scripts', path: '/docs/scripts/validation' },
                { title: 'Template Tools', path: '/docs/scripts/templates' },
                { title: 'Performance Testing', path: '/docs/scripts/performance-testing' },
            ]
        }
    ]

    return (
        <aside className="sidebar">
            {sidebarData.map((section) => (
                <div key={section.title}>
                    <h3>{section.title}</h3>
                    <ul>
                        {section.items?.map((item) => (
                            <li key={item.path}>
                                <Link
                                    to={item.path}
                                    className={location.pathname === item.path ? 'active' : ''}
                                >
                                    {item.title}
                                </Link>
                            </li>
                        ))}
                    </ul>
                </div>
            ))}
        </aside>
    )
}

export default Sidebar
