# macOS hosted agents

Buildkite's macOS hosted agents are:

- [Buildkite agents](/docs/agent) hosted by Buildkite that run in a macOS environment.

- Configured as part of a _Buildkite hosted queue_, where the Buildkite hosted agent's machine type is macOS, has a particular [size](#sizes) to efficiently manage jobs with varying requirements, and comes pre-installed with [software](#macos-instance-software-support).

> 📘 Pro and Enterprise plan feature
> Buildkite macOS hosted agents are only available to Buildkite customers on [Pro or Enterprise](https://buildkite.com/pricing) plans.

Learn more about:

- Best practices for configuring queues in [How should I structure my queues](/docs/pipelines/security/clusters#clusters-and-queues-best-practices-how-should-i-structure-my-queues) of the [Clusters overview](/docs/pipelines/security/clusters), as well as [Manage queues](/docs/agent/queues/managing).

- How to configure a macOS hosted agent in [Create a Buildkite hosted queue](/docs/agent/queues/managing#create-a-buildkite-hosted-queue).

- How to use macOS hosted agents to [build iOS apps](/docs/agent/buildkite-hosted/macos/getting-started-with-ios).

- How to interactively debug a running job using [terminal access](/docs/agent/buildkite-hosted/terminal-access) or browser-based [desktop access](/docs/agent/buildkite-hosted/desktop-access).

- The [concurrency](#concurrency) and [security](#security) of macOS hosted agents.

- The [versioned queues](#versioned-queues) pre-provisioned for new organizations, which pin a specific macOS version.

## Sizes

Buildkite offers a selection of macOS instance types (each based on a different size combination of virtual CPU power and memory capacity, known as an _instance shape_), allowing you to tailor your hosted agents' resources to the demands of your jobs.

<%= render_markdown partial: 'shared/buildkite_hosted_agents/instance_shape_table_mac' %>

Also note the following about macOS hosted agent instances.

- Only [Apple silicon](https://en.wikipedia.org/wiki/Apple_silicon) architectures are supported.

- To accommodate different workloads, instances are capable of running up to 4 hours.

If you have specific needs for longer running hosted agents (over 4 hours), please contact Support at support@buildkite.com.

## Versioned queues

New Buildkite organizations are pre-provisioned with the following macOS hosted queues, in addition to `macos-medium` and `macos-large`:

Queue             | macOS version
----------------- | ----------------
`macos-14-medium` | Sonoma (14)
`macos-15-medium` | Sequoia (15)
`macos-26-medium` | Tahoe (26)
`macos-27-medium` | Golden Gate (27)
{: class="responsive-table"}

Each of these queues uses the `MACOS_ARM64_M4_6X28` (Medium) [instance shape](#sizes) and pins its base image to the listed macOS version. This is different from queues without an explicit version, such as `macos-medium`, which use a default image. See the [image explorer](https://buildkite.com/platform/pipelines/hosting-options/mac-hosted-agents/images/) for the software included in each version. GitHub Actions-style `macos-<version>` runner labels map to these queues. Route a job to the macOS version it expects by [targeting the matching queue](/docs/agent/queues#targeting-a-queue-from-a-pipeline) in your pipeline.

New macOS hosted queues without an explicitly selected macOS or Xcode version default to macOS Tahoe (26.6) with Xcode 26.6. This includes queues you create and the `macos-medium` and `macos-large` queues created automatically for new Buildkite organizations. You can change this default at any time in the queue's **Base image** settings.

## Concurrency

macOS hosted agents can operate concurrently when running your Buildkite pipeline jobs.

<%= render_markdown partial: 'agent/buildkite_hosted/hosted_agents_concurrency_explanation' %>

The number of macOS hosted agents (of a [Buildkite hosted queue](/docs/agent/queues/managing#create-a-buildkite-hosted-queue)) that can process your pipeline jobs concurrently is calculated by your Buildkite plan's _maximum combined vCPU_ value divided by your [instance shape's](#sizes) _vCPU_ value. See the [Buildkite pricing](https://buildkite.com/pricing/) page for details on the **Mac M4 Concurrency** that applies to your plan.

For example, if your Buildkite plan provides you with a maximum combined vCPU value is up to 24, and you've configured a Buildkite hosted queue with the `MACOS_ARM64_M4_6X28` (Medium) [instance shape](#sizes), whose vCPU value is 6, then the number of concurrent hosted agents that can run jobs on this queue is 4 (that is, 24 / 6 = 4).

When concurrency limits are exceeded, additional jobs will be queued until sufficient capacity becomes available.

## macOS instance software support

Each macOS base image includes a set of Xcode versions, simulator runtimes (for iOS, tvOS, visionOS, and watchOS), and [Homebrew packages](#homebrew-packages). The software available varies by macOS version. For the current list of macOS base images and the software included in each one, see the [Mac hosted agent image explorer](https://buildkite.com/platform/pipelines/hosting-options/mac-hosted-agents/images/). If you have specific requirements for software that is not included, please contact Buildkite Support at support@buildkite.com.

While you currently cannot provide custom base images for macOS hosted agents (as is possible using [agent images](/docs/agent/buildkite-hosted/linux#agent-images) for Linux hosted agents), you do have significant control over these virtual machines during job execution—including the ability to install software using Homebrew, use [git mirroring](/docs/agent/buildkite-hosted/cache-volumes#git-mirror-volumes) for performance, and use persistent [cache volumes](/docs/agent/buildkite-hosted/cache-volumes).

Updated Xcode versions will be available one week after Apple offers them for download. This includes Beta, Release Candidate (RC), and official release versions.

Older Xcode versions are removed from base images over time. Some older Xcode versions are only available on earlier macOS point releases. They are incompatible with newer base images. Use the [image explorer](https://buildkite.com/platform/pipelines/hosting-options/mac-hosted-agents/images/) to find the macOS base image that includes the Xcode version you need.

If your queue has an Xcode version pinned that is no longer available, a warning is displayed on the queue list and queue settings pages: "Xcode {version} is no longer available for this macOS version. Your agents may fail to start until you update the base image of your queue." To resolve the warning, navigate to the queue's **Base image** settings and select an available Xcode version.

### Docker support

macOS hosted agents include the Docker CLI (through the `docker` and `docker-buildx` [Homebrew packages](#homebrew-packages)), but do not include a running Docker daemon. Commands that require a Docker daemon, such as `docker build` or `docker run`, fail with an error like `Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?` unless the job connects to a Docker daemon that you provide.

To build Docker images, run these jobs on [Linux hosted agents](/docs/agent/buildkite-hosted/linux), which support Docker image builds (including [remote Docker builders](/docs/agent/buildkite-hosted/linux/remote-docker-builders) on the Enterprise plan), or on [self-hosted agents](/docs/agent/self-hosted), where you control the Docker installation.

## Homebrew packages

Each macOS base image comes with a set of Homebrew packages pre-installed, such as `git`, `jq`, `fastlane`, `cocoapods`, and `xcbeautify`. The packages and their versions vary by macOS version. For the full list of packages and versions in each base image, see the [Mac hosted agent image explorer](https://buildkite.com/platform/pipelines/hosting-options/mac-hosted-agents/images/).

### Identifying Homebrew package versions

To find the [Homebrew package](#homebrew-packages) version used by your macOS hosted agent:

1. Select **Agents** in the global navigation > your [cluster](/docs/pipelines/security/clusters/manage) containing the [macOS Buildkite hosted agent queue](/docs/agent/queues/managing) > your macOS hosted agent.
1. On your macOS hosted agent's page, select **Base image** and scroll down to **Specifications** > **Homebrew packages** to view these packages, along with their respective versions.

### Managing Homebrew package versions

Homebrew package versions are periodically updated when macOS hosted agent images are refreshed. If your builds require explicit, repeatable versions, pin the versions you need as part of your pipeline rather than relying on the image defaults.

#### Inspect currently installed packages

To view installed packages and their versions on the agent:

```bash
brew list --versions
brew info <formula>
brew info <formula>@<major>     # when the formula supports versioned installs
```

For example:

```bash
brew list --versions ruby ruby@3.4 rbenv
brew info ruby@3.4
ruby --version
bundler --version
```

#### Use a version manager for language runtimes

For languages that have version managers such as Ruby, pin the language version in your jobs using a version manager rather than relying on the image's installed runtime.

Example using Ruby with `rbenv`, including a cache for installed Ruby versions:

```yaml
steps:
  - label: "Pin Ruby with rbenv"
    command: |
      eval "$(rbenv init -)"
      rbenv install 3.4.7 --skip-existing
      rbenv global 3.4.7
      ruby -v
      gem install bundler
      bundler -v
    cache:
      paths:
        - "~/.rbenv/versions"
      size: 20g
      name: "rbenv-versions"
```

#### Pin dependencies using a Brewfile

Commit a `Brewfile` to your repository and install from it during the build to make Homebrew dependencies explicit and reduce unexpected version changes.

Example `Brewfile`:

```ruby
brew "wget"
brew "jq"
brew "rbenv"
brew "ruby@3.4"
```
{: codeblock-file="Brewfile"}

Pipeline step:

```yaml
steps:
  - label: "Install Homebrew dependencies"
    command: |
      brew update
      brew bundle --file Brewfile
      brew list --versions
```

When a versioned formula is available (for example, `ruby@3.4` or `python@3.12`), use it to pin to a specific major version.

#### Pin an exact formula version

Homebrew does not support installing an arbitrary historical version of every formula. Options for stricter version control include:

- Using a versioned formula when available (for example, `ruby@3.4` or `python@3.12`)
- Using a language or tool version manager (recommended for runtimes)
- Downloading an exact version from upstream release binaries with a pinned URL and checksum

## Security

<%= render_markdown partial: 'agent/buildkite_hosted/hosted_agents_security_explanation' %>

Note that for macOS hosted agents, virtualization is achieved through Apple's Virtualization framework on Apple Silicon, providing lightweight but secure virtual machine isolation. Learn more about [How Buildkite hosted agents work](/docs/agent/buildkite-hosted#how-buildkite-hosted-agents-work).
