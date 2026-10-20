# Secure your first production pipeline

Use these steps as a starting configuration for one production pipeline in Buildkite Pipelines, then add controls for its [risk profile](/docs/platform/security/risk-profiles). This example isn't a complete security assessment. Each step ends with a check that confirms the control works. The steps apply to every Buildkite plan, unless a step names a plan-specific option and its alternative.

## Before you start

Start with an existing pipeline connected to a repository you control. If you haven't created one yet, follow [Getting started with Pipelines](/docs/pipelines/getting-started). You'll need a Buildkite organization administrator for organization security settings and access to configure teams, clusters, and the pipeline.

Decide whether to use Buildkite hosted or self-hosted agents. Review the [shared responsibilities](/docs/platform/security#shared-responsibility) for your hosting model before configuring production access.

## Configure and verify the pipeline

1. **Require SSO or 2FA:** On the Pro and Enterprise plans, configure [single sign-on (SSO)](/docs/platform/sso) with your identity provider. On other plans, or if you don't use SSO, select **Settings** > **Security**, select **Enforce Two-factor authentication**, and then select **Update Access Control**. Learn more in [Enforce two-factor authentication](/docs/platform/team-management/enforce-2fa).

    To verify, log in as a member of your Buildkite organization in a private browser window, and confirm that you're asked to sign in through your identity provider or enter a 2FA code.

1. **Give the pipeline its own team:** [Enable teams](/docs/platform/team-management/permissions#manage-teams-and-permissions), create a team for the people who maintain the pipeline, and give that team **Full Access** to the pipeline. Remove the pipeline from the **Everyone** team, and give any other team that needs the pipeline **Build & Read** or **Read Only** access.

    To verify, log in as a user who isn't a member of the new team, and confirm that they can't edit the pipeline's settings.

1. **Run the pipeline in its own cluster:** Create a [cluster](/docs/pipelines/security/clusters/manage), create a queue with the key `production`, and move the pipeline to that cluster. Choose the queue type for your hosting model:

    For Buildkite hosted agents, create a [Buildkite hosted queue](/docs/agent/queues/managing#create-a-buildkite-hosted-queue) with the key `production`. Buildkite manages the agent credentials; you don't create an agent token.

    For self-hosted agents, create a [self-hosted queue](/docs/agent/queues/managing#create-a-self-hosted-queue) with the key `production`, and [configure your agents](/docs/agent/queues#assigning-a-self-hosted-agent-to-a-queue) to connect to it. Create the agent token with an expiration date using the [REST API](/docs/agent/self-hosted/tokens#create-a-token-using-the-rest-api), and store it in your secrets manager:

    ```bash
    curl -H "Authorization: Bearer $TOKEN" \
      -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/tokens" \
      -H "Content-Type: application/json" \
      -d '{
        "description": "Production agents",
        "expires_at": "2027-01-01T00:00:00Z"
      }'
    ```

    A cluster created in the Buildkite interface starts with a self-hosted `default` queue. The examples below explicitly select `production` for both the upload and deployment steps, so neither relies on the default queue.

    To verify, confirm that the pipeline belongs to the new cluster and the queue key is `production`. For self-hosted agents, confirm that only your production agents are connected to that queue and that the cluster's **Agent Tokens** page shows the token's expiration date. For hosted agents, confirm that the queue is a Buildkite hosted queue with the intended image settings.

1. **Keep the pipeline steps in your repository:** Replace the steps in the pipeline's YAML steps editor with a single upload step, and define the rest of the steps in a `.buildkite/pipeline.yml` file, which is protected by branch protection rules in your source control system. Learn more in [Defining your pipeline steps](/docs/pipelines/configure/defining-steps#step-defaults-pipeline-dot-yml-file).

    ```yaml
    steps:
      - label: "\:pipeline\: Pipeline upload"
        command: buildkite-agent pipeline upload --reject-secrets
        timeout_in_minutes: 5
        agents:
          queue: production
    ```

    The `--reject-secrets` option enables the [pipeline upload secret check](/docs/pipelines/configure/dynamic-pipelines#security-considerations-for-dynamic-pipelines) on agent v3.

    To verify, open a pull request that changes `.buildkite/pipeline.yml`, and confirm that it can't be merged without a review. Run a build and confirm that the upload step runs on the `production` queue rather than waiting on `default`.

1. **Provide secrets at runtime:** Create each secret as a [Buildkite secret](/docs/pipelines/security/secrets/buildkite-secrets) in the pipeline's cluster, and load it only in the step that needs it. Buildkite secrets are [redacted](/docs/pipelines/security/secrets/buildkite-secrets#redaction) from job logs automatically. Also set a [command timeout](/docs/pipelines/configure/build-timeouts#command-timeouts) on the step to limit how long it can run:

    ```yaml
    steps:
      - label: "Deploy"
        command: scripts/deploy.sh
        timeout_in_minutes: 30
        secrets:
          - DEPLOY_API_TOKEN
        agents:
          queue: production
    ```

    Replace `scripts/deploy.sh` with your deployment script, and `DEPLOY_API_TOKEN` with the secret it needs.

    To verify, search the pipeline's settings and `pipeline.yml` file for the secret's value, and confirm that it doesn't appear. After the step runs, confirm that the value doesn't appear in the job log, or appears only as `[REDACTED]`.

1. **Block builds from untrusted sources:** In the pipeline's GitHub settings, keep **Allow builds from third-party forked repositories** cleared, so that a fork can't run modified steps with access to your secrets. Learn more in [Running builds on pull requests](/docs/pipelines/source-control/github#running-builds-on-pull-requests).

    To verify, confirm that the option is cleared, and that no build in the pipeline's history was created from a third-party fork.

1. **Write and test a response runbook:** Record how to remove a compromised user, rotate `DEPLOY_API_TOKEN`, and revoke agent tokens if you use self-hosted agents, and who to contact at Buildkite. Learn more in [Incident response](/docs/platform/security/incident-response).

    To verify, rehearse credential rotation in a test environment using only the runbook, and confirm that builds still pass and the old credential no longer works. For self-hosted agents, also rehearse replacing an agent token and revoking the old token, and confirm that the agents reconnect.

## Review the remaining controls

After you complete these steps, review the remaining baseline controls in each area of the [Security checklist](/docs/platform/security/checklist) and apply those relevant to your workload. Use your risk profile to select additional controls and track outstanding work.
