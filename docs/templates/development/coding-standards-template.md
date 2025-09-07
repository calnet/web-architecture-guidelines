# [Project Name] Coding Standards

This document defines the coding standards and best practices for
[Project Name]. Following these standards ensures code consistency,
maintainability, and collaboration effectiveness across the development team.

## Code Style

### Formatting and Indentation

**TypeScript/JavaScript**:

- Use **4 spaces** for indentation (no tabs)
- Maximum line length: **100 characters**
- Use **semicolons** at the end of statements
- Use **single quotes** for strings, double quotes for JSX attributes
- Add trailing commas in multi-line objects and arrays

```typescript
// Good
const config = {
    apiUrl: "https://api.example.com",
    timeout: 5000,
    retries: 3,
};

// Bad
const config = {
    apiUrl: "https://api.example.com",
    timeout: 5000,
    retries: 3,
};
```

**CSS/SCSS**:

- Use **4 spaces** for indentation
- Use **kebab-case** for class names
- Order properties alphabetically within blocks
- Use **rem/em** for scalable units, **px** for borders and fixed elements

```scss
// Good
.button-primary {
    background-color: #007bff;
    border: 1px solid transparent;
    border-radius: 0.25rem;
    color: #ffffff;
    font-size: 1rem;
    padding: 0.5rem 1rem;
}
```

### Naming Conventions

**Variables and Functions**:

- Use **camelCase** for variables and functions
- Use descriptive names that explain intent
- Avoid abbreviations unless commonly understood
- Use verbs for functions, nouns for variables

```typescript
// Good
const userAccountBalance = 1500.5;
const isUserAuthenticated = true;

function calculateTotalPrice(items: CartItem[]): number {
    return items.reduce((total, item) => total + item.price, 0);
}
```

**Constants**:

- Use **SCREAMING_SNAKE_CASE** for constants
- Group related constants in enums or const objects

```typescript
// Good
const MAX_RETRY_ATTEMPTS = 3;
const API_ENDPOINTS = {
    USERS: "/api/users",
    ORDERS: "/api/orders",
    PRODUCTS: "/api/products",
} as const;

enum UserRole {
    ADMIN = "admin",
    USER = "user",
    GUEST = "guest",
}
```

## Best Practices

### Code Organization

**Project Structure**:

```text
src/
├── components/          # Reusable UI components
│   ├── common/         # Shared components
│   └── pages/          # Page-specific components
├── services/           # Business logic and API calls
├── hooks/              # Custom React hooks
├── utils/              # Pure utility functions
├── types/              # TypeScript type definitions
├── constants/          # Application constants
├── assets/             # Static assets (images, fonts)
└── styles/             # Global styles and themes
```

### Function and Method Design

**Function Size and Responsibility**:

- Keep functions small and focused (ideally < 20 lines)
- Each function should have a single responsibility
- Use pure functions when possible

```typescript
// Good - Single responsibility, pure function
function calculateDiscountAmount(
    price: number,
    discountPercent: number
): number {
    return price * (discountPercent / 100);
}

function formatCurrency(amount: number, currency = "USD"): string {
    return new Intl.NumberFormat("en-US", {
        style: "currency",
        currency,
    }).format(amount);
}
```

### Error Handling

**Exception Handling**:

- Always handle errors explicitly
- Use specific error types
- Provide meaningful error messages
- Log errors appropriately

```typescript
// Good
async function fetchUserData(userId: string): Promise<User> {
    try {
        const response = await apiClient.get(`/users/${userId}`);
        return response.data;
    } catch (error) {
        if (error instanceof NotFoundError) {
            throw new UserNotFoundError(`User with ID ${userId} not found`);
        }

        logger.error("Failed to fetch user data", { userId, error });
        throw new UserDataFetchError("Unable to retrieve user information");
    }
}
```

## Testing

### Test Structure and Organization

**Test File Naming**:

- Use `.test.ts` or `.spec.ts` suffix
- Mirror the directory structure of source files
- Use descriptive test file names

**Test Organization**:

- Group related tests with `describe` blocks
- Use clear, descriptive test names
- Follow Arrange-Act-Assert pattern

```typescript
// Good
describe("UserService", () => {
    describe("createUser", () => {
        it("should create a new user with valid data", async () => {
            // Arrange
            const userData = {
                email: "test@example.com",
                firstName: "John",
                lastName: "Doe",
            };
            const expectedUser = { id: "123", ...userData };
            mockUserRepository.create.mockResolvedValue(expectedUser);

            // Act
            const result = await userService.createUser(userData);

            // Assert
            expect(result).toEqual(expectedUser);
            expect(mockUserRepository.create).toHaveBeenCalledWith(userData);
        });
    });
});
```

