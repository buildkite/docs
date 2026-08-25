---
description: "Configure the Buildkite Cache preview to save and restore keyed files and directories across Buildkite Pipelines jobs and builds."
---

# Buildkite Cache

> 📘 Preview feature
> Buildkite Cache is currently in preview and must be enabled for your Buildkite organization. To request access, contact the Buildkite Support team at [support@buildkite.com](mailto:support@buildkite.com).

Buildkite Cache saves files and directories from Buildkite Pipelines jobs, then restores them in later jobs and builds. Each cache entry has an ordered cache key. A cache store holds the archived data, while a cache registry associated with a [cluster](/docs/pipelines/security/clusters) tracks entries and controls access.

Use Buildkite Cache for data that can be regenerated, such as package manager download caches and compiled dependencies. Use [build artifacts](/docs/pipelines/configure/artifacts) for build outputs that must be retained or passed between specific jobs. [Cache volumes](/docs/agent/buildkite-hosted/cache-volumes) are a separate Buildkite hosted agent feature that provides best-effort attached storage instead of key-based cache entries.

## Set up Buildkite Cache

When the preview is enabled, each cluster has a cache registry named **Default**. Jobs use this registry unless you [select another registry](#select-a-cache-registry).

Your jobs must run on clustered agents with a Buildkite agent version that includes the `buildkite-agent cache restore` and `buildkite-agent cache save` commands.

### Buildkite hosted agents

Jobs running on [Buildkite hosted agents](/docs/agent/buildkite-hosted) receive a default cache store automatically. You don't need to configure a cache store URL or storage credentials.

### Self-hosted agents

For [self-hosted agents](/docs/agent/self-hosted), provide an Amazon S3 or S3-compatible cache store URL using the `BUILDKITE_AGENT_CACHE_STORE_URL` environment variable. The Buildkite agent uses ambient AWS credentials to access the bucket. Grant the agent runtime read and write access to the cache store using an instance role, workload identity, or temporary credentials such as [Buildkite OIDC with AWS](/docs/pipelines/security/oidc/aws).

The following pipeline-level environment variable configures an S3 bucket and optional prefix in `us-west-2`:

```yaml
env:
  BUILDKITE_AGENT_CACHE_STORE_URL: "s3://example-build-cache/buildkite?region=us-west-2"

steps:
  - label: "Test"
    command: "buildkite-agent cache restore"
```
{: codeblock-file="pipeline.yml"}

You can also set the store URL using `--cache-store-url`. S3 store URLs support the `region`, `endpoint`, `use_path_style`, `concurrency`, and `part_size_mb` query parameters.

## Define and use a cache

Create `.buildkite/cache.yml` in your repository. The following cache definition uses the operating system, architecture, and `package-lock.json` checksum to identify an npm download cache:

```yaml
caches:
  - name: "npm"
    cache_key:
      - "npm"
      - agent: "os"
      - agent: "arch"
        fallback_limit: true
      - checksum: "package-lock.json"
    target_paths:
      - "~/.npm"
```
{: codeblock-file=".buildkite/cache.yml"}

The `name` identifies the cache definition for `--name` selection. Cache names can contain only ASCII letters, numbers, and underscores.

Restore the cache before the command that uses it, then save it after the command has populated the target path:

```yaml
steps:
  - label: "Test"
    command:
      - "buildkite-agent cache restore --name npm"
      - "npm ci"
      - "buildkite-agent cache save --name npm"
      - "npm test"
```
{: codeblock-file="pipeline.yml"}

A normal cache miss exits successfully, so the job continues to `npm ci`. Configuration, storage, and extraction errors cause the cache command to fail. In the example, the save command doesn't overwrite an entry that already exists at the same address.

If you omit `--name`, the command processes every cache in the configuration file. Repeat `--name` to select multiple caches. Set `BUILDKITE_CACHE_NAMES` to provide the same selection using an environment variable.

By default, both commands discover `.buildkite/cache.yml` or `.buildkite/cache.yaml`. If both files exist, discovery fails. Use `--cache-config-file` or `BUILDKITE_CACHE_CONFIG_FILE` to select a different file.

## Configure cache keys

The `cache_key` attribute is an ordered array. Buildkite Cache resolves each part and combines the results to address a cache entry. Key order affects the address.

Each key part can use one of the following sources:

- **Literal string**: Adds a fixed value, such as `npm` or a cache format version.
- `agent`: Adds `os`, `arch`, `branch`, `pipeline`, or `step`. A step uses the step key when one is configured, or the step ID otherwise.
- `env`: Adds the value of an environment variable. An unset variable adds an empty value.
- `checksum`: Adds a SHA-256 checksum of one file, or a combined checksum of an array of files and glob patterns. Paths and patterns are relative to the job working directory.

All literal checksum files must exist. An array can contain unmatched glob patterns when at least one other pattern matches. Buildkite Cache sorts and deduplicates matched paths before calculating the checksum, so pattern order doesn't affect the result.

### Restore from a fallback key

By default, every cache key part must match. Add `fallback_limit: true` to one part to make every following part optional during restore. The marked part remains required.

In the npm example, Buildkite Cache looks for an exact match that includes the lockfile checksum. If no exact entry exists, it can restore the newest entry that matches `npm`, the operating system, and the architecture. The subsequent `npm ci` command updates the restored data, and the save command creates an entry for the new exact key.

You can add `fallback_limit` to at most one key part.

## Configure target paths

The `target_paths` attribute is a non-empty array of unique files or directories to save and restore. Each target must exist when you run `buildkite-agent cache save`. The set of target paths is part of the cache address, but the order of the paths doesn't affect it.

Target paths use the following anchors:

- **Relative paths**: Resolve from the job working directory.
- **Home-relative paths**: Start with `~/` and resolve from the home directory of the user running the agent.
- **Absolute paths**: Restore to the same absolute location.

When a cache entry is restored, Buildkite Cache removes each existing target before extracting the cached data. Restoration replaces the target instead of merging with its contents.

You can't cache an entire working directory, home directory, filesystem root, drive root, or volume root. Target paths must not overlap or resolve to the same location.

## Manage cache registries

A cache registry holds cache entry metadata and controls which jobs can save and restore entries. Registries are scoped to a cluster. Organization administrators and cluster maintainers can manage them.

To open the registries for a cluster:

1. Select **Agents** in the global navigation.
1. Select the cluster.
1. Select **Cache Registries**.

The **Entries** tab lists cache entries and lets you delete entries that are no longer needed. Use the **Cache Store**, **Policy**, and **Settings** tabs to manage the registry.

### Create a cache registry

Create another registry when jobs in the cluster need a different access policy or cache store:

1. On the cluster's **Cache Registries** page, select **New cache registry**.
1. Enter a **Name** and optional **Description**.
1. Select **Agent managed storage** as the **Cache Store**.
1. Configure the cache policy.
1. Select **Create cache registry**.

Buildkite generates the registry slug from its name. Renaming a registry changes its slug and can break commands that select it explicitly.

To make a registry the cluster default, open its **Settings** tab and select **Set as default**. You can't delete the default registry until you select another default.

Changing a registry's cache store removes its existing cache keys. Subsequent restores miss until jobs save new entries.

### Select a cache registry

The cache commands use the cluster default registry when no registry is specified. Select another registry by its slug using either method:

```bash
buildkite-agent cache restore --registry dependency-cache
buildkite-agent cache save --registry dependency-cache
```

```yaml
env:
  BUILDKITE_AGENT_CACHE_REGISTRY: "dependency-cache"
```

The registry value `~` also selects the cluster default.

### Configure a cache policy

Cache policies control how entries are scoped and which jobs can save or restore them. The default unrestricted policy allows jobs in the cluster to share entries with matching cache keys and target paths.

The following policy scopes saved entries by pipeline and branch. Restore first searches the current branch, then the `main` branch in the same pipeline:

```yaml
save:
  scopes:
    branch: true
    pipeline: true
restore:
  scopes:
    - branch: "$current"
      pipeline: "$current"
    - branch: "main"
      pipeline: "$current"
rules:
  - name: "allow-save-and-restore"
    effect: "allow"
    action:
      - "save"
      - "restore"
```

Available scope dimensions are `branch`, `build`, and `pipeline`. Restore scopes are searched in order. The `$current` value resolves from the authenticated job.

Rules are evaluated from top to bottom, and the first rule that matches the requested action and optional `when` condition determines access. If no rule matches, access is denied. Conditions use CEL expressions and can inspect verified job claims and cache entry scopes.

> 🚧 Protect caches from untrusted builds
> Configure registry scopes and rules before sharing a registry with untrusted builds. Don't cache secrets, credentials, or untrusted executable output.

## Cache entry lifecycle

Buildkite Cache uses the following save and restore behavior:

- A save is write-once for an address. If an entry already exists for the resolved key, target paths, policy scopes, and registry, the existing entry isn't overwritten.
- Restore checks the exact key first, then progressively removes optional trailing key parts up to the configured fallback limit. The newest matching entry is restored.
- A miss leaves existing target paths unchanged and exits successfully.
- A missing, corrupted, or unrecognized stored archive is treated as a miss and isn't extracted.
- Cache entries expire three days after creation or their latest exact restore. A fallback restore doesn't extend an entry's expiration.

Treat caches as temporary performance optimizations. Build and test commands must continue to work after a cache miss.
