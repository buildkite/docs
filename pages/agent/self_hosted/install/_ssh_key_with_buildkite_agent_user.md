For GitHub repositories, you can use [Buildkite-managed GitHub App tokens](/docs/agent/self-hosted/code-access#using-a-buildkite-issued-github-app-token) instead of installing SSH keys. Enable token checkout on your self-hosted queue to retrieve temporary, read-only credentials automatically.

SSH keys should be copied to (or generated into) `/var/lib/buildkite-agent/.ssh/`. For example, to generate a new private key which you can add to your source code host:

```bash
$ sudo su buildkite-agent
$ mkdir -p ~/.ssh && cd ~/.ssh
$ ssh-keygen -t ed25519 -C "build@myorg.com"
```
