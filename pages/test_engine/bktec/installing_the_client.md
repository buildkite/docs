# Installing the Test Engine Client

This page provides instructions on how to install the Test Engine Client ([bktec](https://github.com/buildkite/test-engine-client)) using installers provided by Buildkite.

If you need to install this tool on a system without an installer listed below, you'll need to perform a manual installation using one of the binaries from [Test Engine Client's releases page](https://github.com/buildkite/test-engine-client/releases/latest). Once you have the binary, make it executable in your pipeline.

## Debian

1. Ensure you have curl and gpg installed first:

    ```shell
    apt update && apt install curl gpg -y
    ```

1. Install the registry signing key:

    ```shell
    curl -fsSL "https://packages.buildkite.com/buildkite/test-engine-client-deb/gpgkey" | gpg --dearmor -o /etc/apt/keyrings/buildkite_test-engine-client-deb-archive-keyring.gpg
    ```

1. Configure the registry:

    ```shell
    echo -e "deb [signed-by=/etc/apt/keyrings/buildkite_test-engine-client-deb-archive-keyring.gpg] https://packages.buildkite.com/buildkite/test-engine-client-deb/any/ any main\ndeb-src [signed-by=/etc/apt/keyrings/buildkite_test-engine-client-deb-archive-keyring.gpg] https://packages.buildkite.com/buildkite/test-engine-client-deb/any/ any main" > /etc/apt/sources.list.d/buildkite-buildkite-test-engine-client-deb.list
    ```

1. Install the package:

    ```shell
    apt update && apt install bktec
    ```

## Red Hat

1. Configure the registry:

    ```shell
    echo -e "[test-engine-client-rpm]\nname=Test Engine Client - rpm\nbaseurl=https://packages.buildkite.com/buildkite/test-engine-client-rpm/rpm_any/rpm_any/\$basearch\nenabled=1\nrepo_gpgcheck=1\ngpgcheck=0\ngpgkey=https://packages.buildkite.com/buildkite/test-engine-client-rpm/gpgkey\npriority=1" > /etc/yum.repos.d/test-engine-client-rpm.repo
    ```

2. Install the package:

    ```shell
    dnf install -y bktec
    ```

## macOS

The Test Engine Client can be installed using [Homebrew](https://brew.sh) with [Buildkite tap formulae](https://github.com/buildkite/homebrew-buildkite). To install, run:

```shell
brew tap buildkite/buildkite && brew install buildkite/buildkite/bktec
```

## Docker

You can run the Test Engine Client inside a Docker container using the official image in [Docker Hub](https://hub.docker.com/r/buildkite/test-engine-client/tags).

To run the client using Docker:

```shell
docker run buildkite/test-engine-client
```

Or, to add the Test Engine Client binary to your Docker image, include the following in your Dockerfile:

```dockerfile
COPY --from=buildkite/test-engine-client /usr/local/bin/bktec /usr/local/bin/bktec
```
