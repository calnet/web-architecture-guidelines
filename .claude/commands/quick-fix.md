# Quick Fix Command

**Usage**: `/quick-fix "Issue description"`

## Purpose

Provide immediate, actionable fixes for common code quality, formatting, and minor functionality issues.

## Command Behavior

When triggered, this command instructs Claude to identify and provide quick fixes for:

### 1. Code Quality Issues

- **Formatting Problems**
  - Inconsistent indentation
  - Missing semicolons or proper syntax
  - Code style violations
  - Import organization
  
- **Simple Logic Issues**
  - Unused variables and imports
  - Basic conditional logic improvements
  - Simple refactoring opportunities
  - Variable naming improvements

### 2. Documentation Fixes

- **Inline Documentation**
  - Missing or incorrect comments
  - JSDoc/docstring improvements
  - README updates
  - Code example corrections
  
- **Quick Content Updates**
  - Typo corrections
  - Link fixes
  - Format standardization
  - Example code updates

### 3. Configuration Issues

- **Build Configuration**
  - Package.json script fixes
  - Basic webpack/build config issues
  - Environment variable corrections
  - Dependency version conflicts
  
- **Linting & Formatting**
  - ESLint rule fixes
  - Prettier configuration
  - TypeScript configuration adjustments
  - Git hooks setup

### 4. Minor Security & Performance

- **Low-Risk Security Fixes**
  - Basic input validation
  - Simple XSS prevention
  - Environment variable usage
  - Dependency updates
  
- **Simple Performance Improvements**
  - Basic optimization opportunities
  - Inefficient loop fixes
  - Simple caching additions
  - Resource loading improvements

## Expected Output Format

```markdown
## Quick Fix Report

### Issues Identified
[Brief summary of fixable issues found]

### Immediate Fixes
1. **[Issue Type]**: [Description]
   ```[language]
   // Before
   [current code]
   
   // After  
   [fixed code]
   ```text

   **Impact**: [Brief explanation of improvement]

1. **[Issue Type]**: [Description]
   [Similar format for each fix]

### File-by-File Changes

#### `filename.ext`

```diff
- [lines to remove]
+ [lines to add]
```text

### Applied Standards

- [List of coding standards applied]
- [List of best practices implemented]

### Verification Steps

1. [Steps to verify fixes work]
2. [Commands to run for testing]
3. [Expected outcomes]

### Additional Recommendations

- [Suggestions for further improvements]
- [Related issues that might need attention]

```text

## Usage Examples

### Code Quality Fix
```text

/quick-fix "Fix formatting and style issues in the user service module"

```text

### Documentation Update
```text

/quick-fix "Update inline documentation and fix typos in README"

```text

### Configuration Correction
```text

/quick-fix "Fix package.json scripts and dependency issues"

```text

### Security Enhancement
```text

/quick-fix "Add basic input validation to API endpoints"

```text

## Fix Categories

### ✅ Suitable for Quick Fix
- Formatting and style issues
- Simple logic improvements
- Documentation updates
- Configuration corrections
- Import/export organization
- Variable naming improvements
- Basic security enhancements
- Simple performance optimizations

### ❌ Not Suitable for Quick Fix
- Major architectural changes
- Complex business logic modifications
- Database schema changes
- API breaking changes
- Security vulnerabilities requiring design changes
- Performance issues requiring profiling
- Complex refactoring operations

## Quality Assurance
Each quick fix includes:
- Clear before/after code examples
- Explanation of the improvement
- Verification steps
- Impact assessment
- Related best practices reference

## Integration with Development Workflow
- Compatible with existing linting tools
- Follows established coding standards
- Maintains backward compatibility
- Includes appropriate testing suggestions
- Documents changes for review

## Success Criteria
- ✅ Provides immediately actionable fixes
- ✅ Includes clear before/after examples
- ✅ Explains the reasoning for each change
- ✅ Offers verification steps
- ✅ Maintains code quality standards
- ✅ Suggests related improvements
