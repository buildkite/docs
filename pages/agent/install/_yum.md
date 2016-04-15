Firstly, add our yum repository for your architecture (to find your arch run `uname -m`).

For 64-bit (x86_64):

```shell
sudo sh -c 'echo -e "[buildkite-agent]\nname = Buildkite Pty Ltd\nbaseurl = https://yum.buildkite.com/buildkite-agent/stable/x86_64/\nenabled=1\ngpgcheck=0\npriority=1" > /etc/yum.repos.d/buildkite-agent.repo'
```

For 32-bit (i386):

```shell
sudo sh -c 'echo -e "[buildkite-agent]\nname = Buildkite Pty Ltd\nbaseurl = https://yum.buildkite.com/buildkite-agent/stable/i386/\nenabled=1\ngpgcheck=0\npriority=1" > /etc/yum.repos.d/buildkite-agent.repo'
```

Then, install the agent:

```shell
sudo yum -y install buildkite-agent
```

Configure your agent token:

```shell
sudo sed -i "s/xxx/<%= token %>/g" /etc/buildkite-agent/buildkite-agent.cfg
```

<div class="Docs__note">
<em>Note: There's currently an issue installing the package onto Amazon Linux AMI distributions. See this GitHub issue for more information: <a href="https://github.com/buildkite/agent/issues/234">https://github.com/buildkite/agent/issues/234</a></em>
</div>

And then start the agent:

```shell
sudo systemctl enable buildkite-agent && sudo systemctl start buildkite-agent
```

You can view the logs at:

```shell
sudo tail -f /var/log/messages
```
