# Jobs

A collection of common tasks with jobs using the GraphQL API.

<%= render_markdown partial: 'apis/graphql/cookbooks/graphql_console_link' %>

## Get all jobs in a given queue for a given timeframe

Get all jobs in a named queue, created on or after a given date. If you want to get all jobs across your Buildkite organization, you do not need to set a queue name, and you can therefore omit the `agentQueryRules` option.

```graphql
query PipelineRecentBuildLastJobQueue {
  organization(slug: "organization-slug") {
    pipelines(first: 500) {
      edges {
        node {
          slug
          builds(first: 1) {
            edges {
              node {
                number
                jobs(state: FINISHED, first: 1, agentQueryRules: "queue=queue-name") {
                  edges {
                    node {
                      ... on JobTypeCommand {
                        uuid
                        agentQueryRules
                        createdAt
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      pageInfo {
        hasNextPage
        endCursor
      }
    }
  }
}
```

## Get all jobs in a particular concurrency group

To see which jobs are waiting for a concurrency group in case the secret URL fails, you can use the following query.

```
query getConcurrency {
  organization(slug: "organization-slug") {
    jobs(first:100,concurrency:{group:"name"}, type:[COMMAND], state:[LIMITED,WAITING,ASSIGNED]) {
      edges {
        node {
          ... on JobTypeCommand {
            url
            createdAt
          }
        }
      }
    }
  }
}
```

### Handling 504 errors

When attempting to get all jobs in a particular concurrency group throughout your Buildkite organization, you might receive a 504 error in the response, which could result from your specific query being too resource-intensive for the Buildkite GraphQL API to resolve. In such circumstances, restrict the query by a specific pipeline, using its slug.

```
query getConcurrency {
  organization(slug: "organization-slug/pipeline-slug") {
    jobs(first:100,concurrency:{group:"name"}, type:[COMMAND], state:[LIMITED,WAITING,ASSIGNED]) {
      edges {
        node {
          ... on JobTypeCommand {
            url
            createdAt
          }
        }
      }
    }
  }
}
```

## Get the last job of an agent

To get the last job of an agent or `null`. You will need to know the UUID of the agent.

```
query AgentJobs {
  agent(slug: "organization-slug/agent-UUID") {
    jobs(first: 10) {
      edges {
        node {
          ... on JobTypeCommand {
            state
            build {
              state
            }
          }
        }
      }
    }
  }
}
```

## Get the job run time per build

To get the run time of each job in a build, you can use the following query.

```
query GetJobRunTimeByBuild {
  build(slug: "organization-slug/pipeline-slug/build-number") {
    jobs(first: 1) {
      edges {
        node {
          ... on JobTypeCommand {
            startedAt
            finishedAt
          }
        }
      }
    }
  }
}
```

## Get a job's UUID

To get UUIDs of the jobs in a build, you can use the following query.

```graphql
query GetJobsUUID {
  build(slug: "org-slug/pipeline-slug/build-number") {
    jobs(first: 1) {
      edges {
        node {
          ... on JobTypeCommand {
            uuid
          }
        }
      }
    }
  }
}
```

## Get info about a job by its UUID

Get info about a job using the job's UUID only.

```graphql
query GetJob {
  job(uuid: "a00000a-xxxx-xxxx-xxxx-a000000000a") {
    ... on JobTypeCommand {
      id
      uuid
      createdAt
      scheduledAt
      finishedAt
      pipeline{
        name
      }
      build{
        id
        number
        pipeline{
          name
        }
      }
    }
  }
}
```

## Cancel a job

If you need to cancel a job, you can use the following call with the job's ID:

```graphql
mutation CancelJob {
  jobTypeCommandCancel(input: { id: "job-id" }) {
    jobTypeCommand {
      id
    }
  }
}
```

## Get retry information for a job

Gets information about how a job was retried (`retryType`), who retried the job (`retriedBy`) and which job was source of the retry (`uuid`).
`retriedBy` will be `null` if the `retryType` is `AUTOMATIC`.

```graphql
query GetJobRetryInformation {
  job(uuid: "job-uuid") {
    ... on JobTypeCommand {
      retrySource {
        ... on JobInterface {
          uuid
          retried
          retryType
          retriedBy {
            email
            name
          }
        }
      }
    }
  }
}
```
