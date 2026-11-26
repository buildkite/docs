# Organization spend alert API

Retrieve an organization's [spend alert](/docs/platform/spend-alerts) settings, status, and latest invoice estimate.

## Get the organization's spend alert

Requires the `read_spend_alerts` [token scope](/docs/apis/managing-api-tokens#token-scopes) and billing permissions for the organization. If the API isn't available to the organization, the endpoint returns `404 Not Found`.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  "https://api.buildkite.com/v2/organizations/{org.slug}/billing/spend-alert"
```

Success response: `200 OK`. This example shows an enabled alert that has reached its threshold.

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

The endpoint returns the estimate from the latest periodic check, not a fresh calculation. `latest_estimate` and `latest_estimate_checked_at` are `null` until an enabled alert has been checked in the current billing period.
