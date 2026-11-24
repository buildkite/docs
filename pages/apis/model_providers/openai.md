# OpenAI model provider

The OpenAI model provider connects your Buildkite Pipelines jobs to the [OpenAI Responses API](https://developers.openai.com/api/reference/resources/responses/). Use a Buildkite hosted token or your own OpenAI API key, while authenticating requests from jobs with a Buildkite [job token](/docs/agent/self-hosted/tokens#additional-agent-tokens-job-tokens).

## Connect OpenAI

1. As a [Buildkite organization administrator](/docs/platform/team-management/permissions#manage-teams-and-permissions-organization-level-permissions), select **Settings > Integrations > Model Providers**.
1. Select **OpenAI** in **All Providers**.
1. Select an **Authentication Method**. For **Bring Your Own Token (BYO)**, enter your [OpenAI API key](https://platform.openai.com/api-keys) in **API Key**.
1. Select **Create Provider**.

With **Buildkite Hosted Token**, Buildkite supplies the upstream OpenAI credentials and bills model usage. This option requires a paid Pro or Enterprise plan and a valid credit card on file.

With **Bring Your Own Token (BYO)**, Buildkite stores your OpenAI API key encrypted at rest and uses it for upstream requests. OpenAI bills usage to your account.

In both modes, use `$BUILDKITE_AGENT_ACCESS_TOKEN` in your pipeline, not an OpenAI API key. If your agents use [scoped agent tokens](/docs/agent/self-hosted/scoped-agent-tokens#available-permissions), include the `ai_proxy` permission, which their jobs inherit.

## Make a request

The proxy base URL is:

```url
https://agent.buildkite.com/v3/ai/openai
```

Within a job, use `$BUILDKITE_AGENT_ENDPOINT/ai/openai`. Authenticate with either `Authorization: Bearer $BUILDKITE_AGENT_ACCESS_TOKEN` or `Authorization: Token $BUILDKITE_AGENT_ACCESS_TOKEN`.

This pipeline step sends a non-streaming Responses request:

```yaml
steps:
  - label: "OpenAI summary"
    command: |
      curl --fail-with-body "$$BUILDKITE_AGENT_ENDPOINT/ai/openai/v1/responses" \
        -H "Authorization: Bearer $$BUILDKITE_AGENT_ACCESS_TOKEN" \
        -H "Content-Type: application/json" \
        -d '{
          "model": "gpt-5.4-nano",
          "input": "Explain how CI helps teams find regressions.",
          "max_output_tokens": 256
        }'
```

The doubled dollar signs defer [environment variable interpolation](/docs/pipelines/configure/environment-variables#runtime-variable-interpolation) until the job runs. For server-sent events (SSE), add `"stream": true` to the request and use `curl --no-buffer`.

### Configure an OpenAI client

Clients must use the Responses API over HTTP. Set the client's API key to the job token and its base URL to `$BUILDKITE_AGENT_ENDPOINT/ai/openai/v1`, including `/v1`. Chat Completions and WebSocket connections are not supported.

## Supported endpoints

The following endpoints are relative to the proxy base URL:

- `POST /v1/responses`: Create a response, with JSON or SSE output and usage tracking.
- `GET /v1/responses/{response_id}`: Retrieve a response.
- `DELETE /v1/responses/{response_id}`: Delete a response.
- `POST /v1/responses/{response_id}/cancel`: Forward a cancellation request.
- `GET /v1/responses/{response_id}/input_items`: List input items, forwarding pagination and query parameters such as `limit`, `order`, and `after`.
- `GET /v1/models`: List models available to the upstream credentials.
- `GET /v1/models/{model_id}`: Retrieve model information.

Response-specific requests require a response ID recorded for your Buildkite organization. The OpenAI Responses API reference describes request and response fields, but only the endpoints listed above are proxied. The cancellation route does not provide background-execution recovery or background usage reconciliation.

### Model selection

Choose a model that supports the Responses API and is available to the upstream credentials. The proxy does not reject unknown model IDs based on its billing catalog. A listed model does not guarantee support for all its capabilities through the proxy.

## Usage and billing

Buildkite tracks usage reported by `POST /v1/responses` for both hosted and BYO credentials, including completed and incomplete JSON or streaming responses. An incomplete response can still incur token charges. Retrieving a response does not record its usage again.

With Buildkite hosted tokens, token charges use OpenAI Standard processing rates. Omit `service_tier`, or set it to `"default"`. Non-standard processing tiers are not supported with hosted tokens. BYO requests do not have this proxy restriction; upstream validation and billing still apply.

See [OpenAI pricing](https://developers.openai.com/api/docs/pricing) for model-specific token, caching, and long-context rates.

Paid hosted-tool billing is not supported. Do not assume that tools or capabilities described in the upstream API documentation are supported by this integration.

With BYO credentials, OpenAI bills your account directly. Buildkite tracks usage but does not add hosted-token model charges. View usage in **Settings > Usage > Model Providers**, as described in [Monitoring usage](/docs/apis/model-providers#monitoring-usage).

## Rate limits

The default proxy limits apply per OpenAI provider, for both credential modes:

### Request rate limiting

- **Default limit**: 50 requests per minute

### Token rate limiting

- **Default limit**: 100,000 total input and output tokens per minute

Buildkite hosted tokens also have a monthly [OpenAI spend limit](/docs/platform/limits#pipelines-limits). This spend limit does not apply to BYO credentials. OpenAI can impose additional model-access restrictions, quotas, and rate limits on the upstream account. Contact support@buildkite.com to request higher Buildkite limits.
