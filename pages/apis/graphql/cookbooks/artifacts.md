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
