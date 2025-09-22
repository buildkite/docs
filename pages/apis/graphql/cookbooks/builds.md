# Builds

A collection of common tasks with builds using the GraphQL API.

<%= render_markdown partial: 'apis/graphql/cookbooks/graphql_console_link' %>

## Get build info by ID

Get all the available info from a build while only having its UUID.

```
query GetBuilds {
  build(uuid: "a00000a-xxxx-xxxx-xxxx-a000000000a") {
    id
    number
    url
  }
}
```

## Get all environment variables set on a build

Retrieve all of a job's environment variables for a given build. This is the equivalent of what you see in the _Environment_ tab of each build.

```graphql
query GetEnvVarsBuild {
  build(slug:"organization-slug/pipeline-slug/build-number") {
    message
    jobs(first: 10, state:FINISHED) {
      edges {
        node {
          ... on JobTypeCommand {
            label
            env
          }
        }
      }
    }
  }
}
```

## Get all builds for a pipeline

Retrieve all of the builds for a given pipeline, including each build's ID, number, and URL.

```graphql
query GetBuilds {
  pipeline(slug: "organization-slug/pipeline-slug") {
    builds(first: 10) {
      edges {
        node {
          id
          number
          url
        }
      }
    }
  }
}
```

## Get the creation date of the most recent build in every pipeline

Get the creation date of the most recent build in every pipeline. Use pagination to handle large responses. Buildkite sorts builds by newest first.

Get the first 500:

```graphql
query {
  organization(slug: "organization-slug") {
    pipelines(first: 500) {
      count
      pageInfo {
        endCursor
        hasNextPage
      }
      edges {
        node {
          name
          slug
          builds(first: 1) {
            edges {
              node {
                createdAt
              }
            }
          }
        }
      }
    }
  }
}
```

Then, if there are more than 500 results, use the value of `organization.pipelines.pageInfo.endCursor` to get the next page:

```graphql
query {
  organization(slug: "organization-slug") {
    pipelines(first: 500, after: "<endCursor-value-from-previous-response>") {
      count
      pageInfo {
        endCursor
        hasNextPage
      }
      edges {
        node {
          name
          slug
          builds(first: 1) {
            edges {
              node {
                createdAt
              }
            }
          }
        }
      }
    }
  }
}
```

<!-- vale off -->

Replace `<endCursor-value-from-previous-response>` with the actual endCursor string returned from your previous query.

<!-- vale on -->

## Get number of builds between two dates

This query helps you understand how many job minutes you've used by looking at the number of builds. While not equivalent, there's a correlation between the number of builds and job minutes. So, looking at the number of builds in different periods gives you an idea of how the job minutes would compare in those periods.

```graphql
query PipelineBuildCountForPeriod {
  pipeline(slug: "organization-slug") {
    builds(
      createdAtFrom:"YYYY-MM-DDTHH:mm:ss", 
      createdAtTo:"YYYY-MM-DDTHH:mm:ss"
    ) {
      count
      edges{
        node{
          createdAt
          finishedAt
          id
        }
      }
    }
  }
}
```

> 📘 Date format
> In this example, both the `createdAtFrom` and `createdAtTo` fields within the `builds` sub-query of the `pipeline` query must be specified in [DateTime](/docs/apis/graphql/schemas/scalar/datetime) format, which is an ISO-8601 encoded UTC date string.

## Get all builds with a certain state between two dates

This query allows you to find all builds with the same state (for example, `running`) that were started within a certain time frame. For example, you could find all builds that started at a particular point and failed or are still running.

```graphql
query {
  organization(slug: "organization-slug") {
    pipelines(first: 10) {
      edges {
        node {
          name
          slug
          builds(
            first: 10,
            createdAtFrom: "YYYY-MM-DDTHH:mm:ss",
            createdAtTo: "YYYY-MM-DDTHH:mm:ss",
            state: RUNNING
          ) {
            edges {
              node {
                id
                number
                message
                state
                url
              }
            }
          }
        }
      }
    }
  }
}
```

> 📘 Date format
> In this example, both the `createdAtFrom` and `createdAtTo` fields within the `builds` sub-query of the `pipeline` query must be specified in [DateTime](/docs/apis/graphql/schemas/scalar/datetime) format, which is an ISO-8601 encoded UTC date string.

## Count the number of builds on a branch

Count how many builds a pipeline has done for a given repository branch.

```graphql
query PipelineBuildCountForBranchQuery {
  pipeline(slug:"organization-slug/pipeline-slug") {
    builds(branch:"branch-name") {
      count
    }
  }
}
```

You can limit the results to a certain timeframe using `createdAtFrom` or `createdAtTo`.

```graphql
query PipelineBuildCountForBranchQuery {
  pipeline(slug:"organization-slug/pipeline-slug") {
    builds(
      branch:"branch-name", 
      createdAtTo:"YYYY-MM-DDTHH:mm:ss"
    ) {
      count
    }
  }
}
```

> 📘 Date format
> In this example, both the `createdAtTo` field within the `builds` sub-query of the `pipeline` query must be specified in [DateTime](/docs/apis/graphql/schemas/scalar/datetime) format, which is an ISO-8601 encoded UTC date string.

## Increase the next build number

Set the number for the next build to run in this pipeline.

First, get the pipeline ID:

```graphql
query PipelineId {
  pipeline(slug: "organization-slug/pipeline-slug") {
    id
  }
}
```

Then mutate the next build number. In this example, we set `nextBuildNumber` to 300:

```graphql
mutation PipelineUpdate {
  pipelineUpdate(input: {
  id: "pipeline-id",
  nextBuildNumber: 300
  }) {
    pipeline {
      name
      nextBuildNumber
    }
  }
}
```

## Get the total build run time

To get the total run time for a build, you can use the following query.

```
query GetTotalBuildRunTime {
  build(slug: "organization-slug/pipeline-slug/build-number") {
    pipeline {
      name
    }
    url
    startedAt
    finishedAt
  }
}
```

## Create a build on a pipeline

Create a build programmatically.
First, get the ID for the pipeline to create a build for:

```
query GetPipelineID {
  organization(slug: "organization-slug") {
    pipelines(first: 50, search: "part of slug") {
      edges {
        node {
          slug
          id
        }
      }
    }
  }
}
```

Then, create the build:

```
  mutation createBuild {
    buildCreate(
      input: {
        commit: "commit-hash"
        branch: "branch-name"
        pipelineID: "pipeline-id"
      }
    ) {
      build {
        number
      }
    }
  }
```
## Get the webhook payload of a build

This query allows you to fetch the webhook payload of a specific build using its UUID. The payload is only available for 7 days.

```graphql
query GetWebhookPayLoad {
  build(uuid:"build-uuid") {
    source{
      ... on BuildSourceWebhook {
        headers
        payload
      }
    }
  }
}
```
