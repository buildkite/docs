# Buildkite agent version support policy

From January 1, 2027, Buildkite will support each minor release line of the Buildkite agent for one year from the publication date of its first stable release. For the final three months of that year, the release line will be _deprecated_: still supported, but with warnings encouraging you to upgrade. After the year ends, the release line will be _unsupported_. Unsupported agents won't be blocked. They can keep connecting and running jobs, but Buildkite will no longer guarantee they'll stay compatible with the Buildkite service. See [After support ends](#after-support-ends).

The policy will apply to release lines that already exist. Their support windows are measured from their original release dates and won't restart when the policy takes effect.

A fixed support window gives you a predictable timeline for planning agent upgrades. It also lets Buildkite focus maintenance and fixes on the release lines that are still in use, and retire the service-side workarounds that keep older agent versions working, which keeps the Buildkite service simpler and more reliable. One year is long enough to fit agent upgrades into a regular maintenance cycle, while keeping the number of supported release lines manageable.

Buildkite recommends using the latest stable agent release. If you stay on an older supported minor release line, use its latest patch release.

## What changes on January 1, 2027

When the policy takes effect, each release line will enter the phase determined by its original release date:

- Release lines first published on or before January 1, 2026, will become unsupported. This is v3.115.x and earlier.
- Release lines first published between January 2 and April 1, 2026, will become deprecated. This is v3.116.x through v3.121.x.
- All later release lines, from v3.122.x onward and all of v4, will remain supported for now.

### Agent v3

Agent v3.138.x is the final v3 minor release line. Within its support window, it will continue to receive security fixes and selected bug fixes as patch releases, but new features will only ship in v4. Under this policy, v3.138.x will be supported until September 3, 2027, one year after v3.138.0 was published. After that date, no v3 release line will be supported.

If you're still on v3, plan your move to v4 before then. See the [v3 to v4 upgrade guide](/docs/agent/v3-v4-upgrade-guide).

To find and upgrade agents that will be affected by the policy, see [Prepare your agents](#prepare-your-agents).

## How support windows work

A _minor release line_ is the set of releases that share the same major and minor version numbers. For example, `3.120.0` and `3.120.1` both belong to the `3.120.x` line.

The support window starts when the first stable release in that line is published. Installing an agent or publishing a new patch release doesn't restart the window. The agent publishes a new minor release line roughly every one to two weeks, so in practice, a version you install on the day it's released has about a year of support, and a patch release installed six months into its line has about six months.

Each release line moves through three phases:

| Phase | Timing | What it means |
| --- | --- | --- |
| Supported | First nine months | The release line is supported. |
| Deprecated | Final three months | The release line remains supported and jobs run as usual. Warnings encourage you to upgrade before support ends. |
| Unsupported | From the first anniversary | Compatibility is no longer guaranteed. The release line doesn't receive bug fixes or dependency updates. |
{: class="responsive-table"}

For example, a release line first published on January 15, 2026, becomes deprecated on October 15, 2026, and unsupported on January 15, 2027.

This policy covers tagged stable releases only. Pre-releases, betas, release candidates, commit builds, and forks aren't covered, and aren't recommended for production workloads.

## What support includes

For supported release lines, including deprecated lines, Buildkite provides:

- Guaranteed compatibility with the Buildkite service.
- Access to human support under your existing support arrangements.
- Help resolving security, reliability, correctness, and compatibility issues.

Compatibility with the Buildkite service is Buildkite's responsibility for every supported release line. If a supported line stops working with Buildkite, Buildkite fixes it with a backend change or a patch release to that line. You won't need to move to a newer line to stay compatible.

Other fixes, such as bug fixes, dependency updates, and new features, may only ship in newer release lines. You may need to upgrade to receive them, even while your current line is supported.

## After support ends

Unsupported release lines don't receive bug fixes or dependency updates. Unsupported agents may still connect and run jobs, but backend or API changes may cause them to stop working.

Buildkite doesn't block unsupported versions solely because they're out of support. Buildkite may communicate changes affecting unsupported agents in advance, but advance notice isn't guaranteed, particularly for urgent security or reliability changes.

Customers with paid support can still receive help upgrading from unsupported agent versions.

## Prepare your agents

If you run self-hosted agents, find any that will be deprecated or unsupported when the policy takes effect, and upgrade them before January 1, 2027.

### Check your agent versions

Agents in the same fleet can run different versions, especially when they've been upgraded in place. Check every agent rather than one per setup.

To see the versions of all connected agents in your organization, use the [list agents REST API endpoint](/docs/apis/rest-api/agents#list-agents), which returns a `version` field for each agent, or the [GraphQL API](/docs/apis/graphql/cookbooks/agents#search-for-unclustered-agents-in-an-organization), where the `Agent` type has a `version` field.

To check a single installed agent, run this command on the agent machine:

```bash
buildkite-agent --version
```

To check the version that ran a job in the Buildkite Pipelines interface, open a recent build, select a command job that has run on an agent to open its details, and select **Agent**. The **Version** field shows the agent version.

Buildkite manages updates for [Buildkite hosted agents](/docs/agent/buildkite-hosted), so you don't need to check or upgrade them yourself.

If you need help identifying agents that are out of support, contact [Buildkite support](mailto:support@buildkite.com).

### Upgrade your agents

How you upgrade depends on how you installed the agent:

- Package manager or install script: see [Upgrade agents](/docs/agent/self-hosted/install#upgrade-agents).
- Docker: use a major-version tag such as `buildkite/agent:4` so you receive new releases automatically. If you pin an exact version tag such as `buildkite/agent:4.0.0`, you'll need to update it yourself before that line leaves support. See [Version tagging](/docs/agent/self-hosted/install/docker#version-tagging).
- Elastic CI Stack for AWS: the agent version is set by the stack release and the `BuildkiteAgentRelease` parameter. See [Updating your stack](/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/managing-elastic-ci-stack#updating-your-stack).
- Agent Stack for Kubernetes: the agent image defaults to a version matching the controller release. Upgrade the controller, or set the [`image` controller option](/docs/agent/self-hosted/agent-stack-k8s/controller-configuration) to a supported version.

See the [agent releases](https://github.com/buildkite/agent/releases) for release dates and release notes.

## Lifecycle warnings

Before January 1, 2027, job pages show warnings for agent versions that will be deprecated or unsupported when the policy takes effect.

After the policy takes effect, job pages will show a deprecation warning during a release line's final three months of support, and a stronger warning after support ends.

Newer agent versions will also log a warning when their release line is deprecated or unsupported.

## Changes to this policy

Buildkite may update this policy from time to time and will communicate any changes.

For questions about this policy or help upgrading, contact [Buildkite support](mailto:support@buildkite.com).
