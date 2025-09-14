import { Link } from 'react-router-dom'

function HomePage() {
    return (
        <div className="markdown-content">
            <h1>Web Architecture Guidelines</h1>

            <p>
                Welcome to the comprehensive web architecture guidelines repository. This documentation
                provides templates, best practices, and tools for building scalable, maintainable web applications.
            </p>

            <h2>Quick Navigation</h2>

            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '1.5rem', margin: '2rem 0' }}>
                <div style={{ background: '#f8fafc', padding: '1.5rem', borderRadius: '8px', border: '1px solid #e2e8f0' }}>
                    <h3>📋 Templates</h3>
                    <p>Ready-to-use templates for documentation, architecture decisions, and development standards.</p>
                    <Link to="/docs/templates" style={{ color: '#3b82f6', textDecoration: 'none', fontWeight: '500' }}>
                        Explore Templates →
                    </Link>
                </div>

                <div style={{ background: '#f8fafc', padding: '1.5rem', borderRadius: '8px', border: '1px solid #e2e8f0' }}>
                    <h3>🏗️ Architecture</h3>
                    <p>System architecture patterns, security guidelines, and performance best practices.</p>
                    <Link to="/docs/architecture" style={{ color: '#3b82f6', textDecoration: 'none', fontWeight: '500' }}>
                        View Architecture →
                    </Link>
                </div>

                <div style={{ background: '#f8fafc', padding: '1.5rem', borderRadius: '8px', border: '1px solid #e2e8f0' }}>
                    <h3>🤖 AI Agents</h3>
                    <p>Instructions and configurations for various AI coding assistants and agents.</p>
                    <Link to="/docs/ai-agents" style={{ color: '#3b82f6', textDecoration: 'none', fontWeight: '500' }}>
                        AI Agent Guides →
                    </Link>
                </div>

                <div style={{ background: '#f8fafc', padding: '1.5rem', borderRadius: '8px', border: '1px solid #e2e8f0' }}>
                    <h3>💻 Examples</h3>
                    <p>Sample configurations for Docker, TypeScript, package management, and more.</p>
                    <Link to="/docs/examples" style={{ color: '#3b82f6', textDecoration: 'none', fontWeight: '500' }}>
                        Browse Examples →
                    </Link>
                </div>
            </div>

            <h2>Features</h2>

            <ul>
                <li><strong>Comprehensive Templates</strong> - ADR templates, API specifications, coding standards</li>
                <li><strong>Architecture Guidance</strong> - Clean architecture principles, security patterns</li>
                <li><strong>AI Integration</strong> - Instructions for popular AI coding assistants</li>
                <li><strong>Validation Tools</strong> - Automated scripts to ensure compliance and quality</li>
                <li><strong>Example Configurations</strong> - Ready-to-use configuration files</li>
            </ul>

            <h2>Getting Started</h2>

            <p>
                Start by exploring the <Link to="/docs/templates">templates section</Link> to understand
                the available documentation patterns, then review the <Link to="/docs/architecture">
                    architecture guidelines</Link> for implementation best practices.
            </p>

            <blockquote>
                <p>
                    This documentation is designed to be living guidelines that evolve with your project needs.
                    All templates and examples are meant to be customized for your specific requirements.
                </p>
            </blockquote>

            <h2>Recent Updates</h2>

            <ul>
                <li>✅ Enhanced system architecture documentation with Clean Architecture patterns</li>
                <li>✅ Added comprehensive security and performance guidelines</li>
                <li>✅ Created TypeScript template compliance checker</li>
                <li>✅ Improved validation scripts for automated quality assurance</li>
                <li>✅ Added production-ready environment configuration examples</li>
            </ul>
        </div>
    )
}

export default HomePage
