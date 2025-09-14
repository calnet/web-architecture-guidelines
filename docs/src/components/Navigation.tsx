import { Link, useLocation } from 'react-router-dom'

function Navigation() {
    const location = useLocation()

    const navItems = [
        { path: '/', label: 'Home' },
        { path: '/docs/templates', label: 'Templates' },
        { path: '/docs/architecture', label: 'Architecture' },
        { path: '/docs/ai-agents', label: 'AI Agents' },
        { path: '/docs/examples', label: 'Examples' },
    ]

    return (
        <nav className="nav-container">
            <div className="nav-content">
                <Link to="/" className="logo">
                    Web Architecture Guidelines
                </Link>
                <div className="nav-links">
                    {navItems.map((item) => (
                        <Link
                            key={item.path}
                            to={item.path}
                            className={location.pathname === item.path ? 'active' : ''}
                        >
                            {item.label}
                        </Link>
                    ))}
                </div>
            </div>
        </nav>
    )
}

export default Navigation
