# Installing the Buildkite Agent

The Buildkite agent runs on your own machine, whether it's a VPS, server, desktop computer, embedded device. There are installers for:

<% AgentInstallers.each do |installer| %>
* [<%= installer[:title] %>](<%= docs_page_path installer[:url] %>)<% end %>

Alternatively you can install it manually using the instructions below.

## Manual installation

If you need to install the agent on a system not listed above you'll need to perform a manual installation using one of the binaries from [buildkite-agent's releases page](https://github.com/buildkite/agent/releases).


Once you have a binary, create `bin` and `builds` directories in `~/.buildkite-agent` and copy the binary and `bootstrap.sh` file into place:


```bash
mkdir ~/.buildkite-agent ~/.buildkite-agent/bin ~/.buildkite-agent/builds
cp buildkite-agent ~/.buildkite-agent/bin
cp bootstrap.sh ~/.buildkite-agent/bootstrap.sh
```

You should now be able to start the agent:

```bash
buildkite-agent start --help
```

If your architecture isn't on the releases page send an email to support and we'll help you out, or check out the [buildkite-agent's README](https://github.com/buildkite/agent?tab=readme-ov-file#installing) for instructions on how to compile it yourself.

## Upgrade agents

To upgrade your agents, you can either:

* Use the package manager for your operating system.
* Re-run the installation script.

As long as you're using Agent v3 or later, no configuration changes are necessary.
