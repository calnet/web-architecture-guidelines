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
            ]
        },
        {
            title: 'Templates',
            path: '/docs/templates',
            items: [
                { title: 'API Specification', path: '/docs/templates/api' },
                { title: 'Architecture ADR', path: '/docs/templates/architecture' },
                { title: 'Coding Standards', path: '/docs/templates/development' },
                { title: 'User Guides', path: '/docs/templates/user-guides' },
                { title: 'Admin Manual', path: '/docs/templates/admin-manual' },
            ]
        },
        {
            title: 'Architecture',
            path: '/docs/architecture',
            items: [
                { title: 'System Architecture', path: '/docs/architecture/system' },
                { title: 'Security Guidelines', path: '/docs/architecture/security' },
                { title: 'Performance Guidelines', path: '/docs/architecture/performance' },
                { title: 'ADR Examples', path: '/docs/architecture/decisions' },
            ]
        },
        {
            title: 'AI Agents',
            path: '/docs/ai-agents',
            items: [
                { title: 'Anthropic API', path: '/docs/ai-agents/anthropic' },
                { title: 'ChatGPT', path: '/docs/ai-agents/chatgpt' },
                { title: 'GitHub Copilot', path: '/docs/ai-agents/copilot' },
                { title: 'Gemini', path: '/docs/ai-agents/gemini' },
                { title: 'Claude', path: '/docs/ai-agents/claude' },
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