## Performance Guidelines

### General Performance Principles

**Code Efficiency**:

- Prefer algorithms with better time complexity
- Avoid nested loops when possible
- Cache expensive computations
- Use appropriate data structures

```typescript
// Good - O(n) complexity with Map lookup
function findUsersByRole(users: User[], targetRole: string): User[] {
    const roleMap = new Map<string, User[]>();

    users.forEach((user) => {
        if (!roleMap.has(user.role)) {
            roleMap.set(user.role, []);
        }
        roleMap.get(user.role)!.push(user);
    });

    return roleMap.get(targetRole) || [];
}
```

### Frontend Performance

**React Performance**:

```typescript
// Use React.memo for expensive components
const ExpensiveComponent = React.memo(
    ({ data, onAction }: Props) => {
        // Component implementation
    },
    (prevProps, nextProps) => {
        return prevProps.data.id === nextProps.data.id;
    }
);

// Use useCallback for event handlers
const handleItemClick = useCallback(
    (id: string) => {
        onItemSelect(id);
        trackUserAction("item_click", { itemId: id });
    },
    [onItemSelect]
);
```

### Backend Performance

**Database Optimization**:

```typescript
// Use proper indexing and selective queries
const users = await userRepository.find({
    where: { status: "active" }, // Ensure status column is indexed
    select: ["id", "name", "email"], // Only select needed columns
    take: 20, // Limit results
});
```

---

**Template Metadata:**

- Version: 1.0
- Last Updated: [Date]
- Maintained by: [Team Name]
- Review Schedule: Quarterly

### Database Performance

```typescript
// Use proper indexing hints in queries
const users = await userRepository.find({
    where: { email: userEmail }, // Ensure email column is indexed
    select: ["id", "name", "email"], // Only select needed columns
    take: 20, // Limit results
});

// Batch operations instead of loops
const userIds = ["1", "2", "3"];
// Not: multiple findById calls
const users = await userRepository.findByIds(userIds);

// Use transactions for related operations
await dataSource.transaction(async (manager) => {
    const user = await manager.save(User, userData);
    await manager.save(Profile, { ...profileData, userId: user.id });
    await manager.save(Preferences, { ...preferencesData, userId: user.id });
});

// Implement proper pagination
interface PaginationOptions {
    page: number;
    limit: number;
}

async function getPaginatedUsers({ page, limit }: PaginationOptions) {
    const offset = (page - 1) * limit;
    const [users, total] = await userRepository.findAndCount({
        skip: offset,
        take: limit,
        order: { createdAt: "DESC" },
    });

    return {
        users,
        pagination: {
            total,
            page,
            limit,
            totalPages: Math.ceil(total / limit),
        },
    };
}
```

## Security Guidelines

### Input Validation

```typescript
import Joi from "joi";
import DOMPurify from "dompurify";

// Schema-based validation
const userSchema = Joi.object({
    email: Joi.string().email().required(),
    password: Joi.string()
        .min(8)
        .pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
        .required(),
    name: Joi.string().min(2).max(50).required(),
    age: Joi.number().integer().min(13).max(120).optional(),
});

function validateUserInput(input: unknown): User {
    const { error, value } = userSchema.validate(input);
    if (error) {
        throw new ValidationError(error.details[0].message);
    }
    return value;
}

// Sanitize HTML content
function sanitizeHtmlContent(content: string): string {
    return DOMPurify.sanitize(content, {
        ALLOWED_TAGS: ["p", "br", "strong", "em", "u"],
        ALLOWED_ATTR: [],
    });
}

// File upload validation
function validateFileUpload(file: Express.Multer.File): void {
    const allowedMimeTypes = ["image/jpeg", "image/png", "image/gif"];
    const maxSize = 5 * 1024 * 1024; // 5MB

    if (!allowedMimeTypes.includes(file.mimetype)) {
        throw new ValidationError("Invalid file type");
    }

    if (file.size > maxSize) {
        throw new ValidationError("File too large");
    }
}
```

### Secure Coding Practices

