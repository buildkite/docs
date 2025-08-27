One of either the [token](#webhook-token) or [signature](#webhook-signature) headers will be present in every webhook request. The token value and header setting can be found under **Token** in your **Webhook Notification** service.

Your selection in the **Webhook Notification** service will determine which is sent:

<table class="fixed-width">
<tbody>
  <tr><th><code>X-Buildkite-Token</code></th><td>The webhook's <a href="#webhook-token">token</a>. <p class="Docs__api-param-eg"><em>Example:</em> <code>309c9c842g8565adecpd7469x6005989</code></p></td></tr>
  <tr><th><code>X-Buildkite-Signature</code></th><td>The <a href="#webhook-signature">signature</a> created from your webhook payload, webhook token, and the SHA-256 hash function.<p class="Docs__api-param-eg"><em>Example:</em> <code>timestamp=1619071700,signature=30222eb518dc3fb61ec9e64dd78d163f62cb134a6ldb768f1d40e0edbn6e43f0</code></p></td></tr>
</tbody>
</table>
