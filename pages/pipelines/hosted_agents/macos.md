# macOS hosted agents

Buildkite's macOS hosted agents are:

- [Buildkite Agents](/docs/agent/v3) hosted by Buildkite that run in a macOS environment.

- Configured as part of a _Buildkite hosted queue_, where the Buildkite hosted agent's machine type is macOS, has a particular [size](#sizes) to efficiently manage jobs with varying requirements, and comes pre-installed with [software](#macos-instance-software-support).

Learn more about:

- Best practices for configuring queues in [How should I structure my queues](/docs/pipelines/clusters#clusters-and-queues-best-practices-how-should-i-structure-my-queues) of the [Clusters overview](/docs/pipelines/clusters), as well as [Manage queues](/docs/pipelines/clusters/manage-queues).

- How to configure a macOS hosted agent in [Create a Buildkite hosted queue](/docs/pipelines/clusters/manage-queues#create-a-buildkite-hosted-queue).

- How to use macOS hosted agents to [build iOS apps](/docs/pipelines/hosted-agents/macos/getting-started-with-ios).

- The [security](#security) of macOS hosted agents.

## Sizes

Buildkite offers a selection of macOS instance types (each based on a different size combination of virtual CPU power and memory capacity, known as an _instance shape_), allowing you to tailor your hosted agents' resources to the demands of your jobs.

<%= render_markdown partial: 'shared/hosted_agents/hosted_agents_instance_shape_table_mac' %>

Also note the following about macOS hosted agent instances.

- Only [Apple silicon](https://en.wikipedia.org/wiki/Apple_silicon) architectures are supported.

- To accommodate different workloads, instances are capable of running up to 4 hours.

If you have specific needs for Intel architecture machines, or longer running hosted agents (over 4 hours), please contact Support at support@buildkite.com.

## Concurrency

macOS hosted agents can operate concurrently when running your Buildkite pipeline jobs.

<%= render_markdown partial: 'pipelines/hosted_agents/hosted_agents_concurrency_explanation' %>

The number of macOS hosted agents (of a [Buildkite hosted queue](/docs/pipelines/clusters/manage-queues#create-a-buildkite-hosted-queue)) that can process your pipeline jobs concurrently is calculated by your Buildkite plan's _maximum combined vCPU_ value divided by your [instance shape's](#sizes) _vCPU_ value. See the [Buildkite pricing](https://buildkite.com/pricing/) page for details on the **Mac M4 Concurrency** that applies to your plan.

For example, if your Buildkite plan provides you with a maximum combined vCPU value is up to 24, and you've configured a Buildkite hosted queue with the `MACOS_ARM64_M4_6X28` (Medium) [instance shape](#sizes), whose vCPU value is 6, then the number of concurrent hosted agents that can run jobs on this queue is 4 (that is, 24 / 6 = 4).

When concurrency limits are exceeded, additional jobs will be queued until sufficient capacity becomes available.

## macOS instance software support

All standard macOS [Tahoe](#macos-tahoe), [Sequoia](#macos-sequoia) and [Sonoma](#macos-sonoma) version instances have their own respective Xcode and runtime software versions available by default (listed below). Each macOS version also has its own set of [Homebrew packages](#homebrew-packages) with specific versions optimized for that operating system. If you have specific requirements for software that is not listed here, please contact Support at support@buildkite.com.

While you currently cannot provide custom base images for macOS hosted agents (as is possible using [agent images](/docs/pipelines/hosted-agents/linux#agent-images) for Linux hosted agents), you do have significant control over these virtual machines during job execution—including the ability to install software using Homebrew, use [git mirroring](/docs/pipelines/hosted-agents/cache-volumes#git-mirror-volumes) for performance, and leverage persistent [cache volumes](/docs/pipelines/hosted-agents/cache-volumes).

Updated Xcode versions will be available one week after Apple offers them for download. This includes Beta, Release Candidate (RC), and official release versions.

## macOS Tahoe

- 26.0

### Xcode

- 26.0
- 16.4

### Runtimes

#### iOS

- 26.0
- 18.6
- 17.5

#### tvOS

- 26.0
- 17.5
- 16.4

#### visionOS

- 26.0
- 2.5
- 1.2

#### watchOS

- 26.0
- 11.5
- 10.5

## macOS Sequoia

- 15.6.1

### Xcode

- 26.0
- 16.4
- 16.3
- 16.2
- 16.1
- 16.0
- 15.4

### Runtimes

#### iOS

- 26.0
- 18.6
- 18.5
- 18.4 RC
- 18.2 RC
- 18.1
- 18.0
- 17.5
- 16.4
- 15.5

#### tvOS

- 26.0
- 18.5
- 18.4 RC
- 18.2 RC
- 18.1
- 18.0
- 17.5
- 16.4

#### visionOS

- 26.0
- 2.5
- 2.4 RC
- 2.2 RC
- 2.1
- 2.0
- 1.2
- 1.1
- 1.0

#### watchOS

- 26.0
- 11.5
- 11.4 RC
- 11.2 RC
- 11.1
- 11.0
- 10.5
- 9.4

## macOS Sonoma

- 14.6.1

### Xcode

- 16.3
- 16.2
- 16.1
- 16.0
- 15.4
- 15.3
- 15.2
- 15.1
- 14.3.1

### Runtimes

#### iOS

- 18.4 RC
- 18.2 RC
- 18.1
- 18.0
- 17.5
- 17.4
- 17.2
- 16.4
- 16.2
- 15.5

#### tvOS

- 18.4 RC
- 18.2 RC
- 18.1
- 18.0
- 17.5
- 17.4
- 17.2
- 16.4

#### visionOS

- 2.4 RC
- 2.2 RC
- 2.1
- 2.0
- 1.2
- 1.1
- 1.0

#### watchOS

- 11.4 RC
- 11.2 RC
- 11.1
- 11.0
- 10.5
- 10.4
- 10.2
- 9.4

## Homebrew packages

The versions for each of these packages varies by macOS version. See [Identifying Homebrew package versions](#homebrew-packages-identifying-homebrew-package-versions) for instructions on how to identify each package's version.

- ant
- applesimutils
- aria2
- awscli
- azcopy
- azure-cli
- bazelisk
- bicep
- carthage
- cmake
- cocoapods
- curl
- deno
- docker
- fastlane
- gcc@13
- gh
- git
- git-lfs
- gmp
- gnu-tar
- gnupg
- go
- gradle
- httpd
- jq
- kotlin
- libpq
- llvm
- llvm@15
- maven
- mint
- nginx
- node
- openssl@3
- p7zip
- packer
- perl
- php
- pkgconf
- postgresql@14
- python<span>@</span>3.13
- r
- rbenv
- rbenv-bundler
- ruby
- rust
- rustup
- selenium-server
- swiftformat
- swiftlint
- tmux
- unxip
- wget
- xcbeautify
- xcodes
- yq
- zstd

### Identifying Homebrew package versions

To find the [Homebrew package](#homebrew-packages) version used by your macOS hosted agent:

1. Select **Agents** in the global navigation > your [cluster](/docs/pipelines/clusters/manage-clusters) containing the [macOS Buildkite hosted agent queue](/docs/pipelines/clusters/manage-queues) > your macOS hosted agent.
1. On your macOS hosted agent's page, select **Base image** and scroll down to **Specifications** > **Homebrew packages** to view these packages, along with their respective versions.

## Security

<%= render_markdown partial: 'pipelines/hosted_agents/hosted_agents_security_explanation' %>

Note that for macOS hosted agents, virtualization is achieved through Apple's Virtualization framework on Apple Silicon, providing lightweight but secure virtual machine isolation. Learn more about [How Buildkite hosted agents work](/docs/pipelines/hosted-agents#how-buildkite-hosted-agents-work).

## Git mirror cache

The Git mirror cache is a specialized type of cache volume designed to accelerate Git operations by caching the Git repository between builds. This is useful for large repositories that are slow to clone.

These volumes are attached on a best-effort basis depending on their locality, expiration and current usage, and therefore, should not be relied upon as durable data storage. By default, a Git mirror cache is created for each repository.

### Enabling Git mirror cache

To enable Git mirror cache for your hosted agents:

1. Select **Agents** in the global navigation to access the **Clusters** page.
1. Select the cluster in which to enable the Git mirror cache feature.
1. Select **Cache Storage**, then select the **Settings** tab.
1. Select **Enable Git mirror**, then select **Save cache settings** to enable Git mirrors for the selected hosted cluster.

Once enabled, the Git mirror cache will be used for all hosted jobs using Git repositories in that cluster. A separate cache volume will be created for each repository.

<%= image "hosted-agents-git-mirror.png", width: 1760, height: 436, alt: "Hosted agents git mirror setting displayed in the Buildkite UI" %>

### Deleting Git mirror cache

Deleting a cache volume may affect the build time for the associated pipelines until the new cache is established.

To delete a git mirror cache:

1. Select **Agents** in the global navigation to access the **Clusters** page.
1. Select the cluster whose Git mirror cache is to be deleted.
1. Select **Cache Storage**, then select the **Volumes** tab to view a list of all exiting cache volumes.
1. Select **Delete** for the Git mirror cache volume you wish to remove.
1. Confirm the deletion by selecting **Delete Cache Volume**.
