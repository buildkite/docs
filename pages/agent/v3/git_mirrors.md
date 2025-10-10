# Git mirrors

Git mirrors allow you to create local copies of Git repositories on Buildkite Agents. The feature works by maintaining a single bare git mirror for each repository on a host, shared amongst multiple agents and pipelines. Checkouts then reference this mirror using `git clone --reference`, as do submodules.

## When to use Git mirrors

Git mirrors optimize performance and reduce network bandwidth, helping you minimize the time it takes to re-clone large repositories. They're particularly useful in self-hosted build infrastructure where multiple agents are running.

Key benefits to using Git mirrors:

- **Speed up cloning** - share objects across checkouts instead of fetching everything repeatedly.
- **Reduce disk usage** - store common objects once in the mirror.
- **Faster builds** - less time spent on git operations.
- **Local backup** - maintain a complete copy of the repository on your infrastructure.
- **Handle large repositories** - more efficient for repos with a large number of files and extensive history.

## How Git mirrors work

Git mirrors leverage two core Git features:

- `git clone --mirror` creates a complete copy of the remote repository, including all branches and refs. This differs from `git clone --bare` by capturing everything from the remote - crucial when the agent doesn't know which branch it needs to build ahead of time.

- `git clone --reference` creates checkouts that borrow objects from the mirror instead of fetching them from the remote. This saves both network bandwidth and disk space. The caveat: checkouts depend on the mirror remaining healthy and available.

## Setting up Git mirrors

Configure git mirroring using the `--git-mirrors-path` flag on your agents. This sets the central location (the _git mirror directory_) where mirrors are stored.

See these agent configuration options for details:

- [git-clone-mirror-flags](/docs/agent/v3/configuration#git-clone-mirror-flags)
- [git-mirrors-lock-timeout](/docs/agent/v3/configuration#git-mirrors-lock-timeout)
- [git-mirrors-path](/docs/agent/v3/configuration#git-mirrors-path)
- [git-mirrors-skip-update](/docs/agent/v3/configuration#git-mirrors-skip-update)

## Common issues to note with Git mirrors

This section covers known common issues for Git mirrors and the way to solve or prevent these issues.

### Parallelism issues

When multiple agents fetch from the same mirror simultaneously, conflicts can occur. This is the reason there is a locking system in the mirror to prevent multiple agents updating the mirror at the same time. Due to the fact that a mirror directory can be a network file share, it is advisable to ensure the lock works across multiple machines (mostly ensured with file-based locks).

### Checkout corruption

A mirror repository and a reference clone(checkout) work together where the checkout borrows most of its objects from the mirror instead of storing them locally. When `git fetch` runs the mirror, it automatically triggers maintenance (by default `git fetch` runs `git maintenance run --auto`) that cleans up objects it considers not useful whereas some of those files may actually be needed. If this happens, you'll see checkout errors and need to delete the checkout directory and re-clone (which is quick with mirrors enabled).

### Updating mirrors

Using `git remote update` is the usual way to update mirrors as it updates everything in a mirror, however `git fetch origin <branch>` would be the preferred way for most CI/CD use cases as only the objects necessary for a particular job are needed. This is why, in this [PR](https://github.com/buildkite/agent/pull/1112), `git remote update` was switched to `git fetch origin <branch>`. And remember that `git remote update` also runs auto maintenance which may cause the checkout corruption mentioned above.

## Possible alternatives to Git mirrors

If Git mirrors don't fit your use case, consider these alternatives:

- Dissociate
- Git worktree

### Using Dissociate

`git clone --reference <path> -- dissociate` is similar to `--reference`, however it makes copies of the objects during the clone. This could help with repo corruption and reducing network usage, but it consumes hard disk usage for each clone which could introduce a different issue depending on the available storage space.

### Git worktree

In a `--bare` or `--mirror` clone, Git doesn't provide a working copy of the files in the repo. But you can still retrieve them, make commits, and so on. The most convenient way to do that is by using a worktree.

Instead of  `git clone --reference <mirror>`, jobs could be run in a directory inside the mirror. For example:

```bash
cd <mirror>
git worktree add build-12345
cd build-12345
git checkout <branch>
Run the job
cd ..
git worktree remove --force build-12345
```

By using worktree within a single repository, maintenance operations can be ran as many times as possible, because the repository does not secretly depend on objects that might be removed.

A major downside to this approach is that managing agents across machines that share the mirror via network requires significant additional effort.

#### Git submodules

Git submodules are a way for one repository to refer to another repository, so that the contents of that second repository can be used from the code in the first. If mirrors are enabled, submodules would also be mirrored. Submodule mirrors can also be created and updated just like regular mirrors since submodules are also technically mirrors.

The caveat to this is that submodule mirrors need special handling on the agent. The agent has to update the submodule configuration in the main repository using `git submodule update --reference <submodule_mirror>`. The agent has to do that for _each_ submodule, which means parsing the submodule config, and then looping over the submodules to update them.
