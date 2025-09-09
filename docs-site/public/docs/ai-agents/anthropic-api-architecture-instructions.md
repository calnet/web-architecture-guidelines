# Anthropic API Web Application Architecture Instructions

**Instruction Version**: 1.3.3
**Last Updated**: 2025-09-06 @ 18:49
**Target AI**: Anthropic Claude API

## AI-Powered Code Review Integration

**New in v1.2.0**: This repository includes an AI-Powered Code Review workflow system specifically designed for Anthropic API integration projects. This system provides automated code analysis and optimization for applications that integrate with Anthropic's services.

### Enhanced Workflow Features for Anthropic API Projects

When implementing Anthropic API integrations, the AI-Powered Code Review system provides specialized validation for:

- **API Security**: Validates proper ANTHROPIC_API_KEY handling, request authentication, and response validation
- **Rate Limiting**: Ensures proper implementation of rate limiting and usage monitoring
- **Error Handling**: Reviews error handling patterns specific to Anthropic API responses
- **Performance Optimization**: Analyzes streaming implementations, token management, and response caching
- **Cost Optimization**: Reviews token usage patterns and suggests optimization strategies

### Custom Command Integration

The workflow system includes specialized analysis for Anthropic API projects:

```bash
# Architecture review with Anthropic API focus
/architecture-review
# Reviews API integration patterns, conversation management, and system design

# Security scan for API integrations  
/security-scan
# Validates API key security, request/response validation, and data protection

# Performance analysis for streaming and token optimization
/performance-check
# Analyzes streaming performance, token efficiency, and caching strategies
```

For complete setup instructions, see the repository's IMPLEMENTATION_GUIDE.md.

[Previous content remains the same through Frontend Integration Patterns...]

## Frontend Integration Patterns

```typescript
// React hook for Anthropic API integration
export const useAnthropicChat = (conversationId?: string) => {
  const [messages, setMessages] = useState<Message[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  
  const sendMessage = useCallback(async (content: string) => {
    setIsLoading(true);
    setError(null);
    
    try {
      const userMessage: Message = {
        id: generateId(),
        role: 'user',
        content,
        timestamp: new Date()
      };
      
      setMessages(prev => [...prev, userMessage]);
      
      const response = await fetch('/api/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          conversationId,
          message: content
        })
      });
      
      if (!response.ok) {
        throw new Error('Failed to send message');
      }
      
      // Handle streaming response
      const reader = response.body?.getReader();
      if (!reader) throw new Error('No response body');
      
      let assistantMessage: Message = {
        id: generateId(),
        role: 'assistant',
        content: '',
        timestamp: new Date()
      };
      
      setMessages(prev => [...prev, assistantMessage]);
      
      while (true) {
        const { done, value } = await reader.read();
        if (done) break;
        
        const chunk = new TextDecoder().decode(value);
        assistantMessage.content += chunk;
        
        setMessages(prev => 
          prev.map(msg => 
            msg.id === assistantMessage.id 
              ? { ...msg, content: assistantMessage.content }
              : msg
          )
        );
      }
      
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setIsLoading(false);
    }
  }, [conversationId]);
  
  return { messages, sendMessage, isLoading, error };
};

// Vue composition API integration
export const useAnthropicCompletion = () => {
  const completion = ref('');
  const isLoading = ref(false);
  const error = ref<string | null>(null);
  
  const generateCompletion = async (prompt: string, options?: CompletionOptions) => {
    isLoading.value = true;
    error.value = null;
    completion.value = '';
    
    try {
      const response = await $fetch('/api/completion', {
        method: 'POST',
        body: {
          prompt,
          ...options
        }
      });
      
      completion.value = response.text;
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Generation failed';
    } finally {
      isLoading.value = false;
    }
  };
  
  return {
    completion: readonly(completion),
    isLoading: readonly(isLoading),
    error: readonly(error),
    generateCompletion
  };
};

```

## Best Practices Summary

### API Usage Optimization

1. **Implement intelligent caching** for repeated queries
2. **Use streaming responses** for better user experience
3. **Batch requests** where possible to reduce API calls
4. **Monitor token usage** and implement cost controls
5. **Handle rate limits** gracefully with exponential backoff

### Security Considerations

1. **Filter inputs and outputs** for safety and compliance
2. **Implement audit logging** for all API interactions
3. **Use secure API key management** with rotation
4. **Validate and sanitize** all user inputs
5. **Implement proper authentication** and authorization

### Performance Best Practices

1. **Optimize prompt engineering** to reduce token usage
2. **Implement circuit breakers** for resilience
3. **Use connection pooling** for HTTP requests
4. **Cache responses** intelligently based on content type
5. **Monitor and alert** on performance metrics

### Error Handling

1. **Implement graceful degradation** for API failures
2. **Provide meaningful error messages** to users
3. **Log errors comprehensively** for debugging
4. **Implement retry logic** for transient failures
5. **Have fallback mechanisms** for critical features

Remember: Always prioritize user experience, security,
and cost efficiency when integrating with the Anthropic API.
Monitor usage patterns and optimize continuously based on real-world performance data.
