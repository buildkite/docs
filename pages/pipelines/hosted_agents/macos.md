# macOS hosted agents

macOS instances for Buildkite hosted agents are only offered with [Apple silicon](https://en.wikipedia.org/wiki/Apple_silicon) architecture. Please contact support if you have specific needs for Intel machines.

To accommodate different workloads, instances are capable of running up to 4 hours. If you require longer running agents, please contact support at support@buildkite.com.

## Sizes

Buildkite offers a selection of macOS instance types (each based on a different size combination of virtual CPU power and memory capacity, known as an _instance shape_), allowing you to tailor your hosted agents' resources to the demands of your jobs.

<%= render_markdown partial: 'shared/hosted_agents/hosted_agents_instance_shape_table_mac' %>

Extra large instances are available on request. Please contact support@buildkite.com to have them enabled for your account.

## macOS instance software support

The following software will be made available by default on all standard macOS instances during the trial. If you have specific requirements for software that is not listed here, please contact support.

Updated Xcode versions will be available one week after Apple offers them for download. This includes Beta, Release Candidate (RC), and official release versions.

### System software

- macOS 14.5
- Darwin Kernel 23.5.0
- Rosetta 2
- Bash 3.2.57
- Homebrew

### Xcode

- Xcode 16.1-Beta
- Xcode 16.0-Beta6
- Xcode 16.0-Beta5
- Xcode 16.0-Beta4
- Xcode 16.0-Beta3
- Xcode 16.0-Beta2
- Xcode 15.4
- Xcode 15.4-Beta
- Xcode 15.3
- Xcode 15.2
- Xcode 15.1
- Xcode 14.3.1

### Apple runtimes

- iOS 15.5
- iOS 16.2
- iOS 16.4
- iOS 17.2
- iOS 17.4
- iOS 17.5-beta2
- iOS 17.5
- iOS 18.0-beta4
- iOS 18.1-beta
- watchOS 9.4
- watchOS 10.2
- watchOS 10.4
- watchOS 10.5
- watchOS 11.0-beta7
- tvOS 16.4
- tvOS 17.2
- tvOS 17.4
- tvOS 17.5
- tvOS 18.0-beta7
- visionOS 1.0
- visionOS 1.1
- visionOS 1.2
- visionOS 2.0-beta7

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
