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
