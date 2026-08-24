To override specific directives from the `buildkite-agent.service` systemd unit file, implement these configurations using the _drop-in_ directory `/etc/systemd/system/buildkite-agent.service.d`. Within this directory, any files ending with `.conf` are merged in alphanumeric order and parsed after the main `buildkite-agent.service` unit file. Therefore, these `*.conf` files can be used to override or extend the directives of the `buildkite-agent.service` systemd unit file.

The following `.conf` file example overrides the operating system user account running the `buildkite-agent` service, and the environment variable for `HOME`:

```conf
[Service]
# Run the buildite-agent service as a different user:
User=my-service-account
# Change the environment variable for HOME:
Environment=HOME=/opt/my-service-account
```
{: codeblock-file="/etc/systemd/system/buildkite-agent.service.d/change-service-user.conf"}

The Buildkite agent also supports the systemd watchdog mechanism (available since agent version 4.0.0-beta.16). Enable it by setting `WatchdogSec` in a drop-in configuration file:

```conf
[Service]
WatchdogSec=30s
```
{: codeblock-file="/etc/systemd/system/buildkite-agent.service.d/watchdog.conf"}

Once configured, the agent notifies systemd at half the configured interval while its workers are healthy and successfully contacting Buildkite. If a worker fails, or stops successfully contacting Buildkite, the agent stops sending notifications so that systemd can take the configured recovery action, such as restarting the service. The watchdog remains inactive unless `WatchdogSec` is set.
