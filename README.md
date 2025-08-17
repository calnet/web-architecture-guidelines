# Documentation Templates

[Previous content through React/JSX Standards continues...]

### React/JSX Standards

#### Component Structure
```tsx
// Component file structure
import React, { useState, useEffect, useCallback } from 'react';
import { SomeExternalLibrary } from 'external-library';
import { InternalComponent } from '../components';
import { useCustomHook } from '../hooks';
import type { ComponentProps } from './types';
import styles from './Component.module.css';

interface Props {
  title: string;
  onSubmit: (data: FormData) => void;
  disabled?: boolean;
}

export const Component: React.FC<Props> = ({ 
  title, 
  onSubmit, 
  disabled = false 
}) => {
  // State hooks first
  const [isLoading, setIsLoading] = useState(false);
  
  // Custom hooks
  const { data, error } = useCustomHook();
  
  // Callbacks and event handlers
  const handleSubmit = useCallback((formData: FormData) => {
    setIsLoading(true);
    onSubmit(formData);
  }, [onSubmit]);
  
  // Effects last
  useEffect(() => {
    // Effect logic
  }, [dependency]);
  
  // Early returns for loading/error states
  if (error) {
    return <ErrorComponent error={error} />;
  }
  
  return (
    <div className={styles.container}>
      <h1>{title}</h1>
      {/* Component JSX */}
    </div>
  );
};

// Default export at bottom
export default Component;
```

#### JSX Guidelines
```tsx
// Self-closing tags for components without children
<Input type="text" placeholder="Enter name" />

// Proper prop formatting
<Component
  longPropertyName="value"
  anotherProperty={complexValue}
  onEvent={handleEvent}
/>

// Conditional rendering
{isVisible && <Component />}
{condition ? <ComponentA /> : <ComponentB />}

// List rendering with keys
{items.map(item => (
  <ListItem 
    key={item.id} 
    data={item} 
    onClick={handleClick}
  />
))}
```

## Code Organization

### File Structure
```
src/
├── components/           # Reusable UI components
│   ├── common/          # Shared components
│   └── features/        # Feature-specific components
├── hooks/               # Custom React hooks
├── services/            # API and business logic
├── utils/               # Pure utility functions
├── types/               # TypeScript type definitions
├── constants/           # Application constants
├── styles/              # Global styles and themes
└── tests/               # Test utilities and fixtures
```

### Import Organization
```typescript
// 1. Node modules
import React from 'react';
import { Router } from 'express';
import axios from 'axios';

// 2. Internal modules (absolute imports)
import { config } from '@/config';
import { logger } from '@/utils/logger';
import { UserService } from '@/services';

// 3. Relative imports
import { Header } from './Header';
import { validateInput } from '../utils';
import type { ComponentProps } from './types';
```

## Documentation Standards

### Function Documentation
```typescript
/**
 * Calculates the total price including tax and discounts
 * 
 * @param basePrice - The base price before tax and discounts
 * @param taxRate - Tax rate as a decimal (e.g., 0.08 for 8%)
 * @param discountPercent - Discount percentage (0-100)
 * @returns The final price after tax and discounts
 * 
 * @example
 * ```typescript
 * const finalPrice = calculateTotalPrice(100, 0.08, 10);
 * console.log(finalPrice); // 97.2
 * ```
 */
function calculateTotalPrice(
  basePrice: number,
  taxRate: number,
  discountPercent: number
): number {
  const discountAmount = basePrice * (discountPercent / 100);
  const discountedPrice = basePrice - discountAmount;
  return discountedPrice * (1 + taxRate);
}
```

### Code Comments
```typescript
// Good: Explain why, not what
// Cache user data to avoid repeated API calls during session
const userCache = new Map<string, User>();

// Good: Complex business logic explanation
// Calculate compound interest using A = P(1 + r/n)^(nt)
// where P = principal, r = annual rate, n = compounding frequency, t = time
const compoundInterest = principal * Math.pow(1 + rate / frequency, frequency * time);

// Avoid: Obvious comments
// Bad: Increment counter by 1
counter++;
```

