# buildkite-agent lock

The Buildkite Agent's `lock` subcommands provide the ability to coordinate multiple concurrent builds on the same host that access shared resources.

> 🛠 Experimental feature
> The agent-api experiment must be enabled to use the `lock` command. To enable the agent-api experiment, include the `--experiment=agent-api` flag when starting the agent, or add `experiment="agent-api"` to your [agent configuration file](/docs/agent/v3/configuration).

With the `lock` command, processes can acquire and release a lock using the `acquire` and `release` subcommands. For the special case of performing setup once for the life of the agent (and waiting until it is complete), there are the `do` and `done` subcommands. These provide an alternative to using `flock` or OS-dependent locking mechanisms.

## Inspecting the state of a lock

<%= render 'agent/v3/help/lock_get' %>

## Acquiring a lock

<%= render 'agent/v3/help/lock_acquire' %>

## Releasing a previously-acquired lock

<%= render 'agent/v3/help/lock_release' %>

## Starting a do-once section

<%= render 'agent/v3/help/lock_do' %>

## Completing a do-once section

<%= render 'agent/v3/help/lock_done' %>

## Usage within a pipeline

Locks help coordinate access to shared resources when multiple agents run concurrently on the same host, such as when `--spawn` is used to create multiple agents.

### Coordinating sequential access

Use [`acquire`](#acquiring-a-lock) and [`release`](#releasing-a-previously-acquired-lock) when multiple builds need to run the same operation sequentially to prevent conflicts. Each build will execute the task, but only one at a time. This coordination works across multiple pipelines when they use the same lock key and the jobs run on the same host. Unlike [`do`](#starting-a-do-once-section) and [`done`](#completing-a-do-once-section), each build still performs the work—locks just ensure they don't interfere with each other.

> 📘 Sequential locks example
> In this example, we use `db-migration-lock` to ensure that database migrations run sequentially across multiple builds on the same host.
> The lock only controls access to the `bundle exec rake db:migrate` process itself in the below example, and does not lock access to the Vault server defined by the plugin, or any subsequent commands following the `buildkite-agent lock release db-migration-lock '$${token}'` command.
> Multiple builds can still retrieve secrets from Vault concurrently, but only one can execute the actual database migration at a time, as long as all builds use the same lock key.

```yml
steps:
  - label: "Install Dependencies"
    commands:
        - "echo '+++ Installing dependencies'"
        - "bundle install"
        - "npm ci"
    key: "install"

  - label: "Migrate DB Schema"
    commands:
        - "echo '+++ Running DB migration with lock'"
        - "token=$(buildkite-agent lock acquire db-migration-lock)"
        - "bundle exec rake db:migrate"
        - "buildkite-agent lock release db-migration-lock '$${token}'"
    plugins:
        - vault-secrets#v2.2.1:
            server: "https://my-vault-server"
            path: "data/buildkite/postgres"
            auth:
                method: "approle"
                role-id: "my-role-id"
                secret-env: "VAULT_SECRET_ID"
    env:
        RAILS_ENV: "development"
    depends_on: "install"
    key: "migrate-db"
```
{: codeblock-file="pipeline.yml"}

> 📘 Lock key naming
> Lock keys like `db-migration-lock` are arbitrary names you choose to identify your locks. They don't reference predefined values and can be anything you decide, but we recommend that you use descriptive names that clearly indicate what resource or operation is being protected. All builds using the same lock key will coordinate with each other on the same host.

### One-time locks

When running parallel jobs on the same host that need a shared setup, [`do`](#starting-a-do-once-section) and [`done`](#completing-a-do-once-section) ensure expensive operations happen only once. For instance, one agent performs the setup (for example, downloading datasets, generating certificates, starting services, etc.), while others wait and then proceed. This saves time and resources compared to each parallel job repeating the same work. Once marked as `done`, the lock remains completed for all subsequent jobs on the host unless it is restarted.

> 📘 One-time locks example
> In this example, we use `test-env-setup` to ensure that test environment setup happens only once across multiple parallel jobs on the same host.
> The first job to reach the `buildkite-agent lock do test-env-setup` command will receive a response of `do` and execute the setup work (downloading and extracting test data). All other parallel jobs will wait and then receive a response of `done`. These jobs will skip the `if` statement in the example bash script below and output `Assets have already been pulled and unarchived`.
> Unlike the `acquire`/`release` pattern, this lock is performed only once and subsequent jobs benefit from the completed work without repeating it.

```yml
steps:
  - label: "Install Dependencies"
    commands:
        - "echo '+++ Installing dependencies'"
        - "bundle install"
        - "npm ci"
    key: "install"

  - label: "Setup Test Environment"
    command: "setup_test.sh"
    depends_on: "install"
    key: "prep"
    parallelism: 5

  - label: "Run Tests"
    commands:
        - "echo '+++ Running tests'"
        - "bundle exec rspec"
    depends_on: "prep"
    parallelism: 10
```
{: codeblock-file="pipeline.yml"}

```bash
#!/usr/bin/env bash
echo "+++ Setting up shared test environment"
if [[ $(buildkite-agent lock do test-env-setup) == 'do' ]]; then
    echo "Downloading assets..."
    curl -o /tmp/test-data.zip https://releases.example.com/data.zip
    unzip /tmp/test-data.zip -d /tmp/shared-test-files/
    buildkite-agent lock done test-env-setup
else
  echo "Assets have already been pulled and unarchived"
fi
```
{: codeblock-file="setup_test.sh"}
