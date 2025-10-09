# Git mirrors

Implementing Git mirrors within your own self-hosted build infrastructure allows you to reduce both network bandwidth and disk usage when running multiple agents.

Git mirroring is set up by mirroring the repository in a central location (known as the _git mirror directory_), and making each checkout us a `--reference` clone of the mirror.

For Git mirrors, there are two major components to note which are `Git mirror --mirror` and `Git clone --reference`.

`Git mirror --mirror` is similar to `Git clone --bare` with the main difference being that it also clones all the extra elements you normally would not get with `git clone` or `git clone --bare`. The `--mirror` flag actually provides all the branches associated with that repository which is very important in a real scenario as the agent does not know which branch it needs to build. This is also useful if you need to save time cloning a specific branch as git mirror makes a clone of everything in the remote repository (practically as the name implies, a complete mirror of the remote repository)

`Git clone --reference` saves network and disk space however it does come with its caveat. When utilizing `git clone`, ideally, Git fetches the repository and copies the necessary objects locally, however, `git clone --reference` only reaches the remote repo for the important files when it needs to use it. This could be an issue if there are changes to the remote repo or if there is a corruption with with the remote repository

## How do Git mirrors work

A `git clone` command which is primarily used to produce a copy of a repository. After running the cloning command, the users can utilize to make changes or updates to the original repository. This is done using the underlying operations hidden in a secret `.git` directory. Users may also have used `git clone --bare` which exposes all the hidden underlying Git operations at the expense of not checking out the main branch for the users in the root of the directory.

Git mirrors work by mirroring the repository in a central location and making each checkout use a `--reference` clone of the mirror. In other words, it maintains a single bare git mirror for each repository on a host that is shared amongst multiple agents and pipelines. Checkouts reference the git mirror using `git clone --reference`, as do submodules.

You can use Git mirrors by setting the `--git-mirrors-path` flag.

See the following agent configuration options for more information:

- [git-clone-mirror-flags](/docs/agent/v3/configuration#git-clone-mirror-flags)
- [git-mirrors-lock-timeout](/docs/agent/v3/configuration#git-mirrors-lock-timeout)
- [git-mirrors-path](/docs/agent/v3/configuration#git-mirrors-path)
- [git-mirrors-skip-update](/docs/agent/v3/configuration#git-mirrors-skip-update)

## Why use Git mirrors

As described earlier, git mirror is a feature that allows users to create local copies of Git repositories on Buildkite agents. Its primary use is to optimise performance and other factors like network bandwidth with the overall aim of reducing the time it takes to re-clone large repositories.

The main uses for Git mirrors are:

1. Speed up cloning
1. Reduce disk usage
1. Faster build operation
1. Back up for repositories
1. Large repository handling

## Common issues to note with Git mirrors

### Parallelism

With multiple agents trying to git fetch in the same mirror repo, there is a high chance of conflicts between the agents. This is the reason we have a locking system in the mirror to prevent multiple agents updating the mirror at the same time.
Due to the fact that a mirror directory can be a network file share, it is advisable to ensure the lock works across multiple machines. This is mostly ensured with file-based locks.

### Checkout corruption

A mirror repository and a reference clone(checkout) work together where the checkout borrows most of its object from the mirror instead of storing them locally. When `git fetch` runs the Mirror, it automatically triggers maintenance (by default `git fetch` runs `git maintenance run --auto`) that cleans up objects it considers not useful whereas some of those files may actually be needed. In the case that were to happen, this leads to a checkout error. This will then have to be resolved by deleting the checkout directory and re-cloning it. It is relatively easier if git mirrors is enabled.

### Updating mirrors

Using `git remote update` is the usual way to update mirrors as it updates everything in a mirror, however `git fetch origin <branch>` would be the preferred way as for most CI/CD use cases, only the objects needed for a particular job are needed. This is why, in this [PR](https://github.com/buildkite/agent/pull/1112), `git remote update` was switched to `git fetch origin <branch>`, Another point to note here is that`git remote update` also runs auto maintenance which may cause the checkout corruption as mentioned earlier

## Possible alternatives to Git mirrors

### Using Dissociate

`git clone --reference <path> -- dissociate` is similar to `--reference`, however it makes copies of the objects during the clone. This could help with repo corruption and reducing network usage, but it consumes hard disk usage for each clone which could introduce a different issue depending on the available storage space.

### Git worktree

In a `----bare` or `--mirror` clone, Git doesn't provide a working copy of the files in the repo. But you can still retrieve them, make commits..etc. if you need to. The most convenient way to do that is using a worktree.
Instead of  `git clone --reference <mirror>`, jobs could be ran in a directory inside the mirror. Example below

```bash
cd <mirror>
git worktree add build-12345
cd build-12345
git checkout <branch>
Run the job
cd ..
git worktree remove --force build-12345
```

By using worktree within a single repo, maintenance operations can be ran as many times as possible, because the repo does not secretly depend on objects that might be removed.
A major downside however to this approach is that the agents need to be managed across different machines sharing the mirror via a network share which requires a lot of additional effort.

#### Git submodules

Git submodules are a way for one repository to refer to another repository, so that the contents of that second repository can be used from code in the first. If mirrors are enabled, submodules would also be mirrored. Submodule mirrors can also be created and updated just like regular mirrors, this is because submodules are also technically mirrors.
The caveat to this is that submodule mirrors need special handling in the agent. The agent has to update the submodule configuration in the main repo, using `git submodule update --reference <submodule_mirror>`. It has to do that for each submodule which could be a lot in some cases, which means parsing the submodule config, and then looping over them to update them.
