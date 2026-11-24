# Buildkite CLI installation

The Buildkite CLI can be installed on several platforms.

## Debian/Ubuntu

Ensure you have `curl` and `gpg` installed first:

```sh
sudo apt update && sudo apt install curl gpg -y
```

Install the signing key:

```sh
sudo mkdir -p /etc/apt/keyrings
curl -fsSL "https://packages.buildkite.com/buildkite/cli-deb/gpgkey" | sudo gpg --dearmor -o /etc/apt/keyrings/buildkite_cli-deb-archive-keyring.gpg
```

Configure the registry:

```sh
echo -e "deb [signed-by=/etc/apt/keyrings/buildkite_cli-deb-archive-keyring.gpg] https://packages.buildkite.com/buildkite/cli-deb/any/ any main\ndeb-src [signed-by=/etc/apt/keyrings/buildkite_cli-deb-archive-keyring.gpg] https://packages.buildkite.com/buildkite/cli-deb/any/ any main" | sudo tee /etc/apt/sources.list.d/buildkite-buildkite-cli-deb.list
```

Install the Buildkite CLI:

```sh
sudo apt update && sudo apt install -y bk
```

## Red Hat/CentOS

Configure the registry:

```sh
echo -e "[cli-rpm]\nname=Buildkite CLI\nbaseurl=https://packages.buildkite.com/buildkite/cli-rpm/rpm_any/rpm_any/\$basearch\nenabled=1\nrepo_gpgcheck=1\ngpgcheck=0\ngpgkey=https://packages.buildkite.com/buildkite/cli-rpm/gpgkey\npriority=1" | sudo tee /etc/yum.repos.d/cli-rpm.repo
```

Then, install the Buildkite CLI:

```sh
sudo dnf install -y bk
```

## macOS

The Buildkite CLI is packaged into the Buildkite [Homebrew](http://brew.sh/) tap, which is the recommended approach for installing this CLI tool on macOS as it allows you to use the [Buildkite Homebrew formulae](https://github.com/buildkite/homebrew-buildkite) repository.

To install the Buildkite CLI on macOS, run:

```sh
brew install buildkite/buildkite/bk@3
```

## Windows

1. Download the latest Windows release from the [Buildkite CLI releases](https://github.com/buildkite/cli/releases) page.
1. Extract the files to a folder of your choice.
1. Add that folder to your `PATH`, or run `bk.exe` from that folder.

> 📘
> The Buildkite CLI can also be installed into Windows Subsystem for Linux (WSL).

## Manual installation

If your system is not listed above, you can manually install a binary from the [Buildkite CLI releases](https://github.com/buildkite/cli/releases) page.

Choose the archive for your operating system and architecture. Releases include macOS, Linux, and Windows binaries for AMD64 and ARM64. Extract the archive and put the `bk` binary in a directory on your `PATH`.

## Install with mise

To install with [mise](https://mise.jdx.dev/):

```bash
mise use -g github:buildkite/cli@latest
```

## Verify and authenticate

Check the installed version, then authenticate:

```bash
bk version
bk auth login
```

For device authorization, API tokens, and automation, see [Buildkite CLI configuration](/docs/platform/cli/configuration).

## Update the CLI

For a standalone release-binary installation, run:

```bash
bk update
```

This downloads the latest release for your platform, verifies its checksum, and replaces the binary in place. If Homebrew or mise manages the installation, `bk update` prints instructions for that tool instead:

```bash
brew upgrade buildkite/buildkite/bk@3
# Or, for mise:
mise use -g github:buildkite/cli@latest
```

For Debian/Ubuntu or RPM installations, update `bk` using your system package manager.
