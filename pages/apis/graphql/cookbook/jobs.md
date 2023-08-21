## Jobs

A collection of common tasks with jobs using the GraphQL API.

You can test out the Buildkite GraphQL API using the [Buildkite explorer](https://graphql.buildkite.com/explorer). This includes built-in documentation under the _Docs_ panel.

>📘 Suggest recipes
> Want to suggest a recipe? We welcome pull requests to the [docs repo](https://github.com/buildkite/docs).


### Get all jobs in a given queue for a given timeframe

Get all jobs in a named queue, created on or after a given date. Note that if you want all jobs in the default queue, you do not need to set a queue name, so you can omit the `agentQueryRules` option.


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

### Get all jobs in a particular concurrency group

To see which jobs are waiting for a concurrency group in case the secret URL fails, you can use the following query.

```
query getConcurrency {
  organization(slug: "{org}") {
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
### Get the last job of an agent

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

### Get the job run time per build

To get the run time of each job in a build, you can use the following query.

```
query GetJobRunTimeByBuild{
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
### Cancel a job

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
