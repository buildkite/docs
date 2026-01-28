# Buildkite agent code access

If your agent needs to clone your repositories using git and SSH, you'll need to configure your agent with a valid SSH key.

This page explains how to configure your agent with valid SSH keys to gain access to your code in repositories, as well as [SSH keys for GitHub](#ssh-keys-for-github).

## Finding your SSH key directory

When the Buildkite agent runs any git operations, the agent will look for SSH keys in `~/.ssh` under the user the agent is running as. Each platform's [agent installation documentation](/docs/agent/v3/self-hosted/install) specifies which user the agent runs as and in which directory the SSH keys are. For example, on Debian the agent runs as `buildkite-agent` and the SSH keys are in `/var/lib/buildkite-agent/.ssh/` but on macOS the agent runs as the user who started the `launchd` service, and the SSH keys are in that user's `.ssh` directory.

## Debugging SSH key issues

To help debug SSH issues, you can enable verbose logging by running your build with the following environment variable set:

```bash
GIT_SSH_COMMAND="ssh -vvv"
```

## Creating a single SSH key

The following shows an example of creating a new "machine user" SSH key for an agent:

```bash
$ sudo su buildkite-agent # or whichever user your agent runs as
$ mkdir -p ~/.ssh && cd ~/.ssh
$ ssh-keygen -t rsa -b 4096 -C "dev+build@myorg.com"
Generating public/private rsa key pair.
Enter file in which to save the key (/var/lib/buildkite-agent/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /var/lib/buildkite-agent/.ssh/id_rsa.
Your public key has been saved in /var/lib/buildkite-agent/.ssh/id_rsa.pub.
The key fingerprint is:
4b:6f:7b:5f:8e:f7:5b:c1:fa:e3:dd:9a:8e:a8:e8:33 dev@org.com
The key's randomart image is:
+---[RSA 4096]----+
|                 |
|                 |
|                 |
|              .  |
|        S      o |
|       . o    . .|
|        . o  .  o|
|      E. . o...*=|
|     .oo..o..oB*O|
+-----------------+
$ ls
id_rsa  id_rsa.pub
$ cat id_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDELESv1QGfoZ2hECJr.......Yho9hDPoNefDbcdZM4NdKWTVmyNGQo6YTzw== dev+build@myorg.com
```

You'd then add this key to the user's settings on [GitHub](#ssh-keys-for-github), Bitbucket, GitLab, etc.

## Creating multiple SSH keys

If you need to use multiple SSH keys for different pipelines, we support a special repository hostname format which you can use with your `~/.ssh/config`.

To use a different key for a given pipeline, first change the repository hostname in your Buildkite pipeline settings from `server.com` to `server.com-mypipeline`, add an entry to the SSH config file on your agent machine for the host `server.com-mypipeline`, and specify your custom SSH key.

For example, if you had a pipeline repository URL of `git@github.com:org/pipeline-1.git` you would change it in your Buildkite repository settings to `git@github.com-pipeline-1:org/pipeline-1.git` and create the following SSH config file:

```
Host github.com-pipeline-1
  HostName github.com
  IdentityFile /var/lib/buildkite-agent/.ssh/id_rsa.pipeline-1
```

The following example shows how to create the corresponding pipeline-specific SSH key:

```bash
$ sudo su buildkite-agent # or whichever user your agent runs as
$ cd ~/.ssh
$ ssh-keygen -t rsa -b 4096 -C "dev+build-pipeline-1@myorg.com"
Generating public/private rsa key pair.
Enter file in which to save the key (/var/lib/buildkite-agent/.ssh/id_rsa): id_rsa.pipeline-1
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in id_rsa.pipeline-1.
Your public key has been saved in id_rsa.pipeline-1.pub.
The key fingerprint is:
e4:60:69:a3:a0:63:bb:27:e6:ff:53:d3:4a:06:7f:e4 dev@org.com
The key's randomart image is:
+---[RSA 4096]----+
|                 |
|       .         |
|  .   * .        |
| . . = = .       |
|o.  . o S        |
|...    * E       |
| .    + +        |
| o.. . .         |
|oo+....          |
+-----------------+
$ ls
id_rsa.pipeline-1  id_rsa.pipeline-1.pub
```

Alternatively, you can use a shorter approach to creating multiple SSH keys by adding pipeline-specific environments:

> 📘
> Note that if you are using Elastic CI Stack for AWS, the following approach is redundant as the stack creates a [build secrets bucket](/docs/agent/v3/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/security#s3-secrets-bucket) and allows you to specify an SSH key per pipeline as `/{pipeline-slug}/private_ssh_key`.

1. Add a pipeline-specific environment (for example, by using [Elastic CI Stack for AWS's build secrets bucket](/docs/agent/v3/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/security#s3-secrets-bucket) or by having an Agent environment hook that switches on the repository URL or the pipeline slug):

    ```bash
    GIT_SSH_COMMAND="ssh -i ~/.ssh/id_rsa_mypipeline"
    ```
1. Create an identity file at that location:

    ```bash
    ~/.ssh/id_rsa_mypipeline
    ```
1. Add the public key for that identity file to `mypipeline` on the git repository provider.

## Using multiple keys with ssh-agent

If you need to use multiple keys, or want to use keys with pass-phrases, an alternative to the above hostname method is to use `ssh-agent`.

After starting an `ssh-agent` process and adding the keys, ensure the `SSH_AUTH_SOCK` environment variable is exported by your [`environment` hook](/docs/agent/v3/self-hosted/hooks#job-lifecycle-hooks).

For example, if you set up `ssh-agent` like so:

```bash
$ sudo su buildkite-agent
$ ssh-agent -a ~/.ssh/ssh-agent.sock
$ export SSH_AUTH_SOCK=/var/lib/buildkite-agent/.ssh/ssh-agent.sock
$ ssh-add ~/.ssh/id_rsa-pipeline-1
Identity added: /var/lib/buildkite-agent/.ssh/id_rsa-pipeline-1
$ ssh-add ~/.ssh/id_rsa-pipeline-2
Identity added: /var/lib/buildkite-agent/.ssh/id_rsa-pipeline-2
```

The following [`environment` hook](/docs/agent/v3/self-hosted/hooks#job-lifecycle-hooks)
will direct your build's git operations to use the `ssh-agent` socket:

```bash
#!/bin/bash

set -eu

export SSH_AUTH_SOCK="/var/lib/buildkite-agent/.ssh/ssh-agent.sock"
```

## SSH keys for GitHub

The Buildkite Agent clones your source code directly from GitHub or GitHub Enterprise. The easiest way to provide it with access is by creating a "Buildkite Agent" machine user in your organization, and adding it to a team that has access to the relevant repositories.

> 📘
> If you're running a build agent on a local development machine which already has access to GitHub then you can skip this setup and start running builds.

### Method 1: Machine user

Creating a [machine user](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/managing-deploy-keys#machine-users) is the simplest way to create a single SSH key which provides access to your organization's repositories.

To set up a GitHub machine user:

1. On your agent machine, generate a key as per the [Creating a single SSH key](#creating-a-single-ssh-key) instructions.
1. Sign up to GitHub as a new user (using a valid email address), and add the SSH key to the user's settings.
1. Sign back into GitHub as an organization admin, create a new team, then add the new user and any required repositories to the team.

### Method 2: Deploy keys

An alternative method of providing access to your repositories is to use deploy keys. The advantage of deploy keys is they can provide read-only access to your source code, but the disadvantage is that you'll have to configure ssh on your build agents to handle multiple keys.

To setup GitHub deploy keys with the Buildkite Agent, you'll need to do the following for each repository:

1. On your agent machine, generate a key as per the
[Creating multiple SSH keys](#creating-multiple-ssh-keys) instructions.
1. In GitHub, copy the key into the repository's "Deploy keys" settings.