## Testing Standards

### Test Structure
```typescript
describe('UserService', () => {
  describe('createUser', () => {
    it('should create user with valid data', async () => {
      // Arrange
      const userData = {
        email: 'test@example.com',
        name: 'Test User'
      };
      const mockUser = { id: '1', ...userData };
      jest.spyOn(userRepository, 'save').mockResolvedValue(mockUser);
      
      // Act
      const result = await userService.createUser(userData);
      
      // Assert
      expect(result).toEqual(mockUser);
      expect(userRepository.save).toHaveBeenCalledWith(userData);
    });
    
    it('should throw error for invalid email', async () => {
      // Arrange
      const invalidUserData = {
        email: 'invalid-email',
        name: 'Test User'
      };
      
      // Act & Assert
      await expect(userService.createUser(invalidUserData))
        .rejects
        .toThrow('Invalid email format');
    });
  });
});
```

### Test Naming
```typescript
// Pattern: should [expected behavior] when [conditions]
it('should return user data when valid ID is provided', () => {});
it('should throw NotFoundError when user does not exist', () => {});
it('should cache result when called multiple times', () => {});

// Integration tests
it('should create user and send welcome email', () => {});
it('should handle database connection failure gracefully', () => {});
```

## Performance Guidelines

### General Performance
```typescript
// Use memoization for expensive calculations
const memoizedCalculation = useMemo(() => {
  return expensiveCalculation(data);
}, [data]);

// Debounce user input
const debouncedSearch = useCallback(
  debounce((query: string) => {
    performSearch(query);
  }, 300),
  []
);

// Prefer iteration methods over loops for readability
const userNames = users
  .filter(user => user.isActive)
  .map(user => user.name)
  .sort();
```

### Database Performance
```typescript
// Use proper indexing hints in queries
const users = await userRepository.find({
  where: { email: userEmail }, // Ensure email column is indexed
  select: ['id', 'name', 'email'], // Only select needed columns
});

// Batch operations instead of loops
const userIds = ['1', '2', '3'];
const users = await userRepository.findByIds(userIds); // Not: multiple findById calls
```

## Security Guidelines

### Input Validation
```typescript
import Joi from 'joi';

const userSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().min(8).required(),
  name: Joi.string().min(2).max(50).required()
});

function validateUserInput(input: unknown): User {
  const { error, value } = userSchema.validate(input);
  if (error) {
    throw new ValidationError(error.details[0].message);
  }
  return value;
}
```

### Secure Coding Practices
```typescript
// Never log sensitive information
logger.info('User login successful', { 
  userId: user.id,
  // Don't log: password, tokens, personal data
});

// Use parameterized queries
const user = await db.query(
  'SELECT * FROM users WHERE email = $1',
  [email] // Parameterized value, not string concatenation
);

// Sanitize HTML content
import DOMPurify from 'dompurify';
const sanitizedContent = DOMPurify.sanitize(userInput);
```

## Quality Checklist

Before submitting code, ensure:
- [ ] Code follows naming conventions
- [ ] Functions have single responsibility
- [ ] Error handling is implemented
- [ ] Code is properly documented
- [ ] Tests are written and passing
- [ ] No console.log statements in production code
- [ ] Security best practices followed
- [ ] Performance considerations addressed
- [ ] Code is properly formatted
- [ ] No unused imports or variables

---
*Last updated: [Date] | Version: [Version number]*
```

## 5. Final Repository Files

Now I'll save the final repository configuration files:

<function_calls>
<invoke name="Filesystem:write_file">
<parameter name="content"># Web Application Architecture Guidelines

Comprehensive guidelines for building well-architected, secure, scalable, and maintainable web applications.

## Overview

This repository contains architecture guidelines and instructions optimized for AI agents and development teams to build high-quality web applications following industry best practices.

## Structure

```
docs/
├── ai-agents/                          # AI agent-specific instructions
│   ├── claude/                         # Claude-specific instructions
│   │   ├── claude-architecture-instructions-v1.md
│   │   └── claude-architecture-instructions-v2.md
│   ├── chatgpt-architecture-instructions.md
│   ├── copilot-architecture-instructions.md
│   ├── gemini-architecture-instructions.md
│   └── anthropic-api-architecture-instructions.md
├── external-documentation-links.md     # Curated external resources
├── project-integration-guide.md        # How to extend these guidelines
└── templates/                          # Documentation templates
    ├── architecture/                   # Architecture documentation
    ├── api/                           # API documentation
    ├── user-guides/                   # User documentation
    └── development/                   # Development documentation
