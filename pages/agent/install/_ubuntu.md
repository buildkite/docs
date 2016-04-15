First, add our signed apt repository:

```shell
sudo sh -c 'echo deb https://apt.buildkite.com/buildkite-agent stable main > /etc/apt/sources.list.d/buildkite-agent.list'
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 32A37959C2FA5C3C99EFBC32A79206696452D198
```

Then install the agent:

```shell
sudo apt-get update && sudo apt-get install -y buildkite-agent
```

Then configure your agent token:

```shell
sudo sed -i "s/xxx/<%= token %>/g" /etc/buildkite-agent/buildkite-agent.cfg
```

And then start the agent:

```shell
# If upstart is installed (14.04 and below)
sudo service buildkite-agent start

# If systemd is installed (15.04 and above)
sudo systemctl enable buildkite-agent && sudo systemctl start buildkite-agent
```

You can view the logs at:

```shell
# If upstart is installed (14.04 and below)
tail -f /var/log/upstart/buildkite-agent.log

# If systemd is installed (15.04 and above)
tail -f /var/log/syslog | grep buildkite-agent
```
