# Pipelines

A collection of common tasks with pipelines using the GraphQL API.

<%= render_markdown partial: 'apis/graphql/cookbooks/graphql_console_link' %>

## Create a pipeline

Create a pipeline programmatically.

First, get the organization ID, team ID, and cluster ID (`uuid`) values:

```graphql
query getOrganizationTeamAndClusterIds {
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
    clusters(first: 10) {
      edges {
        node {
          name
          uuid
          color
          description
        }
      }
    }
  }
}
```

The relevant cluster's `uuid` value is the `cluster-id` value used in the next step.

Then, create the pipeline:

```graphql
mutation createPipeline {
  pipelineCreate(input: {
    organizationId: "organization-id"
    name: "pipeline-name"
    repository: {url: "repo-url"}
    clusterId: "cluster-id"
    steps: { yaml: "steps:\n - command: \"buildkite-agent pipeline upload\"" }
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

> 📘
When setting pipeline steps using the API, you must pass in a string that Buildkite parses as valid YAML, escaping quotes and line breaks.
> To avoid writing an entire YAML file in a single string, you can place a `pipeline.yml` file in a `.buildkite` directory at the root of your repo, and use the `pipeline upload` command in your pipeline steps to tell Buildkite where to find it. This means you only need the following:
> `steps: { yaml: "steps:\n - command: \"buildkite-agent pipeline upload\"" }`

### Deriving a pipeline slug from the pipeline's name

<%= render_markdown partial: 'platform/deriving_a_pipeline_slug_from_the_pipelines_name' %>

Any attempt to create a new pipeline with a name that matches an existing pipeline's name, results in an error.

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

## Get a list of pipelines and their respective repository

Get a list of the first 100 most recently created pipelines along with the URL of each pipeline's configured repository.

```
query GetPipelinesRepositories{
  organization(slug: "organization-slug") {
    pipelines(first: 100) {
      edges {
        node {
          name
          repository {
            url
          }
        }
      }
    }
  }
}
```

## Get a pipeline's ID

Get a pipeline's ID which can be used in other queries.

```graphql
query {
  pipeline(slug:"organization-slug/pipeline-slug") {
    id
  }
}
```

## Get a pipeline's UUID

Get a pipeline's UUID by searching for it in the API. Search term can match a pipeline slug.

**Note:** Pipeline slugs are modifiable and can change

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

You can get specific pipeline information for each of your pipeline. You can retrieve information for each build, jobs, and any other information listed on [this](/docs/apis/graphql/schemas/object/pipeline) page.

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

The **Pipelines** page in Buildkite shows speed, reliability, and builds per week, for each pipeline. You can also access this information through the API.

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

First, [get the ID of the pipeline](#get-a-pipelines-id) you want to delete.
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

### Delete multiple pipelines

First, [get the IDs of the pipelines](#get-a-pipelines-id) you want to delete.
Then, use the IDs to delete multiple pipelines:

```graphql
mutation PipelinesDelete {
  pipeline1: pipelineDelete(input: {
    id: "pipeline1-id"
  })
  {
    deletedPipelineID
  }

  pipeline2: pipelineDelete(input: {
    id: "pipeline2-id"
  })
  {
    deletedPipelineID
  }
}
```

## Update pipeline schedule with multiple environment variables

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

## Get a list of all webhook URLs

Get a list of all the webhook URLs associated with the 500 most recently created pipelines.

```graphql
query GetPipelineWebhooks {
  organization(slug: "organization-slug") {
    pipelines(first: 500) {
      edges {
        node {
          slug
          webhookURL
        }
      }
    }
  }
}
```

## Archive a pipeline

First, [get the ID of the pipeline](#get-a-pipelines-id) you want to archive.
Then, use the ID to archive the pipeline:

```graphql
mutation PipelineArchive {
  pipelineArchive(input: {
    id: "pipeline-id"
  })
  {
    pipeline {
      id
      name
    }
  }
}
```

### Archive multiple pipelines

First, [get the IDs of the pipelines](#get-a-pipelines-id) you want to archive.
Then, use the IDs to archive the pipelines:

```graphql
mutation PipelinesArchive {
  pipeline1: pipelineArchive(input: {
    id: "pipeline1-id"
  })
  {
    pipeline {
      id
      name
    }
  }

  pipeline2: pipelineArchive(input: {
    id: "pipeline2-id"
  })
  {
    pipeline {
      id
      name
    }
  }
}
```

## Unarchive a pipeline

First, [get the ID of the pipeline](#get-a-pipelines-id) you want to unarchive.
Then, use the ID to unarchive the pipeline:

```graphql
mutation PipelineUnarchive {
  pipelineUnarchive(input: {
    id: "pipeline-id"
  })
  {
    pipeline {
      id
      name
    }
  }
}
```

### Unarchive multiple pipelines

The process for unarchiving multiple pipelines is similar to that for [archiving multiple pipelines](#archive-a-pipeline-archive-multiple-pipelines).

However, use the field `pipelineUnrchive` (in `pipeline1: pipelineUnarchive(input: { ... })`, etc.) instead of `pipelineArchive`.
