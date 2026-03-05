SSH keys should be copied to (or generated into) `/var/lib/buildkite-agent/.ssh/`. For example, to generate a new private key which you can add to your source code host:

```bash
$ sudo su buildkite-agent
$ mkdir -p ~/.ssh && cd ~/.ssh
$ ssh-keygen -t rsa -b 4096 -C "build@myorg.com"
```
