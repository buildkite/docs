# Package Registries webhooks

You can configure webhooks to be triggered in Package Registries when a package, image, chart, model, module, or file is created.

Webhooks are delivered to an HTTP POST endpoint of your choosing with a `Content-Type: application/json` header and a JSON encoded request body.

## Add a webhook

To add a webhook for your package creation event:

1. Select **Package Registries** in the global navigation > your registry to configure webhooks on.

1. Select **Settings** tab > **Notification Services** page.

1. Select the **Add** button on **Webhook**.

1. Specifying your webhook's **Description** and **Webhook URL**.

1. If you are using self-signed certificates for your webhooks, clear the **Verify TLS Certificates** checkbox.

1. To allow the authenticity of your Package Registries webhook events to be verified, configure your webhook's **Token** value to be sent either as a plain text [`X-Buildkite-Token`](#webhook-token) value or an encrypted [`X-Buildkite-Signature`](#webhook-signature) in the request [header](#http-headers), bearing in mind that the latter provides the more secure verification method.

1. In the **Events** section, ensure the **package.created** event has been selected.

1. Select the **Save Webhook Settings** button to save these changes and add the webhook.

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
  <tr><th><code>X-Buildkite-Event</code></th><td>The type of event<p class="Docs__api-param-eg"><em>Example:</em> <code>package.created</code></p></td></tr>
</tbody>
</table>

<%= render_markdown partial: 'apis/webhooks/http_headers_token_or_signature' %>

## Webhook token

<%= render_markdown partial: 'apis/webhooks/webhook_token' %>

## Webhook signature

<%= render_markdown partial: 'apis/webhooks/webhook_signature' %>

### Verifying HMAC signatures

<%= render_markdown partial: 'apis/webhooks/verifying_hmac_signatures' %>

### Defending against replay attacks

<%= render_markdown partial: 'apis/webhooks/defending_against_replay_attacks' %>

## Edit, disable, re-enable or delete a webhook

To do any of these actions a webhook:

1. Select **Package Registries** in the global navigation > your registry with your configured webhooks.
1. Select **Settings** tab > **Notification Services** to open its page.
1. Select the webhook to open its page, and to:
    * Edit the webhook, alter the **Description**, **Webhook URL**, **Verify TLS Certificates** and **Token** fields as required (see [Add a webhook](#add-a-webhook) for details), then select the **Save Webhook Settings** button.
    * Disable the webhook, select its **Disable** button and confirm the action. Disabled webhooks have a note at the top to indicate this state.
        - To re-enable the disabled webhook, select its **Enable** button.
    * Delete the webhook, select its **Delete** button and confirm the action. The webhook is removed from the **Notification Services** page.

## Request logs

The last 20 webhook request and responses are saved, so you can debug and inspect your webhook. Each webhook's request logs are available on the bottom of their settings page.
