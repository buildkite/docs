# Enforcing security controls

Enforce security controls in systems that the people running builds cannot change. A security scan in a repository's pipeline definition can be removed by someone who can edit that definition. A cloud trust policy, an organization permission, or a self-hosted agent setting can enforce a restriction outside that repository.

Use the [Security checklist](/docs/platform/security/checklist) to choose and audit controls. This page explains where to enforce them and how to check that a pipeline change cannot bypass them. For a new setup, start with [Secure your first production pipeline](/docs/platform/security/first-production-pipeline).

## Restrict who can change security settings

Configure [teams and permissions](/docs/platform/team-management/permissions) so that users who only need to run or inspect builds cannot change pipeline settings. Grant **Build & Read** or **Read Only** instead of **Full Access** where appropriate. Review the **Everyone** team's access as well as access granted through other teams.

Require [single sign-on (SSO)](/docs/platform/sso) or [two-factor authentication (2FA)](/docs/platform/team-management/enforce-2fa). On the Enterprise plan, use [organization security settings](/docs/pipelines/security/permissions#manage-organization-security-for-pipelines) to restrict actions such as changing pipeline visibility, managing agent tokens, and stopping agents.

Verify these permissions with a non-administrator test account. Confirm that the account can perform its intended work but cannot change the settings it should not control. Organization administrators retain broad access, so review administrator membership separately.

## Protect pipeline definitions and required checks

Keep pipeline definitions in version control and protect changes with required reviews and branch protection. Where available, use [pipeline templates](/docs/pipelines/governance/templates) (Enterprise plan only) to standardize required checks across Buildkite Pipelines. Limit who can change the template and the settings that select it.

On self-hosted agents, use [agent hooks](/docs/agent/hooks) to enforce checks outside the repository. If repository hooks could override those checks, [disable local hooks](/docs/agent/self-hosted/security#restrict-access-by-the-buildkite-agent-controller-disable-local-hooks). This setting also disables plugins, so test compatibility before enabling it.

Treat build triggers as part of the enforcement boundary. Keep [fork builds](/docs/pipelines/source-control/github#running-builds-on-pull-requests) disabled on pipelines that can access production secrets, or require an authorized approval before running untrusted code with those credentials. Don't authorize deployments from an unverified commit author's identity. For webhook-triggered builds, use a [block step](/docs/pipelines/configure/step-types/block-step) and verify `BUILDKITE_UNBLOCKER_TEAMS` for the authenticated user who approves it.

In a test pipeline, try removing a required scan and changing the repository pipeline definition. Confirm that the enforced check still runs or that the build is rejected. Repeat for each build source you allow.

## Enforce self-hosted agent restrictions

Apply [agent-controller restrictions](/docs/agent/self-hosted/security#restrict-access-by-the-buildkite-agent-controller) to every self-hosted agent that can receive the protected jobs. Restrict repositories and plugins, or disable command evaluation where builds should only run checked-in scripts. Disabling command evaluation also disables plugins.

Disabling command evaluation doesn't protect against malicious checked-in scripts and doesn't constrain a custom `command` hook. Review both repository access and the hooks that actually execute commands.

Use a [pre-bootstrap hook](/docs/agent/self-hosted/security#restrict-access-by-the-buildkite-agent-controller-strict-checks-using-a-pre-bootstrap-hook) to reject unexpected commands, repositories, or environment variables before checkout. Protect the agent configuration and hook files from modification by build jobs.

For [signed pipelines](/docs/agent/self-hosted/security/signed-pipelines), keep verification failures set to `block` and separate signing agents from agents that only verify and execute steps. Keep signing keys in [AWS KMS](/docs/agent/self-hosted/security/signed-pipelines#aws-kms-managed-key-setup). Verify-only agents must not have `kms:Sign` permission. Signed steps cannot be used with pipeline templates.

Test a disallowed repository, plugin, or command on every relevant agent pool. A restriction on the pipeline-upload agent does not establish that the agents executing later jobs enforce the same policy.

Buildkite hosted agents don't expose these self-hosted agent-controller settings. For hosted workloads, enforce access through organization permissions, protected pipeline definitions, separate clusters, and secret and cloud access policies.

## Enforce workload and credential boundaries

Use separate [clusters](/docs/pipelines/security/clusters) for production and untrusted workloads. Queues route jobs within a cluster; they do not provide the same isolation boundary. Review cross-cluster rules as explicit grants of access.

Restrict [Buildkite secret access policies](/docs/pipelines/security/secrets/buildkite-secrets/access-policies) to the builds that need each credential. Prefer first-party claims generated by Buildkite over claims influenced by repository content or users.

Use [OIDC](/docs/pipelines/security/oidc) to exchange job identity for short-lived cloud credentials. Restrict access in the cloud provider's trust policy with immutable claims such as `organization_id` and `pipeline_id`, rather than mutable slugs. For AWS, match the required subject and any [session-tag conditions](/docs/pipelines/security/oidc/aws#step-2-create-a-new-or-update-an-existing-iam-role-to-use-with-your-pipelines). Session tags do not restrict access unless the trust policy checks them.

Test both an allowed build and a build from a different pipeline, branch, or cluster. The allowed build should obtain only the required access; the other build should be denied. Test with non-production credentials before changing production policies.

## Keep secrets out of uploaded pipelines

Keep the [pipeline upload secret check](/docs/pipelines/configure/dynamic-pipelines) enabled. Agent v3 requires the `--reject-secrets` flag:

```bash
buildkite-agent pipeline upload --reject-secrets .buildkite/pipeline.yml
```

The check detects values from the agent process environment whose variable names match the default secret-name patterns: `*_PASSWORD`, `*_SECRET`, `*_TOKEN`, `*_PRIVATE_KEY`, `*_SSH_KEY`, `*_ACCESS_KEY`, `*_SECRET_KEY`, `*_CONNECTION_STRING`, and `*_API_KEY`. The check also covers values assigned to matching variables in pipeline-level, step-level, and trigger-step `build` environment maps. Pure runtime substitutions and values shorter than six bytes are not treated as secrets.

Don't use `--allow-secrets` or `BUILDKITE_AGENT_PIPELINE_UPLOAD_ALLOW_SECRETS` unless the upload intentionally contains a secret and you understand the exposure risk. This check is not a replacement for a [secrets store](/docs/pipelines/security/secrets/managing) or [log redaction](/docs/pipelines/configure/managing-log-output#redacted-environment-variables).

In a test pipeline, use a non-sensitive test value longer than six bytes in a matching variable and confirm that an upload containing the value is rejected. If a repository can change the upload command, it can also remove the flag. Enforce the upload process outside that repository when the check must be mandatory.

## Detect changes to enforced controls

Manage supported resources with the [Buildkite Terraform provider](/docs/platform/terraform-provider), protect the configuration repository with required reviews, and use a dedicated service account to apply approved changes. Compare the actual configuration with the approved configuration regularly.

Review the [audit log](/docs/platform/audit-log) for security-setting changes (Enterprise plan only), and send relevant events to your monitoring system. Document an emergency change procedure, including who can use it and how those changes are reviewed afterward.

Record each control's owner, enforcement location, allowed and denied test cases, and last verification date. Re-run those tests after changes to agent images, pipeline templates, permissions, or cloud trust policies. Use the checklist's _Audit this area_ sections to gather supporting evidence, not as a substitute for testing that a prohibited action is denied.
