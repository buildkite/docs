# Pipelines

A collection of common tasks with pipelines using the GraphQL API.

You can test out the Buildkite GraphQL API using the [Buildkite explorer](https://graphql.buildkite.com/explorer). This includes built-in documentation under the _Docs_ panel.

>📘 Suggest recipes
> Want to suggest a recipe? We welcome pull requests to the [docs repo](https://github.com/buildkite/docs).

## Create a pipeline

Create a pipeline programmatically.

First, get the organization ID and team ID:

```graphql
query getOrganizationAndTeamId {
  organization(slug: "organization-slug") {
    id
    teams(first:500) {
      edges {
        node {
          id
          slug
        }
      }
    }
  }
}
```

Then, create the pipeline:

```graphql
mutation createPipeline {
  pipelineCreate(input: {
    organizationId: "organization-id"
    name: "pipeline-name",
    repository: {url: "repo-url"},
    steps: { yaml: "steps:\n - command: \"buildkite-agent pipeline upload\"" },
    teams: { id: "team-id" }
  }) {
    pipeline {
      id
      name
      teams(first: 10) {
        edges {
          node {
            id
          }
        }
      }
    }
  }
}
```

>📘
When setting pipeline steps using the API, you must pass in a string that Buildkite parses as valid YAML, escaping quotes and line breaks.
> To avoid writing an entire YAML file in a single string, you can place a <code>pipeline.yml</code> file in a <code>.buildkite</code> directory at the root of your repo, and use the <code>pipeline upload</code> command in your pipeline steps to tell Buildkite where to find it. This means you only need the following:
> <code>
steps: { yaml: "steps:\n - command: \"buildkite-agent pipeline upload\"" }
</code>

## Get a list of recently created pipelines

Get a list of the 500 most recently created pipelines.

```graphql
query RecentPipelineSlugs {
  organization(slug: "organization-slug") {
    pipelines(first: 500) {
      edges {
        node {
          slug
        }
      }
    }
  }
}
```

## Get a pipeline's UUID

Get a pipeline's UUID by searching for it in the API. Search term can match a pipeline slug.

_Note: Pipeline slugs are modifiable and can change_

```graphql
query GetPipelineUUID {
  organization(slug: "organization-slug") {
    pipelines(first: 50, search: "part of slug") {
      edges {
        node {
          slug
          uuid
        }
      }
    }
  }
}
```

## Get a pipeline's information

You can get specific pipeline information for each of your pipeline. You can retrieve information for each build, jobs, and any other information listed on [this](https://buildkite.com/docs/apis/graphql/schemas/object/pipeline) page.

```graphql
query GetPipelineInfo {
  pipeline(uuid: "pipeline-uuid") {
    slug
    uuid
    builds(first:50){
      edges {
        node {
          state
          message
        }
      }
    }
  }
}
```

## Get pipeline metrics

The _Pipelines_ page in Buildkite shows speed, reliability, and builds per week, for each pipeline. You can also access this information through the API.

```graphql
query AllPipelineMetrics {
  organization(slug: "organization-slug") {
    name
    pipelines(first: 50) {
      edges {
        node {
          name
          metrics {
            edges {
              node {
                label
                value
              }
            }
          }
        }
      }
    }
  }
}
```

## Delete a pipeline

First, get the ID of the pipeline you want to delete:

```graphql
query {
  pipeline(slug:"organization-slug/pipeline-slug") {
    id
  }
}
```

Then, use the ID to delete the pipeline:

```graphql
mutation PipelineDelete {
  pipelineDelete(input: {
    id: "pipeline-id"
  })
  {
    deletedPipelineID
  }
}
```

### Update pipeline schedule with multiple environment variables

You can set multiple environment variables on a pipeline schedule by using the new-line value `\n` as a delimiter.

```graphql
mutation UpdateSchedule {
  pipelineScheduleUpdate(input:{
    id: "schedule-id"
    env: "FOO=bar\nBAR=foo"
  }) {
    pipelineSchedule {
      id
      env
    }
  }
}
```
