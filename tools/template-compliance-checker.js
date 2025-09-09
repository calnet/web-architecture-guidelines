"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.TemplateComplianceChecker = void 0;
exports.generateComplianceReport = generateComplianceReport;
const promises_1 = require("fs/promises");
const path_1 = require("path");
// Template definitions with required sections
const TEMPLATE_DEFINITIONS = {
    'adr-template.md': {
        name: 'Architecture Decision Record',
        version: '1.0',
        requiredSections: ['Status', 'Context', 'Decision', 'Consequences'],
        optionalSections: ['Date', 'Deciders', 'Technical Story', 'Considered Options']
    },
    'system-architecture-document.md': {
        name: 'System Architecture Document',
        version: '1.0',
        requiredSections: ['Overview', 'Architecture', 'Components', 'Security', 'Performance'],
        optionalSections: ['Glossary', 'References', 'Appendix']
    },
    'api-specification.md': {
        name: 'API Specification',
        version: '1.0',
        requiredSections: ['Authentication', 'Endpoints', 'Error Handling', 'Rate Limiting'],
        optionalSections: ['Versioning', 'Webhooks', 'SDKs', 'Examples']
    },
    'user-manual-template.md': {
        name: 'User Manual',
        version: '1.0',
        requiredSections: ['Getting Started', 'Features', 'Troubleshooting'],
        optionalSections: ['FAQ', 'Glossary', 'Contact Support']
    },
    'admin-manual-template.md': {
        name: 'Admin Manual',
        version: '1.0',
        requiredSections: ['Administration', 'Configuration', 'Monitoring'],
        optionalSections: ['Backup', 'Security', 'Performance Tuning']
    },
    'setup-guide-template.md': {
        name: 'Setup Guide',
        version: '1.0',
        requiredSections: ['Prerequisites', 'Installation', 'Configuration', 'Verification'],
        optionalSections: ['Troubleshooting', 'Next Steps', 'Additional Resources']
    },
    'coding-standards-template.md': {
        name: 'Coding Standards',
        version: '1.0',
        requiredSections: ['Code Style', 'Best Practices', 'Testing'],
        optionalSections: ['Documentation', 'Performance', 'Security']
    }
};
class TemplateComplianceChecker {
    constructor(projectPath) {
        this.projectPath = projectPath;
    }
    async scanProjectTemplates() {
        const templatePaths = [];
        const templateDirs = [
            'docs/templates',
            'docs/architecture',
            'docs/api',
            'docs/user-guides',
            'docs/development'
        ];
        for (const dir of templateDirs) {
            const fullPath = (0, path_1.join)(this.projectPath, dir);
            try {
                const files = await this.scanDirectory(fullPath);
                templatePaths.push(...files.filter(f => f.endsWith('.md')));
            }
            catch (error) {
                // Directory might not exist, skip
                continue;
            }
        }
        return templatePaths;
    }
    async scanDirectory(dirPath) {
        const files = [];
        try {
            const entries = await (0, promises_1.readdir)(dirPath);
            for (const entry of entries) {
                const fullPath = (0, path_1.join)(dirPath, entry);
                const stats = await (0, promises_1.stat)(fullPath);
                if (stats.isDirectory()) {
                    const subFiles = await this.scanDirectory(fullPath);
                    files.push(...subFiles);
                }
                else if (stats.isFile() && entry.endsWith('.md')) {
                    files.push(fullPath);
                }
            }
        }
        catch (error) {
            // Handle access errors gracefully
        }
        return files;
    }
    async analyzeTemplate(templatePath) {
        const content = await (0, promises_1.readFile)(templatePath, 'utf-8');
        const fileName = templatePath.split('/').pop() || '';
        const templateDef = this.findTemplateDefinition(fileName);
        if (!templateDef) {
            return {
                templateName: fileName,
                baseVersion: 'unknown',
                projectVersion: 'unknown',
                complianceScore: 0,
                missingRequiredSections: [],
                customizations: [],
                filePath: (0, path_1.relative)(this.projectPath, templatePath)
            };
        }
        const { missingRequiredSections, customizations } = this.analyzeContent(content, templateDef);
        const complianceScore = this.calculateComplianceScore(templateDef, missingRequiredSections);
        return {
            templateName: templateDef.name,
            baseVersion: templateDef.version,
            projectVersion: this.extractProjectVersion(content) || templateDef.version,
            complianceScore,
            missingRequiredSections,
            customizations,
            filePath: (0, path_1.relative)(this.projectPath, templatePath)
        };
    }
    findTemplateDefinition(fileName) {
        // Try exact match first
        if (TEMPLATE_DEFINITIONS[fileName]) {
            return TEMPLATE_DEFINITIONS[fileName];
        }
        // Try partial matches
        for (const [defName, definition] of Object.entries(TEMPLATE_DEFINITIONS)) {
            if (fileName.includes(defName.replace('-template.md', '')) ||
                defName.includes(fileName.replace('.md', ''))) {
                return definition;
            }
        }
        return null;
    }
    analyzeContent(content, templateDef) {
        const lines = content.split('\n');
        const headers = lines.filter(line => line.startsWith('#')).map(line => line.replace(/^#+\s*/, '').trim());
        const missingRequiredSections = templateDef.requiredSections.filter(section => !headers.some(header => header.toLowerCase().includes(section.toLowerCase())));
        const customizations = headers.filter(header => !templateDef.requiredSections.some(section => header.toLowerCase().includes(section.toLowerCase())) &&
            !templateDef.optionalSections.some(section => header.toLowerCase().includes(section.toLowerCase())));
        return { missingRequiredSections, customizations };
    }
    calculateComplianceScore(templateDef, missingRequiredSections) {
        const totalRequired = templateDef.requiredSections.length;
        const foundRequired = totalRequired - missingRequiredSections.length;
        return totalRequired > 0 ? foundRequired / totalRequired : 1;
    }
    extractProjectVersion(content) {
        const versionMatch = content.match(/version:\s*([^\s\n]+)/i) ||
            content.match(/v(\d+\.\d+(?:\.\d+)?)/i);
        return versionMatch ? versionMatch[1] : null;
    }
    generateRecommendations(compliance) {
        const recommendations = [];
        const lowComplianceTemplates = compliance.filter(t => t.complianceScore < 0.8);
        if (lowComplianceTemplates.length > 0) {
            recommendations.push(`Consider updating ${lowComplianceTemplates.length} templates with compliance scores below 80%`);
        }
        const templatesWithMissingSections = compliance.filter(t => t.missingRequiredSections.length > 0);
        if (templatesWithMissingSections.length > 0) {
            recommendations.push(`Add missing required sections to ${templatesWithMissingSections.length} templates`);
        }
        const outdatedTemplates = compliance.filter(t => t.baseVersion !== t.projectVersion);
        if (outdatedTemplates.length > 0) {
            recommendations.push(`Consider updating ${outdatedTemplates.length} templates to latest base versions`);
        }
        if (recommendations.length === 0) {
            recommendations.push('All templates meet compliance standards! 🎉');
        }
        return recommendations;
    }
    async validateTemplateCompliance() {
        const templatePaths = await this.scanProjectTemplates();
        const templates = [];
        for (const templatePath of templatePaths) {
            try {
                const compliance = await this.analyzeTemplate(templatePath);
                templates.push(compliance);
            }
            catch (error) {
                console.warn(`Failed to analyze template: ${templatePath}`, error);
            }
        }
        const overallScore = templates.length > 0
            ? templates.reduce((sum, t) => sum + t.complianceScore, 0) / templates.length
            : 0;
        const overall = overallScore >= 0.8 && templates.every(t => t.missingRequiredSections.length === 0);
        return {
            overall,
            overallScore,
            templates,
            recommendations: this.generateRecommendations(templates),
            generatedAt: new Date().toISOString()
        };
    }
}
exports.TemplateComplianceChecker = TemplateComplianceChecker;
// CLI Usage
async function generateComplianceReport(projectPath) {
    const checker = new TemplateComplianceChecker(projectPath);
    const report = await checker.validateTemplateCompliance();
    // Generate HTML report
    const htmlReport = generateHTMLReport(report);
    // Save reports
    const { writeFile, mkdir } = await Promise.resolve().then(() => require('fs/promises'));
    await mkdir((0, path_1.join)(projectPath, 'reports'), { recursive: true });
    await writeFile((0, path_1.join)(projectPath, 'reports', 'compliance-report.json'), JSON.stringify(report, null, 2));
    await writeFile((0, path_1.join)(projectPath, 'reports', 'compliance-report.html'), htmlReport);
    // Console output
    console.log('📊 Template Compliance Report');
    console.log('============================');
    console.log(`Overall Score: ${(report.overallScore * 100).toFixed(1)}%`);
    console.log(`Status: ${report.overall ? '✅ PASSED' : '❌ NEEDS ATTENTION'}`);
    console.log(`Templates Analyzed: ${report.templates.length}`);
    console.log('');
    if (report.recommendations.length > 0) {
        console.log('📋 Recommendations:');
        report.recommendations.forEach(rec => console.log(`  • ${rec}`));
    }
}
function generateHTMLReport(report) {
    return `
<!DOCTYPE html>
<html>
<head>
    <title>Template Compliance Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .header { border-bottom: 2px solid #eee; padding-bottom: 20px; }
        .score { font-size: 24px; font-weight: bold; color: ${report.overall ? '#28a745' : '#dc3545'}; }
        .template { border: 1px solid #ddd; margin: 10px 0; padding: 15px; border-radius: 5px; }
        .compliance-high { border-left: 4px solid #28a745; }
        .compliance-medium { border-left: 4px solid #ffc107; }
        .compliance-low { border-left: 4px solid #dc3545; }
        .missing-sections { color: #dc3545; }
        .customizations { color: #6c757d; }
        .recommendations { background-color: #f8f9fa; padding: 15px; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Template Compliance Report</h1>
        <p>Generated: ${new Date(report.generatedAt).toLocaleString()}</p>
        <div class="score">Overall Score: ${(report.overallScore * 100).toFixed(1)}%</div>
        <p>Status: ${report.overall ? '✅ PASSED' : '❌ NEEDS ATTENTION'}</p>
    </div>
    
    <h2>Templates (${report.templates.length})</h2>
    ${report.templates.map(template => {
        const complianceClass = template.complianceScore >= 0.8 ? 'compliance-high' :
            template.complianceScore >= 0.6 ? 'compliance-medium' : 'compliance-low';
        return `
        <div class="template ${complianceClass}">
            <h3>${template.templateName}</h3>
            <p><strong>File:</strong> ${template.filePath}</p>
            <p><strong>Compliance Score:</strong> ${(template.complianceScore * 100).toFixed(1)}%</p>
            <p><strong>Version:</strong> ${template.projectVersion} (Base: ${template.baseVersion})</p>
            
            ${template.missingRequiredSections.length > 0 ? `
                <div class="missing-sections">
                    <strong>Missing Required Sections:</strong>
                    <ul>${template.missingRequiredSections.map(s => `<li>${s}</li>`).join('')}</ul>
                </div>
            ` : ''}
            
            ${template.customizations.length > 0 ? `
                <div class="customizations">
                    <strong>Customizations:</strong>
                    <ul>${template.customizations.map(s => `<li>${s}</li>`).join('')}</ul>
                </div>
            ` : ''}
        </div>
      `;
    }).join('')}
    
    <div class="recommendations">
        <h2>Recommendations</h2>
        <ul>
            ${report.recommendations.map(rec => `<li>${rec}</li>`).join('')}
        </ul>
    </div>
</body>
</html>
  `.trim();
}
// CLI entry point
if (require.main === module) {
    const projectPath = process.argv[2] || process.cwd();
    generateComplianceReport(projectPath).catch(console.error);
}
