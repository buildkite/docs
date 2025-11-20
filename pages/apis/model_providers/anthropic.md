# Anthropic model provider

The Anthropic model provider enables organizations to integrate Claude AI models into Buildkite pipelines. This model provider supports both [**Buildkite Hosted Tokens**](/docs/apis/model-providers#connect-to-a-model-provider-buildkite-hosted-token) as well as [**Bring Your Own Token (BYO)**](/docs/apis/model-providers#connect-to-a-model-provider-bring-your-own-token), providing flexible access to Anthropic's AI capabilities.

## Claude Code compatibility

The Anthropic model provider is fully compatible with Claude Code, which allows you to run Claude Code directly within your Buildkite pipelines, enabling automated code generation, refactoring, and testing in your CI/CD environment.

### Supported models

Buildkite supports all current Anthropic Claude models, including Claude Sonnet 4.5, Opus 4.1, and Haiku 4.5.

## Base URL

Once you have [connected your Buildkite organization to your Anthropic model provider](/docs/apis/model-providers#connect-to-a-model-provider), you can access your Anthropic Claude models through the [Claude API](https://platform.claude.com/docs/en/api/overview), by appending these endpoints to the relevant [Buildkite model provider API endpoint](/docs/apis/model-providers#connect-to-a-model-provider-buildkite-model-provider-api-endpoints) as the base URL:

```url
https://agent.buildkite.com/v3/ai/anthropic
```

### Supported endpoints

The following [Claude API](https://platform.claude.com/docs/en/api/overview) endpoints are available through Buildkite model provider API:

- [`POST /v1/messages` endpoint](https://platform.claude.com/docs/en/api/messages): Generates completions and chat responses. Token usage is automatically tracked for billing.
- [`POST /v1/messages/count_tokens` endpoint](https://platform.claude.com/docs/en/api/messages/count_tokens): Calculates token usage before making requests to optimize costs.
- [`GET /v1/models` endpoint](https://docs.claude.com/en/api/models-list): Retrieves all available Anthropic models.
- [`GET /v1/models/{model_id}` endpoint](https://docs.claude.com/en/api/models): Gets information about a specific model's capabilities and limits.

These endpoints are accessed by appending them to the end of your Buildkite model provider API's base URL—for example, to access the Claude API `POST /v1/messages` endpoint from your Buildkite Agent, use the following URL:

```url
https://agent.buildkite.com/v3/ai/anthropic/v1/messages
```

## Authentication methods

The Anthropic model provider supports two authentication header formats, both of which use a [job token](/docs/agent/v3/tokens#additional-agent-tokens-job-tokens) for authentication.

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

## Basic example

Here's a simple pipeline that generates unit tests for your code:

```yaml
steps:
  - label: "Failure analysis"
    command: |
      curl -X POST "$BUILDKITE_AGENT_ENDPOINT/ai/anthropic/v1/messages" \
        -H "Content-Type: application/json" \
        -H "x-api-key: $BUILDKITE_AGENT_ACCESS_TOKEN" \
        -d '{
          "model": "claude-sonnet-4-5",
          "max_tokens": 1000,
          "messages": [
            {
              "role": "system",
              "content": "..."
            },
            {
              "role": "user",
              "content": "Analyze the test failures in this log"
            }
          ]
        }'
```

## Rate limits

The following rate limits apply to Anthropic API requests:

### Request rate limiting

- **Default limit**: 50 requests per minute

### Input token rate limiting

- **Default limit**: 50,000 input tokens per minute per provider.

- **Token calculation**: `total_input_token = cache_creation_input_tokens + input_tokens`.

To request a higher rate limit for your Buildkite organization, please contact support@buildkite.com.

## Response formats

Anthropic provider supports both:

- **Non-streaming responses**: Complete responses returned after processing.

- **Streaming responses**: Real-time response chunks for long-running completions.
