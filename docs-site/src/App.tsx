import { Routes, Route } from 'react-router-dom'
import Navigation from './components/Navigation'
import Sidebar from './components/Sidebar'
import DocumentationPage from './components/DocumentationPage'
import HomePage from './components/HomePage'

function App() {
    return (
        <div className="app">
            <Navigation />
            <main className="main-container">
                <Sidebar />
                <div className="content">
                    <Routes>
                        <Route path="/" element={<HomePage />} />
                        <Route path="/docs/:category/:slug?" element={<DocumentationPage />} />
                    </Routes>
                </div>
            </main>
        </div>
    )
}

export default App
