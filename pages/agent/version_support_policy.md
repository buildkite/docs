# Buildkite agent version support policy

From January 1, 2027, Buildkite will support each minor release line of the Buildkite agent for one year from the publication date of its first stable release. This policy applies to existing release lines. On January 1, 2027, lines whose first stable release was published on or before January 1, 2026, will be unsupported.

Buildkite recommends using the latest stable agent release. If you remain on an older supported minor release line, use its latest stable patch release.

## Prepare for January 1, 2027

If you manage self-hosted agents, check their versions and upgrade any that will be unsupported when the policy takes effect. To check an installed agent's version, run:

```bash
buildkite-agent --version
```

To check the version used for a job in the Buildkite Pipelines interface:

1. Open the pipeline, then open a recent build.
1. Select a command job that has run on an agent to open its details.
1. Select **Agent**, then read the **Version** field.

If the **Agent** tab or version isn't available, use the command above on the agent machine.

Check a representative agent from each distinct setup you run, such as each agent image or deployment configuration. Include older setups that are still in use.

See the [agent releases](https://github.com/buildkite/agent/releases) for release dates and release notes, and [Upgrade agents](/docs/agent/self-hosted/install#upgrade-agents) for upgrade instructions.

Buildkite manages updates for hosted agents, so you don't need to upgrade them yourself.

The policy does not automatically block unsupported agents on January 1, 2027. Existing agents can continue connecting and running jobs, but Buildkite will no longer guarantee compatibility for unsupported versions.

## How support windows work

A _minor release line_ includes releases with the same major and minor version numbers. For example, `3.120.0` and `3.120.5` both belong to the `3.120.x` line.

The support window starts when the first stable release in that line is published. Installing an agent or publishing a new patch does not restart the window.

Each release line moves through three phases:

| Phase | Timing | What it means |
| --- | --- | --- |
| Supported | First nine months | The release line is supported. |
| Deprecated | Final three months | The release line remains supported. Warnings encourage you to upgrade before support ends. |
| Unsupported | From the first anniversary | Compatibility is no longer guaranteed. The release line does not receive bug fixes or dependency updates. |
{: class="responsive-table"}

For example, a line first released on January 15, 2026, becomes deprecated on October 15, 2026, and unsupported on January 15, 2027.

When the policy takes effect, existing release lines enter the phase determined by their original release date. Their support windows do not restart on January 1, 2027.

This policy covers tagged stable releases only. Pre-releases, betas, release candidates, commit builds, and forks are not covered and are generally not recommended for production workloads.

## What support includes

For supported release lines, including deprecated lines, Buildkite provides:

- Guaranteed compatibility with the Buildkite service.
- Access to human support under your existing support arrangements.
- Help resolving security, reliability, correctness, and compatibility issues.

Depending on the issue, the resolution may be a patch to the affected release line, an upgrade to a newer release line, a backend fix, or an operational workaround.

Buildkite considers applying fixes to older release lines based on feasibility and customer need. Not every fix will be applied to every supported release line. You may need to upgrade to resolve an issue, even while your current line is supported.

Deprecated agents remain supported and jobs run as usual. Upgrade before support ends.

## After support ends

Unsupported release lines do not receive bug fixes or dependency updates. Unsupported agents may still connect and run jobs, but backend or API changes may cause them to stop working.

Buildkite does not block unsupported versions solely because they are out of support. Buildkite may communicate changes affecting unsupported agents in advance, but advance notice is not guaranteed.

Customers with paid support can still receive help upgrading unsupported agents.

## Lifecycle warnings

Before January 1, 2027, affected job pages will show warnings for agent versions that will be deprecated or unsupported when the policy takes effect.

After the policy takes effect, job pages will show deprecation warnings during a release line's final three months of support and stronger warnings after support ends.

Agent versions that implement lifecycle checks will also log warnings when deprecated or unsupported.

Buildkite may update this policy and will communicate any changes.

For questions about this policy or help upgrading, contact [Buildkite support](mailto:support@buildkite.com).
