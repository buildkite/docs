# OAuth device authorization

[OAuth 2.0 Device Authorization Grant](https://datatracker.ietf.org/doc/html/rfc8628) (RFC 8628) lets applications running in environments without browser access (such as SSH sessions, remote development environments, or constrained devices) authenticate with Buildkite. The device requests a code and polls for a token, while the user completes authorization in a browser on any device.

## How it works

```
┌────────────┐  1. POST /oauth/device_authorization  ┌──────────────┐
│            │ ──────────────────────────────────────▶│              │
│   Device   │ ◀──────────────────────────────────────│  Buildkite   │
│            │    device_code + user_code              │              │
│            │                                         └──────────────┘
│            │  2. Display user_code to user
│            │     User visits verification_uri        ┌──────────────┐
│            │     and enters user_code               ▶│   Browser    │
│            │                                         │ (any device) │
│            │                                         └──────────────┘
│            │  3. Poll POST /oauth/token              ┌──────────────┐
│            │ ──────────────────────────────────────▶│              │
│            │ ◀──────────────────────────────────────│  Buildkite   │
└────────────┘   access_token (once approved)         └──────────────┘
```

1. **Request** a device code from `POST /oauth/device_authorization`.
1. **Display** the `user_code` to the user and direct them to the `verification_uri` to enter the code and authorize the application in a browser.
1. **Poll** `POST /oauth/token` with the `device_code` at the specified interval until the user approves, denies, or the code expires.

## Device authorization request

Request a device code by sending a `POST` request to the device authorization endpoint:

Endpoint: `POST https://buildkite.com/oauth/device_authorization`

```
POST /oauth/device_authorization HTTP/1.1
Host: buildkite.com
Content-Type: application/x-www-form-urlencoded

client_id=your-client-id
&scope=read_user read_organizations
```

### Request parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `client_id` | Yes | The client ID of your OAuth application |
| `scope` | Yes | Space-delimited list of [scopes](/docs/apis/managing-api-tokens#token-scopes). At least one valid scope is required |
| `client_secret` | Conditional | Required for confidential clients. Not required for public clients |

### Response

A successful response returns a JSON object:

```json
{
  "device_code": "GmRhmhcxfnZfIQFAcZx7VFMylYeXPOO5",
  "user_code": "BCDF-GHJK",
  "verification_uri": "https://buildkite.com/oauth/device",
  "verification_uri_complete": "https://buildkite.com/oauth/device/BCDF-GHJK",
  "expires_in": 600,
  "interval": 5
}
```

| Field | Description |
|-------|-------------|
| `device_code` | The device verification code used to poll the token endpoint |
| `user_code` | The user-facing code displayed to the user, formatted as `XXXX-XXXX` |
| `verification_uri` | The URL where the user enters the code |
| `verification_uri_complete` | The full verification URL with the code pre-filled |
| `expires_in` | Seconds until the codes expire (600 seconds, that is, 10 minutes) |
| `interval` | Minimum seconds between polling requests (starts at 5 seconds) |

## User authorization

Direct the user to the `verification_uri` (`https://buildkite.com/oauth/device`) to enter the `user_code`. Alternatively, send them directly to `verification_uri_complete`, which pre-fills the code.

The user:

1. Enters the code (when using `verification_uri`).
1. Reviews the application name and requested scopes.
1. Selects a Buildkite organization to authorize.
1. Approves or denies the request.

## Token request

While the user completes authorization, poll the token endpoint using the `device_code`:

Endpoint: `POST https://buildkite.com/oauth/token`

```
POST /oauth/token HTTP/1.1
Host: buildkite.com
Content-Type: application/x-www-form-urlencoded

grant_type=urn:ietf:params:oauth:grant-type:device_code
&client_id=your-client-id
&device_code=GmRhmhcxfnZfIQFAcZx7VFMylYeXPOO5
```

### Request parameters

<!-- vale Buildkite.existence = NO -->

| Parameter | Required | Description |
|-----------|----------|-------------|
| `grant_type` | Yes | Must be `urn:ietf:params:oauth:grant-type:device_code` |
| `client_id` | Yes | The client ID of your OAuth application |
| `device_code` | Yes | The `device_code` from the device authorization response |

<!-- vale Buildkite.existence = YES -->

### Successful response

Once the user approves the request, the token endpoint returns:

```json
{
  "access_token": "bkua_...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "refresh_token": "...",
  "scope": "read_user read_organizations"
}
```

Use the `access_token` value in the `Authorization` header for API requests:

```
Authorization: Bearer bkua_...
```

## Polling errors

While waiting for user approval, the token endpoint returns error responses until the user acts. Poll at the interval specified in the device authorization response and handle these errors:

| `error` | Description | Action |
|---------|-------------|--------|
| `authorization_pending` | The user has not yet approved or denied the request | Continue polling at the current interval |
| `slow_down` | Polling too frequently | Increase the polling interval by 5 seconds and continue polling |
| `access_denied` | The user denied the authorization request | Stop polling and inform the user |
| `expired_token` | The device code has expired | Stop polling. Request a new device code to restart the flow |
| `invalid_grant` | The device code is invalid or has already been used | Stop polling |

> 📘
> The initial polling interval is 5 seconds. Each `slow_down` response increases the required interval by 5 seconds. Respect the interval to avoid repeated `slow_down` responses.

## Available scopes

Device authorization tokens support the same scopes as [Buildkite API access tokens](/docs/apis/managing-api-tokens#token-scopes).

## Troubleshooting

The device authorization and token endpoints return error responses with an `error` code and optional `error_description`:

```json
{
  "error": "invalid_client"
}
```

### Common errors

| `error` | Fix |
|---------|-----|
| `invalid_client` | Check that the `client_id` is correct and the application is enabled. Confidential clients must also provide a valid `client_secret` |
| `invalid_scope` | Ensure all requested scopes are valid. An empty or missing `scope` parameter is rejected |
| `server_error` | The device authorization service is temporarily unavailable. Retry later |