```

## Quick Start

### For AI Agents
1. Choose the appropriate instruction file for your AI agent
2. Use it as a system prompt or reference guide
3. Adapt recommendations based on project context

### For Development Teams
1. Review the [Project Integration Guide](docs/project-integration-guide.md)
2. Use [documentation templates](docs/templates/) for your project
3. Reference [external documentation](docs/external-documentation-links.md) as needed

### For Project-Specific Implementation
1. Fork or reference this repository
2. Follow the integration guide to extend guidelines for your project
3. Maintain separation between base and project-specific guidelines

## AI Agent Instructions

### [Claude](docs/ai-agents/claude/)
- **V1**: Foundational architecture guidance
- **V2**: Enhanced with advanced patterns, performance optimization, and modern practices

### [ChatGPT](docs/ai-agents/chatgpt-architecture-instructions.md)
System role optimized for ChatGPT's interaction patterns with comprehensive technology recommendations.

### [GitHub Copilot](docs/ai-agents/copilot-architecture-instructions.md)
Code generation focused guidelines with security-first patterns and framework integration examples.

### [Gemini](docs/ai-agents/gemini-architecture-instructions.md)
Advanced analytical approach with multi-dimensional architecture strategy and emerging technology integration.

### [Anthropic API](docs/ai-agents/anthropic-api-architecture-instructions.md)
Specialized guidance for building applications that integrate with Anthropic's API services.

## Core Principles

- **Security by Design**: Built-in security from conception
- **Performance First**: Optimized for scale and efficiency
- **Developer Experience**: Tools and practices that enhance productivity
- **Maintainability**: Long-term sustainability and evolution
- **Accessibility**: Inclusive design for all users
- **Documentation**: Living documentation that evolves with code

## Technology Stack Coverage

### Backend
- Node.js, Python, C#, Java, Go, Rust
- REST APIs, GraphQL, gRPC
- Microservices and monolithic architectures

### Frontend
- React, Vue.js, Angular, Svelte
- Progressive Web Apps (PWA)
- Mobile-first responsive design

### Infrastructure
- Cloud platforms (AWS, Azure, GCP)
- Containerization (Docker, Kubernetes)
- CI/CD pipelines and GitOps

### Databases
- PostgreSQL, MongoDB, Redis
- Database optimization and scaling
- Data modeling and migrations

## Quality Standards

- **Type Safety**: TypeScript and strong typing practices
- **Testing**: TDD, unit, integration, and E2E testing
- **Code Quality**: Linting, formatting, and review processes
- **Security**: Authentication, authorization, and data protection
- **Performance**: Optimization strategies and monitoring

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Make your changes and add tests
4. Commit with conventional commit messages
5. Submit a pull request

### Commit Message Format
```
type(scope): description

[optional body]

[optional footer]
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

## Versioning

This project follows semantic versioning. Major updates to guidelines warrant version increments.

- **Major**: Breaking changes to core principles
- **Minor**: New guidelines or significant enhancements
- **Patch**: Bug fixes and minor improvements

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- **Issues**: [GitHub Issues](../../issues)
- **Discussions**: [GitHub Discussions](../../discussions)
- **Wiki**: [Project Wiki](../../wiki)

## Acknowledgments

Built on industry best practices and lessons learned from:
- Clean Architecture principles
- Domain-Driven Design (DDD)
- Twelve-Factor App methodology
- OWASP security guidelines
- Web Content Accessibility Guidelines (WCAG)

---

*Continuously updated to reflect current best practices and emerging technologies.*