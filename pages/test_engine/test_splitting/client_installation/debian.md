# Installing Buildkite Test Engine Client on Debian

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
