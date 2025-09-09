# ADR-002: Database Schema Design Patterns

## Status

**Status**: Accepted  
**Date**: 2025-09-03  
**Deciders**: Architecture Team, Database Team  
**Supersedes**: N/A  
**Superseded by**: N/A  

## Context

We need to establish consistent database schema design patterns to ensure scalability, maintainability, and performance across all applications. The schema patterns should support the technology stack defined in ADR-001 and provide clear guidelines for developers.

## Decision Drivers

- Scalability requirements for growing data volumes
- Performance optimization for common query patterns
- Maintainability and versioning of schema changes
- Data integrity and consistency requirements
- Support for microservices architecture
- Compliance with data governance policies

## Options Considered

### Schema Design Approaches

1. **Single Database with Shared Schema**
   - Pros: Simple deployment, ACID transactions across services, easier data consistency
   - Cons: Tight coupling, scaling bottlenecks, harder to maintain service boundaries

2. **Database per Service (Microservices Pattern)**
   - Pros: Service independence, technology diversity, better scalability
   - Cons: Distributed transactions complexity, data consistency challenges

3. **Hybrid Approach with Shared Core Schema**
   - Pros: Balance of consistency and independence, gradual migration path
   - Cons: Increased complexity, potential for schema conflicts

## Decision

We have decided to adopt the following database schema design patterns:

### Core Patterns

1. **Entity-Based Schema Design**
   - Each business entity gets its own table group
   - Clear naming conventions: `entity_name` format
   - Consistent primary key strategy using UUIDs

2. **Audit Trail Pattern**
   - All business-critical tables include audit columns: `created_at`, `updated_at`, `created_by`, `updated_by`
   - Soft delete pattern using `deleted_at` column where appropriate
   - Change tracking for sensitive data

3. **Versioning Strategy**
   - Database migrations using Prisma migrate
   - Schema versioning aligned with application releases
   - Backward compatibility for at least 2 versions

### Data Architecture

- **PostgreSQL** as primary database (from ADR-001)
- **Database per Service** approach for new microservices
- **Shared Core Database** for existing monolithic components during transition
- **Event Sourcing** for audit-heavy domains

### Schema Standards

```sql
-- Standard table structure
CREATE TABLE entity_name (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  -- business columns --
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  deleted_at TIMESTAMP WITH TIME ZONE NULL
);

-- Standard indexes
CREATE INDEX idx_entity_name_created_at ON entity_name(created_at);
CREATE INDEX idx_entity_name_updated_at ON entity_name(updated_at);
CREATE INDEX idx_entity_name_active ON entity_name(id) WHERE deleted_at IS NULL;
```

## Rationale

**Entity-Based Design** provides clear boundaries and makes the codebase easier to understand and maintain. The consistent structure reduces cognitive load for developers.

**Audit Trail Pattern** ensures compliance requirements are met by default and provides excellent debugging capabilities for production issues.

**Database per Service** for new services provides the flexibility needed for microservices architecture while maintaining pragmatic approach for existing systems.

## Consequences

### Positive

- Consistent schema structure across all applications
- Built-in audit capabilities for compliance
- Clear migration and versioning strategy
- Supports both monolithic and microservices architectures

### Negative

- Additional storage overhead for audit columns
- Complexity of managing distributed transactions
- Requires careful planning for service boundaries

### Neutral

- Team needs training on PostgreSQL advanced features
- Requires tooling for cross-service data queries
- Migration strategy needed for existing schemas

## Implementation Plan

1. **Phase 1**: Define schema templates and Prisma models (Week 1-2)
2. **Phase 2**: Implement migration tooling and scripts (Week 3-4)
3. **Phase 3**: Create documentation and team training (Week 5-6)
4. **Phase 4**: Apply to pilot project (Week 7-8)
5. **Phase 5**: Rollout to existing projects (Week 9-12)

## Related Decisions

- [ADR-001]: Technology Stack Selection (defines PostgreSQL usage)
- [ADR-003]: Authentication Strategy (affects user audit columns)

## Monitoring and Review

This decision will be reviewed:

- After each major project implementation
- Quarterly architecture reviews
- When performance issues arise
- When compliance requirements change

---

## Last Updated

September 3, 2025
