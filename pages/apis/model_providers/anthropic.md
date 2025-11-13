# Anthropic

Anthropic Model Provider enables organizations to integrate Claude models into CI/CD pipelines. It supports both Buildkite Hosted Tokens as well as Bring-Your-Own (BYO) Tokens, providing flexible access to Anthropic's AI capabilities.

## Claude Code compatibility

Anthropic provider is fully compatible with Claude Code. You can run Claude Code directly within your Buildkite pipelines, enabling automated code generation, refactoring, and testing in your CI/CD environment.

## Supported models

Buildkite supports all current Anthropic Claude models, including Claude Sonnet 4.5, Opus 4.1, and Haiku 4.5.

## Base URL

When using Buildkite Hosted authentication, all Anthropic API requests go through:
```
https://agent.buildkite.com/v3/ai/anthropic
```

## Supported endpoints

The following Anthropic API endpoints are available through Buildkite Model Provider API:

- `POST /v1/messages` Generate completions and chat responses. Token usage is automatically tracked for billing.
- `POST /v1/messages/count_tokens` Calculate token usage before making requests to optimize costs.
- `GET /v1/models` Retrieve all available Anthropic models.
- `GET /v1/models/{model_id}` Get information about a specific model's capabilities and limits.

## Authentication methods

Anthropic provider supports two authentication header formats:

### Authorization header (standard Agent API)

```bash
-H "Authorization: Token $BUILDKITE_AGENT_ACCESS_TOKEN"
```

<!-- vale off -->

### x-api-key header (Claude SDK compatible)

<!-- vale on -->

```bash
-H "x-api-key: $BUILDKITE_AGENT_ACCESS_TOKEN"
```

Both methods use Job token for authentication.

## Rate limits

The following rate limits apply to Anthropic API requests:

### Request rate limiting

- **Default limit**: 50 requests per minute

### Input token rate limiting

- **Default limit**: 50,000 input tokens per minute per provider
- **Token calculation**: `total_input_token = cache_creation_input_tokens + input_tokens`

To request a higher rate limit for your Buildkite organization, please contact support@buildkite.com.

## Response formats

Anthropic provider supports both:

- **Non-streaming responses**: Complete responses returned after processing
- **Streaming responses**: Real-time response chunks for long-running completions
