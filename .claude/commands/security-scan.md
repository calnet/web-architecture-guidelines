# Security Scan Command

**Usage**: `/security-scan "Security focus area"`

## Purpose

Conduct comprehensive security vulnerability assessment and compliance validation against established security standards.

## Command Behavior

When triggered, this command instructs Claude to perform a thorough security analysis covering:

### 1. OWASP Top 10 Compliance

- **A01: Broken Access Control**
  - Authentication and authorization mechanisms
  - Role-based access control implementation
  - Session management security
  
- **A02: Cryptographic Failures**
  - Data encryption at rest and in transit
  - Key management practices
  - Cryptographic algorithm selection
  
- **A03: Injection Attacks**
  - SQL injection prevention
  - Cross-site scripting (XSS) protection
  - Command injection vulnerabilities
  
- **A04: Insecure Design**
  - Security-by-design principles
  - Threat modeling implementation
  - Secure development lifecycle

### 2. Security Controls Assessment

- Input validation and sanitization
- Output encoding and escaping
- Security headers configuration
- CORS policy implementation
- Rate limiting and DoS protection

### 3. Authentication & Authorization

- Multi-factor authentication support
- Password policy enforcement
- JWT token security
- OAuth/OIDC implementation
- Privilege escalation prevention

### 4. Data Protection

- Personal data handling (GDPR/CCPA compliance)
- Data classification and labeling
- Secure data storage practices
- Data transmission security
- Backup and recovery security

### 5. Infrastructure Security

- Container security (if applicable)
- Cloud security configuration
- Network security controls
- Monitoring and logging
- Incident response capabilities

## Expected Output Format

```markdown
## Security Assessment Report

### Executive Summary
[High-level security posture assessment]

### Critical Vulnerabilities
| Severity | Issue | Impact | Recommendation |
|----------|-------|--------|----------------|
| High | [Vulnerability] | [Impact] | [Fix] |
| Medium | [Vulnerability] | [Impact] | [Fix] |

### OWASP Top 10 Compliance
- [A01] Broken Access Control: ✅/⚠️/❌
- [A02] Cryptographic Failures: ✅/⚠️/❌
- [A03] Injection: ✅/⚠️/❌
- [Continue for all 10...]

### Security Controls Review
- Authentication: [Assessment]
- Authorization: [Assessment]
- Input Validation: [Assessment]
- Data Protection: [Assessment]

### Recommended Actions
1. **Immediate** (Fix within 24 hours)
   - [Critical security fixes]
   
2. **Short-term** (Fix within 1 week)
   - [Important security improvements]
   
3. **Long-term** (Plan for next sprint)
   - [Security enhancements]

### Code Examples
[Before/after examples showing security improvements]

### Compliance Checklist
- [ ] OWASP compliance verified
- [ ] Security headers configured
- [ ] Input validation implemented
- [ ] Authentication mechanisms secured
```

## Usage Examples

### General Security Review

```
/security-scan "Comprehensive security assessment of the user management system"
```

### Focused Vulnerability Assessment

```
/security-scan "Check the API endpoints for injection vulnerabilities"
```

### Compliance Review

```
/security-scan "OWASP Top 10 compliance validation for the payment module"
```

## Security Standards Reference

This command validates against:

- OWASP Application Security Verification Standard (ASVS)
- NIST Cybersecurity Framework
- ISO 27001 security controls
- CIS Critical Security Controls
- PCI DSS (if applicable)
- SOC 2 Type II requirements

## Integration Points

- Automated security testing tools
- Dependency vulnerability scanning
- Static Application Security Testing (SAST)
- Dynamic Application Security Testing (DAST)
- Infrastructure as Code security scanning

## Success Criteria

- ✅ Identifies security vulnerabilities
- ✅ Provides OWASP compliance assessment
- ✅ Offers specific remediation steps
- ✅ Includes security code examples
- ✅ References industry standards
- ✅ Prioritizes fixes by risk level
