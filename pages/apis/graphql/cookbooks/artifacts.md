# Artifacts

A collection of common tasks with artifacts using the GraphQL API.

<%= render_markdown partial: 'apis/graphql/cookbooks/graphql_console_link' %>

## List download URLs for artifacts from a build

To get the download URLs for artifacts from a build.
If the artifact is stored on Buildkite-managed artifact storage, the download URL will be valid for only 10 minutes.

```graphql
query GetDownloadURLsForArtifactsFromBuild {
  build(uuid: "build-uuid") {
    jobs(first: 500) {
      edges {
        node {
          ... on JobTypeCommand {
            artifacts {
              edges {
                node {
                  id
                  path
                  downloadURL
                }
              }
            }
          }
        }
      }
    }
  }
}
```

## Filter artifacts by state

The `artifacts` field on a command job accepts an optional `state` argument to return only artifacts in a given state. Valid values are `NEW`, `ERROR`, `FINISHED`, `DELETED`, and `EXPIRED`.

Buildkite-hosted artifacts past their retention window match the `EXPIRED` filter, except artifacts whose stored state is `NEW`. Those artifacts continue to match the `NEW` filter. The returned `state` field remains a string and uses lowercase values such as `expired` and `new`, matching the behavior of the [REST API](/docs/apis/rest-api/artifacts).

To list only artifacts that failed to upload:

```graphql
query GetErroredArtifactsForJob {
  job(uuid: "job-uuid") {
    ... on JobTypeCommand {
      artifacts(state: ERROR) {
        edges {
          node {
            uuid
            path
            state
          }
        }
      }
    }
  }
}
```

## Filter artifacts by path

The `artifacts` field also accepts an optional `path` argument. When the value contains a `*`, it is treated as a glob wildcard. Otherwise, the path must match exactly.

To list all artifacts under a `logs/` directory:

```graphql
query GetLogArtifactsForJob {
  job(uuid: "job-uuid") {
    ... on JobTypeCommand {
      artifacts(path: "logs/*") {
        edges {
          node {
            uuid
            path
            state
          }
        }
      }
    }
  }
}
```

To list a single artifact by its exact path:

```graphql
query GetArtifactByExactPath {
  job(uuid: "job-uuid") {
    ... on JobTypeCommand {
      artifacts(path: "coverage/index.html") {
        edges {
          node {
            uuid
            path
            downloadURL
          }
        }
      }
    }
  }
}
```

You can combine `state` and `path` in the same query. The following example returns only successfully uploaded artifacts under `logs/`:

```graphql
query GetFinishedLogArtifactsForJob {
  job(uuid: "job-uuid") {
    ... on JobTypeCommand {
      artifacts(state: FINISHED, path: "logs/*") {
        edges {
          node {
            uuid
            path
            downloadURL
          }
        }
      }
    }
  }
}
```

## Delete an artifact

1. [Get the artifact's GraphQL ID](#list-download-urls-for-artifacts-from-a-build) from a build query.
1. Use that ID to delete the artifact:

```graphql
mutation ArtifactDelete {
  artifactDelete(input: {
    id: "artifact-id"
  }) {
    deletedArtifactId
    artifact {
      state
    }
  }
}
```

The artifact record is retained and marked as deleted. Files stored by Buildkite are removed from storage asynchronously. Artifacts hosted outside Buildkite, such as those in custom AWS S3, Google Cloud, or Artifactory storage, are left in place and must be deleted manually from that storage.
