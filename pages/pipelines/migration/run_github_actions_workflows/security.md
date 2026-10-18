---
description: "Understand the trust and authorization boundaries that apply when Buildkite Pipelines runs GitHub Actions workflows with the GitHub Actions Buildkite plugin and buildkite-gha runtime."
---

# Security model for GitHub Actions workflows

GitHub Actions normally combines workflow execution and GitHub-managed credentials behind a runner. The [GitHub Actions Buildkite plugin](https://buildkite.com/resources/plugins/buildkite-plugins/github-actions-buildkite-plugin/) and `buildkite-gha` runtime keep the workflow syntax, but run each supported job as a native Buildkite Pipelines job. The runtime doesn't create a GitHub Actions run or a GitHub-hosted runner, so the Buildkite agent, the [queue](/docs/agent/queues), and Buildkite policies provide the security boundary.

Treat workflow steps and third-party actions as you would on a self-hosted GitHub Actions runner: code can use anything available to its job. Workflow syntax can request permissions, but it doesn't make code trusted or grant access by itself.

## How GitHub Actions security maps to Buildkite Pipelines

| GitHub Actions concept | buildkite-gha and Buildkite Pipelines boundary |
| --- | --- |
| Runner or runner group | The Buildkite queue selects the agent environment. Use a disposable host or equivalent whole-job isolation. |
| Job | A native Buildkite Pipelines command job. All workflow steps share its workspace and Buildkite identity. |
| `permissions` and `GITHUB_TOKEN` | Top-level workflow permissions and the Buildkite Pipelines workflow-token policy determine whether Buildkite issues a scoped token. GitHub repository and organization defaults aren't inherited. |
| Repository and environment secrets | Static secret names resolve through [Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets) when the destination job's identity and the secret's [access policy](/docs/pipelines/security/secrets/buildkite-secrets/access-policies) allow them. Environment-defined secret names resolve to `<ENVIRONMENT>_<NAME>` Buildkite secrets. Event and fork scoping aren't inherited. |
| Environment protection rules | Required reviewers become a Buildkite Pipelines block step that any user who can unblock the pipeline may approve. Reviewer lists, self-review prevention, wait timers, branch policies, and custom rules aren't enforced. Unsupported rules fail the compile. |
| Repository, organization, and environment variables | The Buildkite backend reads them from GitHub with its own credentials. Values are copied into the job plan artifact as `organization_vars`, `repository_vars`, and `environment_vars`. They're configuration, not secrets: anyone who can read build artifacts can read them. |
| OIDC | Actions use Buildkite-issued [OIDC](/docs/pipelines/security/oidc) tokens and claims. Cloud trust policies must trust Buildkite rather than GitHub. |
{: class="responsive-table"}

The [compatibility reference](/docs/pipelines/migration/run-github-actions-workflows/compatibility) describes what works. This page describes where trust and authorization come from.

## Isolate the whole job

Steps in one job share:

- The workspace
- Environment changes
- Running processes
- Action state
- The job's Buildkite identity

A shell step can affect a later action, and an action can affect a later shell step. Docker actions, job containers, and service containers add packaging. They aren't security boundaries.

Run untrusted jobs on a queue with:

- A disposable machine or equivalent whole-job isolation
- No ambient protected credentials
- A clean environment for every job
- Host-level CPU, memory, disk, and network limits

[Buildkite hosted agents](/docs/agent/buildkite-hosted) are ephemeral and are destroyed after each job.

Job and service container options can grant privileges, mount host paths, publish ports, and override Docker settings. Job container options can't override the runner-owned network or entrypoint, but other Docker create options pass through. Job container volumes accept named volumes, anonymous volumes, and absolute host bind mounts. The private Docker network, ownership labels, and cleanup checks reduce accidental residue. They don't contain hostile code.

On a persistent [self-hosted agent](/docs/agent/self-hosted), workflow code can read exposed host resources and leave state for later jobs.

## Repository data does not grant authority

Treat workflow files, action metadata, event snapshots, and job plans as untrusted input. They can describe work and request permissions. Buildkite Pipelines configuration and server-side policy choose the queue and decide which credentials the job can receive.

[Private reusable workflows](/docs/pipelines/migration/run-github-actions-workflows#supported-functionality-and-limitations-private-reusable-workflows) use the separate, default-off `private-reusable-workflows` importer setting. After anonymous access fails, including when the shared anonymous GitHub API quota is exhausted, the importer passes Git a canonical credential-free `https://github.com/` URL for the called repository. The importer passes the requested ref as one literal ref name. Refspec syntax, including a leading `+`, is rejected before Git runs.

Git inherits the importer's credential helpers, configuration, and environment. Credentials come only from credential helpers:

- Terminal prompts and askpass programs (`GIT_ASKPASS`, `core.askPass`, `SSH_ASKPASS`) are disabled, so a denied repository fails instead of running or waiting on a prompt program.
- Inherited `http.extraHeader` and `http.cookieFile` values, including host-scoped `http.<url>.*` values, are reset, so a token stored as a header or cookie isn't sent to a repository the helper didn't authorize.

Each Git invocation allows only the HTTPS transport, refuses redirects, verifies TLS, and checks received objects. These values are pinned for the exact repository URL. Git environment variables that would relax them, such as `GIT_SSL_NO_VERIFY` and `GIT_ALLOW_PROTOCOL`, are removed, so inherited configuration can't weaken them. `GIT_EXEC_PATH` and the `GIT_DIR` family are also removed, so Git runs its remote helpers from its own installation and writes only to the private repository created for the fetch. That repository is created with an empty init template, and every command ignores replace refs. As a result, an inherited template can't seed refs or objects that substitute another tree for the pinned commit.

The importer expands the URL with `git ls-remote --get-url` before fetching, and stops if an inherited `url.<base>.insteadOf` rewrite changed it. This keeps the request and the credential helper lookup on `github.com`. The Buildkite agent repository-provider helper requests access for the exact repository. Operators can also configure broader credentials. Denied repositories, refs, paths, and tenants remain indistinguishable from missing sources. Private action source access is separate and remains unsupported.

This design reuses ambient importer Git authority instead of minting a workflow-path-scoped credential. Access is repository-wide: enabling it allows workflow source to select any workflow in any GitHub repository those credentials can read. Restrict the importer's Git credentials, or use the Buildkite repository-provider access policy to approve only required repositories.

Digests and immutable source locks detect changed code. They don't make code trusted or grant credentials.

Prebuilt Docker action metadata can name a public `docker://` image. The action source lock protects the image declaration, but a mutable image tag can resolve to different content when each job starts. Use an image digest when content immutability matters. Image pulls use an empty private Docker configuration and never receive action secrets, registry credentials, or ambient Docker authority. Private images are unsupported.

### Source and event checks

- Public actions and reusable workflows resolve once per operation to an immutable commit and repository digest.
- Plans bind the digest of each selected workflow file.
- Runtime jobs don't load remote workflow YAML from the caller workspace.
- Path-filter admission uses reserved linked-webhook data only after matching it to the Buildkite repository, commit, workflow, and bounded local Git history. Missing, shallow, ambiguous, or mismatched evidence blocks admission.
- Release ingestion matches the webhook activity and tag to the Buildkite Pipelines event, branch, and tag. The GitHub Code Access App supplies server-resolved commit provenance. A local `HEAD` fallback preserves compatibility but can't grant hosted release token issuance.

Action locks record a sorted, unique `executable_paths` list alongside the source digest. Paths are relative to the local action directory for workspace actions, and to the entire repository for GitHub actions, including substituted `actions/cache` releases. The plan digest binds this metadata. An absent list uses filesystem modes. An explicit empty list records no executable files. The compiler and plan validator limit the sum of executable path lengths to 1 MiB per action graph or job plan, counting each distinct lock's list. Reusing one lock doesn't consume the budget again.

Linux and macOS verification always reads executable bits from the filesystem, so declared paths can't hide mode changes. On [Windows jobs](/docs/pipelines/migration/run-github-actions-workflows/compatibility#windows-jobs), where Unix modes aren't preserved, the source verifier uses the recorded paths instead. Content, additions, removals, and special files remain checked. Cache manifests keep their existing format and must match the verified tree. Stale or mismatched manifests fail rather than being rewritten from provenance.

Plans without `executable_paths` remain readable. New plans require the matching runtime: `run-job` still rejects a compiler and runtime version mismatch. This optional field doesn't make plans portable between CLI versions.

Explicit and generated event snapshots provide compatibility context. They don't authorize path-filter admission, queues, secrets, or tokens.

The compiler resolves ordinary scalar `github.event.*` references before it creates a plan. For linked webhooks and explicit event snapshots, the importer uploads one content-addressed payload artifact for every job's [`GITHUB_EVENT_PATH`](/docs/pipelines/migration/run-github-actions-workflows/compatibility#expressions-and-contexts-event-file), even when no expression reads the event. Reduced fallback snapshots are retained only when runtime event expressions need them. Plans retain the digest and transport and file markers, not the payload. Runtime jobs download from the exact importer job and verify the digest. This keeps matrix plans small and lets retries use the original event.

The artifact is limited to 25 MiB and follows the Buildkite build's artifact access and retention settings. The artifact isn't redacted and isn't a secret store: anyone who can download the artifact can read user-provided values in the event.

The runtime doesn't log event file contents. The runtime creates a separate directory per job and removes it after post hooks. Host files are owner-readable. Docker jobs permit other image users to read the file through a read-only mount. The event directory isn't writable by those users and is outside the writable checkout and runner temp. This doesn't isolate mutually untrusted steps within one job or processes sharing the runner's user account.

The snapshot remains untrusted input. The compiler doesn't add issued tokens, resolved secrets, registry credentials, OIDC tokens, or internal admission metadata to it. Those values stay on their separate credential boundaries.

### Reusable-workflow guards

Reusable-workflow call conditions become immutable plan guards. These guards run in the caller scope before the flattened job requests secrets or tokens, starts OIDC, materializes actions, creates containers, or runs steps.

Direct `needs` values come from producer-attributed, digest-bound result manifests. A missing or changed manifest stops the job.

### Matrices from job outputs

A [matrix from a job output](/docs/pipelines/migration/run-github-actions-workflows/compatibility#job-syntax-matrices-from-job-outputs) is untrusted graph input. The deferred step reads it from the same result manifest and accepts only scalar rows within the static-matrix limits. The deferred step then feeds the rows into a full recompilation of the workflow with the importer's recorded event, variables, runner mappings, and OIDC settings.

Rows can only supply `matrix` values. Runner labels, queues, images, permissions, secrets, and admission come from that recompilation and its Buildkite Pipelines policy checks, exactly as for static jobs. The recompilation must reproduce the jobs the earlier uploads already created before anything is uploaded. The stage record and the workflow in the checkout are digest-checked against what the importer compiled.

When matrices chain, each deferred step writes the next stage's record with the rows it accepted and their producer result digests. The next step:

- Verifies those results again before using the rows.
- Validates the rows the same way.
- Reads the event and runtimes from the same importer.
- Pins the same action revisions.
- Only expands the matrices that the initial compilation left to a later stage.

The same verified producer manifest can supply the matrix consumer's [scheduling values](/docs/pipelines/migration/run-github-actions-workflows/compatibility#job-syntax-scheduling-from-matrix-producer-outputs). Only the scheduling expression profiles receive those outputs. General compile-time contexts and authority analysis don't. These profiles reject tokens and secrets even in unreachable branches. A resolved group remains data, never another expression. Scheduling doesn't grant credential authority.

[Runner selection from a job output](/docs/pipelines/migration/run-github-actions-workflows/compatibility#job-syntax-runners-from-job-outputs) uses the same verified manifests and continuation checks. The output is available only to scheduling expressions. Other expressions retain their runtime dependencies, including reusable-workflow inputs used by credential authority analysis. Output text is never parsed as workflow source. A selected label must pass the importer's mappings, live runner resolution, and hosted admission before any deferred job is uploaded.

## Credential boundaries

| Credential | Boundary |
| --- | --- |
| Repository checkout | The native adapter checks the event repository and exact commit. Buildkite authorizes private access. Credentials apply only to Git commands and aren't persisted. |
| Private reusable workflow source | Git uses the importer's existing HTTPS credential helpers only while resolving an approved source. The importer passes no authenticated URL, captures no credential, and suppresses Git output. Credentials never reach plans, pipeline YAML, or runtime jobs. |
| `GITHUB_TOKEN` | A short-lived token for the event repository. Buildkite enforces the top-level workflow permission map and build provenance. The token isn't ambient. |
| Cache token | A fresh job-bound token for each compatible JavaScript or Docker action lifecycle. Shell steps don't receive it. |
| Workflow secrets | Static names resolve with [`buildkite-agent secret get`](/docs/agent/cli/reference/secret) in the destination job. The Buildkite secret access policy is the authority. |
| Registry credentials | Explicit credentials resolve in the destination job. Passwords go to Docker through standard input and use a private per-job Docker configuration. Secret-derived values stay out of plans and pipeline YAML. Authored literals don't. |
| OIDC token | Host JavaScript actions in jobs with `id-token: write` can request Buildkite OIDC tokens through a loopback endpoint. Shell steps and containerized actions can't. |
{: class="responsive-table"}

An action that receives a credential can use or exfiltrate it. The action can also export `GITHUB_TOKEN` to later steps through `GITHUB_ENV`. Masking reduces accidental disclosure. Masking isn't access control and can't catch transformed values.

### OIDC secrets migration

The `bk secret migrate github-actions` command of the Buildkite CLI generates a reviewed GitHub Actions workflow with a static secret allowlist. To run a migration, see [Migrate GitHub Actions secrets](/docs/pipelines/migration/github-actions-secrets). `buildkite-gha` v0.102.0 removed its equivalent `migrate-secrets` command. Workflows that `buildkite-gha migrate-secrets` prepared have the same trust boundaries.

After the workflow is committed to the default branch, the Buildkite CLI creates a short-lived Buildkite migration grant bound to:

- The immutable GitHub repository and owner IDs
- The exact workflow path and commit
- The default branch
- `workflow_dispatch` as the only accepted event
- The destination cluster
- The secret names
- An access policy for every destination secret. The policy must contain at least one rule, and every rule must include at least one condition, such as `pipeline_id`. Buildkite rejects a policy that would let every job in the cluster read the secrets, such as `- {}`, or no job at all, such as `[]`.

The workflow proves its identity with a GitHub-signed OIDC token and consumes the grant once. The grant expires after a short time and can't be reused. Buildkite doesn't authorize the request from mutable repository names or the customizable `sub` claim alone.

GitHub OIDC authenticates the workflow. It doesn't choose the workflow's Buildkite authority. The authenticated Buildkite user fixes that authority when creating the grant. When the workflow uses the grant, Buildkite checks again that this user can still manage the destination cluster. If the user has left the organization or lost that permission, or the cluster has been deleted, the migration fails without writing secrets or consuming the grant. The workflow receives no Buildkite API token and can't change the destination, policy, or allowlist. No Buildkite API token or other long-lived bootstrap credential is stored in GitHub.

The generated workflow requests only the `id-token: write` permission and no repository write permission. The workflow contains one static `${{ secrets.NAME }}` reference for each selected secret, and no dynamic secret-name input, secret enumeration, `secrets: inherit`, artifact, or output containing secret values. The workflow sends values only in one in-memory HTTPS request. It disables shell tracing, rejects redirects, and doesn't print Buildkite response bodies. Buildkite errors and audit data must never include the values.

Secret names are public metadata, and can appear in prompts, the generated workflow YAML, logs, and results. Secret values appear only in the GitHub Actions job's environment and the in-memory HTTPS request.

The migration is create-only. If a destination secret already exists, the migration fails before writing any secrets. Buildkite creates all secrets in the batch and consumes the grant together, so a failed migration leaves no usable partial set of secrets. The migration can't copy `GITHUB_TOKEN`, which stays on its separate [workflow-token boundary](#credential-boundaries-github-token).

Anyone who can change and run the default-branch workflow can read the selected GitHub secrets. Binding the grant to the reviewed commit prevents another workflow revision from using its authority. The CLI creates a grant and dispatches the workflow only when you run the corresponding command. The CLI never commits, pushes, merges, or deletes repository files. Remove the migration workflow after the run succeeds. This migration-specific OIDC path doesn't add OIDC support to imported Buildkite Pipelines jobs.

### GitHub token

Token issuance requires the pipeline's **Allow workflow-authorized GitHub access tokens** setting, which is off by default for existing pipelines. Buildkite Pipelines issues tokens only to running command jobs on [Buildkite hosted agents](/docs/agent/buildkite-hosted). Buildkite Pipelines reads only the top-level workflow permission policy from the pipeline repository at the build's immutable commit.

Important limits:

- Omitted permissions mean exactly `contents: read`. GitHub repository and organization defaults aren't inherited.
- Write access requires an explicit top-level map.
- `read-all` expands to the 13 supported repository scopes with read access. It doesn't include `id-token` or unsupported aliases.
- The compiler accepts `write-all` and requests every supported write scope, but Buildkite Pipelines rejects the request when issuing the token, so no token is created.
- An empty map, or a map containing only `none`, creates no token.
- Job-level and called-workflow repository maps don't narrow or expand the token. Reusable jobs use the top-level requesting workflow's permissions.
- Pull requests have a `contents: read` ceiling. Merge queues are denied.
- Incomplete or cyclic trigger and rebuild provenance is denied.
- Native release builds need the GitHub Code Access App for server-side commit provenance.

The exact step call `toJSON(github)` also requests a token because the retained context includes `token`. Before evaluating an authorized step context, the runtime registers the token with both Buildkite agent [redaction](/docs/pipelines/security/secrets/buildkite-secrets#redaction) and local redaction.

[Bounded workflow-token retries](/docs/pipelines/migration/run-github-actions-workflows/compatibility#repositories-credentials-and-github-services-github-token) keep the requested scope, but they don't make token issuance idempotent. A failed response can leave an additional token with the same scope valid until it expires. The runtime doesn't cache tokens across jobs or retry ambiguous transport failures.

The serialized context contains only the fields listed in the [compatibility reference](/docs/pipelines/migration/run-github-actions-workflows/compatibility#expressions-and-contexts-runtime-interpolation). A runtime job also loads the verified event artifact when it requires `github.event`.

For non-pull-request builds, a user who can create a build at any commit may choose code that requests the workflow's allowed permissions. Enable write tokens only when those build-creation paths are trusted.

### Workflow secrets

Workflow secrets are Buildkite secrets available to the destination job. They aren't GitHub repository, environment, event, or fork-scoped secrets. Jobs with a GitHub environment resolve environment-defined secret names to `<ENVIRONMENT>_<NAME>` Buildkite secrets. Buildkite secret access policies remain the authorization boundary. See [Deployment environments](/docs/pipelines/migration/run-github-actions-workflows/compatibility#job-syntax-deployment-environments).

`secrets: inherit` lets a repository-local reusable-workflow call, including a verified root-repository self call, place that callee job's statically referenced secret names in its plan. It's one hop, and every nested edge must repeat it. A repository-local call can instead map a declared callee alias from one direct caller secret reference. Required declarations must be mapped. Optional unmapped aliases stay empty. See [Reusable workflows](/docs/pipelines/migration/run-github-actions-workflows/compatibility#workflow-syntax-reusable-workflows) for the self-call forwarding scope.

Nested explicit mappings compose aliases to the original Buildkite secret. They can forward only authority received from the parent and never fall back to a same-named Buildkite secret. The runtime retrieves each original once and projects its value to the authorized aliases. Remote forwarding and secret names invented by action metadata remain unsupported.

Plans and pipeline YAML contain secret names, never values. Restrict the destination job with Buildkite secret access policies. Arbitrary code in the same job identity can also run `buildkite-agent secret get`.

`GITHUB_TOKEN` stays on its separate workflow-token boundary. Forwarding it to a declared alias preserves that scoped token boundary. Forwarding never requests an ordinary Buildkite secret.

### Variables

GitHub Actions variables (`${{ vars.NAME }}`) are configuration values, not secrets. The Buildkite backend reads them from GitHub with its own credentials, restricted to the pipeline's configured repository. The importer copies the repository and organization scopes into every job plan, and each declared environment's variables into the plans of the jobs that declare it.

A plan artifact (`.buildkite-gha/plans/<digest>.json`) therefore contains plaintext values, readable by anyone who can read the build's artifacts. Running `compile --format ir-json` inside a job prints both scopes to stdout, and so to the job log, whenever the workflow references `vars`. Store sensitive values as secrets instead.

A value used in a compile-time field, such as a job name, matrix value, or runner label, also appears where that field does: in the pipeline YAML and in a compile diagnostic that quotes the field. Runtime references, processing reports, and resolution errors never carry values. They name variables only. A job sees the scopes GitHub gives each position, and a name that no scope defines evaluates as empty rather than exposing another repository's value. See [Repository and organization variables](/docs/pipelines/migration/run-github-actions-workflows/compatibility#job-syntax-repository-and-organization-variables).

### OIDC

Jobs with `id-token: write` expose the `getIDToken()` wire contract to each host JavaScript action invocation. The endpoint is loopback-only and protected by a single-purpose bearer token. The runtime mints a Buildkite token for the action's requested audience, then registers it with both redactors before use.

Cloud providers must trust the Buildkite issuer and claims. GitHub-shaped claims and the GitHub issuer aren't emulated. Plugin OIDC configuration can add Buildkite claims without granting `id-token: write`. To configure a cloud provider, see [Use OIDC with AWS](/docs/pipelines/migration/run-github-actions-workflows#supported-functionality-and-limitations-use-oidc-with-aws).

## Checkout and submodules

Buildkite authorizes managed GitHub and Origin repositories through the Git credential protocol. A checked-in `.gitmodules` file can select another repository from the same provider when Buildkite authorizes it.

- Managed tokens are repository-specific and read-only.
- External HTTPS submodules are anonymous.
- SSH and other non-HTTPS transports are disabled.
- The credential helper is offered only to the event provider's host, uses HTTP-path matching, and is scoped to repository, LFS, and submodule commands. The helper is never written to Git configuration or persisted for later steps. Git, Git LFS, and the Buildkite agent helper are resolved before action hooks. LFS filters use the resolved executable instead of searching the workflow's `PATH` while credentials are available.

Checkout paths are relative to the workspace. Traversal, `.git` path segments, and symbolic-link parents are rejected before Git runs. Existing checkout directories aren't reused, even with `clean: false`.

Git owns submodule parsing and recursion, so keep Git current and prefer a pinned job image.

Command scoping limits accidental spread. It doesn't stop a hostile concurrent process under the same job identity from reaching the agent or credential helper. Use a separate UID, sandbox, or pre-job credential broker for that boundary.

## Error-reporting boundary

Configured clients send [Bugsnag error reports](/docs/pipelines/migration/run-github-actions-workflows/cli#disable-telemetry-bugsnag-error-reports) directly to Bugsnag, not through the job-authenticated Agent API. Job-log redaction doesn't protect HTTP payloads, so reports omit raw messages and causes rather than relying on log masks. An embedded ingestion key is public to anyone who receives the binary, and build outputs such as release binaries can contain it.

## Operator checklist

1. Leave the plugin `version` unset for the latest stable release, or pin an exact stable release from `0.9.0` onward for a controlled rollout.
1. Run imported jobs on an isolated queue with no ambient credentials.
1. Treat public actions as third-party code and prefer immutable commit pins.
1. Restrict managed repository access, secrets, and write tokens with Buildkite policy.
1. Keep Git and the job image patched.
1. Validate before upload:

    ```bash
    buildkite-gha validate \
      --profile hosted \
      --event-path event.json \
      .github/workflows/ci.yml
    ```

1. Keep private actions and protected queues out of imported workflows.
1. Approve only required private reusable workflow sources.
1. Configure OIDC trust for the Buildkite issuer, then restrict subjects and audiences to the intended jobs.