```typescript
// Never log sensitive information
logger.info("User login successful", {
    userId: user.id,
    timestamp: new Date().toISOString(),
    // Don't log: password, tokens, personal data
});

// Use parameterized queries to prevent SQL injection
const user = await db.query(
    "SELECT * FROM users WHERE email = $1 AND status = $2",
    [email, "active"] // Parameterized values, not string concatenation
);

// Implement proper session management
const sessionData = {
    userId: user.id,
    role: user.role,
    expiresAt: new Date(Date.now() + SESSION_DURATION),
};

// Sanitize output to prevent XSS
function sanitizeForDisplay(userInput: string): string {
    return userInput
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#39;");
}

// Environment variable validation
function getRequiredEnvVar(name: string): string {
    const value = process.env[name];
    if (!value) {
        throw new Error(`Required environment variable ${name} is not set`);
    }
    return value;
}

// Rate limiting implementation
const rateLimitMap = new Map<string, { count: number; resetTime: number }>();

function checkRateLimit(
    identifier: string,
    maxRequests: number,
    windowMs: number
): boolean {
    const now = Date.now();
    const record = rateLimitMap.get(identifier);

    if (!record || now > record.resetTime) {
        rateLimitMap.set(identifier, { count: 1, resetTime: now + windowMs });
        return true;
    }

    if (record.count >= maxRequests) {
        return false;
    }

    record.count++;
    return true;
}
```

## Error Handling Patterns

### Centralized Error Handling

```typescript
// Error types hierarchy
abstract class AppError extends Error {
    abstract statusCode: number;
    abstract isOperational: boolean;

    constructor(message: string, public context?: Record<string, any>) {
        super(message);
        this.name = this.constructor.name;
    }
}

class ValidationError extends AppError {
    statusCode = 400;
    isOperational = true;
}

class NotFoundError extends AppError {
    statusCode = 404;
    isOperational = true;
}

class InternalError extends AppError {
    statusCode = 500;
    isOperational = false;
}

// Global error handler
function handleError(error: Error, req?: Request, res?: Response): void {
    logger.error("Application error", {
        error: error.message,
        stack: error.stack,
        context: error instanceof AppError ? error.context : undefined,
        request: req
            ? {
                  method: req.method,
                  url: req.url,
                  headers: req.headers,
                  body: req.body,
              }
            : undefined,
    });

    if (res) {
        const statusCode = error instanceof AppError ? error.statusCode : 500;
        const message =
            error instanceof AppError && error.isOperational
                ? error.message
                : "Internal server error";

        res.status(statusCode).json({
            error: {
                message,
                code: error.name,
                ...(process.env.NODE_ENV === "development" && {
                    stack: error.stack,
                }),
            },
        });
    }
}

// Async error wrapper
function asyncHandler<T extends any[], R>(
    fn: (...args: T) => Promise<R>
): (...args: T) => Promise<R> {
    return async (...args: T): Promise<R> => {
        try {
            return await fn(...args);
        } catch (error) {
            handleError(error as Error);
            throw error;
        }
    };
}
```

## Code Quality Checklist

### Pre-Commit Checklist

Before submitting code, ensure:

#### Code Quality

- [ ] Code follows naming conventions
- [ ] Functions have single responsibility
- [ ] No code duplication (DRY principle)
- [ ] Complex logic is properly commented
- [ ] No unused imports or variables
- [ ] Consistent formatting throughout

#### Error Handling Checklist

- [ ] All async operations have error handling
- [ ] Custom errors provide meaningful messages
- [ ] Errors are logged with appropriate context
- [ ] User-facing errors are sanitized

#### Testing Checklist

- [ ] Tests are written for new functionality
- [ ] Tests cover edge cases and error scenarios
- [ ] Test coverage meets minimum requirements (80%)
- [ ] Integration tests for API endpoints

#### Performance

- [ ] No obvious performance bottlenecks
- [ ] Database queries are optimized
- [ ] Large lists are paginated
- [ ] Heavy computations are memoized

#### Security

- [ ] Input validation is implemented
- [ ] No sensitive data in logs
- [ ] Authentication and authorization checks
- [ ] SQL injection prevention

#### Documentation

- [ ] Complex functions have JSDoc comments
- [ ] README is updated if needed
- [ ] API documentation is current
- [ ] Breaking changes are documented

### Code Review Guidelines

#### For Authors

- **Keep PRs small**: Limit to 400 lines of changes when possible
- **Write descriptive titles**: Explain what and why, not just how
- **Provide context**: Link to issues, explain decisions
- **Self-review first**: Review your own code before requesting review
- **Test thoroughly**: Ensure all tests pass and new functionality works

