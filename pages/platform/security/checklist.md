---
toc_include_h3: false
---

# Security checklist

Use this checklist to secure your Buildkite organization, or to review an existing one before a security audit. Start with the baseline controls in each area, then add the controls that match the risks in your workloads. You don't need to enable every security feature to use Buildkite securely. Buildkite and your organization [share responsibility for security](/docs/platform/security#shared-responsibility).

If you suspect an active compromise, follow [Incident response](/docs/platform/security/incident-response) before working through this checklist.

<a id="start-with-what-you-need-to-protect"></a>
<a id="where-to-start"></a>

## How to use this page

Start with each area's baseline, then use your [workload risk profile](/docs/platform/security/risk-profiles) to select additional controls. For a new setup, follow [Secure your first production pipeline](/docs/platform/security/first-production-pipeline) for configuration and verification examples.

Check items after configuring and verifying them. Selections stay in this browser; they aren't evidence of compliance or a security score.

<a id="security-areas"></a>

<p class="SecurityChecklist__storage" data-security-storage role="status"></p>

<% SECURITY_AREAS['areas'].each do |area| -%>
<span hidden data-security-area="<%= area['anchor'] %>" data-security-summary="<%= ERB::Util.html_escape(area['summary']) %>"></span>
<% end -%>

<!-- Area names, summaries, and audit examples are stored in data/content/security_areas.yaml. -->

<% security_area = ->(anchor) { SECURITY_AREAS['areas'].find { |a| a['anchor'] == anchor } } -%>
<% audit_area = ->(anchor) {
  audit = security_area.(anchor)['audit']
  "### Audit this area\n\n#{audit['limits']}\n\n" +
    { 'api' => 'API', 'cli' => 'CLI', 'mcp' => 'Ask the Buildkite MCP' }.map { |key, label|
      "#### #{label}\n\n#{audit[key]}"
    }.join("\n")
} -%>
<a id="authentication-and-session-security-in-the-buildkite-interface-apis-and-cli"></a>
<a id="api-access-token-compromise"></a>

## <%= security_area.('authentication-and-access-control')['name'] %>

<%= security_area.('authentication-and-access-control')['summary'] %>

