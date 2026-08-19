# Git mirror seeding

When [Git mirrors](/docs/agent/self-hosted/configure/git-mirrors) are enabled on the Elastic CI Stack for AWS, each instance maintains a local bare mirror of every repository it builds. On ephemeral instances, the first job on each new instance must create these mirrors with a full `git clone --mirror`. For large repositories, this cold start can dominate job startup time.

Git mirror seeding removes this cold start. You upload archives of pre-built mirrors to an S3 bucket, and each instance downloads and extracts them into its Git mirror directory at boot, before the agent starts. The first job on the instance then fetches only the commits created since the archive was built, instead of cloning the entire repository.

Seeding is best-effort. If the bucket is empty, unreachable, or an archive is invalid, the instance logs a warning and the agent starts normally, falling back to a full `git clone --mirror` on the first job.

> 📘 Linux instances only
> Git mirror seeding is supported on Linux instances only. On Windows stacks, the seed bucket is ignored and no bucket access is granted to the instance role.

## Enabling Git mirror seeding

Set both of the following [configuration parameters](/docs/agent/self-hosted/aws/elastic-ci-stack/ec2-linux-and-windows/configuration-parameters) on your stack:

- `BuildkiteAgentEnableGitMirrors`: `true`
- `GitMirrorSeedBucket`: the name of an existing S3 bucket containing your seed archives

The S3 bucket must already exist — the stack does not create it. The stack grants its instances read-only access (`s3:GetObject` and `s3:ListBucket`) scoped to the `git-mirror-seeds/` prefix of the bucket. If your stack uses a custom `InstanceRoleARN`, grant that role equivalent access to the bucket separately.

When `GitMirrorSeedBucket` is set, the default `InstanceCreationTimeout` increases from `PT5M` to `PT15M` to allow time for downloading and extracting seed archives at boot. If extracting your archives takes longer, set `InstanceCreationTimeout` explicitly.

## Creating seed archives

Store archives in your bucket under the fixed `git-mirror-seeds/` prefix, one archive per repository:

```
s3://<bucket>/git-mirror-seeds/
  git-github-com-org-repo-git.tar.gz
  https---github-com-acme-inc-project-git.tar.gz
```

Supported archive formats are `.tar`, `.tar.gz`, and `.zip`. Compressed archives (`.tar.gz`) are recommended, as they transfer from S3 significantly faster.

### Naming convention

Archive file names must match the name of the agent's mirror directory for the repository, which is the repository URL with every non-alphanumeric character replaced by `-`. To compute it:

```bash
printf '%s' "git@github.com:org/repo.git" | sed 's/[^a-zA-Z0-9]/-/g'
# => git-github-com-org-repo-git
```

Use the exact repository URL your pipelines are configured with. For example, `https://github.com/acme-inc/project.git` produces `https---github-com-acme-inc-project-git`, which is a different mirror name than the SSH URL for the same repository.

### Archive contents

Archives must be created from a bare mirror (created with `git clone --mirror`), not a regular checkout. Each archive must contain exactly one top-level directory, named after the archive, containing the mirror. Archives that don't match this shape — for example, archives with multiple top-level entries, or a directory that isn't a bare Git repository — are rejected at boot with a warning.

To create and upload an archive from an instance that already has a mirror:

```bash
# Compute the sanitized mirror name
REPO_URL="git@github.com:org/repo.git"
SANITIZED_NAME=$(printf '%s' "${REPO_URL}" | sed 's/[^a-zA-Z0-9]/-/g')

# Create a compressed tar from an existing mirror
MIRROR_PATH="/var/lib/buildkite-agent/git-mirrors/${SANITIZED_NAME}"
tar czf "/tmp/${SANITIZED_NAME}.tar.gz" -C "$(dirname "${MIRROR_PATH}")" "${SANITIZED_NAME}"

# Upload to S3
aws s3 cp "/tmp/${SANITIZED_NAME}.tar.gz" "s3://<bucket>/git-mirror-seeds/${SANITIZED_NAME}.tar.gz"
```

> 🚧 Build archives on Linux
> Archives created with the default `tar` on macOS embed AppleDouble metadata files (`._*`) and extended attributes that produce warnings when extracted on Linux. Build seed archives on a Linux machine — ideally on a stack instance itself, as in the example pipeline below.

## How seeding behaves at boot

At instance boot, before the agent starts, the instance lists the `git-mirror-seeds/` prefix and processes each supported archive:

- Each archive is extracted into a temporary staging directory and validated before being moved into the Git mirror directory, so an invalid archive can never overwrite or delete other mirrors.
- If a mirror directory with the same name already exists on the instance, the archive is skipped.
- Corrupt or invalid archives are discarded with a warning, and the agent starts regardless of the seeding outcome.
- Stale archives still work: the agent's first job fetches only the missing commits, and the agent corrects the mirror's remote URL automatically. Archives that don't correspond to any pipeline's repository sit unused on disk.

Seeding progress and warnings are logged to the system log on the instance, which you can view with `journalctl` or in the instance's CloudWatch log groups.

## Keeping seed archives fresh

Stale archives still work, but fresher archives mean smaller deltas and faster first jobs. A scheduled Buildkite pipeline running on a regular cadence (for example, nightly or weekly) can rebuild and upload archives:

```yaml
env:
  SEED_BUCKET: "my-seed-bucket"

steps:
  - label: ":git: Create and upload git mirror seed archive"
    command: |
      SANITIZED_NAME=$$(printf '%s' "$$BUILDKITE_REPO" | sed 's/[^a-zA-Z0-9]/-/g')
      MIRROR_PATH="/var/lib/buildkite-agent/git-mirrors/$$SANITIZED_NAME"

      if [[ ! -d "$$MIRROR_PATH" ]]; then
        echo "Mirror not found at $$MIRROR_PATH"
        exit 1
      fi

      echo "--- :package: Creating archive"
      TAR_FILE=$$(mktemp --suffix=.tar.gz)
      trap 'rm -f "$$TAR_FILE"' EXIT
      tar czf "$$TAR_FILE" -C "$$(dirname "$$MIRROR_PATH")" "$$SANITIZED_NAME"

      echo "--- :s3: Uploading"
      aws s3 cp "$$TAR_FILE" "s3://$$SEED_BUCKET/git-mirror-seeds/$$SANITIZED_NAME.tar.gz"
```
{: codeblock-file="pipeline.yml"}

The stack only grants its instances read access to the seed prefix, so the pipeline that creates archives needs `s3:PutObject` on the seed bucket. Grant this via a separate IAM policy, a custom bootstrap script, or by running the pipeline on a queue whose instances have broader S3 permissions.
