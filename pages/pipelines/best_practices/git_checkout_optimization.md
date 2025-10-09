# Git checkout optimization

This section covers optimization of Git workflows.

## Git mirrors

See more in [Git mirrors](/docs/agent/v3). Change the link to a separate git mirrors page when it's live!

## Sparse checkout

Sparse checkout is a Git feature that lets you check out only a subset of paths from a repository into your working directory, while the local repo still has the full commit history. You define the paths you care about (manually or via cone mode with sparse patterns), and Git populates only those files locally. This speeds up operations and reduces disk usage on very large, monorepo-style projects, without changing the repository itself or requiring server-side setup.

Also see [Sparse checkout Buildkite plugin](https://buildkite.com/resources/plugins/buildkite-plugins/sparse-checkout-buildkite-plugin/).

### Sparse checkout vs Git mirrors

Sparse checkout:

- Client-side only
- Pulls entire history but materializes only selected paths in the working tree
- Great for developer workflows on monorepos where different teams touch different directories
- No separate repository to maintain

Git mirrors:

- A separate repository that mirrors another repo (often using --mirror or --bare)
- Commonly used for CI/CD, caching, migration, or read-only replication across networks
- May include all refs and history, or be combined with filtering techniques if you build specialized mirrors
- Requires setup and maintenance of the mirror location

### When to use which

- Use sparse checkout when developers need to work in a large repo but only on a few directories, optimizing local checkouts and IDE performance without changing server infrastructure.
- Use a Git mirror when you need a replicated source of truth for CI, faster clones for many agents, network isolation, or migration between hosts. If you’re optimizing developer workstation performance, choose sparse checkout. If you’re optimizing distribution, reliability, or centralization for automation and scaling, choose a mirror.
