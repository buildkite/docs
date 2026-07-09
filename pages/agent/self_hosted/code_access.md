# Self-hosted agent code access

When the Buildkite agent runs a build, it clones the pipeline's repository using git. For SSH-based repository URLs (for example, `git@github.com:org/repo.git`), the agent needs access to an SSH private key that has been authorized with your source control provider.

There are two ways to provide SSH access:

- **Buildkite secrets (recommended):** Store the SSH key centrally and reference it in your pipeline YAML. No key files need to be distributed to agent machines.
- **Managing keys on agent machines:** Place SSH key files directly in the agent user's `~/.ssh` directory on each machine.

## Using Buildkite secrets (recommended)

The simplest way to give self-hosted agents SSH access to your repositories is to store the private key as a [Buildkite secret](/docs/pipelines/security/secrets/buildkite-secrets) and reference it using `checkout.ssh_secret` in your pipeline YAML. This approach works with all source control providers (GitHub, GitLab, Bitbucket, and others) and eliminates the need to distribute SSH key files to every agent machine.

To set this up:

1. Generate an SSH key pair:

    ```bash
    ssh-keygen -t ed25519 -C "buildkite-agent@myorg.com"
    ```

1. Add the public key to your source control provider as a deploy key or machine user key.

1. Store the private key as a Buildkite secret in your cluster. See [Create a secret](/docs/pipelines/security/secrets/buildkite-secrets#create-a-secret) for instructions.

1. Reference the secret name in your pipeline YAML using `checkout.ssh_secret`:

    ```yaml
    steps:
      - label: "Build"
        command: "make build"
        checkout:
          ssh_secret: "MY_SSH_KEY"
    ```

The secret name must start with a letter, contain only letters, numbers, and underscores, and must not start with `buildkite` or `bk`.

> 📘 Step-level only
> The `ssh_secret` key is step-level only. It is not inherited from a pipeline-level `checkout` block, so you must set it on each step that needs it.

For more details on how `checkout.ssh_secret` works, see [SSH key from Buildkite secrets](/docs/pipelines/configure/git-checkout#ssh-key-from-buildkite-secrets).

## Managing SSH keys on agent machines

If you aren't using Buildkite secrets, you can configure SSH keys directly on each machine where the agent runs. The rest of this page covers this approach, including how to create and manage SSH key files, configure multiple keys for different pipelines, and set up access for specific providers like GitHub.

### Finding your SSH key directory

When the Buildkite agent runs any git operations, it looks for SSH keys in `~/.ssh` under the user the agent runs as. Each platform's [agent installation documentation](/docs/agent/self-hosted/install) specifies which user the agent runs as and where the SSH keys are stored. For example, on Debian the agent runs as `buildkite-agent` and the SSH keys are in `/var/lib/buildkite-agent/.ssh/`, but on macOS the agent runs as the user who started the `launchd` service, and the SSH keys are in that user's `.ssh` directory.

### Creating a single SSH key

The following example shows how to create a new "machine user" SSH key for an agent using Ed25519:

```bash
$ sudo su buildkite-agent # or whichever user your agent runs as
$ mkdir -p ~/.ssh && cd ~/.ssh
$ ssh-keygen -t ed25519 -C "dev+build@myorg.com"
Generating public/private ed25519 key pair.
Enter file in which to save the key (/var/lib/buildkite-agent/.ssh/id_ed25519):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /var/lib/buildkite-agent/.ssh/id_ed25519.
Your public key has been saved in /var/lib/buildkite-agent/.ssh/id_ed25519.pub.
The key fingerprint is:
SHA256:xB3TkRRqLmHmAXbRdN5gR4kVTU3mGSo9K2tKLCqwHIk dev+build@myorg.com
The key's randomart image is:
+--[ED25519 256]--+
|   .+ +o+        |
|   . B.=         |
|    o O o        |
|     = = +       |
|    o + S o      |
|   + = + = .     |
|    * B E o      |
|   o =.= .      |
|    o+*+o.       |
+----[SHA256]-----+
$ ls
id_ed25519  id_ed25519.pub
$ cat id_ed25519.pub
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGjVMoSnPzBnGMKRHdwNfzCnpE7iY8MYbz3aLfK2E0OP dev+build@myorg.com
```

You then add this public key to the user's settings on [GitHub](#managing-ssh-keys-on-agent-machines-ssh-keys-for-github), Bitbucket, GitLab, or your source control provider.

> 📘 RSA keys
> If your source control provider requires RSA keys, you can generate an RSA 4096 key instead:
>
> ```bash
> ssh-keygen -t rsa -b 4096 -C "dev+build@myorg.com"
> ```

### Creating multiple SSH keys

If you need to use multiple SSH keys for different pipelines, the Buildkite agent supports a special repository hostname format that you can use with your `~/.ssh/config`.

To use a different key for a given pipeline, first change the repository hostname in your Buildkite pipeline settings from `server.com` to `server.com-mypipeline`, add an entry to the SSH config file on your agent machine for the host `server.com-mypipeline`, and specify your custom SSH key.

For example, if you had a pipeline repository URL of `git@github.com:org/pipeline-1.git` you would change it in your Buildkite repository settings to `git@github.com-pipeline-1:org/pipeline-1.git` and create the following SSH config file:

```
Host github.com-pipeline-1
  HostName github.com
  IdentityFile /var/lib/buildkite-agent/.ssh/id_ed25519.pipeline-1
```

The following example shows how to create the corresponding pipeline-specific SSH key:

```bash
$ sudo su buildkite-agent # or whichever user your agent runs as
$ cd ~/.ssh
$ ssh-keygen -t ed25519 -C "dev+build-pipeline-1@myorg.com"
Generating public/private ed25519 key pair.
Enter file in which to save the key (/var/lib/buildkite-agent/.ssh/id_ed25519): id_ed25519.pipeline-1
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in id_ed25519.pipeline-1.
Your public key has been saved in id_ed25519.pipeline-1.pub.
The key fingerprint is:
SHA256:Q8mR4hZx5fCnAkNpVSo9dGZyXrW7cUhJvLsTpE2gN1w dev+build-pipeline-1@myorg.com
The key's randomart image is:
+--[ED25519 256]--+
|       .+ +o+    |
|       . B.=     |
|        o O o    |
|     o . = +     |
|    . + S o      |
|   o = + = .     |
|    * B E o      |
|   o =.= .      |
|    o+*+o.       |
+----[SHA256]-----+
$ ls
id_ed25519.pipeline-1  id_ed25519.pipeline-1.pub
```

> 📘 RSA keys
> If your provider requires RSA, use `ssh-keygen -t rsa -b 4096` instead and adjust the filenames accordingly (for example, `id_rsa.pipeline-1`).

Alternatively, you can use a shorter approach to creating multiple SSH keys by adding pipeline-specific environments:

> 📘
> If you are using Elastic CI Stack for AWS, the following approach is redundant as the stack creates a [build secrets bucket](/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/security#s3-secrets-bucket) and allows you to specify an SSH key per pipeline as `/{pipeline-slug}/private_ssh_key`.

1. Add a pipeline-specific environment (for example, by using [Elastic CI Stack for AWS's build secrets bucket](/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/security#s3-secrets-bucket) or by having an agent environment hook that switches on the repository URL or the pipeline slug):

    ```bash
    GIT_SSH_COMMAND="ssh -i ~/.ssh/id_ed25519_mypipeline"
    ```

1. Create an identity file at that location:

    ```bash
    ~/.ssh/id_ed25519_mypipeline
    ```

1. Add the public key for that identity file to `mypipeline` on the git repository provider.

### Using multiple keys with ssh-agent

If you need to use multiple keys, or want to use keys with passphrases, an alternative to the hostname method above is to use `ssh-agent`.

After starting an `ssh-agent` process and adding the keys, ensure the `SSH_AUTH_SOCK` environment variable is exported by your [`environment` hook](/docs/agent/hooks#job-lifecycle-hooks).

For example, if you set up `ssh-agent` like so:

```bash
$ sudo su buildkite-agent
$ ssh-agent -a ~/.ssh/ssh-agent.sock
$ export SSH_AUTH_SOCK=/var/lib/buildkite-agent/.ssh/ssh-agent.sock
$ ssh-add ~/.ssh/id_ed25519-pipeline-1
Identity added: /var/lib/buildkite-agent/.ssh/id_ed25519-pipeline-1
$ ssh-add ~/.ssh/id_ed25519-pipeline-2
Identity added: /var/lib/buildkite-agent/.ssh/id_ed25519-pipeline-2
```

The following [`environment` hook](/docs/agent/hooks#job-lifecycle-hooks) directs your build's git operations to use the `ssh-agent` socket:

```bash
#!/bin/bash

set -eu

export SSH_AUTH_SOCK="/var/lib/buildkite-agent/.ssh/ssh-agent.sock"
```

### SSH keys for GitHub

The Buildkite agent clones your source code directly from GitHub or GitHub Enterprise. The easiest way to provide access is by creating a "Buildkite agent" machine user in your organization and adding it to a team that has access to the relevant repositories.

> 📘
> If you're running a build agent on a local development machine that already has access to GitHub, you can skip this setup and start running builds.

#### Method 1: Machine user

Creating a [machine user](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/managing-deploy-keys#machine-users) is the simplest way to create a single SSH key that provides access to your organization's repositories.

To set up a GitHub machine user:

1. On your agent machine, generate a key as per the [Creating a single SSH key](#managing-ssh-keys-on-agent-machines-creating-a-single-ssh-key) instructions.
1. Sign up to GitHub as a new user (using a valid email address), and add the SSH key to the user's settings.
1. Sign back into GitHub as an organization admin, create a new team, then add the new user and any required repositories to the team.

#### Method 2: Deploy keys

An alternative method of providing access to your repositories is to use deploy keys. The advantage of deploy keys is that they can provide read-only access to your source code, but the disadvantage is that you need to configure SSH on your build agents to handle multiple keys.

To set up GitHub deploy keys with the Buildkite agent, do the following for each repository:

1. On your agent machine, generate a key as per the [Creating multiple SSH keys](#managing-ssh-keys-on-agent-machines-creating-multiple-ssh-keys) instructions.
1. In GitHub, copy the key into the repository's **Deploy keys** settings.

## Debugging SSH key issues

To help debug SSH issues, you can enable verbose logging by running your build with the following environment variable set:

```bash
GIT_SSH_COMMAND="ssh -vvv"
```

This works for both [Buildkite secrets](#using-buildkite-secrets-recommended) and [agent-managed SSH keys](#managing-ssh-keys-on-agent-machines).

### Troubleshooting Buildkite secrets SSH keys

If the checkout fails with an SSH authentication error when using `checkout.ssh_secret`, verify that:

- The secret name meets the naming constraints: starts with a letter, contains only letters, numbers, and underscores, and does not start with `buildkite` or `bk`.
- The secret exists in [Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets) within the correct cluster and contains a valid SSH private key.
- The `ssh_secret` key is set at the step level, not the pipeline level.
- The corresponding public key has been added to your source control provider.

For additional troubleshooting steps, see the [SSH key issues during checkout](/docs/pipelines/configure/git-checkout#ssh-key-issues-during-checkout) section on the Git checkout page.

### Troubleshooting agent-managed SSH keys

If the agent cannot authenticate using keys in `~/.ssh`, check the following:

- The SSH key files are in the correct directory for the user the agent runs as. See [Finding your SSH key directory](#managing-ssh-keys-on-agent-machines-finding-your-ssh-key-directory).
- The key files have the correct permissions (`600` for the private key, `644` for the public key).
- The public key has been added to your source control provider.
- If using multiple keys with custom hostnames, verify that the `~/.ssh/config` entries match the modified repository URL in your pipeline settings.
