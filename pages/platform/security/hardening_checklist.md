# Security hardening checklist

This checklist brings together the security controls available across the Buildkite platform, [Buildkite Pipelines](/docs/pipelines), and [Buildkite Package Registries](/docs/package-registries) into a single reference. Each item describes what to configure and why, and links to the page that documents the control in detail.

Use this checklist when you set up a new Buildkite organization, review an existing Buildkite organization against a security baseline, or prepare for a security audit. To prepare a response plan for a suspected compromise, see [Incident response](/docs/platform/security/incident-response).

## How to use this checklist

A CI/CD environment holds credentials for the systems it builds and deploys to, and runs code from every commit pushed to the repositories it builds. Hardening a Buildkite organization means working in two directions: restricting what a job can reach, and restricting who can change what a job does.

The controls on this page are grouped by area. Within each area, the controls are split into three tiers, which you can work through in order:

- **Baseline:** Low-friction controls that any Buildkite organization handling production credentials should apply first.
- **Recommended:** The target state for teams running production deployments from Buildkite Pipelines.
- **Advanced:** Controls for organizations that treat their build system as part of their trusted computing base.

Some controls carry a label in parentheses:

- **(Enterprise plan only)** or **(Pro and Enterprise plans)**: The control requires that [Buildkite plan](https://buildkite.com/pricing).
- **(self-hosted agents only)**: The control applies to [self-hosted agents](/docs/agent/self-hosted) and is not available on [Buildkite hosted agents](/docs/agent/buildkite-hosted).

> 📘 Choosing between self-hosted and Buildkite hosted agents
> For small teams with limited experience in hosting and hardening infrastructure, Buildkite hosted agents provide a secure, fully managed solution that reduces operational overhead. Organizations with stringent governance, risk, and compliance (GRC) requirements should consider running their most sensitive workloads on self-hosted agents, as this approach offers greater control over security configurations, network boundaries, and compliance controls. Learn more in [Buildkite hosted agents network security](/docs/agent/buildkite-hosted/network-security#considerations-build-infrastructure-segmentation-best-practices).

## Authentication and access control

These controls govern who can sign in to your Buildkite organization, what they can change, and how much a compromised credential can reach.

### Baseline

- **Enforce single sign-on (SSO) or two-factor authentication (2FA):** Require users to log in through your identity provider with [SSO](/docs/platform/sso) (Pro and Enterprise plans), or [enforce 2FA](/docs/platform/team-management/enforce-2fa) for all members. Enforcing SSO for your entire Buildkite organization requires 2FA enforcement to be disabled, so decide which approach applies before you configure either. Users without 2FA lose access immediately when 2FA is enforced, and existing API access tokens continue to work.
- **Enable teams and reduce the Everyone team:** Without [teams](/docs/platform/team-management/permissions#manage-teams-and-permissions), every user can access every pipeline. Enabling teams creates an **Everyone** team that preserves existing access, so create narrower teams and remove pipelines from the **Everyone** team.
- **Grant the lowest pipeline permission that works:** Give teams that don't need to change a pipeline the **Build & Read** or **Read Only** [pipeline-level permission](/docs/pipelines/security/permissions#manage-teams-and-permissions-pipeline-level-permissions). Apply the same approach to [registry permissions](/docs/package-registries/security/permissions). Once a team loses **Full Access**, only another team with **Full Access** or a Buildkite organization administrator can restore it.
- **Scope and expire API access tokens:** Grant each [API access token](/docs/apis/managing-api-tokens) only the [scopes](/docs/apis/managing-api-tokens#token-scopes) it needs, and set a short **Token Expiry**. Tokens using the **Public Key** credential type don't expire, so track them separately in your [rotation](/docs/apis/managing-api-tokens#api-token-security-rotation) process.
- **Audit API access tokens regularly:** Review every token with access to your Buildkite organization on the [API access audit](/docs/apis/managing-api-tokens#auditing-tokens) page, and [remove your organization](/docs/apis/managing-api-tokens#auditing-tokens-removing-an-organization-from-a-token) from tokens that are stale or over-scoped.

### Recommended

- **Limit SSO session duration:** Set an [SSO session duration](/docs/platform/sso#sso-session-duration) so that sessions don't stay valid indefinitely.
- **Automate deprovisioning with SCIM:** Configure SCIM provisioning for [Okta](/docs/platform/sso/okta#using-scim-to-provision-and-manage-users) or [Microsoft Entra ID](/docs/platform/sso/azure-ad#using-scim-to-provision-and-manage-users) (Enterprise plan only), so that removing a user from your identity provider also removes their access to Buildkite. Users who joined before SCIM was configured need to be [synced](/docs/platform/sso/okta#using-scim-to-provision-and-manage-users-syncing-existing-users-for-deprovisioning) before SCIM can remove them.
- **Restrict organization-wide actions:** Use the **Security** page to control who can delete pipelines, change pipeline visibility, manage notification services, manage agent tokens, and stop agents, across all users of your Buildkite organization (Enterprise plan only). Learn more in [Manage organization security for pipelines](/docs/pipelines/security/permissions#manage-organization-security-for-pipelines).
- **Revoke inactive API access tokens automatically:** Configure [inactive API token revocation](/docs/apis/managing-api-tokens#inactive-api-tokens-revocation) so that forgotten tokens are revoked after a set period (Enterprise plan only).
- **Restrict who can create API access tokens:** Set `restrict_user_api_token_creation` using the [API settings](/docs/apis/rest-api/organizations/api-settings) endpoint, so that only Buildkite organization administrators can create new API access tokens.
- **Check who can trigger builds:** Map Buildkite users to their source control identities with [team-based permissions](/docs/platform/team-management/permissions#manage-teams-and-permissions-team-level-permissions), and use [agent hooks](/docs/agent/hooks) with [programmatic team management](/docs/platform/team-management/permissions#manage-teams-and-permissions-programmatically-managing-teams) to check that a commit author is allowed to trigger a build before it runs. See the [agent hooks example](https://buildkite.com/resources/examples/buildkite/agent-hooks-example/) for a working implementation.
- **Limit GraphQL access with portals:** API access tokens with GraphQL access can run any GraphQL query. Use [portals](/docs/apis/graphql/portals) to expose only the specific GraphQL operations that an integration needs.
- **Use the remote MCP server:** When using the [Buildkite MCP server](/docs/apis/mcp-server), prefer the [remote MCP server](/docs/apis/mcp-server#types-of-mcp-servers-remote-mcp-server), which issues short-lived OAuth access tokens, over a local MCP server configured with a long-lived API access token.

### Advanced

- **Pin SSO sessions to IP addresses:** Enable [SSO session IP address pinning](/docs/platform/sso#sso-session-ip-address-pinning) so that users must re-authenticate when their IP address changes (Enterprise plan only).
- **Restrict API access by IP address:** Set an organization-wide [IP address allowlist](/docs/apis/managing-api-tokens#restricting-api-access-by-ip-address) for the REST and GraphQL APIs (Enterprise plan only). The allowlist takes effect immediately, so confirm that it includes your own IP addresses before you save it.
- **Use OAuth Token Exchange for services:** Instead of giving a service a long-lived API access token tied to a user, use [OAuth Token Exchange](/docs/apis/oauth-token-exchange) to issue short-lived tokens with a limited lifetime and scope.

## Buildkite agent security

These controls harden the infrastructure that runs your builds. The agent controls in this section protect your infrastructure if the Buildkite control plane is compromised. To protect against users with commit access to your repositories, see also [Pipeline and supply chain integrity](#pipeline-and-supply-chain-integrity).

### Baseline

- **Run every pipeline and agent in a cluster:** [Clusters](/docs/pipelines/security/clusters) isolate pipelines and agents from each other. Run pipelines with sensitive builds on dedicated agents in their own cluster, so that a compromise of a less trusted environment, such as an open source repository, cannot reach them. Limit who can manage a cluster's agent tokens by assigning [cluster maintainers](/docs/pipelines/security/clusters/manage#manage-maintainers-on-a-cluster).
- **Give agent tokens an expiry and a rotation plan:** [Create agent tokens using the API](/docs/agent/self-hosted/tokens#agent-token-lifetime) with an expiration date, so that you can automate rotation. Agent tokens created in the Buildkite interface don't expire. Store agent tokens in a secrets manager, and [revoke](/docs/agent/self-hosted/tokens#revoke-a-token) tokens you no longer use.
- **Restrict or disable plugins:** Use the agent's [plugin allowlist](/docs/agent/self-hosted/security#restrict-access-by-the-buildkite-agent-controller-allow-a-list-of-plugins) to restrict which plugin sources can run, or [disable plugins](/docs/agent/self-hosted/security#restrict-access-by-the-buildkite-agent-controller-disable-plugins) if you don't use them (self-hosted agents only). Anchor and escape your regular expressions, and apply the same configuration to every agent, as the allowlist is enforced by each agent individually.
- **Force clean checkouts for untrusted builds:** Set `BUILDKITE_CLEAN_CHECKOUT` on steps that build untrusted code, such as third-party pull requests, so that files from a previous checkout don't persist. Learn more in [Force clean checkouts](/docs/agent/self-hosted/security#force-clean-checkouts).
- **Set command timeouts:** Use [command timeouts](/docs/pipelines/configure/build-timeouts#command-timeouts) to limit how long malicious code can run on a compromised agent.
- **Upgrade your agents regularly:** [Upgrade your Buildkite agents](/docs/agent/self-hosted/install#upgrade-agents) to receive security fixes and new security controls.

### Recommended

- **Restrict agent tokens by IP address:** Set **Allowed IP Addresses** on each agent token, so that a leaked token cannot be used outside your network. Learn more in [Restrict an agent token's access by IP address](/docs/pipelines/security/clusters/manage#restrict-an-agent-tokens-access-by-ip-address), including the limitations of this feature.
- **Disable command evaluation:** [Disable command evaluation](/docs/agent/self-hosted/security#restrict-access-by-the-buildkite-agent-controller-disable-command-evaluation) on agents that run untrusted code, so that they only run scripts checked in to the repository (self-hosted agents only). This setting also disables plugins. Other tools in a job can still be influenced through environment variables, so combine this setting with a [pre-bootstrap hook](/docs/agent/self-hosted/security#restrict-access-by-the-buildkite-agent-controller-strict-checks-using-a-pre-bootstrap-hook) or the [environment variable allowlist](/docs/agent/cli/reference/start#enable-environment-variable-allowlist).
- **Allowlist repositories:** Use the agent's [`allowed-repositories`](/docs/agent/cli/reference/start#allowed-repositories) setting to restrict which repositories an agent can clone (self-hosted agents only).
- **Require strict SSH host key checking:** [Require strict SSH host key checking](/docs/agent/self-hosted/security#require-strict-ssh-host-key-checking) against your own `known_hosts` file, instead of trusting unknown hosts on first connection (self-hosted agents only).
- **Use ephemeral and isolated build environments:** Run [ephemeral agents](/docs/pipelines/glossary#ephemeral-agent) in isolated virtual machines or containers with minimal operating systems, no inbound SSH access, and strict network egress controls.
- **Protect the Kubernetes pod spec:** On the [Agent Stack for Kubernetes](/docs/agent/self-hosted/agent-stack-k8s), enable [`prohibit-kubernetes-plugin`](/docs/agent/self-hosted/agent-stack-k8s/securing-the-stack) so that pipelines cannot override the controller-defined pod spec.
- **Review the Elastic CI Stack for AWS security guidance:** If you run the [Elastic CI Stack for AWS](/docs/agent/self-hosted/aws/elastic-ci-stack), review its [security considerations](/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/security). Run the stack in your own VPC, store the agent token in AWS Secrets Manager, and limit build access to the [Amazon EC2 instance metadata](/docs/agent/self-hosted/aws/architecture/securing-your-setup).
- **Audit cluster rules:** Clusters are isolated from each other by default. Create [rules](/docs/pipelines/security/clusters/rules) only where pipelines need to trigger builds or read artifacts across clusters, and review each rule as a deliberate grant of access.

### Advanced

- **Use job acquisition tokens for ephemeral agents:** Have your stack controller issue a [job acquisition token](/docs/agent/self-hosted/job-acquisition-tokens) for each job, so that a compromised job cannot read the long-lived agent token. The Agent Stack for Kubernetes uses job acquisition tokens by default.
- **Disable repository hooks:** If you enforce policies with agent hooks, [disable local hooks](/docs/agent/self-hosted/security#restrict-access-by-the-buildkite-agent-controller-disable-local-hooks) so that [repository hooks](/docs/agent/hooks#hook-locations-repository-hooks) cannot override them (self-hosted agents only). This setting also disables plugins.
- **Validate jobs with a pre-bootstrap hook:** Use a [pre-bootstrap hook](/docs/agent/self-hosted/security#restrict-access-by-the-buildkite-agent-controller-strict-checks-using-a-pre-bootstrap-hook) to reject jobs with unexpected repositories, commands, or environment variables before any code is checked out (self-hosted agents only).
- **Customize the bootstrap:** When the agent settings aren't enough, [replace the bootstrap](/docs/agent/self-hosted/security#customize-the-bootstrap) with your own script to control every phase of a job (self-hosted agents only).

## Pipeline and supply chain integrity

These controls protect the integrity of what your pipelines run: the steps, the plugins and dependencies, the commit being built, and the artifacts produced. Apply the build trigger controls first, as they determine whether the other controls protect you from users with commit access, or from anyone who can open a pull request or an issue.

### Baseline

- **Keep fork builds disabled on pipelines with secrets:** Keep [builds from third-party forked repositories](/docs/pipelines/source-control/github#running-builds-on-pull-requests) disabled on any pipeline that can access secrets, as a fork can modify the pipeline definition to extract them. If a pipeline needs to accept fork builds, gate them with a block step, as described in [Dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines).
- **Treat issue-triggered builds as untrusted input:** [Builds triggered by issue activity](/docs/pipelines/source-control/github#running-builds-on-additional-github-events-running-builds-on-issue-activity) don't require a trusted author, so any GitHub user can trigger one. Treat issue content as untrusted input in any step that processes it.
- **Keep the agent authoritative over Git flags:** Keep the [agent checkout-override mode](/docs/pipelines/configure/git-checkout#agent-checkout-override-mode) at `from-job` (the default) or `strict`. Only use `none` if you trust everyone who can change your pipeline YAML, as this mode lets the pipeline pass arbitrary Git flags to the agent.
- **Pin plugin versions:** [Pin plugins](/docs/pipelines/integrations/plugins/using#pinning-plugin-versions) to the commit SHA of a tag rather than the tag itself, so that the plugin's contents cannot change after you review it. Prefer [private plugins](/docs/pipelines/integrations/plugins/using#plugin-sources) for sensitive pipelines.
- **Connect source control using the Buildkite GitHub App:** Use the [Buildkite GitHub App integration](/docs/pipelines/source-control/github#connecting-buildkite-and-github) for repository connections, and enforce branch protection rules on [GitHub](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/managing-a-branch-protection-rule) or [GitLab](https://docs.gitlab.com/user/project/repository/branches/protected/).

### Recommended

- **Enable commit verification:** Use [commit verification](/docs/pipelines/configure/git-checkout#commit-verification) to check that the commit being built exists on the branch it claims to be on. Verification can be skipped or bypassed in some cases, so don't rely on it alone to grant access to protected branches or secrets.
- **Defer or disable interpolation in pipeline uploads:** Escape variables with `$$` to [defer their evaluation](/docs/agent/cli/reference/pipeline#environment-variable-substitution-escaping-the-dollars-character) to job runtime, or [disable interpolation](/docs/agent/cli/reference/pipeline#environment-variable-substitution-disabling-interpolation) for an upload. Move logic that handles values an attacker could influence, such as branch names, pull request titles, or issue comments, into scripts checked in to your repository.
- **Scan dependencies and generate SBOMs:** Run automated dependency, malware, and container scanning on every merge, using tools such as [GuardDog](https://github.com/DataDog/guarddog), [Snyk](https://snyk.io/), or [Trivy](https://buildkite.com/resources/plugins/equinixmetal-buildkite/trivy-buildkite-plugin/), and generate a [software bill of materials (SBOM)](https://en.wikipedia.org/wiki/Software_supply_chain) for your packages. Find integrations among the [security and compliance plugins](https://buildkite.com/resources/plugins/category/security-compliance/). Trigger [notifications](/docs/pipelines/configure/notify) and remediation workflows when [critical CVEs](https://www.cve.org/) are found.
- **Make security scans mandatory:** Use [pipeline templates](/docs/pipelines/governance/templates) (Enterprise plan only) and [agent hooks](/docs/agent/hooks) to make sure security scans cannot be removed by editing a `pipeline.yml` file.
- **Verify downloaded artifacts:** Use [`buildkite-agent artifact shasum`](/docs/agent/cli/reference/artifact#fetching-the-sha-of-an-artifact) to check that a downloaded artifact matches the one that was uploaded.
- **Use verified container images:** Build from [verified Docker images](https://docs.docker.com/docker-hub/repos/manage/trusted-content/dvp-program/), and track the exact package versions used in each build, for example, using [annotations](/docs/agent/cli/reference/annotate).

### Advanced

- **Sign your pipelines:** Use [signed pipelines](/docs/agent/self-hosted/security/signed-pipelines) so that agents refuse to run steps that were modified after upload (self-hosted agents only). Keep `verification-failure-behavior` at its default of `block`, sign and verify on separate agents so that the agents that run jobs only hold the verification key, and store signing keys in [AWS KMS](/docs/agent/self-hosted/security/signed-pipelines#aws-kms-managed-key-setup). Signed steps cannot be used with pipeline templates.
- **Publish packages with SLSA provenance:** Generate and publish [SLSA provenance](/docs/package-registries/security/slsa-provenance) attestations with packages in Buildkite Package Registries (Enterprise plan only), or sign artifacts using tools such as [in-toto](https://in-toto.io/) or [cosign](https://github.com/sigstore/cosign), and verify them before deployment.

## Secrets management

Buildkite Pipelines supports several ways of providing secrets to a build. In order of preference: use [OIDC](/docs/pipelines/security/oidc) to federate with the target system so that no long-lived credential is stored at all, use an external secrets storage service, or use [Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets). Never store secret values in your pipeline configuration.

### Baseline

- **Keep secrets out of pipeline configuration:** Don't store secrets in [pipeline settings or `pipeline.yml` files](/docs/pipelines/security/secrets/risk-considerations), and don't reference them in a step's `command`, as these values are stored by Buildkite and shown in the Buildkite interface. Don't use [build meta-data](/docs/pipelines/configure/build-meta-data) for secrets either, as it is visible in the Buildkite interface and through the REST API.
- **Use a secrets store:** Store secrets in [Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets) or an external [secrets storage service](/docs/pipelines/security/secrets/managing#using-a-secrets-storage-service), such as AWS Secrets Manager or HashiCorp Vault.
- **Keep the pipeline upload secret check enabled:** The agent rejects pipeline uploads that contain values from secret environment variables. Agent v3 doesn't run this check by default, so pass `--reject-secrets` to `pipeline upload`. Don't use `--allow-secrets` unless you understand the risk. Learn more in [Dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines).
- **Check that your secrets are redacted:** The agent [redacts](/docs/pipelines/configure/managing-log-output#redacted-environment-variables) values of environment variables whose names match a set of patterns. Make sure your variable names match these patterns, or set `redacted-vars` to include them. Values shorter than six bytes are never redacted.
- **Never skip redaction:** Don't use the [`--skip-redaction`](/docs/agent/cli/reference/secret#skip-redaction) option of `buildkite-agent secret get`, which prints the secret to the job log when called directly.
- **Scan repositories for committed secrets:** Use secret scanning tools, such as [git-secrets](https://github.com/awslabs/git-secrets), to prevent secrets from being committed to your repositories before they enter the build process.

### Recommended

- **Use access policies on Buildkite secrets:** Add an [access policy](/docs/pipelines/security/secrets/buildkite-secrets/access-policies) to each Buildkite secret, so that only matching builds can read it. Prefer [first-party claims](/docs/pipelines/security/secrets/buildkite-secrets/access-policies#policy-schema-first-party-claims), which are generated by Buildkite, over third-party claims, which can be influenced by users.
- **Scope secrets to the steps that need them:** If you [export secrets from an environment hook](/docs/pipelines/security/secrets/managing#without-a-secrets-storage-service-exporting-secrets-with-environment-hooks), export each secret only for the pipeline and step that needs it. For example, don't give test steps access to production deployment credentials. Use separate [clusters](/docs/pipelines/security/clusters/manage) and [queues](/docs/agent/queues/managing) for each environment, so that builds can only access the secrets they need.
- **Redact secrets fetched at runtime:** Pass secrets fetched from an external secrets store to [`buildkite-agent redactor add`](/docs/agent/cli/reference/redactor), as these values are not redacted automatically.
- **Store checkout SSH keys as Buildkite secrets:** Use [`checkout.ssh_secret`](/docs/pipelines/configure/git-checkout#ssh-key-from-buildkite-secrets) instead of distributing SSH keys to every agent. If you keep keys on your agents, prefer read-only deploy keys for each repository. Learn more in [Code access for self-hosted agents](/docs/agent/self-hosted/code-access).
- **Replace static cloud credentials with OIDC:** Request short-lived [OIDC tokens](/docs/pipelines/security/oidc) in your jobs and exchange them for cloud credentials, for example, with [AWS](/docs/pipelines/security/oidc/aws) or [Azure](/docs/pipelines/security/oidc/azure). Prefer immutable identifiers, such as pipeline UUIDs, over slugs in your trust policies.
- **Rotate secrets regularly:** Rotate secrets on a schedule, even when you have no reason to believe they have been compromised, and automate rotation where possible.

### Advanced

- **Choose the OIDC subject claim deliberately:** Use a [custom subject claim](/docs/agent/cli/reference/oidc#custom-subject-claims) to set the scope of each trust relationship, and inspect a token's `sub` claim before writing a trust policy that matches it exactly.
- **Compensate for single-claim matching in Azure:** Azure federated identity credentials match only on the subject, so any build that produces a matching token can authenticate. Apply the mitigations in [OIDC with Azure known limitations](/docs/pipelines/security/oidc/azure#known-limitations), such as enabling OIDC only on deployment pipelines whose triggers you control.

## Network and data exposure

These controls cover the boundaries between your build infrastructure and everything outside it: which connections your agents make, which requests Buildkite accepts on your behalf, where your build data is stored, and which resources can be accessed by anyone who has a URL. Buildkite encrypts all platform communications with TLS by default.

### Baseline

- **Allow only outbound connections from self-hosted agents:** Self-hosted agents only make outbound HTTPS connections. Run them in private networks, and allow only the [hosts they require](/docs/agent/self-hosted/security/network-requirements) (self-hosted agents only).
- **Limit access to cloud instance metadata:** Build jobs can reach [cloud instance metadata endpoints](/docs/agent/self-hosted/security/network-requirements#optional-hosts-cloud-instance-metadata) and act with the instance's IAM permissions. [Restrict this access](/docs/agent/self-hosted/aws/architecture/securing-your-setup) and grant your agent instances only the permissions they need.
- **Verify outbound webhooks with signatures:** Configure webhook notifications to send a [webhook signature](/docs/apis/webhooks/pipelines#webhook-signature) rather than a plain token, verify the HMAC signature in your receiver, and reject stale timestamps to [defend against replay attacks](/docs/apis/webhooks/pipelines#webhook-signature-defending-against-replay-attacks).
- **Keep public pipelines disabled:** A [public pipeline](/docs/pipelines/configure/public-pipelines) gives anyone read access to its builds, logs, and artifacts. Keep public pipeline creation disabled unless your project is open source, and restrict who can change pipeline visibility (Enterprise plan only).
- **Make artifacts in your own S3 bucket private:** When the agent uploads artifacts to [your own Amazon S3 bucket](/docs/agent/cli/reference/artifact#using-your-private-aws-s3-bucket), it uses the `public-read` ACL by default. Set `BUILDKITE_S3_ACL` to `private` and enable server-side encryption. Learn more in [Access control](/docs/agent/cli/reference/artifact#using-your-private-aws-s3-bucket-access-control).

### Recommended

- **Use OIDC for Buildkite hosted agents:** Have your services authenticate Buildkite hosted agents with OIDC rather than by IP address, as [hosted agent IP address ranges](/docs/agent/buildkite-hosted/network-security) are shared between Buildkite customers.
- **Get Buildkite IP addresses from the Meta API:** For allowlists on your own services, fetch the current Buildkite platform IP addresses from the [Meta API](/docs/apis/rest-api/meta) rather than maintaining a fixed list.
- **Filter incoming webhooks by IP address:** If you use a self-hosted source control system, such as GitHub Enterprise Server, enter its IP addresses to [filter incoming webhooks](/docs/pipelines/security/incoming-webhooks#what-security-information-is-stored-in-the-secret-in-a-buildkite-url). Webhooks from GitHub-hosted repositories are filtered automatically. A pipeline's webhook URL contains its secret, so treat the URL as a credential.
- **Use the GitHub (Limited Access) app with self-hosted agents:** If you run builds only on self-hosted agents, connect GitHub with the [GitHub (Limited Access)](/docs/pipelines/source-control/github#github-repository-provider-options) app, which has no code access.
- **Treat build status badges as public:** [Build status badges](/docs/pipelines/integrations/other/build-status-badges) don't require authentication, so don't publish badges for pipelines whose build status is sensitive.
- **Review remote access to Buildkite hosted agents:** Periodically review whether [remote access to hosted agents](/docs/apis/rest-api/organizations/pipeline-settings#enable-hosted-agents-remote-access) is enabled, and monitor the `JOB_TERMINAL_SESSION_STARTED` [audit log](/docs/platform/audit-log) event.
- **Use instance roles for artifact uploads:** Use instance role credentials and an [IAM policy](/docs/agent/cli/reference/artifact#using-your-private-aws-s3-bucket-iam-permissions) scoped to your artifacts bucket, instead of long-lived access keys.
- **Store artifacts in private, encrypted storage:** Use [Buildkite Package Registries](/docs/package-registries) or private cloud storage, such as [Amazon S3](/docs/agent/cli/reference/artifact#using-your-private-aws-s3-bucket), [Google Cloud Storage](/docs/agent/cli/reference/artifact#using-your-private-google-cloud-bucket), or [Azure Blob Storage](/docs/agent/cli/reference/artifact#using-your-private-azure-blob-container), with encryption at rest and in transit.

### Advanced

- **Route agent traffic through a proxy:** [Run your agents behind a proxy](/docs/agent/self-hosted/security#run-the-agent-behind-a-proxy) that you monitor, so that all outbound traffic is logged (self-hosted agents only).
- **Apply zero trust networking:** Apply a [zero trust architecture](https://www.ibm.com/think/topics/zero-trust) with least-privilege egress rules for self-hosted agents, and keep traffic to cloud services private using [AWS PrivateLink](https://docs.aws.amazon.com/vpc/latest/privatelink/what-is-privatelink.html), [VPC endpoints](https://docs.aws.amazon.com/vpc/latest/privatelink/create-interface-endpoint.html), or [Private Google Access](https://cloud.google.com/vpc/docs/private-google-access).
- **Keep workflow-scoped GitHub access tokens disabled:** Only enable [workflow-scoped GitHub access tokens](/docs/pipelines/source-control/github#workflow-scoped-github-access-tokens) if you trust everyone who can create a build at an arbitrary commit, as the token permissions are read from the workflow file at that commit.
- **Keep build data in storage you control:** Configure [build exports](/docs/apis/rest-api/organizations/pipeline-settings#configure-build-export) and [job log archiving](/docs/pipelines/governance/job-log-archiving) to your own storage (Enterprise plan only).

## Monitoring and detection

Preventive controls can fail or be misconfigured. These controls determine whether you detect that, and how quickly.

### Baseline

- **Review the audit log:** Use the [audit log](/docs/platform/audit-log) to review changes to tokens, users, SSO settings, pipelines, and secrets in your Buildkite organization (Enterprise plan only).

### Recommended

- **Stream audit events to your SIEM:** Use [Amazon EventBridge](/docs/pipelines/integrations/observability/amazon-eventbridge) to send audit log events to your [security information and event management (SIEM)](https://en.wikipedia.org/wiki/Security_information_and_event_management) system.
- **Alert on security-relevant events:** Create alerts for the [logged events](/docs/platform/audit-log#logged-events) that matter most, such as agent token and API access token changes, SSO provider changes, secret access, pipeline visibility changes, and terminal sessions. Also alert on unusual IP addresses, secret access patterns, and spikes in build frequency.
- **Remove inactive users:** Review the [inactive user list](/docs/platform/team-management/inactive-user-list) regularly, and remove users who no longer need access (Enterprise plan only).
- **Export metrics to your observability platform:** Send Buildkite Pipelines metrics to your monitoring platform, for example, using [OpenTelemetry](/docs/pipelines/integrations/observability/opentelemetry), to maintain visibility across pipeline activity.

## Governance and configuration management

These controls keep security configuration consistent across teams, so that gaps in one team's setup don't go unnoticed.

### Recommended

- **Manage configuration as code:** Manage pipelines, teams, and agent tokens using the [Buildkite Terraform provider](/docs/platform/terraform-provider), with a mandatory review process for changes. Use a service account that isn't tied to an individual user to apply the changes.
- **Restrict manual configuration changes:** Make pipelines **Read Only** for teams, so that only your infrastructure-as-code workflow and Buildkite organization administrators can change them. Alert on manual changes in your SIEM, and document a break-glass process for emergencies.
- **Enforce policies with agent hooks:** Use [agent hooks](/docs/agent/hooks) to enforce policies that cannot be bypassed by changing a `pipeline.yml` file, for example, to validate pipeline definitions against your security requirements.

### Advanced

- **Enforce agent configuration:** Use [ephemeral agents](/docs/pipelines/glossary#ephemeral-agent), or configuration management tools such as [Ansible](https://docs.ansible.com/) or [Puppet](https://www.puppet.com/), to keep agent configuration consistent and prevent drift on persistent hosts.

## Incident readiness

Several incident response actions are not self-service, so prepare them before you need them.

### Baseline

- **Write an incident response runbook:** Document how to remove a compromised user from Buildkite and your identity provider, how to revoke agent tokens and API access tokens, and who to contact at Buildkite. Learn more in [Incident response](/docs/platform/security/incident-response).

## Further questions

If you didn't find coverage of a security-related question that interests you here, contact support@buildkite.com.
