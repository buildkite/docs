# Pipelines webhooks

Pipelines webhooks allow you to monitor and respond to events within your Buildkite organization, providing a real time view of activity and allowing you to extend and integrate Buildkite into your systems.

## Add a webhook

To add a webhook for your pipeline event:

1. Select **Settings** in the global navigation > **Notification Services** to access the [**Notification Services** page](https://buildkite.com/organizations/-/services).

1. Select the **Add** button on **Webhook**.

1. Specifying your webhook's **Description** and **Webhook URL**.

1. If you are using self-signed certificates for your webhooks, clear the **Verify TLS Certificates** checkbox.

1. To allow the authenticity of your Pipeline webhook events to be verified, configure your webhook's **Token** value to be sent either a as a plain text [`X-Buildkite-Token`](#webhook-token) value or an encrypted [`X-Buildkite-Signature`](#webhook-signature) in the request [header](#http-headers), bearing in mind that the latter provides the more secure verification method.

1. Select one or more of the listed [**Events**](#events) that will trigger this webhook, which include the following categories of webhooks:
    * [Build events](/docs/apis/webhooks/pipelines/build-events)
    * [Job events](/docs/apis/webhooks/pipelines/job-events)
    * [Agent events](/docs/apis/webhooks/pipelines/agent-events)
    * [Ping](/docs/apis/webhooks/pipelines/ping-events) and [agent token](/docs/apis/webhooks/pipelines/agent-token-events) events
    * Other events associated with [third-party application integrations](/docs/apis/webhooks/pipelines/integrations).

1. Select the **Pipelines** that this webhook will trigger:
    * **All Pipelines**.
    * **Only Some pipelines**, where you can select specific pipelines in your Buildkite organization.
    * **Pipelines in Teams**, where you can select pipelines accessible to specific teams configured in your Buildkite organization.
    * **Pipelines in Clusters**, where you can select pipelines associated with specific Buildkite clusters.

1. In the **Branch filtering** field, specify the branches that will trigger this webhook. You can leave this field empty to allow all branches to trigger the webhook, or select a subset of branches you would like to trigger it, based on [branch configuration](/docs/pipelines/configure/workflows/branch-configuration) and [pattern examples](/docs/pipelines/configure/workflows/branch-configuration#branch-pattern-examples).

1. Select the **Add Webhook Notification** button to save these changes and add the webhook.

## Events

You can subscribe to one or more of the following events:

<table>
<thead>
  <tr><th>Event</th><th>Description</th></tr>
</thead>
<tbody>
  <tr><th><code>ping</code></th><td>Webhook notification settings have changed</td></tr>
  <tr><th><code>build.scheduled</code></th><td>A build has been scheduled</td></tr>
  <tr><th><code>build.running</code></th><td>A build has started running</td></tr>
  <tr><th><code>build.failing</code></th><td>A build is failing</td></tr>
  <tr><th><code>build.finished</code></th><td>A build has finished</td></tr>
  <tr><th><code>build.skipped</code></th><td>A job has been scheduled</td></tr>
  <tr><th><code>job.scheduled</code></th><td>A job has been scheduled</td></tr>
  <tr><th><code>job.started</code></th><td>A command step job has started running on an agent</td></tr>
  <tr><th><code>job.finished</code></th><td>A job has finished</td></tr>
  <tr><th><code>job.activated</code></th><td>A block step job has been unblocked using the web or API</td></tr>
  <%= render_markdown partial: 'apis/webhooks/pipelines/agent_events_table' %>
  <tr><th><code>cluster_token.registration_blocked</code></th><td>An attempted agent registration has been blocked because the request IP address is not included in the agent token's <a href="/docs/pipelines/clusters/manage-clusters#restrict-an-agent-tokens-access-by-ip-address">allowed IP addresses</a></td></tr>
</tbody>
</table>

## HTTP headers

The following HTTP headers are present in every webhook request, which allow you to identify the event that took place, and to verify the authenticity of the request:

<table>
<tbody>
  <tr><th><code>X-Buildkite-Event</code></th><td>The type of event<p class="Docs__api-param-eg"><em>Example:</em> <code>build.scheduled</code></p></td></tr>
</tbody>
</table>

One of either the [token](/docs/apis/webhooks/pipelines#webhook-token) or [signature](/docs/apis/webhooks/pipelines#webhook-signature) headers will be present in every webhook request. The token value and header setting can be found under **Token** in your **Webhook Notification** service.

Your selection in the **Webhook Notification** service will determine which is sent:

<table class="fixed-width">
<tbody>
  <tr><th><code>X-Buildkite-Token</code></th><td>The webhook's <a href="/docs/apis/webhooks/pipelines#webhook-token">token</a>. <p class="Docs__api-param-eg"><em>Example:</em> <code>309c9c842g8565adecpd7469x6005989</code></p></td></tr>
  <tr><th><code>X-Buildkite-Signature</code></th><td>The <a href="/docs/apis/webhooks/pipelines#webhook-signature">signature</a> created from your webhook payload, webhook token, and the SHA-256 hash function.<p class="Docs__api-param-eg"><em>Example:</em> <code>timestamp=1619071700,signature=30222eb518dc3fb61ec9e64dd78d163f62cb134a6ldb768f1d40e0edbn6e43f0</code></p></td></tr>
</tbody>
</table>

## HTTP request body

Each event's data is sent JSON encoded in the request body. See each event's documentation ([agent](/docs/apis/webhooks/pipelines/agent-events), [build](/docs/apis/webhooks/pipelines/build-events#request-body-data), [job](/docs/apis/webhooks/pipelines/job-events), [ping](/docs/apis/webhooks/pipelines/ping-events)) to see which keys are available in the payload. For example:

```json
{
  "event": "build.started",
  "build": {
    "keys": "vals"
  },
  "sender": {
    "keys": "vals"
  }
}
```

> 🚧 Fast transitions and webhooks
> Note that if a build transitions between states very quickly, for example from blocked (<code>finished</code>) to unblocked (<code>running</code>), the webhook may be in a different state from the actual build. This is a known limitation of webhooks, in that they may represent a later version of the object than the one that triggered the event.

## Webhook token

By default, Buildkite will send a token with each webhook in the `X-Buildkite-Token` header.

The token value and header setting can be found under **Token** in your **Webhook Notification** service.

The token is passed in clear text.

## Webhook signature

Buildkite can optionally send an HMAC signature in place of a webhook token.

The `X-Buildkite-Signature` header contains a timestamp and an HMAC signature. The timestamp is prefixed by `timestamp=` and the signature is prefixed by `signature=`.

Buildkite generates the signature using HMAC-SHA256; a hash-based message authentication code [HMAC](https://en.wikipedia.org/wiki/HMAC) used with the [SHA-256](https://en.wikipedia.org/wiki/SHA-2) hash function and a secret key. The webhook token value is used as the secret key. The timestamp is an integer representation of a UTC timestamp. The raw request body is the signed message.

The token value and header setting can be found under **Token** in your **Webhook Notification** service.

### Verifying HMAC signatures

When using HMAC signatures, you'll want to verify that the signature is legitimate.

Using the token as the secret along with the timestamp from the webhook, compute the expected signature based on the raw request body. There should be a library available in the programming language you are using that can perform this operation.

Compare the code to the signature received in the webhook. If they do not match, your payload has been altered.

The below example in Ruby verifies the signature and timestamp using the OpenSSL gem's HMAC :

```ruby
require 'openssl'

class BuildkiteWebhook
  def self.valid?(webhook_request_body, header, secret)
    timestamp, signature = get_timestamp_and_signatures(header)
    expected = OpenSSL::HMAC.hexdigest("sha256", secret, "#{timestamp}.#{webhook_request_body}")
    Rack::Utils.secure_compare(expected, signature)
  end

  def self.get_timestamp_and_signatures(header)
    parts = header.split(",").map { |kv| kv.split("=", 2).map(&:strip) }.to_h
    [parts["timestamp"], parts["signature"]]
  end
end

BuildkiteWebhook.valid?(
  request.body.read,
  request.headers["X-Buildkite-Signature"],
  ENV["BUILDKITE_WEBHOOK_SECRET"]
)
```

### Defending against replay attacks

A [replay attack](https://en.wikipedia.org/wiki/Replay_attack) is when an attacker intercepts a valid payload and its signature, then re-transmits them. One way to help mitigate such attacks is to send a timestamp with your payload and only accept them within a short window (for example, 5 minutes).

Buildkite sends a timestamp in the `X-Buildkite-Signature` header. The timestamp is part of the signed payload so that it is verified by the signature. An attacker will not be able to change the timestamp without invalidating the signature.

To help protect against a replay attack, upon receipt of a webhook:

1. Verify the signature
1. Check the timestamp against the current time

If the webhook's timestamp is within your chosen window of the current time, it can reasonably be assumed to be the original webhook.

## Example implementations

The following example repositories show how to receive a webhook event and trigger a LIFX powered build light. You can browse their source, fork them, and deploy them to Heroku directly from their GitHub readmes, or use them as an example to implement webhooks in your tool of choice.

<a class="Docs__example-repo" href="https://github.com/buildkite/lifx-buildkite-build-light-node">
  <span class="icon">:node:</span>
  <span class="detail">
    <strong>Node webhook example application</strong>
    <span class="repo">github.com/buildkite/lifx-buildkite-build-light-node</span>
  </span>
</a>

<a class="Docs__example-repo" href="https://github.com/buildkite/lifx-buildkite-build-light-ruby">
  <span class="icon">:ruby:</span>
  <span class="detail">
    <strong>Ruby webhook example application</strong>
    <span class="repo">github.com/buildkite/lifx-buildkite-build-light-ruby</span>
  </span>
</a>

<a class="Docs__example-repo" href="https://github.com/buildkite/lifx-buildkite-build-light-php">
  <span class="icon">:php:</span>
  <span class="detail">
    <strong>PHP webhook example application</strong>
    <span class="repo">github.com/buildkite/lifx-buildkite-build-light-php</span>
  </span>
</a>

<a class="Docs__example-repo" href="https://github.com/buildkite/lifx-buildkite-build-light-webtask">
  <span class="icon">:node:</span>
  <span class="detail">
    <strong>Webtask.io webhook example application</strong>
    <span class="repo">github.com/buildkite/lifx-buildkite-build-light-webtask</span>
  </span>
</a>

<%= image "panda_light.gif", alt: "Build panda" %>

## Request logs

The last 20 webhook request and responses are saved, so you can debug and inspect your webhook. Each webhook's request logs are available on the bottom of their settings page.
