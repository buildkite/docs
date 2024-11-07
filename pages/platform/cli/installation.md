# Buildkite CLI installation

The Buildkite CLI can be installed on several platforms.

## Debian/Ubuntu

Ensure you have `curl` and `gpg` installed first:

```sh
sudo apt update && sudo apt install curl gpg -y
```

Install the signing key:

```sh
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

The Buildkite CLI is packaged into the Buildkite [Homebrew](http://brew.sh/) tap. To install, run:

```sh
brew install buildkite/buildkite/bk@3
```

## Windows

1. Download the latest Windows release from the [Buildkite CLI releases](https://github.com/buildkite/cli/releases) page.
2. Extract the files to a folder of your choice.
3. Run `bk.exe` from a command prompt.

> 📘
> The Buildkite CLI can also be installed into Windows Subsystem for Linux (WSL).

## Manual installation

If your system is not listed above, you can manually install a binary from the [Buildkite CLI releases](https://github.com/buildkite/cli/releases) page.
