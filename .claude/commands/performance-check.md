# Performance Check Command

**Usage**: `/performance-check "Performance focus area"`

## Purpose

Analyze application performance characteristics and identify optimization
opportunities across all layers of the system.

## Command Behavior

When triggered, this command instructs Claude to conduct comprehensive
performance analysis:

### 1. Frontend Performance

- **Core Web Vitals**
  - Largest Contentful Paint (LCP)
  - First Input Delay (FID)
  - Cumulative Layout Shift (CLS)
  
- **Loading Performance**
  - Bundle size optimization
  - Code splitting effectiveness
  - Lazy loading implementation
  - Resource optimization (images, fonts, etc.)
  
- **Runtime Performance**
  - JavaScript execution efficiency
  - Memory usage patterns
  - DOM manipulation optimization
  - Event handling efficiency

### 2. Backend Performance

- **API Performance**
  - Response time optimization
  - Throughput analysis
  - Concurrent request handling
  - Rate limiting effectiveness
  
- **Database Performance**
  - Query optimization
  - Index effectiveness
  - Connection pooling
  - Transaction efficiency
  
- **Caching Strategy**
  - Cache hit ratios
  - Cache invalidation strategy
  - CDN utilization
  - Application-level caching

### 3. Infrastructure Performance

- **Resource Utilization**
  - CPU usage patterns
  - Memory consumption
  - I/O performance
  - Network utilization
  
- **Scalability Analysis**
  - Horizontal scaling readiness
  - Load balancing effectiveness
  - Auto-scaling configuration
  - Performance under load

### 4. Monitoring & Observability

- Performance metrics collection
- Application Performance Monitoring (APM)
- Real User Monitoring (RUM)
- Synthetic monitoring setup

## Expected Output Format

```markdown
## Performance Analysis Report

### Performance Summary
[Overall performance assessment and key metrics]

### Critical Performance Issues
| Priority | Component | Issue | Impact | Solution |
|----------|-----------|-------|--------|----------|
| High | [Component] | [Issue] | [Impact] | [Fix] |
| Medium | [Component] | [Issue] | [Impact] | [Fix] |

### Core Web Vitals Assessment
- **LCP**: [Current] / [Target] - [Status]
- **FID**: [Current] / [Target] - [Status]  
- **CLS**: [Current] / [Target] - [Status]

### Performance Metrics
| Metric | Current | Target | Status |
|--------|---------|--------|--------|
| Page Load Time | [value] | [target] | ✅/⚠️/❌ |
| API Response Time | [value] | [target] | ✅/⚠️/❌ |
| Database Query Time | [value] | [target] | ✅/⚠️/❌ |

### Optimization Recommendations
1. **Immediate Wins** (Low effort, high impact)
   - [Specific optimizations with code examples]
   
2. **Short-term Improvements** (Medium effort, medium impact)
   - [Optimization strategies and implementation]
   
3. **Long-term Optimizations** (High effort, high impact)
   - [Architectural improvements and refactoring]

### Code Examples
[Before/after performance optimization examples]

### Monitoring Setup
- [ ] Performance budget defined
- [ ] Monitoring tools configured
- [ ] Alerting thresholds set
- [ ] Performance CI/CD gates established
```text

## Usage Examples

### General Performance Review

```text
/performance-check "Analyze overall application performance and identify
bottlenecks"
```text

### Database Performance Focus

```text
/performance-check "Review database query performance and optimization
opportunities"
```text

### Frontend Performance Analysis

```text
/performance-check "Evaluate Core Web Vitals and frontend loading performance"
```text

## Performance Standards

This command evaluates against:

- Google Core Web Vitals thresholds
- Industry standard response time benchmarks
- Accessibility performance guidelines
- Mobile performance best practices
- Progressive Web App performance criteria

## Tools Integration

Compatible with performance monitoring tools:

- Google PageSpeed Insights
- Lighthouse CI
- WebPageTest
- New Relic / DataDog / AppDynamics
- Synthetic monitoring services

## Performance Budget Guidelines

- Page load time: < 3 seconds
- API response time: < 200ms (95th percentile)
- Database queries: < 100ms average
- Bundle size: < 250KB gzipped
- Images: WebP format, lazy loaded
- Fonts: preloaded, font-display: swap

## Success Criteria

- ✅ Identifies performance bottlenecks
- ✅ Provides specific optimization recommendations
- ✅ Includes measurable performance targets
- ✅ References industry benchmarks
- ✅ Offers code-level improvements
- ✅ Suggests monitoring and alerting setup
