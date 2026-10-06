---
description: "Move GitHub Actions repository secrets into Buildkite secrets with the Buildkite CLI."
---

# Migrate GitHub Actions secrets

GitHub doesn't let you read a secret's value after you save it. To move GitHub Actions repository secrets into [Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets), use the [Buildkite CLI](/docs/platform/cli) to create a one-use migration workflow.

GitHub Actions sends the selected values directly to Buildkite. The values don't pass through your machine.

> 📘 Buildkite CLI version
> Use Buildkite CLI version 3.59.1 or later. Check your version with `bk version`.

## Before you start

You need:

- A local checkout of a `github.com` repository that has GitHub Actions repository secrets.
- The [GitHub CLI](https://cli.github.com/) signed in to an account that can read the repository's Actions secrets.
- The Buildkite CLI signed in to the Buildkite organization that will receive the secrets.
- A Buildkite pipeline for the repository.
- Permission to [create Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets#create-a-secret) in that pipeline's cluster.

## Create the migration workflow

From your repository, run:

```bash
bk secret migrate github-actions prepare \
  --secret DEPLOY_TOKEN \
  --match 'AWS_*' \
  --output .github/workflows/migrate-buildkite-secrets.yml
```

The Buildkite CLI finds the Buildkite pipeline for your repository and creates a workflow that names each secret it will move. The CLI won't select a secret if a secret with the same name already exists in the destination cluster.

To choose secrets interactively, leave out `--secret` and `--match`.

## Review and merge the workflow

Review the workflow like any other code change. Check which secrets it moves, where they go, and which pipeline can use them.

By default, only the matched pipeline can use the migrated secrets. To use a different [access policy](/docs/pipelines/security/secrets/buildkite-secrets/access-policies), pass `--policy-file` when you create the workflow.

The Buildkite CLI doesn't commit or push files. Commit the workflow without changing it:

```bash
git add .github/workflows/migrate-buildkite-secrets.yml
git commit -m "Migrate GitHub Actions secrets to Buildkite"
git push origin main
```

If your default branch requires pull requests, create a pull request:

```bash
git switch -c migrate-buildkite-secrets
git add .github/workflows/migrate-buildkite-secrets.yml
git commit -m "Migrate GitHub Actions secrets to Buildkite"
git push -u origin migrate-buildkite-secrets
gh pr create --fill
```

Merge the pull request after it's approved.

## Run the migration

Run the workflow:

```bash
bk secret migrate github-actions run \
  --workflow .github/workflows/migrate-buildkite-secrets.yml
```

The Buildkite CLI checks that the workflow on your default branch matches the reviewed workflow before it starts the migration. If the workflow has changed, the command stops.

The command prints the GitHub Actions run URL:

```text
Dispatch accepted for .github/workflows/migrate-buildkite-secrets.yml on main with 3 secrets. The migration is not complete until the GitHub Actions run succeeds.
Actions: https://github.com/acme-inc/app/actions/runs/123456789
```

A successful command means GitHub started the workflow. The migration is complete only after the GitHub Actions run succeeds.

To watch the run from your terminal:

```bash
gh run watch 123456789 --exit-status
```

A successful run prints the names of the secrets it created:

```text
Created Buildkite secret DEPLOY_TOKEN
Created Buildkite secret AWS_ACCESS_KEY_ID
Created Buildkite secret AWS_SECRET_ACCESS_KEY
Migration complete. Remove this workflow from the default branch.
```

Each migration can only be used once. If the run fails before it creates the secrets, run `bk secret migrate github-actions run` again.

## Remove the workflow

After the migration succeeds, remove the workflow:

```bash
git rm .github/workflows/migrate-buildkite-secrets.yml
git commit -m "Remove secret migration workflow"
git push origin main
```

If your default branch requires pull requests, remove the workflow in a pull request.

## Use the migrated secrets

Add each secret to the step that needs it:

```yaml
steps:
  - label: "Deploy"
    command: "./scripts/deploy.sh"
    secrets:
      - DEPLOY_TOKEN
```

> 🚧 Secrets in commands
> Buildkite Pipelines interpolates `$DEPLOY_TOKEN` when it uploads your pipeline YAML, before your job receives its secrets. If you reference a secret directly in a YAML `command`, use `$$DEPLOY_TOKEN`.

```yaml
steps:
  - label: "Check secret"
    command: "test -n \"$$DEPLOY_TOKEN\""
    secrets:
      - DEPLOY_TOKEN
```

## Limitations

- Only `github.com` repository secrets are supported. GitHub Enterprise Server and other GitHub secret types aren't supported.
- Each workflow can move up to 40 secrets.
- Each secret value must not be blank and must be smaller than 32 KiB.
- You can't migrate `GITHUB_TOKEN`.
- The migration never overwrites an existing Buildkite secret.
