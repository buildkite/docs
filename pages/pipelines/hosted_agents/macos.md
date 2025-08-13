# macOS hosted agents

macOS instances for Buildkite hosted agents are only offered with [Apple silicon](https://en.wikipedia.org/wiki/Apple_silicon) architecture. Please contact support if you have specific needs for Intel machines.

To accommodate different workloads, instances are capable of running up to 4 hours. If you require longer running agents, please contact support at support@buildkite.com.

## Sizes

Buildkite offers a selection of macOS instance types (each based on a different size combination of virtual CPU power and memory capacity, known as an _instance shape_), allowing you to tailor your hosted agents' resources to the demands of your jobs.

<%= render_markdown partial: 'shared/hosted_agents/hosted_agents_instance_shape_table_mac' %>

## macOS instance software support

All standard macOS [Sequoia](#macos-sequoia) and [Sonoma](#macos-sonoma) version instances have their own respective Xcode and runtime software versions available by default (listed below). For both of these macOS versions, the [Homebrew packages](#homebrew-packages) and their versions (listed further down) are also available. If you have specific requirements for software that is not listed here, please contact support.

Updated Xcode versions will be available one week after Apple offers them for download. This includes Beta, Release Candidate (RC), and official release versions.

## macOS Sequoia

- 15.4.1

### Xcode

- 16.3
- 16.2
- 16.1
- 16.0
- 15.4

### Runtimes

#### iOS

- 18.4 RC
- 18.2 RC
- 18.1
- 18.0
- 17.5
- 16.4
- 15.5

#### tvOS

- 18.4 RC
- 18.2 RC
- 18.1
- 18.0
- 17.5
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
- 9.4

## macOS Sonoma

- 14.6.1

### Xcode

- 16.3-RC2
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

<table>
  <tr>
    <th>Package</th>
    <th>Version</th>
  </tr>
  <tr>
    <td>ant</td>
    <td>1.10.15_1</td>
  </tr>
  <tr>
    <td>applesimutils</td>
    <td>0.9.12</td>
  </tr>
  <tr>
    <td>aria2</td>
    <td>1.37.0</td>
  </tr>
  <tr>
    <td>awscli</td>
    <td>2.25.49</td>
  </tr>
  <tr>
    <td>azcopy</td>
    <td>10.29.1</td>
  </tr>
  <tr>
    <td>azure-cli</td>
    <td>2.75.0</td>
  </tr>
  <tr>
    <td>bazelisk</td>
    <td>1.26.0</td>
  </tr>
  <tr>
    <td>bicep</td>
    <td>0.36.177</td>
  </tr>
  <tr>
    <td>carthage</td>
    <td>0.40.0</td>
  </tr>
  <tr>
    <td>cmake</td>
    <td>4.0.3</td>
  </tr>
  <tr>
    <td>cocoapods</td>
    <td>1.16.2_1</td>
  </tr>
  <tr>
    <td>codeql</td>
    <td>2.21.4</td>
  </tr>
  <tr>
    <td>curl</td>
    <td>8.14.1</td>
  </tr>
  <tr>
    <td>deno</td>
    <td>2.4.1</td>
  </tr>
  <tr>
    <td>docker</td>
    <td>28.3.0</td>
  </tr>
  <tr>
    <td>fastlane</td>
    <td>2.228.0</td>
  </tr>
  <tr>
    <td>gcc@13</td>
    <td>13.4.0</td>
  </tr>
  <tr>
    <td>gh</td>
    <td>2.74.2</td>
  </tr>
  <tr>
    <td>git</td>
    <td>2.50.1</td>
  </tr>
  <tr>
    <td>git-lfs</td>
    <td>3.7.0</td>
  </tr>
  <tr>
    <td>gmp</td>
    <td>6.3.0</td>
  </tr>
  <tr>
    <td>gnu-tar</td>
    <td>1.35</td>
  </tr>
  <tr>
    <td>gnupg</td>
    <td>2.4.8</td>
  </tr>
  <tr>
    <td>go</td>
    <td>1.24.5</td>
  </tr>
  <tr>
    <td>gradle</td>
    <td>8.14.3</td>
  </tr>
  <tr>
    <td>httpd</td>
    <td>2.4.63</td>
  </tr>
  <tr>
    <td>jq</td>
    <td>1.8.1</td>
  </tr>
  <tr>
    <td>kotlin</td>
    <td>2.2.0</td>
  </tr>
  <tr>
    <td>libpq</td>
    <td>17.5</td>
  </tr>
  <tr>
    <td>llvm@15</td>
    <td>15.0.7</td>
  </tr>
  <tr>
    <td>maven</td>
    <td>3.9.10</td>
  </tr>
  <tr>
    <td>mint</td>
    <td>0.18.0</td>
  </tr>
  <tr>
    <td>nginx</td>
    <td>1.29.0</td>
  </tr>
  <tr>
    <td>node</td>
    <td>24.3.0</td>
  </tr>
  <tr>
    <td>openssl@3</td>
    <td>3.5.1</td>
  </tr>
  <tr>
    <td>p7zip</td>
    <td>17.06</td>
  </tr>
  <tr>
    <td>packer</td>
    <td>1.13.1</td>
  </tr>
  <tr>
    <td>perl</td>
    <td>5.40.2</td>
  </tr>
  <tr>
    <td>php</td>
    <td>8.4.10</td>
  </tr>
  <tr>
    <td>pkgconf</td>
    <td>2.5.1</td>
  </tr>
  <tr>
    <td>postgresql@14</td>
    <td>14.18</td>
  </tr>
  <tr>
    <td>r</td>
    <td>4.5.1</td>
  </tr>
  <tr>
    <td>rbenv</td>
    <td>1.3.2</td>
  </tr>
  <tr>
    <td>rbenv-bundler</td>
    <td>1.0.1</td>
  </tr>
  <tr>
    <td>ruby</td>
    <td>3.4.4</td>
  </tr>
  <tr>
    <td>rust</td>
    <td>1.88.0</td>
  </tr>
  <tr>
    <td>rustup</td>
    <td>1.28.2</td>
  </tr>
  <tr>
    <td>selenium-server</td>
    <td>4.34.0</td>
  </tr>
  <tr>
    <td>swiftformat</td>
    <td>0.56.4</td>
  </tr>
  <tr>
    <td>swiftlint</td>
    <td>0.59.1</td>
  </tr>
  <tr>
    <td>tmux</td>
    <td>3.5a</td>
  </tr>
  <tr>
    <td>unxip</td>
    <td>3.2</td>
  </tr>
  <tr>
    <td>wget</td>
    <td>1.25.0</td>
  </tr>
  <tr>
    <td>xcbeautify</td>
    <td>2.29.0</td>
  </tr>
  <tr>
    <td>xcodes</td>
    <td>1.6.2</td>
  </tr>
  <tr>
    <td>yq</td>
    <td>4.45.4</td>
  </tr>
  <tr>
    <td>zstd</td>
    <td>1.5.7</td>
  </tr>
</table>

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
