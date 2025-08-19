Buildkite can optionally send an HMAC signature in place of a webhook token.

The `X-Buildkite-Signature` header contains a timestamp and an HMAC signature. The timestamp is prefixed by `timestamp=` and the signature is prefixed by `signature=`.

Buildkite generates the signature using HMAC-SHA256; a hash-based message authentication code [HMAC](https://en.wikipedia.org/wiki/HMAC) used with the [SHA-256](https://en.wikipedia.org/wiki/SHA-2) hash function and a secret key. The webhook token value is used as the secret key. The timestamp is an integer representation of a UTC timestamp. The raw request body is the signed message.

The token value and header setting can be found under **Token** in your **Webhook Notification** service.
