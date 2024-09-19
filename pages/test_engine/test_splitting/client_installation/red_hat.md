# Installing Buildkite Test Engine Client on RedHat

1. Configure the registry:

    ```shell
    echo -e "[test-engine-client-rpm]\nname=Test Engine Client - rpm\nbaseurl=https://packages.buildkite.com/buildkite/test-engine-client-rpm/rpm_any/rpm_any/\$basearch\nenabled=1\nrepo_gpgcheck=1\ngpgcheck=0\ngpgkey=https://packages.buildkite.com/buildkite/test-engine-client-rpm/gpgkey\npriority=1" > /etc/yum.repos.d/test-engine-client-rpm.repo
    ```

2. Install the package:

    ```shell
    dnf install -y bktec
    ```
