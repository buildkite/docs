# OpenAI model provider

The OpenAI model provider connects your Buildkite Pipelines jobs to the OpenAI Responses API. Use a Buildkite hosted token or your own OpenAI API key, while authenticating requests from jobs with a Buildkite [job token](/docs/agent/self-hosted/tokens#additional-agent-tokens-job-tokens).

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

Clients must use the Responses API over HTTP. Set the client's API key to the job token and its base URL to `$BUILDKITE_AGENT_ENDPOINT/ai/openai/v1`, including `/v1`. For example, with the [OpenAI Python SDK](https://github.com/openai/openai-python) installed on your agent:

```python
import os
from openai import OpenAI

client = OpenAI(
    api_key=os.environ["BUILDKITE_AGENT_ACCESS_TOKEN"],
    base_url=f"{os.environ['BUILDKITE_AGENT_ENDPOINT']}/ai/openai/v1",
)

response = client.responses.create(
    model="gpt-5.4-nano",
    input="Explain how CI helps teams find regressions.",
    max_output_tokens=256,
)
print(response.output_text)
```

Using an OpenAI-compatible client does not make all of its features available through the proxy. Chat Completions and WebSocket connections are not supported.

## Supported endpoints

The following endpoints are relative to the proxy base URL:

- `POST /v1/responses`: Create a response, with JSON or SSE output and usage tracking.
- `GET /v1/responses/{response_id}`: Retrieve a response.
- `DELETE /v1/responses/{response_id}`: Delete a response.
- `POST /v1/responses/{response_id}/cancel`: Forward a cancellation request.
- `GET /v1/responses/{response_id}/input_items`: List input items, forwarding pagination and query parameters such as `limit`, `order`, and `after`.
- `GET /v1/models`: List models available to the upstream credentials.
- `GET /v1/models/{model_id}`: Retrieve model information.

Response-specific requests require a response ID recorded for your Buildkite organization. The [OpenAI Responses API reference](https://developers.openai.com/api/reference/resources/responses/) describes request and response fields, but only the endpoints listed above are proxied. The cancellation route does not provide background-execution recovery or background usage reconciliation.

### Model selection

Choose a model that supports the Responses API and is available to the upstream credentials. The billing catalog includes `gpt-5.2`, `gpt-5.3-codex`, `gpt-5.4-mini`, `gpt-5.4-nano`, `gpt-6-astra`, `gpt-6.1-sol`, `gpt-6.1-terra`, and `gpt-6-luna`, alongside older models.

The catalog identifies models and specific aliases or snapshots for billing. It is not a request allowlist: the proxy does not reject a request solely because its model ID is unknown. A catalog entry or a model returned by `/v1/models` does not guarantee support for every model capability or client feature through the proxy.

## Usage and billing

Buildkite tracks usage reported by `POST /v1/responses`, including completed and incomplete JSON responses and terminal `response.completed` or `response.incomplete` SSE events. An incomplete response can still incur token charges. Retrieving a response does not record its usage again.

With Buildkite hosted tokens, token charges use OpenAI Standard processing rates. Omit `service_tier`, or set it to `"default"`. Non-standard processing tiers are not supported with hosted tokens. BYO requests do not have this proxy restriction; upstream validation and billing still apply.

Token accounting separates uncached input, cached input, visible output, and reasoning tokens. Reasoning tokens are charged at the output rate without counting them again as visible output. For GPT-6 models, paid 30-minute and 12-hour cache writes are accounted for separately from uncached input and cache reads. Requests with more than 272,000 input tokens use long-context rates for the whole request, not just tokens above the threshold. See [OpenAI pricing](https://developers.openai.com/api/docs/pricing) for provider rates.

Paid hosted-tool billing is not supported. Do not assume that tools or capabilities described in the upstream API documentation are supported by this integration.

With BYO credentials, OpenAI bills your account directly. Buildkite tracks usage but does not add hosted-token model charges. View usage in **Settings > Usage > Model Providers**, as described in [Monitoring usage](/docs/apis/model-providers#monitoring-usage).

## Limits

The default proxy limits apply per OpenAI provider, for both credential modes:

- 50 requests per minute
- 100,000 total input and output tokens per minute

Buildkite hosted tokens also have a monthly [OpenAI spend limit](/docs/platform/limits#pipelines-limits). This spend limit does not apply to BYO credentials. OpenAI can impose additional model-access restrictions, quotas, and rate limits on the upstream account. Contact support@buildkite.com to request higher Buildkite limits.
