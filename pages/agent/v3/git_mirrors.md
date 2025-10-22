# Git mirrors

Git mirrors allow you to create local copies of Git repositories on Buildkite Agents. Git mirrors work by maintaining a single bare Git mirror for each repository on a host, shared among multiple agents and pipelines. Checkouts then reference this mirror using `git clone --reference`, as do submodules.

## When to use Git mirrors

Git mirrors optimize performance and reduce network bandwidth, helping you minimize the time it takes to re-clone large repositories. They're particularly useful in [self-hosted](/docs/pipelines/architecture#self-hosted-hybrid-architecture) build infrastructure where multiple agents are running.

Key benefits of Git mirrors:

- Speed up cloning by sharing objects across checkouts instead of fetching everything repeatedly.
- Reduce disk usage by storing common objects once in the mirror.
- Achieve faster builds with less time spent on Git operations.
- Maintain a complete copy of the repository on your infrastructure as a local backup.
- Handle large repositories more efficiently, especially those with many files and extensive history.

## How Git mirrors work

Git mirrors leverage two core Git features:

- `git clone --mirror` creates a complete copy of the remote repository, including all branches and references. This differs from `git clone --bare` by capturing everything from the remote. This is crucial when the agent doesn't "know" which branch it needs to build ahead of time.

- `git clone --reference` creates checkouts that borrow objects from the mirror instead of fetching them from the remote. This saves both network bandwidth and disk space. One caveat is that checkouts depend on the mirror remaining healthy and available.

## Setting up Git mirrors

Configure Git mirroring using the `--git-mirrors-path` flag on agents. This flag sets the central location (the Git mirror directory) where the agent stores mirrors.

Use these agent configuration options:

- [git-clone-mirror-flags](/docs/agent/v3/configuration#git-clone-mirror-flags)
- [git-mirrors-lock-timeout](/docs/agent/v3/configuration#git-mirrors-lock-timeout)
- [git-mirrors-path](/docs/agent/v3/configuration#git-mirrors-path)
- [git-mirrors-skip-update](/docs/agent/v3/configuration#git-mirrors-skip-update)

## Git submodules

Git submodules allow one repository to reference another, enabling code in the first repository to use contents from the second. When you enable mirrors, the agent also mirrors submodules. You can create and update submodule mirrors the same way as regular mirrors.

Submodule mirrors require special handling on the agent. The agent must update the submodule configuration in the main repository using `git submodule update --reference <submodule_mirror>`. This must be done for each submodule, which means parsing the submodule configuration and then iterating over the submodules to update them.

## Common issues with Git mirrors

This section covers common issues with Git mirrors and how to solve or prevent them.

### Parallelism issues

When multiple agents fetch from the same mirror simultaneously, conflicts may occur. The Buildkite Agent implements a locking system that prevents multiple agents from updating the same mirror simultaneously. This file-based lock works across multiple machines, even when the mirror directory is a network file share.

### Checkout corruption

A mirror repository and a reference clone (checkout) work together. The checkout borrows most of its objects from the mirror instead of storing them locally. When `git fetch` updates the mirror, it automatically triggers maintenance that cleans up objects Git considers unnecessary. By default, `git fetch` runs `git maintenance run --auto`. However, some of those objects may actually be needed by the checkout. If this happens, you'll see checkout errors and need to delete the checkout directory and re-clone (which is quick with mirrors enabled).

### Updating mirrors

The command `git remote update` is commonly used to refresh mirrors because it updates all references. However, `git fetch origin <branch>` is the preferred approach for most CI/CD use cases because it fetches only the objects a particular job requires. The Buildkite Agent now uses `git fetch origin <branch>` instead of `git remote update` for this reason. Remember that `git remote update` also runs auto maintenance that may cause the checkout corruption mentioned above.