#### For Reviewers

- **Be constructive**: Provide specific, actionable feedback
- **Focus on important issues**: Don't nitpick formatting if tools handle it
- **Explain reasoning**: Help the author understand your suggestions
- **Appreciate good code**: Acknowledge well-written code and clever solutions
- **Test the changes**: Pull and test significant changes locally

### Automated Quality Gates

#### ESLint Configuration

```json
{
    "extends": [
        "@typescript-eslint/recommended",
        "@typescript-eslint/recommended-requiring-type-checking"
    ],
    "rules": {
        "@typescript-eslint/no-unused-vars": "error",
        "@typescript-eslint/explicit-function-return-type": "warn",
        "@typescript-eslint/no-explicit-any": "warn",
        "prefer-const": "error",
        "no-var": "error",
        "complexity": ["warn", 10],
        "max-lines-per-function": ["warn", 50]
    }
}
```

#### TypeScript Configuration

```json
{
    "compilerOptions": {
        "strict": true,
        "noImplicitAny": true,
        "noImplicitReturns": true,
        "noImplicitThis": true,
        "noUnusedLocals": true,
        "noUnusedParameters": true
    }
}
```

#### Test Coverage Requirements

```json
{
    "jest": {
        "coverageThreshold": {
            "global": {
                "branches": 80,
                "functions": 80,
                "lines": 80,
                "statements": 80
            }
        }
    }
}
```

## Tools and Automation

### Development Tools

- **Code Formatting**: Prettier with consistent configuration
- **Linting**: ESLint with TypeScript support
- **Type Checking**: TypeScript in strict mode
- **Testing**: Jest for unit/integration tests, Cypress/Playwright for E2E
- **Code Coverage**: Istanbul/NYC for coverage reporting

### Pre-commit Hooks

```json
{
    "husky": {
        "hooks": {
            "pre-commit": "lint-staged && npm run type-check",
            "commit-msg": "commitlint -E HUSKY_GIT_PARAMS"
        }
    },
    "lint-staged": {
        "*.{ts,tsx}": ["eslint --fix", "prettier --write", "git add"],
        "*.{js,jsx}": ["eslint --fix", "prettier --write", "git add"]
    }
}
```

### CI/CD Quality Gates

- **Build Verification**: Ensure code compiles successfully
- **Test Execution**: All tests must pass
- **Coverage Check**: Minimum coverage thresholds
- **Security Scanning**: Dependency vulnerability checks
- **Performance Testing**: Bundle size and runtime performance
- **Code Quality**: SonarQube or similar analysis

## Language-Specific Guidelines

### Python (if applicable)

```python
# Follow PEP 8 style guide
# Use type hints
def calculate_total(price: float, tax_rate: float) -> float:
    """Calculate total price including tax."""
    return price * (1 + tax_rate)

# Use dataclasses for data structures
from dataclasses import dataclass

@dataclass
class User:
    id: str
    name: str
    email: str
    is_active: bool = True
```

### Java (if applicable)

```java
// Follow Oracle Java conventions
// Use meaningful names
public class UserService {
    private static final int DEFAULT_PAGE_SIZE = 20;

    public Optional<User> findUserById(String userId) {
        // Implementation
    }
}
```

### C# (if applicable)

```csharp
// Follow Microsoft C# conventions
// Use PascalCase for public members
public class UserService
{
    private const int DefaultPageSize = 20;

    public async Task<User?> GetUserByIdAsync(string userId)
    {
        // Implementation
    }
}
```

## Maintenance and Evolution

### Regular Code Reviews

- **Weekly team reviews**: Discuss code quality trends
- **Monthly architecture reviews**: Ensure standards are being followed
- **Quarterly standard updates**: Evolve standards based on lessons learned

### Continuous Improvement

- **Collect feedback**: Regular developer surveys on coding standards
- **Monitor metrics**: Track code quality metrics over time
- **Update tools**: Keep development tools and dependencies current
- **Share knowledge**: Regular tech talks and knowledge sharing sessions

### Documentation Updates

- **Version control**: Track changes to coding standards
- **Communication**: Announce changes to the entire team
- **Training**: Provide training on new standards or tools
- **Examples**: Update code examples to reflect current best practices

---

_Template Version: 1.0_  
_Last Updated: [Date]_  
_For questions or suggestions, contact: [Team/Email]_
