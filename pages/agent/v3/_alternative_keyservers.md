The PGP key used to sign the Buildkite Agent package is also hosted on the following keyservers. Use these keyservers if the one in the installation instructions is down.

- [keyserver.ubuntu.com](https://keyserver.ubuntu.com)

    ```shell
    curl -fsSL 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x32A37959C2FA5C3C99EFBC32A79206696452D198&exact=on&options=mr' | sudo gpg --dearmor -o /usr/share/keyrings/buildkite-agent-archive-keyring.gpg
    ```

- [pgp.mit.edu](https://pgp.mit.edu)

    ```shell
    curl -fsSL 'https://pgp.mit.edu/pks/lookup?op=get&search=0x32A37959C2FA5C3C99EFBC32A79206696452D198&exact=on&options=mr' | sudo gpg --dearmor -o /usr/share/keyrings/buildkite-agent-archive-keyring.gpg
    ```
