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
