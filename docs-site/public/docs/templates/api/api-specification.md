# API Specification Template

**Template Version**: 1.3.4
**Last Updated**: 2025-09-06 @ 22:12
**Compliance Score**: Targeting 100%  

## Overview

- **Version**: 1.3.4
- **Base URL**: [API base URL]
- **Protocol**: REST/GraphQL/gRPC
- **Authentication**: [Auth method]

## Authentication

### [Auth Method] Authentication

```http
Authorization: Bearer <token>
```text

**Example:**

```bash
curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
     https://api.example.com/v1/users
```text

## Endpoints

### [Resource Name]

#### GET /[resource]

Retrieve a list of [resources]

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `limit` | integer | No | Number of items to return (default: 20, max: 100) |
| `offset` | integer | No | Number of items to skip (default: 0) |
| `filter` | string | No | Filter criteria |

**Response:**

```json
{
  "data": [
    {
      "id": "string",
      "name": "string",
      "created_at": "2023-01-01T00:00:00Z"
    }
  ],
  "meta": {
    "total": 0,
    "limit": 20,
    "offset": 0
  }
}
```text

**Status Codes:**

- `200 OK`: Success
- `400 Bad Request`: Invalid parameters
- `401 Unauthorized`: Authentication required
- `403 Forbidden`: Insufficient permissions
- `500 Internal Server Error`: Server error

#### POST /[resource]

Create a new [resource]

**Request Body:**

```json
{
  "name": "string",
  "description": "string"
}
```text

**Response:**

```json
{
  "id": "string",
  "name": "string",
  "description": "string",
  "created_at": "2023-01-01T00:00:00Z"
}
```text

#### PUT /[resource]/{id}

Update an existing [resource]

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Unique identifier of the resource |

**Request Body:**

```json
{
  "name": "string",
  "description": "string"
}
```text

**Response:**

```json
{
  "id": "string",
  "name": "string",
  "description": "string",
  "updated_at": "2023-01-01T00:00:00Z"
}
```text

#### DELETE /[resource]/{id}

Delete a [resource]

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Unique identifier of the resource |

**Response:**

```json
{
  "message": "Resource deleted successfully"
}
```text

## Error Handling

All errors follow this format:

```json
{
  "error": {
    "code": "string",
    "message": "string",
    "details": {}
  }
}
```text

### Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `INVALID_REQUEST` | 400 | Request validation failed |
| `UNAUTHORIZED` | 401 | Authentication required |
| `FORBIDDEN` | 403 | Insufficient permissions |
| `NOT_FOUND` | 404 | Resource not found |
| `CONFLICT` | 409 | Resource already exists |
| `RATE_LIMITED` | 429 | Too many requests |
| `INTERNAL_ERROR` | 500 | Internal server error |

## Rate Limiting

- **Limit**: 1000 requests per hour per API key
- **Headers**: Rate limit information in response headers

```http
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1640995200
```text

## Pagination

For endpoints that return multiple items, pagination is implemented using
offset-based pagination:

**Request Parameters:**

- `limit`: Number of items per page (default: 20, max: 100)
- `offset`: Number of items to skip (default: 0)

**Response Format:**

```json
{
  "data": [...],
  "meta": {
    "total": 1000,
    "limit": 20,
    "offset": 0,
    "has_more": true
  }
}
```text

## Examples

### Complete Example

```bash
# Create a user
curl -X POST https://api.example.com/v1/users \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"name": "John Doe", "email": "john@example.com"}'

# Response
{
  "id": "usr_1234567890",
  "name": "John Doe",
  "email": "john@example.com",
  "created_at": "2023-01-01T00:00:00Z"
}
```text

### Error Example

```bash
# Invalid request
curl -X POST https://api.example.com/v1/users \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"name": ""}'

# Error Response
{
  "error": {
    "code": "INVALID_REQUEST",
    "message": "Validation failed",
    "details": {
      "name": "Name is required"
    }
  }
}
```text

## SDKs and Libraries

- **JavaScript**: `npm install @company/api-client`
- **Python**: `pip install company-api-client`
- **Go**: `go get github.com/company/api-client-go`
- **Java**: Available on Maven Central
- **PHP**: Available on Packagist

## Changelog

### Version 1.2 (2023-03-01)

- Added pagination support for all list endpoints
- Enhanced error responses with detailed validation messages
- Added rate limiting headers

### Version 1.1 (2023-02-01)

- Added new endpoint: GET /users/{id}/posts
- Deprecated: POST /users/{id}/avatar (use PUT instead)
- Improved response times

### Version 1.0 (2023-01-01)

- Initial release

## Testing

### Postman Collection

[Link to Postman collection]

### Test Environment

- **Base URL**: <https://api-test.example.com>
- **Authentication**: Use test API keys

### Sample Requests

See the `examples/` directory for complete request/response examples.

---
*Template Version: 1.3.4*****************  
*Last Updated: [Date]*