For token types, prefixes, scopes, and lifetimes, see the [Token reference](/docs/platform/security/tokens#token-reference).

If an API access token may already be compromised, follow the [token revocation steps](/docs/platform/security/incident-response#contain-the-incident-revoke-compromised-tokens) before reviewing these preventive controls.

### Baseline

- **Enforce single sign-on (SSO) or two-factor authentication (2FA):** Require users to log in through your identity provider with [SSO](/docs/platform/sso) (Pro and Enterprise plans), or [enforce 2FA](/docs/platform/team-management/enforce-2fa) for all members. Enforcing SSO for your entire Buildkite organization requires 2FA enforcement to be disabled, so decide which approach applies before you configure either. Users without 2FA lose access immediately when 2FA is enforced, and existing API access tokens continue to work.
- **Enable teams and reduce the Everyone team:** Without [teams](/docs/platform/team-management/permissions#manage-teams-and-permissions), every user can access every pipeline. Enabling teams creates an **Everyone** team that preserves existing access, so create narrower teams and remove pipelines from the **Everyone** team.
- **Grant the lowest pipeline permission that works:** Give teams that don't need to change a pipeline the **Build & Read** or **Read Only** [pipeline-level permission](/docs/pipelines/security/permissions#manage-teams-and-permissions-pipeline-level-permissions). Apply the same approach to [registry permissions](/docs/package-registries/security/permissions). Review overlapping team memberships, as the highest pipeline permission applies. Once a team loses **Full Access**, only another team with **Full Access** or a Buildkite organization administrator can restore it.
- **Scope and expire API access tokens:** Grant each [API access token](/docs/apis/managing-api-tokens) only the [scopes](/docs/apis/managing-api-tokens#token-scopes) it needs, and set a short **Token Expiry**. Tokens using the **Public Key** credential type don't expire, so track them separately in your [rotation](/docs/apis/managing-api-tokens#api-token-security-rotation) process.
- **Audit API access tokens regularly:** Review every token with access to your Buildkite organization on the [API access audit](/docs/apis/managing-api-tokens#auditing-tokens) page, and [remove your organization](/docs/apis/managing-api-tokens#auditing-tokens-removing-an-organization-from-a-token) from tokens that are stale or over-scoped.

This baseline is complete when every member signs in with SSO or 2FA, no pipeline is in the **Everyone** team unless you've decided it should be, and every token on the API access audit page has an owner, only the scopes it needs, and an expiry or a rotation date.

### Recommended

- **Limit SSO session duration:** Set an [SSO session duration](/docs/platform/sso#sso-session-duration) so that sessions don't stay valid indefinitely.
- **Automate deprovisioning with SCIM:** Configure SCIM provisioning for [Okta](/docs/platform/sso/okta#using-scim-to-provision-and-manage-users) or [Microsoft Entra ID](/docs/platform/sso/azure-ad#using-scim-to-provision-and-manage-users) (Enterprise plan only), so that removing a user from your identity provider also removes their access to Buildkite. Users who joined before SCIM was configured need to be [synced](/docs/platform/sso/okta#using-scim-to-provision-and-manage-users-syncing-existing-users-for-deprovisioning) before SCIM can remove them.
- **Restrict organization-wide actions:** Use the **Security** page to control who can delete pipelines, change pipeline visibility, manage notification services, manage agent tokens, and stop agents, across all users of your Buildkite organization (Enterprise plan only). Learn more in [Manage organization security for pipelines](/docs/pipelines/security/permissions#manage-organization-security-for-pipelines).
- **Revoke inactive API access tokens automatically:** Configure [inactive API token revocation](/docs/apis/managing-api-tokens#inactive-api-tokens-revocation) so that forgotten tokens are revoked after a set period (Enterprise plan only).
- **Restrict who can create API access tokens:** Set `restrict_user_api_token_creation` using the [API settings](/docs/apis/rest-api/organizations/api-settings) endpoint, so that only Buildkite organization administrators can create new API access tokens.
- **Authorize sensitive builds by a verified creator:** Use an [agent hook](/docs/agent/hooks) to check that the build creator belongs to a team that's allowed to run the job, using `BUILDKITE_BUILD_CREATOR_TEAMS`, as shown in [Programmatically managing teams](/docs/platform/team-management/permissions#manage-teams-and-permissions-programmatically-managing-teams). Only trust this value when Buildkite authenticated the creator, that is, when `BUILDKITE_SOURCE` is `ui` or `api`. For builds created by a GitHub webhook, the creator is taken from the unverified commit author, which anyone who can push an unsigned commit can set to another user's identity, so don't treat it as authentication. To authorize a webhook-triggered deployment, add a [block step](/docs/pipelines/configure/step-types/block-step) before it, and check `BUILDKITE_UNBLOCKER_TEAMS`, which lists the teams of the authenticated user who unblocked the build.
- **Limit GraphQL access with portals:** API access tokens with GraphQL access can run any GraphQL query. Use [portals](/docs/apis/graphql/portals) to expose only the specific GraphQL operations that an integration needs.
- **Use the remote MCP server:** When using the [Buildkite MCP server](/docs/apis/mcp-server), prefer the [remote MCP server](/docs/apis/mcp-server#types-of-mcp-servers-remote-mcp-server), which issues short-lived OAuth access tokens, over a local MCP server configured with a long-lived API access token.

### Advanced

- **Pin SSO sessions to IP addresses:** Enable [SSO session IP address pinning](/docs/platform/sso#sso-session-ip-address-pinning) so that users must re-authenticate when their IP address changes (Enterprise plan only).
- **Restrict API access by IP address:** Set an organization-wide [IP address allowlist](/docs/apis/managing-api-tokens#restricting-api-access-by-ip-address) for the REST and GraphQL APIs (Enterprise plan only). The allowlist takes effect immediately, so confirm that it includes your own IP addresses before you save it.
- **Use OAuth Token Exchange for services:** Instead of giving a service a long-lived API access token tied to a user, use [OAuth Token Exchange](/docs/apis/oauth-token-exchange) to issue short-lived tokens with a limited lifetime and scope.

<%= audit_area.('authentication-and-access-control') %>

## <%= security_area.('buildkite-agent-security')['name'] %>

<%= security_area.('buildkite-agent-security')['summary'] %> Choose the section for your hosting model. Clusters separate workloads in both models; queues route jobs within a cluster and aren't a substitute for that security boundary. Review [pipeline and supply chain integrity](#pipeline-and-supply-chain-integrity) for controls on the code that agents run.

### Buildkite hosted agents

Buildkite manages agent installation, updates, and the infrastructure that isolates each job. Your organization still manages its images and the access granted to builds. You don't create or rotate agent tokens for hosted agents.

#### Baseline

- **Separate hosted production workloads:** Place production pipelines and their [hosted queues](/docs/agent/queues/managing#create-a-buildkite-hosted-queue) in a dedicated [cluster](/docs/pipelines/security/clusters). Don't run untrusted pull requests in a cluster that provides production secrets.
- **Maintain Linux agent images:** Assign an owner to each [custom agent image](/docs/agent/buildkite-hosted/linux/custom-agent-images). Scan and rebuild images when their operating system packages or dependencies need security updates, then update the queues or steps that use them. Buildkite supplies the agent binary; it doesn't maintain the packages you add.
- **Review macOS base image selections:** Check each macOS queue's **Base image** settings against the [available macOS and Xcode versions](/docs/agent/buildkite-hosted/macos#macos-instance-software-support). Test newer images and update the queue selection when needed. Buildkite maintains the base images; you maintain software installed by your jobs.
- **Pin hosted pipeline plugins:** Review plugin code and [pin plugins to commit SHAs](/docs/pipelines/integrations/plugins/using#pinning-plugin-versions). Self-hosted agent-controller plugin allowlists aren't available on hosted agents.
- **Set hosted job timeouts:** Configure [command timeouts](/docs/pipelines/configure/build-timeouts#command-timeouts) for every command step, including uploads and deployments.

This baseline is complete when production and untrusted workloads use separate clusters, every custom image has an update owner, macOS queue selections have been reviewed, plugins are pinned, and command steps have timeouts.

#### Recommended

- **Authenticate hosted jobs to your services:** Use [OIDC](/docs/agent/buildkite-hosted/network-security) to identify the organization, pipeline, and job. Hosted IP ranges are shared across customers and don't establish that identity.
- **Review interactive job access:** Enable [remote access](/docs/apis/rest-api/organizations/pipeline-settings#enable-hosted-agents-remote-access) only when needed. On the Enterprise plan, review `JOB_TERMINAL_SESSION_STARTED` events in the [audit log](/docs/platform/audit-log).
- **Review hosted cache sharing:** Treat [cache volumes](/docs/agent/buildkite-hosted/cache-volumes) as reusable build data, not a secrets store. Keep untrusted workloads separate from queues that build releases.

### Self-hosted agents

Your organization manages the hosts, images, agent configuration, and updates. Apply these controls to every agent in the relevant pool, not just the agent that uploads a pipeline.

<a id="buildkite-agent-security-baseline"></a>

#### Baseline

- **Run every pipeline and agent in a cluster:** [Clusters](/docs/pipelines/security/clusters) isolate pipelines and agents from each other. Run pipelines with sensitive builds on dedicated agents in their own cluster, so that a compromise of a less trusted environment, such as an open source repository, cannot reach them. Limit who can manage a cluster's agent tokens by assigning [cluster maintainers](/docs/pipelines/security/clusters/manage#manage-maintainers-on-a-cluster).
- **Give agent tokens an expiry and a rotation plan:** [Create agent tokens using the API](/docs/agent/self-hosted/tokens#agent-token-lifetime) with an expiration date, so that you can automate rotation. Agent tokens created in the Buildkite interface don't expire. Store agent tokens in a secrets manager, and [revoke](/docs/agent/self-hosted/tokens#revoke-a-token) tokens you no longer use.
- **Restrict or disable plugins:** Use the agent's [plugin allowlist](/docs/agent/self-hosted/security#restrict-access-by-the-buildkite-agent-controller-allow-a-list-of-plugins) to restrict which plugin sources can run, or [disable plugins](/docs/agent/self-hosted/security#restrict-access-by-the-buildkite-agent-controller-disable-plugins) if you don't use them. Anchor and escape your regular expressions, and apply the same configuration to every agent, as the allowlist is enforced by each agent individually.
- **Force clean checkouts for untrusted builds:** Set `BUILDKITE_CLEAN_CHECKOUT` on steps that build untrusted code, such as third-party pull requests, so that files from a previous checkout don't persist. Learn more in [Force clean checkouts](/docs/agent/self-hosted/security#force-clean-checkouts).
- **Set command timeouts:** Use [command timeouts](/docs/pipelines/configure/build-timeouts#command-timeouts) to limit how long malicious code can run on a compromised agent.
- **Upgrade agents and their images regularly:** [Upgrade your Buildkite agents](/docs/agent/self-hosted/install#upgrade-agents) for security fixes. Patch the host operating system and installed tools, rebuild images, and replace or update agents that use older versions.

This baseline is complete when every pipeline runs in a cluster, every agent token has an owner and an expiry or rotation date, plugin sources are restricted or pinned, untrusted builds use clean checkouts, every command step has a timeout, and your self-hosted agents run a current agent version.

<a id="buildkite-agent-security-recommended"></a>

#### Recommended

- **Restrict agent tokens by IP address:** Set **Allowed IP Addresses** on each agent token, so that a leaked token cannot be used outside your network. Changing the allowed ranges disconnects existing agents whose IP addresses no longer match and prevents their running jobs from completing. Learn more in [Restrict an agent token's access by IP address](/docs/pipelines/security/clusters/manage#restrict-an-agent-tokens-access-by-ip-address), including the limitations of this feature.
- **Disable command evaluation:** [Disable command evaluation](/docs/agent/self-hosted/security#restrict-access-by-the-buildkite-agent-controller-disable-command-evaluation) to restrict agents to checked-in scripts if the control plane sends malicious commands (self-hosted agents only). This setting also disables plugins. It doesn't protect against malicious repository changes or constrain a custom `command` hook. Other tools in a job can still be influenced through environment variables, so combine this setting with a [pre-bootstrap hook](/docs/agent/self-hosted/security#restrict-access-by-the-buildkite-agent-controller-strict-checks-using-a-pre-bootstrap-hook) or the [environment variable allowlist](/docs/agent/cli/reference/start#enable-environment-variable-allowlist).
- **Allowlist repositories:** Use the agent's [`allowed-repositories`](/docs/agent/cli/reference/start#allowed-repositories) setting to restrict which repositories an agent can clone (self-hosted agents only).
- **Require strict SSH host key checking:** [Require strict SSH host key checking](/docs/agent/self-hosted/security#require-strict-ssh-host-key-checking) against your own `known_hosts` file, instead of trusting unknown hosts on first connection (self-hosted agents only).
- **Use ephemeral and isolated build environments:** Run [ephemeral agents](/docs/pipelines/glossary#ephemeral-agent) in isolated virtual machines or containers with minimal operating systems, no inbound SSH access, and strict network egress controls.
- **Protect the Kubernetes pod spec:** On the [Agent Stack for Kubernetes](/docs/agent/self-hosted/agent-stack-k8s), enable [`prohibit-kubernetes-plugin`](/docs/agent/self-hosted/agent-stack-k8s/securing-the-stack) so that pipelines cannot override the controller-defined pod spec.
- **Review the Elastic CI Stack for AWS security guidance:** If you run the [Elastic CI Stack for AWS](/docs/agent/self-hosted/aws/elastic-ci-stack), review its [security considerations](/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/security). Run the stack in your own VPC, store the agent token in AWS Secrets Manager, and limit build access to the [Amazon EC2 instance metadata](/docs/agent/self-hosted/aws/architecture/securing-your-setup).
- **Audit cluster rules:** Clusters are isolated from each other by default. Create [rules](/docs/pipelines/security/clusters/rules) only where pipelines need to trigger builds or read artifacts across clusters, and review each rule as a deliberate grant of access.

<a id="buildkite-agent-security-advanced"></a>

#### Advanced

- **Use job acquisition tokens for ephemeral agents:** Have your stack controller issue a [job acquisition token](/docs/agent/self-hosted/job-acquisition-tokens) for each job, so that a compromised job cannot read the long-lived agent token. The Agent Stack for Kubernetes uses job acquisition tokens by default.
- **Disable repository hooks:** If you enforce policies with agent hooks, [disable local hooks](/docs/agent/self-hosted/security#restrict-access-by-the-buildkite-agent-controller-disable-local-hooks) so that [repository hooks](/docs/agent/hooks#hook-locations-repository-hooks) cannot override them (self-hosted agents only). This setting also disables plugins.
- **Validate jobs with a pre-bootstrap hook:** Use a [pre-bootstrap hook](/docs/agent/self-hosted/security#restrict-access-by-the-buildkite-agent-controller-strict-checks-using-a-pre-bootstrap-hook) to reject jobs with unexpected repositories, commands, or environment variables before any code is checked out (self-hosted agents only).
- **Customize the bootstrap:** When the agent settings aren't enough, [replace the bootstrap](/docs/agent/self-hosted/security#customize-the-bootstrap) with your own script to control every phase of a job (self-hosted agents only).

<%= audit_area.('buildkite-agent-security') %>

<a id="source-code-security-and-version-control-integrity"></a>
<a id="dependencies-and-package-management"></a>

## <%= security_area.('pipeline-and-supply-chain-integrity')['name'] %>

<%= security_area.('pipeline-and-supply-chain-integrity')['summary'] %> Apply the build trigger controls first, as they determine whether the other controls protect you from users with commit access, or from anyone who can open a pull request or an issue.

### Baseline

- **Keep fork builds disabled on pipelines with secrets:** Keep [builds from third-party forked repositories](/docs/pipelines/source-control/github#running-builds-on-pull-requests) disabled on any pipeline that can access secrets, as a fork can modify the pipeline definition to extract them. If a pipeline needs to accept fork builds, gate them with a block step, as described in [Dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines).
- **Treat issue-triggered builds as untrusted input:** [Builds triggered by issue activity](/docs/pipelines/source-control/github#running-builds-on-additional-github-events-running-builds-on-issue-activity) don't require a trusted author, so any GitHub user can trigger one. Treat issue content as untrusted input in any step that processes it.
- **Keep the agent authoritative over Git flags:** Keep the [agent checkout-override mode](/docs/pipelines/configure/git-checkout#agent-checkout-override-mode) at `from-job` (the default) or `strict`. Only use `none` if you trust everyone who can change your pipeline YAML, as this mode lets the pipeline pass arbitrary Git flags to the agent.
- **Pin plugin versions:** [Pin plugins](/docs/pipelines/integrations/plugins/using#pinning-plugin-versions) to the commit SHA of a tag rather than the tag itself, so that the plugin's contents cannot change after you review it. Prefer [private plugins](/docs/pipelines/integrations/plugins/using#plugin-sources) for sensitive pipelines.
- **Connect source control using the Buildkite GitHub App:** Use the [Buildkite GitHub App integration](/docs/pipelines/source-control/github#connecting-buildkite-and-github) for repository connections, and enforce branch protection rules on [GitHub](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/managing-a-branch-protection-rule) or [GitLab](https://docs.gitlab.com/user/project/repository/branches/protected/).

This baseline is complete when every pipeline with secrets rejects fork builds or gates them with a block step, issue-triggered builds treat issue content as untrusted, the checkout-override mode is `from-job` or `strict` on every agent, every plugin is pinned to a commit SHA, and your default branches are protected.

### Recommended

- **Enable commit verification:** Use [commit verification](/docs/pipelines/configure/git-checkout#commit-verification) to check that the commit being built exists on the branch it claims to be on. Set `git-commit-verification` to `strict` on each supported self-hosted agent while retaining `from-job` or `strict` checkout-override mode. These modes ignore pipeline-level `checkout.commit_verification`. Verification can be skipped or bypassed in some cases, so don't rely on it alone to grant access to protected branches or secrets. Enforce Git commit signatures separately through your source control system's branch protection rules.
- **Defer or disable interpolation in pipeline uploads:** Escape variables with `$$` to [defer their evaluation](/docs/agent/cli/reference/pipeline#environment-variable-substitution-escaping-the-dollars-character) to job runtime, or [disable interpolation](/docs/agent/cli/reference/pipeline#environment-variable-substitution-disabling-interpolation) for an upload. Move logic that handles values an attacker could influence, such as branch names, pull request titles, or issue comments, into scripts checked in to your repository.
- **Scan dependencies and generate SBOMs:** Run automated dependency, malware, and container scanning on every merge, using tools such as [GuardDog](https://github.com/DataDog/guarddog), [Snyk](https://snyk.io/), or [Trivy](https://buildkite.com/resources/plugins/equinixmetal-buildkite/trivy-buildkite-plugin/), and generate a [software bill of materials (SBOM)](https://en.wikipedia.org/wiki/Software_supply_chain) for your packages. Find integrations among the [security and compliance plugins](https://buildkite.com/resources/plugins/category/security-compliance/). Trigger [notifications](/docs/pipelines/configure/notify) and remediation workflows when [critical CVEs](https://www.cve.org/) are found.
- **Make security scans mandatory:** Use [pipeline templates](/docs/pipelines/governance/templates) (Enterprise plan only) and [agent hooks](/docs/agent/hooks) to make sure security scans cannot be removed by editing a `pipeline.yml` file.
- **Verify downloaded artifacts:** Use [`buildkite-agent artifact shasum`](/docs/agent/cli/reference/artifact#fetching-the-sha-of-an-artifact) to check that a downloaded artifact matches the one that was uploaded.
- **Use verified container images:** Build from [verified Docker images](https://docs.docker.com/docker-hub/repos/manage/trusted-content/dvp-program/), and track the exact package versions used in each build, for example, using [annotations](/docs/agent/cli/reference/annotate).

### Advanced

- **Sign your pipelines:** Use [signed pipelines](/docs/agent/self-hosted/security/signed-pipelines) so that agents refuse to run steps that were modified after upload (self-hosted agents only). Keep `verification-failure-behavior` at its default of `block`, sign and verify on separate agents so that the agents that run jobs only hold the verification key, and store signing keys in [AWS KMS](/docs/agent/self-hosted/security/signed-pipelines#aws-kms-managed-key-setup). Verify-only agents must not have `kms:Sign` permission. Signed steps cannot be used with pipeline templates.
- **Publish packages with SLSA provenance:** Generate and publish [SLSA provenance](/docs/package-registries/security/slsa-provenance) attestations with packages in Buildkite Package Registries (Enterprise plan only), or sign artifacts using tools such as [in-toto](https://in-toto.io/) or [cosign](https://github.com/sigstore/cosign), and verify them before deployment.

<%= audit_area.('pipeline-and-supply-chain-integrity') %>

## <%= security_area.('secrets-management')['name'] %>

<%= security_area.('secrets-management')['summary'] %> Buildkite Pipelines supports several ways of providing secrets to a build. In order of preference: use [OIDC](/docs/pipelines/security/oidc) to federate with the target system so that no long-lived credential is stored at all, use an external secrets storage service, or use [Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets). Never store secret values in your pipeline configuration.

### Baseline

- **Keep secrets out of pipeline configuration:** Don't store secrets in [pipeline settings or `pipeline.yml` files](/docs/pipelines/security/secrets/risk-considerations), and don't reference them in a step's `command`, as these values are stored by Buildkite and shown in the Buildkite interface. Don't use [build meta-data](/docs/pipelines/configure/build-meta-data) for secrets either, as it is visible in the Buildkite interface and through the REST API.
- **Use a secrets store:** Store secrets in [Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets) or an external [secrets storage service](/docs/pipelines/security/secrets/managing#using-a-secrets-storage-service), such as AWS Secrets Manager or HashiCorp Vault.
- **Keep the pipeline upload secret check enabled:** The agent rejects pipeline uploads that contain values from secret environment variables. Agent v3 doesn't run this check by default, so pass `--reject-secrets` to `pipeline upload`. Don't use `--allow-secrets` unless you understand the risk. Learn more in [Dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines).
- **Check that your secrets are redacted:** The agent [redacts](/docs/pipelines/configure/managing-log-output#redacted-environment-variables) values of environment variables whose names match a set of patterns. Make sure your variable names match these patterns, or set `redacted-vars` to include them. Setting `redacted-vars` replaces the defaults, so include every default pattern you want to retain. Values shorter than six bytes are never redacted.
- **Never skip redaction:** Don't use the [`--skip-redaction`](/docs/agent/cli/reference/secret#skip-redaction) option of `buildkite-agent secret get`, which prints the secret to the job log when called directly.
- **Scan repositories for committed secrets:** Use secret scanning tools, such as [git-secrets](https://github.com/awslabs/git-secrets), to prevent secrets from being committed to your repositories before they enter the build process.

This baseline is complete when no secret value appears in pipeline settings, `pipeline.yml` files, step commands, or build meta-data, every secret comes from a secrets store and is redacted from job logs, and secret scanning runs on every repository that Buildkite Pipelines builds.

### Recommended

- **Use access policies on Buildkite secrets:** Add an [access policy](/docs/pipelines/security/secrets/buildkite-secrets/access-policies) to each Buildkite secret, so that only matching builds can read it. Prefer [first-party claims](/docs/pipelines/security/secrets/buildkite-secrets/access-policies#policy-schema-first-party-claims), which are generated by Buildkite, over third-party claims, which can be influenced by users.
- **Scope secrets to the steps that need them:** If you [export secrets from an environment hook](/docs/pipelines/security/secrets/managing#without-a-secrets-storage-service-exporting-secrets-with-environment-hooks), export each secret only for the pipeline and step that needs it. For example, don't give test steps access to production deployment credentials. Use separate [clusters](/docs/pipelines/security/clusters/manage) for workloads with different trust requirements. Queues route jobs within a cluster; they don't isolate cluster secrets by themselves.
- **Redact secrets fetched at runtime:** Pass secrets fetched from an external secrets store to [`buildkite-agent redactor add`](/docs/agent/cli/reference/redactor), as these values are not redacted automatically.
- **Use temporary checkout credentials:** For GitHub repositories on self-hosted agents, enable [GitHub App token checkout](/docs/agent/self-hosted/code-access#using-a-buildkite-issued-github-app-token) on the queue to replace long-lived repository credentials with short-lived, read-only tokens. If you need SSH-based checkout, use [`checkout.ssh_secret`](/docs/pipelines/configure/git-checkout#ssh-key-from-buildkite-secrets) instead of distributing SSH keys to every agent. If you keep keys on your agents, prefer read-only deploy keys for each repository.
- **Replace static cloud credentials with OIDC:** Request short-lived [OIDC tokens](/docs/pipelines/security/oidc) in your jobs and exchange them for cloud credentials, for example, with [AWS](/docs/pipelines/security/oidc/aws) or [Azure](/docs/pipelines/security/oidc/azure). Restrict access in your cloud provider's trust policies with immutable claims, such as `organization_id` and `pipeline_id`, rather than mutable slugs.
- **Restrict AWS roles with OIDC session tags:** Match the required subject claim and use `aws:RequestTag` conditions to narrow the [AWS trust policy](/docs/pipelines/security/oidc/aws#step-2-create-a-new-or-update-an-existing-iam-role-to-use-with-your-pipelines). Pass the corresponding claims as session tags so that role assumptions can be traced in [CloudTrail](/docs/pipelines/security/oidc/aws#aws-cloudtrail).
- **Rotate secrets regularly:** Rotate secrets on a schedule, even when you have no reason to believe they have been compromised, and automate rotation where possible.

### Advanced

- **Choose the OIDC subject claim deliberately:** Use a [custom subject claim](/docs/agent/cli/reference/oidc#custom-subject-claims) to set the scope of each trust relationship, and inspect a token's `sub` claim before writing a trust policy that matches it exactly.
- **Compensate for single-claim matching in Azure:** Azure federated identity credentials match only on the subject, so any build that produces a matching token can authenticate. Apply the mitigations in [OIDC with Azure known limitations](/docs/pipelines/security/oidc/azure#known-limitations), such as enabling OIDC only on deployment pipelines whose triggers you control.

<%= audit_area.('secrets-management') %>

<a id="network-and-transport-security"></a>
<a id="artifact-storage-and-integrity"></a>

## <%= security_area.('network-and-data-exposure')['name'] %>

<%= security_area.('network-and-data-exposure')['summary'] %> Buildkite encrypts all platform communications with TLS by default.

### Baseline

- **Allow only outbound connections from self-hosted agents:** Self-hosted agents only make outbound HTTPS connections. Run them in private networks, and allow only the [hosts they require](/docs/agent/self-hosted/security/network-requirements) (self-hosted agents only).
- **Limit access to cloud instance metadata:** Build jobs can reach [cloud instance metadata endpoints](/docs/agent/self-hosted/security/network-requirements#optional-hosts-cloud-instance-metadata) and act with the instance's IAM permissions. [Restrict this access](/docs/agent/self-hosted/aws/architecture/securing-your-setup) and grant your agent instances only the permissions they need.
- **Verify outbound webhooks with signatures:** Configure webhook notifications to send a [webhook signature](/docs/apis/webhooks/pipelines#webhook-signature) rather than a plain token, verify the HMAC signature in your receiver, and reject stale timestamps to [defend against replay attacks](/docs/apis/webhooks/pipelines#webhook-signature-defending-against-replay-attacks).
- **Keep public pipelines disabled:** A [public pipeline](/docs/pipelines/configure/public-pipelines) gives anyone read access to its builds, logs, and artifacts. Keep public pipeline creation disabled unless your project is open source, and restrict who can change pipeline visibility (Enterprise plan only). On other plans, check pipeline visibility as part of your [regular access review](#monitoring-and-detection-baseline).
- **Make artifacts in your own S3 bucket private:** When the agent uploads artifacts to [your own Amazon S3 bucket](/docs/agent/cli/reference/artifact#using-your-private-aws-s3-bucket), it uses the `public-read` ACL by default. For buckets with ACLs enabled, set `BUILDKITE_S3_ACL` to `private`. For [ACL-disabled buckets](https://docs.aws.amazon.com/AmazonS3/latest/userguide/about-object-ownership.html), set it to `bucket-owner-full-control` and restrict access using bucket policies. Enable server-side encryption. Learn more in [Access control](/docs/agent/cli/reference/artifact#using-your-private-aws-s3-bucket-access-control).

This baseline is complete when your self-hosted agents can only connect to the hosts they require, builds can't use instance permissions beyond what they need, every webhook receiver verifies signatures, every public pipeline is intentionally public, and artifacts in your own buckets are private.

### Recommended

- **Use OIDC for Buildkite hosted agents:** Have your services authenticate Buildkite hosted agents with OIDC rather than by IP address, as [hosted agent IP address ranges](/docs/agent/buildkite-hosted/network-security) are shared between Buildkite customers.
- **Get Buildkite IP addresses from the Meta API:** For allowlists on your own services, fetch the current Buildkite platform IP addresses from the [Meta API](/docs/apis/rest-api/meta) rather than maintaining a fixed list.
- **Filter incoming webhooks by IP address:** If you use a self-hosted source control system, such as GitHub Enterprise Server, enter its IP addresses to [filter incoming webhooks](/docs/pipelines/security/incoming-webhooks#what-security-information-is-stored-in-the-secret-in-a-buildkite-url). Webhooks from GitHub-hosted repositories are filtered automatically. A pipeline's webhook URL contains its secret, so treat the URL as a credential.
- **Match GitHub App permissions to your checkout method:** If you run builds only on self-hosted agents and manage checkout credentials yourself, use the [GitHub (Limited Access)](/docs/pipelines/source-control/github#github-repository-provider-options) app, which has no code access. For Buildkite-managed GitHub App token checkout, use the full-access **GitHub** app with access limited to the repositories your jobs need.
- **Treat build status badges as public:** [Build status badges](/docs/pipelines/integrations/other/build-status-badges) don't require authentication, so don't publish badges for pipelines whose build status is sensitive.
- **Review remote access to Buildkite hosted agents:** Periodically review whether [remote access to hosted agents](/docs/apis/rest-api/organizations/pipeline-settings#enable-hosted-agents-remote-access) is enabled, and monitor the `JOB_TERMINAL_SESSION_STARTED` [audit log](/docs/platform/audit-log) event.
- **Use instance roles for artifact uploads:** Use instance role credentials and an [IAM policy](/docs/agent/cli/reference/artifact#using-your-private-aws-s3-bucket-iam-permissions) scoped to your artifacts bucket, instead of long-lived access keys.
- **Store artifacts in private, encrypted storage:** Use [Buildkite Package Registries](/docs/package-registries) or private cloud storage, such as [Amazon S3](/docs/agent/cli/reference/artifact#using-your-private-aws-s3-bucket), [Google Cloud Storage](/docs/agent/cli/reference/artifact#using-your-private-google-cloud-bucket), or [Azure Blob Storage](/docs/agent/cli/reference/artifact#using-your-private-azure-blob-container), with encryption at rest and in transit.

### Advanced

- **Route agent traffic through a proxy:** [Run your agents behind a proxy](/docs/agent/self-hosted/security#run-the-agent-behind-a-proxy) that you monitor to log traffic routed through it (self-hosted agents only). Configure network egress restrictions separately; proxy environment variables alone don't force all build traffic through the proxy.
- **Apply zero trust networking:** Apply a [zero trust architecture](https://www.ibm.com/think/topics/zero-trust) with least-privilege egress rules for self-hosted agents, and keep traffic to cloud services private using [AWS PrivateLink](https://docs.aws.amazon.com/vpc/latest/privatelink/what-is-privatelink.html), [VPC endpoints](https://docs.aws.amazon.com/vpc/latest/privatelink/create-interface-endpoint.html), or [Private Google Access](https://cloud.google.com/vpc/docs/private-google-access).
- **Keep workflow-scoped GitHub access tokens disabled:** Only enable [workflow-scoped GitHub access tokens](/docs/pipelines/source-control/github#workflow-scoped-github-access-tokens) if you trust everyone who can create a build at an arbitrary commit, as the token permissions are read from the workflow file at that commit.
- **Keep build data in storage you control:** Configure [build exports](/docs/apis/rest-api/organizations/pipeline-settings#configure-build-export) and [job log archiving](/docs/pipelines/governance/job-log-archiving) to your own storage (Enterprise plan only).

<%= audit_area.('network-and-data-exposure') %>

<a id="monitoring-anomaly-detection-logging"></a>

## <%= security_area.('monitoring-and-detection')['name'] %>

<%= security_area.('monitoring-and-detection')['summary'] %> The controls in this section determine whether you detect these problems, and how quickly.

### Baseline

- **Review access on a schedule:** At least monthly, review the [API access audit](/docs/apis/managing-api-tokens#auditing-tokens) page, the members and administrators of your Buildkite organization, the visibility of your pipelines, and the agents connected to each cluster. These reviews are available on every plan.
- **Review the audit log:** Use the [audit log](/docs/platform/audit-log) to review changes to tokens, users, SSO settings, pipelines, and secrets in your Buildkite organization (Enterprise plan only). On other plans, stream **Agent Connected** and **Agent Blocked** events to your monitoring system using [Amazon EventBridge](/docs/pipelines/integrations/observability/amazon-eventbridge) or [agent webhooks](/docs/apis/webhooks/pipelines/agent-events), so that you detect unexpected agents between reviews.

This baseline is complete when a named person runs the access review on a fixed schedule and records what they checked, and either reviews the audit log or receives agent events.

### Recommended

- **Stream audit events to your SIEM:** Use [Amazon EventBridge](/docs/pipelines/integrations/observability/amazon-eventbridge) to send audit log events to your [security information and event management (SIEM)](https://en.wikipedia.org/wiki/Security_information_and_event_management) system.
- **Alert on security-relevant events:** Create alerts for the [logged events](/docs/platform/audit-log#logged-events) that matter most, such as agent token and API access token changes, SSO provider changes, secret access, pipeline visibility changes, and terminal sessions. Also alert on unusual IP addresses, secret access patterns, and spikes in build frequency.
- **Remove inactive users:** Review the [inactive user list](/docs/platform/team-management/inactive-user-list) regularly, and remove users who no longer need access (Enterprise plan only). To remove access as soon as a user is removed from your identity provider, [automate deprovisioning with SCIM](#authentication-and-access-control-recommended).
- **Export metrics to your observability platform:** Send Buildkite Pipelines metrics to your monitoring platform, for example, using [OpenTelemetry](/docs/pipelines/integrations/observability/opentelemetry), to maintain visibility across pipeline activity.

<%= audit_area.('monitoring-and-detection') %>

<a id="consistent-pipeline-as-code-approach"></a>

## <%= security_area.('governance-and-configuration-management')['name'] %>

<%= security_area.('governance-and-configuration-management')['summary'] %>

### Baseline

- **Keep pipeline steps in version control:** Keep only the `buildkite-agent pipeline upload` step in each pipeline's YAML steps editor, and define the remaining steps in a [`pipeline.yml` file](/docs/pipelines/configure/defining-steps#step-defaults-pipeline-dot-yml-file) in the repository, so that pipeline changes go through code review and branch protection.
- **Assign an owner to each area:** Name an owner for each area on this page, who decides which controls apply and tracks the gaps.

This baseline is complete when the steps of every production pipeline come from a reviewed `pipeline.yml` file, and every area on this page has a named owner.

### Recommended

- **Manage configuration as code:** Manage pipelines, teams, and agent tokens using the [Buildkite Terraform provider](/docs/platform/terraform-provider). Require two reviewers for changes to production security configuration, and use a dedicated service account to apply approved changes.
- **Restrict manual configuration changes:** Make pipelines **Read Only** for teams, so that only your infrastructure-as-code workflow and Buildkite organization administrators can change them. Alert on manual changes in your SIEM, and document a break-glass process for emergencies.
- **Enforce policies with agent hooks:** Use [agent hooks](/docs/agent/hooks) to enforce policies that cannot be bypassed by changing a `pipeline.yml` file, for example, to validate pipeline definitions against your security requirements.

### Advanced

- **Enforce agent configuration:** Use [ephemeral agents](/docs/pipelines/glossary#ephemeral-agent), or configuration management tools such as [Ansible](https://docs.ansible.com/) or [Puppet](https://www.puppet.com/), to keep agent configuration consistent and prevent drift on persistent hosts.

<%= audit_area.('governance-and-configuration-management') %>

<a id="incident-response-and-recovery"></a>

## <%= security_area.('incident-readiness')['name'] %>

<%= security_area.('incident-readiness')['summary'] %> Several incident response actions require help from Buildkite support. If you suspect an active compromise, follow [Incident response](/docs/platform/security/incident-response) for containment, investigation, and recovery steps.

### Baseline

- **Write and test an incident response runbook:** Give the runbook a named owner and store it where responders can reach it during an outage. Document containment actions and who can authorize them. Rehearse the runbook at least once in a test environment, and record the outcome.
- **Assign responders and record support contacts:** Name an incident lead and backup. Record support@buildkite.com, security@buildkite.com, and any emergency support contact available under your plan. Notify Buildkite support immediately when you discover an incident, and the security team for exposed secrets. Learn more in [Prepare before an incident](/docs/platform/security/incident-response#prepare-before-an-incident).
- **Document how to revoke access:** Rehearse [removing a compromised user](/docs/platform/security/incident-response#contain-the-incident-remove-a-compromised-user) from your Buildkite organization and disabling their identity provider account, so they can't rejoin using SSO. Include [removing organization access from compromised API tokens](/docs/platform/security/incident-response#contain-the-incident-revoke-compromised-tokens). Ask Buildkite support to end platform-wide user sessions when needed.
- **Prepare agent token revocation and agent shutdown:** Record the cluster and token IDs and the [agent token revocation request](/docs/apis/rest-api/clusters/agent-tokens#revoke-a-token) in your runbook. Revoking a token stops new registrations, not connected agents. Rehearse stopping or replacing affected self-hosted agents and canceling unwanted jobs; draining alone lets a running job finish.
- **Rehearse secret rotation:** In a test environment, replace a credential, update the secrets store, and verify that the new credential works and the old one is rejected. Include credentials for downstream systems, not just Buildkite tokens. Use [Rotate exposed secrets](/docs/platform/security/incident-response#contain-the-incident-rotate-exposed-secrets) as the response procedure.
- **Test emergency account recovery:** If you use SSO, validate the dedicated break-glass account and its [authentication, storage, and monitoring controls](/docs/platform/security/incident-response#prepare-before-an-incident). For other setups, verify that responders can access the administrator account and its 2FA recovery codes through your approved recovery process.

This baseline is complete when responders can reach the tested runbook and escalation contacts, remove user and token access, stop affected agents and jobs, rotate credentials, and recover administrator access. Record the test dates and any gaps that still need an owner.

### Recommended

- **Prepare to stop unwanted builds:** Document the [incoming GitHub webhook control, separate trigger controls, and build cancellation steps](/docs/platform/security/incident-response#contain-the-incident-stop-unwanted-builds) for each affected pipeline. Disabling webhook processing doesn't block every trigger or cancel existing builds. Rehearse containment in a test pipeline, and confirm unwanted jobs have stopped before resuming builds.
- **Plan support-assisted investigation:** Record how to request an [access-log investigation](/docs/platform/security/incident-response#investigate-the-incident) into who accessed exposed builds. Include the incident window and affected build IDs. Ask about restoring older access logs if you have the Enterprise plan, and confirm availability before relying on them.

### Advanced

- **Rehearse SSO reauthorization safely:** In a test organization, rehearse [disabling and re-enabling SSO](/docs/platform/team-management/permissions#removing-users-during-a-security-incident-disabling-and-re-enabling-sso) with a dedicated optional-SSO administrator account ready. Disabling SSO rescinds every active SSO authorization, including the administrator's. API access tokens are unaffected, so this doesn't replace user and token revocation.
- **Automate tested revocation and rotation:** Automate the revocation and rotation procedures you've already rehearsed. Test target selection, approvals, failure handling, and rejection of old credentials in a test environment. Keep a manual fallback if the automation or its credentials are unavailable.

<%= audit_area.('incident-readiness') %>

## <%= security_area.('security-controls')['name'] %>

<%= security_area.('security-controls')['summary'] %>

For more information, see [Enforcing security controls](/docs/platform/security/enforcing-security-controls).

### Baseline

- **Choose enforcement points outside repository control:** Enforce permissions, required checks, and credential access where build authors cannot change them. Use organization permissions, protected self-hosted agent hooks, secret access policies, or cloud trust policies as appropriate.
- **Restrict changes to controls:** Limit who can edit security policies, agent configuration, hooks, and pipeline or template settings. Protect configuration changes with required reviews. Use **Build & Read** or **Read Only** instead of **Full Access** for teams that don't need to change pipelines.
- **Test allowed and denied actions:** Use a non-administrator test account and non-production build resources. Confirm that intended work succeeds, prohibited changes and access are rejected, and removing a required check from a repository cannot skip it. Repeat for each build source you allow.

This baseline is complete when every mandatory control has an owner, a protected enforcement location, and recorded results showing that allowed actions succeed and denied actions fail.

### Recommended

- **Enforce restrictions on every receiving agent:** Test restrictions on every self-hosted agent pool that can receive protected jobs, not just the pipeline-upload agent. Protect configuration and hooks from build jobs. Disabling command evaluation doesn't protect against malicious checked-in scripts or constrain a custom `command` hook. For hosted workloads, use permissions, protected definitions, clusters, and credential policies instead.
- **Verify workload and credential boundaries:** Use separate clusters for production and untrusted workloads, not just separate queues. Test secret and cloud access with both an allowed build and a build from a different pipeline, branch, or cluster that should be denied. Cloud trust policies must check the claims and any session tags they rely on.
- **Enforce the pipeline upload secret check:** For agent v3, use `buildkite-agent pipeline upload --reject-secrets`. Protect the upload process outside the repository when this check must be mandatory. Verify rejection with a non-sensitive test value longer than six bytes in a matching secret variable, as described in [Keep secrets out of uploaded pipelines](/docs/platform/security/enforcing-security-controls#keep-secrets-out-of-uploaded-pipelines).

### Advanced

- **Verify signed-step enforcement:** For signed pipelines, keep verification failures set to `block`, separate signing agents from verify-only agents, and ensure verify-only agents have no `kms:Sign` permission. Test that an invalid signature is rejected. Signed steps cannot be used with pipeline templates.

<%= audit_area.('security-controls') %>

## Audit guidance

Choose the [hosted or self-hosted agent controls](#buildkite-agent-security) that apply to your queues. If you use both, review both sections. Plan-specific controls name their requirements or alternatives.

_Baseline_ covers foundational protections, _Recommended_ adds protections for production delivery, and _Advanced_ covers specialized threats and higher-consequence workloads.

Record controls that don't apply, outstanding work, owners, and review dates in your own tracking system. Checklist selections aren't saved in your Buildkite organization.

Each area ends with _Audit this area_, with API and CLI examples, MCP prompts, and checks that require a manual review. Start with the [authentication and access audit](#authentication-and-access-control-audit-this-area), or choose an area from the table of contents. Use a token with the documented read scopes and access to the resources under review. Set `ORG_SLUG`, `PIPELINE_SLUG`, and `CLUSTER_ID` to your own values where used. Examples that use `bk` require an authenticated [Buildkite CLI](/docs/platform/cli) installation; commands that filter JSON also require `jq`.

List examples show the first page only. Follow [pagination](/docs/apis/rest-api#pagination) before treating an inventory as complete. Audit events use cursor pagination: follow the response's `links.next` URL. Use [read-only MCP access](/docs/apis/mcp-server#read-only-remote-mcp-server), replace the example organization and pipeline names in prompts, and verify the results. A prompt is not an access control.

Review the baseline in each area, then use its completion criteria to verify your setup. Counts include alternatives and controls for different plans and hosting models, so completing every item isn't the goal.

For the responsibilities Buildkite and your organization share, see the [Security overview](/docs/platform/security#shared-responsibility). For more information about making controls mandatory, see [Enforcing security controls](/docs/platform/security/enforcing-security-controls).

## Further questions

If you didn't find coverage of a security-related question that interests you here, contact support@buildkite.com.
