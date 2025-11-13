# Model providers overview

The _model providers_ feature provides [Buildkite Agents](/docs/agent/v3) with direct access to large language models (LLMs) through the Buildkite platform, enabling AI-powered workflows within your CI/CD environment. This feature provides secure, integrated access to LLMs, also known as _models_ or _AI models_, without requiring separate infrastructure setup.

Local AI coding tools operate in isolation with limited context and no connection to your actual build environment. Model providers solve this by bringing AI capabilities directly into your pipelines, where they have access to:

- Build logs, artifacts, and pipeline history
- Organizational security policies and audit trails
- Real-time build context for informed decision-making

Once you have connected your Buildkite organization to a model provider, your AI agents can then respond to build failures from Buildkite pipelines, optimize performance, and improve your pipelines automatically. Every step of your software delivery process can benefit from AI that understands your actual build context.

## Connect to a model provider

Connecting your Buildkite organization to an AI model through the Buildkite platform can only be done by [Buildkite organization administrators](/docs/platform/team-management/permissions#manage-teams-and-permissions-organization-level-permissions). Currently, only [Anthropic](/docs/apis/model-providers/anthropic) models are supported.

To connect to a model provider:

1. Select **Settings** in the global navigation to access the to access the [**Organization Settings**](https://buildkite.com/organizations/~/settings) page.

1. Select **Integrations > Model Providers** to access your organization's [**Model Providers**](https://buildkite.com/organizations/~/model-providers) page.

1. In **All Providers**, select the model provider to enable for your organization.

1. Choose your **Authentication Method**—[**Buildkite Hosted Token**](#connect-to-a-model-provider-buildkite-hosted-token) or [**Bring Your Own Token (BYO)**](#connect-to-a-model-provider-bring-your-own-token), depending on your security requirements and preferences.

### Buildkite hosted token

With the **Buildkite Hosted Token** authentication option, you can start using AI models immediately. Buildkite handles the infrastructure and authentication, and therefore, there's no need to:

- Create accounts with model providers.
- Manage API keys or secrets.
- Configure additional infrastructure.

Your pipelines authenticate using existing Buildkite job tokens:

### Bring your own token

For organizations with existing model provider relationships or specific security requirements, the **Bring Your Own Token (BYO)** authentication option lets you:

- Use your own API keys with AI model providers.
- Maintain direct billing relationships.
- Control API access and quotas.
- Benefit from Buildkite's usage tracking and integration.

Once configured, integrate AI capabilities into your build workflows using the Buildkite Agent API.

### Basic example

Here's a simple pipeline that generates unit tests for your code:

```yaml
steps:
  - label: "Failure analysis"
    command: |
      curl -X POST "$BUILDKITE_AGENT_ENDPOINT/ai/anthropic/v1/messages" \
        -H "Content-Type: application/json" \
        -H "x-api-key: $BUILDKITE_AGENT_ACCESS_TOKEN" \
        -d '{
          "model": "claude-3-5-sonnet",
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

## Monitoring usage

To track your Buildkite organization's AI model usage through the Buildkite interface:

1. Select **Settings** in the global navigation to access the to access the [**Organization Settings**](https://buildkite.com/organizations/~/settings) page.

1. Select **Usage** to access your Buildkite organization's usage [**Usage > Summary**](https://buildkite.com/organizations/~/usage) page.

1. Select the [**Hosted Models**](https://buildkite.com/organizations/~/usage?product=hosted_models) tab to view your model provider usage.

