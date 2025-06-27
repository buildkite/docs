# buildkite-agent lock

The Buildkite Agent's `lock` subcommands provide the ability to coordinate multiple concurrent builds on the same host that access shared resources.

> 🛠 Experimental feature
> The agent-api experiment must be enabled to use the `lock` command. To enable the agent-api experiment, include the `--experiment=agent-api` flag when starting the agent or add `experiment="agent-api"` to your agent [configuration file](/docs/agent/v3/configuration).

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

Use `acquire` and `release` when multiple builds need to run the same operation sequentially to prevent conflicts. Each build will execute the task, but only one at a time. In this database migration example, concurrent schema changes could corrupt the database, so locks ensure migrations run one after another in the order they were requested. This coordination works across multiple pipelines when they use the same lock key and the jobs run on the same host. Unlike `do/done`, each build still performs the work - locks just ensure they don't interfere with each other.

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

### One-time locks

When running parallel jobs, on the same host, that need shared setup, `do` and `done` ensure expensive operations happen only once. One agent performs the setup (downloading datasets, generating certificates, starting services, etc.,) while others wait and then proceed. This saves time and resources compared to each parallel job repeating the same work. Once marked as `done`, the lock remains completed for all subsequent jobs on the host unless it is restarted.

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
