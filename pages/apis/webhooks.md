---
title: Webhooks
description: Receive real-time Buildkite events in your systems
weight: 10
---

# Webhooks overview

Buildkite webhooks let you react to activity in Buildkite as it happens. They deliver JSON payloads to an HTTP endpoint that you control whenever selected events occur. Common use cases include:

* Chat alerts in Slack or Microsoft Teams
* Infrastructure automation, such as scaling agents
* Analytics or data warehouse ingestion
* Custom dashboards and wallboards

## Creating a webhook

1. In Buildkite, open **Settings → Notification Services** for your organization or pipeline.
2. Click **Add Webhook**.
3. Enter your endpoint URL and optional secret token.
4. Choose the event families to subscribe to.
5. Save the service. Buildkite immediately sends a `ping` event so you can verify delivery.

## Event families

| Event family | Description |
|--------------|-------------|
| [Pipelines → Agent events](/docs/apis/webhooks/pipelines/agent_events) | Agent heartbeats, connects, disconnects, and stops |
| [Pipelines → Build events](/docs/apis/webhooks/pipelines/build_events) | Build starts, finishes, cancels, and state changes |
| [Pipelines → Job events](/docs/apis/webhooks/pipelines/job_events) | Job scheduling, running, finishing, and log uploads |
| [Pipelines → Ping events](/docs/apis/webhooks/pipelines/ping_events) | Notification service configuration changes |
| [Pipelines → Agent-token events](/docs/apis/webhooks/pipelines/agent_token_events) | Token creation and deletion |
| [Pipelines → Integrations](/docs/apis/webhooks/pipelines/integrations) | Third-party integration events |
| [Test Engine events](/docs/apis/webhooks/test_engine) | Test session lifecycle and result uploads |

## Delivery details

* HTTP `POST` with `application/json` body.
* Header `X-Buildkite-Event` identifies the event type.
* Optional HMAC-SHA256 signature in `X-Buildkite-Signature` when you set a secret token.

## Security best practices

* Use a secret token and verify the `X-Buildkite-Signature` header.
* Serve your endpoint over TLS.
* Restrict accepted IP ranges to Buildkite’s outgoing addresses.
* Treat webhook payloads as untrusted input and validate data types.

## See also

* [REST API overview](/docs/apis/rest_api)
* [GraphQL API overview](/docs/apis/graphql_api)
* [Amazon EventBridge integration](/docs/pipelines/integrations/other/amazon_eventbridge)
