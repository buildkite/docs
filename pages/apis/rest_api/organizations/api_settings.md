# API settings

The API settings endpoints let you read and update an organization's API security settings, mirroring the **Security > API settings** page in the Buildkite UI.

These endpoints require a `read_organization_settings` or `write_organization_settings` [access token scope](/docs/apis/managing-api-tokens#token-scopes), and the authenticated user must be a Buildkite organization administrator.

## Get API settings

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/api-settings"
```

```json
{
  "url": "https://api.buildkite.com/v2/organizations/acme-inc/api-settings",
  "allowed_ip_addresses": "192.0.2.0/24 198.51.100.0/24",
  "revoke_inactive_tokens_after_days": 90,
  "restrict_user_api_token_creation": false,
  "features": {
    "api_ip_allow_list": true,
    "inactive_api_token_revocation": true
  }
}
```

Required scope: `read_organization_settings`

Success response: `200 OK`

Error responses:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>403 Forbidden</code></th>
    <td>The token does not have the <code>read_organization_settings</code> scope, or the authenticated user is not an organization administrator.</td>
  </tr>
</tbody>
</table>

## Update API settings

Updates one or more API security settings for the organization. Include only the fields you want to change. The response contains the full updated settings.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -X PATCH "https://api.buildkite.com/v2/organizations/{org.slug}/api-settings" \
  -d '{
    "allowed_ip_addresses": "192.0.2.0/24 198.51.100.0/24",
    "revoke_inactive_tokens_after_days": 90,
    "restrict_user_api_token_creation": true
  }'
```

```json
{
  "url": "https://api.buildkite.com/v2/organizations/acme-inc/api-settings",
  "allowed_ip_addresses": "192.0.2.0/24 198.51.100.0/24",
  "revoke_inactive_tokens_after_days": 90,
  "restrict_user_api_token_creation": true,
  "features": {
    "api_ip_allow_list": true,
    "inactive_api_token_revocation": true
  }
}
```

Required scope: `write_organization_settings`

Success response: `200 OK`

Error responses:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>403 Forbidden</code></th>
    <td>The token does not have the <code>write_organization_settings</code> scope, the authenticated user is not an organization administrator, or the organization's plan does not include the requested plan-gated feature.</td>
  </tr>
  <tr>
    <th><code>422 Unprocessable Entity</code></th>
    <td>A field value failed validation—for example, an IP address not in CIDR notation, a revocation period not in the set of allowed values, or a non-boolean value for <code>restrict_user_api_token_creation</code>.</td>
  </tr>
</tbody>
</table>

## Request fields

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>allowed_ip_addresses</code></th>
    <td>A space-separated string of CIDR ranges that are permitted to make API requests for this organization. Pass <code>null</code> to remove the allowlist. Requires the API IP allowlist plan feature; returns <code>403</code> if the organization is not entitled.</td>
  </tr>
  <tr>
    <th><code>revoke_inactive_tokens_after_days</code></th>
    <td>Automatically revokes API tokens that have been inactive for the specified number of days. Accepted values are <code>30</code>, <code>60</code>, <code>90</code>, <code>180</code>, and <code>365</code>. Pass <code>null</code> to disable automatic revocation. Requires the inactive API token revocation plan feature; returns <code>403</code> if the organization is not entitled.</td>
  </tr>
  <tr>
    <th><code>restrict_user_api_token_creation</code></th>
    <td>When <code>true</code>, only organization administrators can create API access tokens. Accepts <code>true</code> or <code>false</code>.</td>
  </tr>
</tbody>
</table>

## Response fields

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>url</code></th>
    <td>The canonical API URL for this resource.</td>
  </tr>
  <tr>
    <th><code>allowed_ip_addresses</code></th>
    <td>The current IP allowlist as a space-separated string of CIDR ranges, or <code>null</code> if no allowlist is configured.</td>
  </tr>
  <tr>
    <th><code>revoke_inactive_tokens_after_days</code></th>
    <td>The number of days of inactivity after which API tokens are automatically revoked, or <code>null</code> if automatic revocation is not configured.</td>
  </tr>
  <tr>
    <th><code>restrict_user_api_token_creation</code></th>
    <td>Whether non-administrator users are prevented from creating API access tokens.</td>
  </tr>
  <tr>
    <th><code>features</code></th>
    <td>A map of plan-gated features for this organization. Each key corresponds to a feature (<code>api_ip_allow_list</code>, <code>inactive_api_token_revocation</code>) and its value is <code>true</code> if the feature is available on the organization's plan, or <code>false</code> if it is not. Use this to distinguish between a setting being configured off and the feature not being available on the plan.</td>
  </tr>
</tbody>
</table>

> 🚧 IP allowlist self-lockout
> The IP allowlist takes effect immediately. If you write a CIDR range that does not include your own IP address, your next API request will be rejected. There is no dry-run mode. This matches the behavior of the UI.
