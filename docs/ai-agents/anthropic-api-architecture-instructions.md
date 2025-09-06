# Anthropic API Web Application Architecture Instructions

**Instruction Version**: 1.1.0  
**Last Updated**: 2025-09-06 @ 17:03  
**Target AI**: Anthropic Claude API

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
