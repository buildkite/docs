# Package Registry webhooks

You can configure webhooks to be triggered by the following events in Package Registries:

- When a package is created.

Webhooks are delivered to an HTTP POST endpoint of your choosing with a `Content-Type: application/json` header and a JSON encoded request body.

## Add a webhook

To add a webhook to a package registry:

1. Select **Package Registries** in the global navigation > the package registry to configure webhooks on.
1. Select **Settings** > **Notification Services** tab.
1. Select the **Add** button on **Webhooks**.
1. Specifying your webhook's **Description** and **Webhook URL**.
1. Select one or more of the following **Events** that will trigger this webhook:
   + **Package created**
1. Select the **Save** button to save these changes and add the webhook.

### Package created

The webhook is triggered when a package is created by published through an ecosystem-native CLI or using the [REST API](/docs/apis/rest-api/package_registries/packages).

Example payload:

```json
{
  "event": "package.created",
  "package": {
    {
      "id": "0191e23a-4bc8-7683-bfa4-5f73bc9b7c44",
      "url": "https://api.buildkite.com/v2/packages/organizations/my_great_org/registries/my-registry/packages/0191e23a-4bc8-7683-bfa4-5f73bc9b7c44",
      "web_url": "https://buildkite.com/organizations/my_great_org/packages/registries/my-registry/packages/0191e23a-4bc8-7683-bfa4-5f73bc9b7c44",
      "name": "banana",
      "organization": {
        "id": "0190e784-eeb7-4ce4-9d2d-87f7aba85433",
        "slug": "my_great_org",
        "url": "https://api.buildkite.com/v2/organizations/my_great_org",
        "web_url": "https://buildkite.com/my_great_org"
      },
      "registry": {
        "id": "0191e238-e0a3-7b0b-bb34-beea0035a39d",
        "graphql_id": "UmVnaXN0cnktLS0wMTkxZTIzOC1lMGEzLTdiMGItYmIzNC1iZWVhMDAzNWEzOWQ=",
        "slug": "my-registry",
        "url": "https://api.buildkite.com/v2/packages/organizations/my_great_org/registries/my-registry",
        "web_url": "https://buildkite.com/organizations/my_great_org/packages/registries/my-registry"
      }
    }
  },
  "sender": {
    "id": "01989b9e-f7e2-4577-92e7-dcdf141598aa",
    "name": "Developer"
  }
}
```

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
  <tr><th><code>X-Buildkite-Token</code></th><td>The webhook's <a href="/docs/apis/webhooks/package_registries#webhook-token">token</a>. <p class="Docs__api-param-eg"><em>Example:</em> <code>309c9c842g8565adecpd7469x6005989</code></p></td></tr>
  <tr><th><code>X-Buildkite-Signature</code></th><td>The <a href="/docs/apis/webhooks/package_registries#webhook-signature">signature</a> created from your webhook payload, webhook token, and the SHA-256 hash function.<p class="Docs__api-param-eg"><em>Example:</em> <code>timestamp=1619071700,signature=30222eb518dc3fb61ec9e64dd78d163f62cb134a6ldb768f1d40e0edbn6e43f0</code></p></td></tr>
</tbody>
</table>

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


## Edit, disable, re-enable or delete a webhook

To do any of these actions a webhook:

1. Select **Package Registries** in the global navigation > your registry with configured webhooks.
1. Select **Settings** > **Notification Services** tab t open its page.
1. Select the webhook to open its page, and to:
   + Edit the webhook, alter the **Description**, **Webhook URL**, **Events** and **Teams** fields as required (see [Add a webhook](#add-a-webhook) for details), then select the **Save** button.
   + Disable the webhook, select its **Disable** button and confirm the action. Disabled webhooks have a note at the top to indicate this state.
     - Re-enable the disabled webhook, select its **Enable** button.
   + Delete the webhook, select its **Delete** button and confirm the action. The webhook is removed from the **Notification Services** page.

## Request logs

The last 20 webhook request and responses are saved, so you can debug and inspect your webhook. Each webhook's request logs are available on the bottom of their settings page.
