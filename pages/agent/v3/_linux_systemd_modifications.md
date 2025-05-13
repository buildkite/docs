If you wish to override specific directives from the `buildkite-agent.service` systemd unit file, the correct way to do this is via a "drop-in" directory at `/etc/systemd/system/buildkite-agent.service.d`. Within this directory any files ending with `.conf` will be merged in alphanumeric order and parsed after the main `buildkite-agent.service` unit file. These `*.conf` files can be used to override or extend the directives of the `buildkite-agent.service` systemd unit file.

Example overrides to `User` and environment variable for `HOME`:

```
[Service]
# Run the buildite-agent service as a different user:
User=my-service-account
# Change the environment variable for HOME:
Environment=HOME=/opt/my-service-account
```

{: codeblock-file="/etc/systemd/system/buildkite-agent.service.d/change-service-user.conf"}
