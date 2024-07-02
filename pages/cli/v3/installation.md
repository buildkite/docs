# Buildkite CLI Installation

The CLI can be installed on the following platforms:

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

Install the CLI:

```sh
sudo apt update && sudo apt install -y bk
```

## Red Hat/CentOS

Configure the registry:

```sh
echo -e "[cli-rpm]\nname=Buildkite CLI\nbaseurl=https://packages.buildkite.com/buildkite/cli-rpm/rpm_any/rpm_any/\$basearch\nenabled=1\nrepo_gpgcheck=1\ngpgcheck=0\ngpgkey=https://packages.buildkite.com/buildkite/cli-rpm/gpgkey\npriority=1" | sudo tee /etc/yum.repos.d/cli-rpm.repo
```

Then, install the CLI:

```sh
sudo dnf install -y bk
```

## macOS

The CLI is packaged into the Buildkite homebrew tap. To install, run:

```sh
brew install buildkite/buildkite/bk@3
```

## Windows



## Manual installation

If your system is not listed above, you can can manually install a binary from the [CLI releases page](https://github.com/buildkite/cli/releases).
