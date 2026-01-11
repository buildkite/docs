# Installing Buildkite Agent on Windows

The Buildkite Agent is supported on Windows 8, Windows Server 2012, and newer. There are two installation methods: automated using PowerShell, and manual installation.

## Security considerations

The agent runs scripts from the agent's hooks directory, and checks-out and runs scripts from code repositories. Please consider the file system permissions for these directories carefully, especially when operating in a multi-user environment.

## Automated install with PowerShell

You'll need to run the automated installer within PowerShell with administrative privileges.

Once you're in an escalated PowerShell session, you can run this script to install the latest version of the agent:

```shell
PS> $env:buildkiteAgentToken = "<your_token>"
PS> Set-ExecutionPolicy Bypass -Scope Process -Force
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/buildkite/agent/main/install.ps1'))
```

## Manual installation

1. Download the latest Windows release from <a href="https://github.com/buildkite/agent/releases">Buildkite Agent releases on GitHub</a>
2. Extract the files to a directory of your choice (we recommend `C:\buildkite-agent`)
3. Edit `buildkite-agent.cfg` and add your [agent token](/docs/agent/v3/self-hosted/tokens)
4. Run `buildkite-agent.exe start` from a command prompt

## SSH key configuration

Copy or generate SSH keys into your `.ssh` directory. For example, typing the following into Git Bash generates a new private key which you can add to your source code host:

```bash
$ ssh-keygen -t rsa -b 4096 -C "build@myorg.com"
```

See the [Agent SSH keys](/docs/agent/v3/self-hosted/ssh-keys) documentation for more details.

## File locations

* Configuration: `C:\buildkite-agent\buildkite-agent.cfg`
* Agent Hooks: `C:\buildkite-agent\hooks`
* Builds: `C:\buildkite-agent\builds`
* SSH keys: `%USERPROFILE%\.ssh`

## Configuration

The configuration file is located at `C:\buildkite-agent\buildkite-agent.cfg`. See the [configuration documentation](/docs/agent/v3/configuration) for an explanation of each configuration setting.

There are two options to be aware of for this initial setup:

* Set your [agent token](/docs/agent/v3/self-hosted/tokens), if you did not set it as an environment variable during installation.
* You may need to use the `shell` configuration option. On Windows, Buildkite defaults to using Batch. If you want to use PowerShell or PowerShell Core, you must point Buildkite to the correct shell. For example, to use PowerShell:

    ```cfg
    #Provide the path to PowerShell executables
    shell="C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
    ```

> 📘
> Using PowerShell Core (PowerShell 6 or 7) causes unusual behavior around pipeline upload. Refer to <a href="/docs/pipelines/configure/defining-steps#step-defaults-pipeline-dot-yml-file">Defining steps: pipeline.yml file</a> for details.

## Upgrading

Rerun the install script.

## Git for Windows

While the agent will work without Git installed, you will require [Git for Windows](https://gitforwindows.org/) to interact with Git. You will need Git Bash to use SSH on Windows 7 or below.

> 📘
> Buildkite does not currently support using Git Bash to run Bash scripts as part of your pipeline. We recommend using CMD (default) or PowerShell 5.x. You can also use PowerShell Core, but be aware of the odd behavior around pipeline upload steps. Refer to <a href="/docs/pipelines/configure/defining-steps#step-defaults-pipeline-dot-yml-file">Defining steps: pipeline.yml file</a> for more information.

## Running as a service

The simplest way to run buildkite-agent as a service is to use a third-party tool like [nssm](https://nssm.cc/). Once both nssm and the [Buildkite Agent](#automated-install-with-powershell) have been installed, you can create the service that will run the Buildkite Agent using either of the following (set of) commands:

Run the nssm GUI, create the Buildkite Agent service and configure it manually:

```
nssm install buildkite-agent
```

Alternatively, create the Buildkite Agent service with the following set of nssm commands, ensuring that the command prompt or PowerShell running these commands has administrator privileges:

```
# These commands assume you installed the agent using PowerShell
# Your paths may be different if you did a manual installation
nssm install buildkite-agent "C:\buildkite-agent\bin\buildkite-agent.exe" "start"
nssm set buildkite-agent AppParameters "start --queue=windows"
nssm set buildkite-agent AppStdout "C:\buildkite-agent\buildkite-agent.log"
nssm set buildkite-agent AppStderr "C:\buildkite-agent\buildkite-agent.log"

nssm status buildkite-agent
# Expected output: SERVICE_STOPPED

nssm start buildkite-agent
# Expected output: buildkite-agent: START: The operation completed successfully.

nssm status buildkite-agent
# Expected output: SERVICE_RUNNING
```

If you'd like to change the user the buildkite-agent service runs as, you can use the same third-party tool [nssm](https://nssm.cc/) using the command line:

```
nssm set buildkite-agent ObjectName "COMPUTER_NAME\ACCOUNT_NAME" "PASSWORD"
```

> 📘
> Ensure that this new user is a local admin on the system or has been granted all the necessary permissions to run the buildkite-agent service via nssm.

Replace the following:

* `COMPUTER_NAME`: The system name under **Settings**. For example, `PC`.
* `ACCOUNT_NAME`: The name of the account you'd like to use. For example, `Administrator`.
* `PASSWORD`: The password for the account you'd like to use. You can reference a variable rather than directly specifying the value.

## Which user the agent runs as

On Windows, all commands run as the invoking user.

## Installing Buildkite on Windows Subsystem for Linux 2

<!-- date -->

You can use Buildkite on Windows through WSL2, but it has limitations. At present (12 January 2022), hooks and plugins both have issues. We recommend using CMD (default) or PowerShell 5.x instead.

To install the agent on WSL2, follow the [generic Linux installation guide](/docs/agent/v3/self-hosted/installing/linux). Do not use the guides for Ubuntu, Debian, and so on, even if that is the Linux distro you are using with WSL2.

> 📘
> Using WSL2 causes unusual behavior during pipeline upload. Refer to <a href="/docs/pipelines/configure/defining-steps#step-defaults-pipeline-dot-yml-file">Defining steps: pipeline.yml file</a> for details.
