# macOS hosted agents

macOS instances for Buildkite hosted agents are only offered with [Apple silicon](https://en.wikipedia.org/wiki/Apple_silicon) architecture. Please contact support if you have specific needs for Intel machines.

To accommodate different workloads, instances are capable of running up to 4 hours. If you require longer running agents, please contact support at support@buildkite.com.

## Sizes

Buildkite offers a selection of macOS instance types (each based on a different size combination of virtual CPU power and memory capacity, known as an _instance shape_), allowing you to tailor your hosted agents' resources to the demands of your jobs.

<%= render_markdown partial: 'shared/hosted_agents/hosted_agents_instance_shape_table_mac' %>

Extra large instances are available on request. Please contact support@buildkite.com to have them enabled for your account.

## macOS instance software support

All standard macOS [Sequoia](#macos-sequoia) and [Sonoma](#macos-sonoma) instances have their own respective Xcode and runtime software available by default (listed below). For each of these macOS versions, the [Homebrew packages](#homebrew-packages) and their versions (listed further down) are also available. If you have specific requirements for software that is not listed here, please contact support.

Updated Xcode versions will be available one week after Apple offers them for download. This includes Beta, Release Candidate (RC), and official release versions.

## macOS Sequoia

<ul>
  <li>Version: 15.1</li>
</ul>

### Xcode

<ul>
  <li>16.2-RC</li>
  <li>16.2</li>
  <li>16.1</li>
  <li>16.0</li>
  <li>15.4</li>
</ul>

### Runtimes

<ul>
  <li>
    iOS
    <ul>
      <li>18.2 RC</li>
      <li>18.1</li>
      <li>18.0</li>
      <li>17.5</li>
      <li>16.4</li>
      <li>15.5</li>
    </ul>
  </li>
  <li>
    tvOS
    <ul>
      <li>18.2 RC</li>
      <li>18.1</li>
      <li>18.0</li>
      <li>17.5</li>
      <li>16.4</li>
    </ul>
  </li>
  <li>
    visionOS
    <ul>
      <li>2.2 RC</li>
      <li>2.1</li>
      <li>2.0</li>
      <li>1.2</li>
      <li>1.1</li>
      <li>1.0</li>
    </ul>
  </li>
  <li>
    watchOS
    <ul>
      <li>9.4</li>
      <li>11.2 RC</li>
      <li>11.1</li>
      <li>11.0</li>
      <li>10.5</li>
    </ul>
  </li>
</ul>

## macOS Sonoma

<ul>
  <li>Version: 14.6.1</li>
</ul>

### Xcode

<ul>
  <li>16.2-RC</li>
  <li>16.2</li>
  <li>16.1</li>
  <li>16.0</li>
  <li>15.4</li>
  <li>15.3</li>
  <li>15.2</li>
  <li>15.1</li>
  <li>14.3.1</li>
</ul>

### Runtimes

<ul>
  <li>
    iOS
    <ul>
      <li>18.2 RC</li>
      <li>18.1</li>
      <li>18.0</li>
      <li>17.5</li>
      <li>17.4</li>
      <li>17.2</li>
      <li>16.4</li>
      <li>16.2</li>
      <li>15.5</li>
    </ul>
  </li>
  <li>
    tvOS
    <ul>
      <li>18.2 RC</li>
      <li>18.1</li>
      <li>18.0</li>
      <li>17.5</li>
      <li>17.4</li>
      <li>17.2</li>
      <li>16.4</li>
    </ul>
  </li>
  <li>
    visionOS
    <ul>
      <li>2.2 RC</li>
      <li>2.1</li>
      <li>2.0</li>
      <li>1.2</li>
      <li>1.1</li>
      <li>1.0</li>
    </ul>
  </li>
  <li>
    watchOS
    <ul>
      <li>9.4</li>
      <li>11.2 RC</li>
      <li>11.1</li>
      <li>11.0</li>
      <li>10.5</li>
      <li>10.4</li>
      <li>10.2</li>
    </ul>
  </li>
</ul>

## Homebrew packages

<ul>
  <li>ant 1.10.15</li>
  <li>applesimutils 0.9.10</li>
  <li>aria2 1.37.0</li>
  <li>awscli 2.22.17</li>
  <li>azcopy 10.27.1</li>
  <li>azure-cli 2.67.0_1</li>
  <li>bazelisk 1.25.0</li>
  <li>bicep 0.32.4</li>
  <li>carthage 0.40.0</li>
  <li>cmake 3.31.2</li>
  <li>cocoapods 1.16.2</li>
  <li>curl 8.11.1</li>
  <li>deno 2.1.4</li>
  <li>docker 27.4.0</li>
  <li>fastlane 2.226.0</li>
  <li>gcc@13 13.3.0</li>
  <li>gh 2.63.2</li>
  <li>git 2.47.1</li>
  <li>git-lfs 3.6.0</li>
  <li>gmp 6.3.0</li>
  <li>gnu-tar 1.35</li>
  <li>gnupg 2.4.6</li>
  <li>go 1.23.4</li>
  <li>gradle 8.11.1</li>
  <li>httpd 2.4.62</li>
  <li>jq 1.7.1</li>
  <li>kotlin 2.1.0</li>
  <li>libpq 17.2</li>
  <li>llvm@15 15.0.7</li>
  <li>maven 3.9.9</li>
  <li>mint 0.17.5_1</li>
  <li>nginx 1.27.3</li>
  <li>node 23.4.0</li>
  <li>openssl@3 3.4.0</li>
  <li>p7zip 17.05</li>
  <li>packer 1.11.2</li>
  <li>perl 5.40.0</li>
  <li>php 8.4.1_1</li>
  <li>pkgconf 2.3.0_1</li>
  <li>postgresql@14 14.15</li>
  <li>r 4.4.2_2</li>
  <li>rbenv 1.3.0</li>
  <li>rbenv-bundler 1.0.1</li>
  <li>ruby 3.3.6</li>
  <li>rust 1.83.0</li>
  <li>rustup 1.27.1_1</li>
  <li>selenium-server 4.27.0</li>
  <li>swiftformat 0.55.3</li>
  <li>tmux 3.5a</li>
  <li>unxip 3.1</li>
  <li>wget 1.25.0</li>
  <li>xcbeautify 2.16.0</li>
  <li>yq 4.44.6</li>
  <li>zstd 1.5.6</li>
</ul>

<!--
### Other languages and compilers

- GCC 13
- Clang/LLVM 15
- .NET Core SDK 8
- Node 21
- Kotlin 1.9
- OpenJDK 21
- Go 1.21
- Perl 5.38
- PHP 8.3
- Python 3
- Ruby 3.3 & rbenv
- R 4.3
- Rust 1.75

### Development tools

- Git
- Git LFS
- CocoaPods
- Ant
- Maven
- Mint
- Gradle
- Carthage
- CMake
- Yarn
- PNPM
- Bazel
- pkg-config
- xcbeautify
- swiftformat

### Servers

- Apache HTTPD
- NGINX
- Postgres 14.12

### Browser automation

- Safari 17.1
- Chrome 121
- ChromeDriver
- Selenium Server

### Assorted tools

- AWS CLI
- Azure CLI
- gcloud CLI
- CodeQL
- Bicep CLI
- fastlane
- GitHub CLI
- 7-zip
- Aria2
- azcopy
- wget
- GnuPG
- GNU Tar
- jq
- yq
- OpenSSL
- Packer
- zstd
- nsc
- unxip
- PowerShell
- tmux
- Docker CLI
- 1Password CLI
- ns

### Libraries

- libpq
- GMP
-->

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
