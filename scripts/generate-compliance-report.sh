#!/bin/bash

echo "📊 Generating template compliance report..."

# Check if TypeScript is available
if command -v npx &> /dev/null && npx tsc --version &> /dev/null; then
    echo "Using TypeScript compiler..."
    
    # Compile and run TypeScript version
    npx tsc tools/template-compliance-checker.ts --target es2020 --module commonjs --outDir tools/dist --moduleResolution node
    node tools/dist/template-compliance-checker.js "$(pwd)"
    
elif command -v node &> /dev/null; then
    echo "TypeScript not available, using Node.js fallback..."
    
    # Simple Node.js version for basic validation
    node -e "
    const fs = require('fs');
    const path = require('path');
    
    console.log('📊 Basic Template Compliance Check');
    console.log('================================');
    
    const templateDirs = ['docs/templates', 'docs/architecture', 'docs/api', 'docs/user-guides', 'docs/development'];
    let totalTemplates = 0;
    let validTemplates = 0;
    
    templateDirs.forEach(dir => {
        if (fs.existsSync(dir)) {
            const files = fs.readdirSync(dir).filter(f => f.endsWith('.md'));
            files.forEach(file => {
                totalTemplates++;
                const content = fs.readFileSync(path.join(dir, file), 'utf-8');
                const hasTitle = content.match(/^#/m);
                const hasContent = content.length > 100;
                
                if (hasTitle && hasContent) {
                    validTemplates++;
                    console.log(\`✅ \${file}\`);
                } else {
                    console.log(\`❌ \${file} - Missing title or insufficient content\`);
                }
            });
        }
    });
    
    const score = totalTemplates > 0 ? (validTemplates / totalTemplates * 100).toFixed(1) : '0';
    console.log(\`\nOverall Score: \${score}% (\${validTemplates}/\${totalTemplates})\`);
    
    // Create basic HTML report
    const htmlReport = \`
<!DOCTYPE html>
<html>
<head><title>Basic Template Compliance Report</title></head>
<body>
    <h1>Template Compliance Report</h1>
    <p>Generated: \${new Date().toLocaleString()}</p>
    <p>Overall Score: \${score}%</p>
    <p>Valid Templates: \${validTemplates}/\${totalTemplates}</p>
</body>
</html>\`;
    
    if (!fs.existsSync('reports')) fs.mkdirSync('reports');
    fs.writeFileSync('reports/compliance-report.html', htmlReport);
    console.log('📄 Report saved to reports/compliance-report.html');
    "
    
else
    echo "❌ Neither TypeScript nor Node.js available"
    echo "Creating basic shell-based report..."
    
    # Shell-based basic validation
    mkdir -p reports
    
    echo "# Template Compliance Report" > reports/compliance-report.md
    echo "Generated: $(date)" >> reports/compliance-report.md
    echo "" >> reports/compliance-report.md
    
    total=0
    valid=0
    
    for dir in docs/templates docs/architecture docs/api docs/user-guides docs/development; do
        if [ -d "$dir" ]; then
            for file in "$dir"/*.md; do
                if [ -f "$file" ]; then
                    total=$((total + 1))
                    if [ -s "$file" ] && head -n 1 "$file" | grep -q "^#"; then
                        valid=$((valid + 1))
                        echo "✅ $file" >> reports/compliance-report.md
                    else
                        echo "❌ $file - Missing title or empty" >> reports/compliance-report.md
                    fi
                fi
            done
        fi
    done
    
    if [ $total -gt 0 ]; then
        score=$((valid * 100 / total))
    else
        score=0
    fi
    
    echo "" >> reports/compliance-report.md
    echo "Overall Score: ${score}% (${valid}/${total})" >> reports/compliance-report.md
    
    echo "📄 Basic report saved to reports/compliance-report.md"
    echo "Overall Score: ${score}% (${valid}/${total})"
fi

echo "🎉 Compliance report generation completed!"