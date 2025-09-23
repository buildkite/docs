A [replay attack](https://en.wikipedia.org/wiki/Replay_attack) is when an attacker intercepts a valid payload and its signature, then re-transmits them. One way to help mitigate such attacks is to send a timestamp with your payload and only accept them within a short window (for example, 5 minutes).

Buildkite sends a timestamp in the `X-Buildkite-Signature` header. The timestamp is part of the signed payload so that it is verified by the signature. An attacker will not be able to change the timestamp without invalidating the signature.

To help protect against a replay attack, upon receipt of a webhook:

1. Verify the signature
1. Check the timestamp against the current time

If the webhook's timestamp is within your chosen window of the current time, it can reasonably be assumed to be the original webhook.
