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
