# Organization spend alert API

The organization spend alert API lets you retrieve the status of a Buildkite organization's [spend alert](/docs/platform/spend-alerts): whether it's eligible, its threshold, whether the threshold is reached, and the latest invoice estimate.

> 📘 Required permissions
> This endpoint requires the `read_spend_alerts` [access token scope](/docs/apis/managing-api-tokens#token-scopes), and the authenticated user must be a Buildkite organization administrator with billing permissions (the same access required to manage the spend alert on the **Billing** settings page). The endpoint also requires [spend alerts](/docs/platform/spend-alerts) to be enabled for your organization. Otherwise, it returns `404 Not Found`.

## Get the organization's spend alert

```bash
curl -H "Authorization: Bearer $TOKEN" \
  "https://api.buildkite.com/v2/organizations/{org.slug}/billing/spend-alert"
```

A Pro plan organization with an enabled alert that has reached its threshold:

```json
{
  "eligible": true,
  "enabled": true,
  "effective_at": null,
  "threshold": { "amount": "200.00", "currency": "USD" },
  "threshold_reached": true,
  "current_period": { "starts_at": "2026-11-06T00:00:00.000Z", "ends_at": "2026-12-05T23:59:59.999Z" },
  "latest_estimate": { "amount": "236.50", "currency": "USD" },
  "latest_estimate_checked_at": "2026-11-20T09:00:00.000Z"
}
```

An organization that isn't eligible for spend alerts, such as one on the Free or Enterprise plan, or in a trial:

```json
{
  "eligible": false,
  "enabled": false,
  "effective_at": null,
  "threshold": null,
  "threshold_reached": false,
  "current_period": null,
  "latest_estimate": null,
  "latest_estimate_checked_at": null
}
```

A Pro plan organization with no alert set up returns the same shape as an eligible organization, with `enabled` set to `false` and `threshold` and `latest_estimate` set to `null`.

An organization with an alert scheduled to start when a pending plan change takes effect, such as an Enterprise organization moving to Pro:

```json
{
  "eligible": false,
  "enabled": false,
  "effective_at": "2027-01-01T00:00:00.000Z",
  "threshold": { "amount": "150.00", "currency": "USD" },
  "threshold_reached": false,
  "current_period": null,
  "latest_estimate": null,
  "latest_estimate_checked_at": null
}
```

Required scope: `read_spend_alerts`

Success response: `200 OK`

### Response fields

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>eligible</code></th>
    <td>Whether the organization is eligible for a spend alert, for example, a monthly Pro plan that renews automatically.</td>
  </tr>
  <tr>
    <th><code>enabled</code></th>
    <td>Whether a live spend alert is turned on. This is <code>false</code> while a scheduled alert's <code>effective_at</code> date hasn't arrived, or while the organization isn't eligible.</td>
  </tr>
  <tr>
    <th><code>effective_at</code></th>
    <td>ISO 8601 timestamp of when a spend alert scheduled by a pending plan change starts. <code>null</code> for a live alert, or when no alert is scheduled.</td>
  </tr>
  <tr>
    <th><code>threshold</code></th>
    <td>The invoice threshold that triggers the alert, as an <code>amount</code> decimal string and <code>currency</code>. <code>null</code> if no alert is set up.</td>
  </tr>
  <tr>
    <th><code>threshold_reached</code></th>
    <td>Whether the latest estimate has reached the threshold for a live, enabled alert.</td>
  </tr>
  <tr>
    <th><code>current_period</code></th>
    <td>The organization's current billing period, with <code>starts_at</code> and <code>ends_at</code> ISO 8601 timestamps. <code>null</code> when the organization isn't eligible for a spend alert.</td>
  </tr>
  <tr>
    <th><code>latest_estimate</code></th>
    <td>The next-invoice estimate from the periodic spend alert check, as an <code>amount</code> decimal string and <code>currency</code>. This check runs every three hours, and again after the alert is edited. <code>null</code> until a live alert has been checked in the current billing period.</td>
  </tr>
  <tr>
    <th><code>latest_estimate_checked_at</code></th>
    <td>ISO 8601 timestamp of when <code>latest_estimate</code> was calculated. <code>null</code> when <code>latest_estimate</code> is <code>null</code>.</td>
  </tr>
</tbody>
</table>

### Error responses

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>403 Forbidden</code></th>
    <td>The token does not have the <code>read_spend_alerts</code> scope, or the authenticated user does not have billing permissions for the organization.</td>
  </tr>
  <tr>
    <th><code>404 Not Found</code></th>
    <td>Spend alerts are not enabled for the organization, or the organization does not exist or is not accessible with this token.</td>
  </tr>
</tbody>
</table>
