# Model providers overview

Model providers give Buildkite agents direct access to large language models (LLMs), enabling AI-powered workflows within your CI/CD environment. It provides secure, integrated access to AI models without requiring separate infrastructure setup.

Local AI coding tools operate in isolation with limited context and no connection to your actual build environment. Model providers solve this by bringing AI capabilities directly into your pipelines, where they have access to:

- Build logs, artifacts, and pipeline history
- Organizational security policies and audit trails
- Real-time build context for informed decision-making

AI agents can now respond to build failures, optimize performance, and improve your pipelines automatically. Every step of your software delivery process can benefit from AI that understands your actual build context.

## Supported providers

Currently, Buildkite supports [Anthropic](/docs/apis/model-providers/anthropic) models only.

## Getting started

Organization admins can enable model providers in a few steps:

1. Select **Settings** in the global navigation to access the to access the [**Organization Settings**](https://buildkite.com/organizations/~/settings) page.

1. Navigate to your [Model providers page](https://buildkite.com/organizations/~/model-providers) from **Settings**

1. Select the model provider to enable for your organization.

1. Choose your authentication method

## Authentication methods

Model providers support two authentication approaches to fit different security requirements.

### Buildkite Hosted

With Buildkite Hosted authentication, you can start using Large language models immediately. Buildkite handles the infrastructure and authentication, so there's no need to:

- Create accounts with model providers
- Manage API keys or secrets
- Configure additional infrastructure

Your pipelines authenticate using existing Buildkite job tokens:

### Bring your own token

For organizations with existing model provider relationships or specific security requirements, BYO token authentication lets you:

- Use your own API keys with model providers
- Maintain direct billing relationships
- Control API access and quotas
- Benefit from Buildkite's usage tracking and integration

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

Track your organization's AI model usage through the Buildkite dashboard

1. **Navigate to [Usage page](https://buildkite.com/organizations/~/usage)** from the Settings
2. Select the [**Hosted Models**](https://buildkite.com/organizations/~/usage?product=hosted_models) tab
