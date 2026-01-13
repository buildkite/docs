# Pause and resume an agent

You can _pause_ an agent to prevent any jobs of the cluster's pipelines from being dispatched to that particular agent. This is similar to [pausing and resuming queues](/docs/agent/v3/queues/managing#pause-and-resume-a-queue), but instead, applies to individual agents.

_Pausing_ an agent is a useful alternative to _stopping_ an agent, especially when resources are tied to the lifetime of the agent, such as a cloud instance configured to terminate when the agent exits. By pausing an agent, you can investigate problems in its environment more easily, without the worry of jobs being dispatched to it. Pausing is also useful when performing maintenance on an agent's environment, where idleness would be preferred, especially for maintenance operations that would affect the reliability or speed of jobs if they ran at the same time. Some examples of maintenance operations that could benefit from pausing an agent include:

- pruning Docker caches
- emptying temporary directories
- updating code mirrors
- installing software updates
- compacting or vacuuming databases

> 📘 Pause timeouts
> A paused agent continues to consume resources even while it is not running any jobs. Since it could be undesirable to do this indefinitely, each pause has a timeout specified in minutes. The default timeout is 5 minutes.

With Buildkite Agent v3.93 and later, a paused ephemeral agent also remains running after it would normally exit. An _ephemeral_ agent is an agent started with any one of these flags:

- `--acquire-job`
- `--disconnect-after-job`
- `--disconnect-after-idle-timeout`

Pausing an ephemeral agent is useful for preventing ephemeral resources such as EC2 instances or Kubernetes pods from being automatically removed. This allows manually inspecting and diagnosing a failing agent's environment. An ephemeral agent that is paused but otherwise idle will exit once it is resumed.

> 📘 Paused agents and scaling
> The Agent Scaler component of Elastic CI Stack for AWS considers paused agents to be available for jobs, even though they are not. The stack will _not_ scale up extra instances to maintain capacity merely because an agent becomes paused.

To pause an agent:

1. Select **Agents** in the global navigation to access the **Clusters** page.
1. Select the cluster with the agent to pause.
1. On the **Queues** page, select the queue with the agent to resume.
1. On the queue's details page, select the agent to pause.
1. On the agent's details page, select **Pause Agent**.
1. Enter a timeout (in minutes) and an optional note, and select **Yes, pause
   this agent** to pause the agent.

    **Note:** Use this note to explain why you're pausing the agent. The note
    will be displayed on the agent's details page.

Jobs _already_ started by an agent that becomes paused will continue to run. New jobs that target the agent's queue will be dispatched to other agents in the queue, or wait.

To resume an agent:

1. Select **Agents** in the global navigation to access the **Clusters** page.
1. Select the cluster with the agent to resume.
1. On the **Queues** page, select the queue with the agent to resume.
1. On the queue's details page, select the agent to resume.
1. On the agent's details page, select **Yes, resume this agent**.

    Jobs will resume being dispatched to the agent as usual, including any jobs waiting to run.

## Using the REST API

To pause an agent (clustered or unclustered) using the [REST API](/docs/apis/rest-api), run the following example `curl` command:

```bash
curl -H "Authorization: Bearer ${TOKEN}" \
  -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/agents/{id}/pause" \
  -H "Content-Type: application/json" \
  -d '{
    "note": "A short note explaining why this agent is being paused",
    "timeout_in_minutes": 60
  }'
```

where:

<%= render_markdown partial: 'apis/descriptions/rest_access_token' %>

<%= render_markdown partial: 'apis/descriptions/rest_org_slug' %>

To resume an agent using the [REST API](/docs/apis/rest-api), run the following example `curl` command:

```bash
curl -H "Authorization: Bearer ${TOKEN}" \
  -X PUT "https://api.buildkite.com/v2/organizations/{org.slug}/agents/{id}/resume" \
  -H "Content-Type: application/json" \
  -d '{}'
```

## Using the GraphQL API

To pause an agent (clustered or unclustered) using the [GraphQL API](/docs/apis/graphql-api), run the following example [mutation](/docs/apis/graphql/schemas/mutation/agentpause):

```graphql
mutation {
  agentPause(
      input: {
          id: "The GraphQL ID for the agent to pause"
          note: "Note explaining why the agent is being paused"
          timeoutInMinutes: 60
      }
  ) {
    agent {
      uuid
      paused
      pausedAt
      pausedBy { uuid }
      pausedNote
    }
  }
}
```

where the GraphQL ID for an agent can be found from an `agents` GraphQL query:

```graphql
query {
   organization(slug: "Your_org_slug") {
    agents(first: 10) {
      edges {
        node {
          id
        }
      }
    }
  }
}
```

To resume an agent using the [GraphQL API](/docs/apis/graphql-api), run the following example [mutation](/docs/apis/graphql/schemas/mutation/agentresume):

```graphql
mutation {
  agentResume(
      input: {
          id: "The GraphQL ID for the agent to resume"
      }
  ) {
    agent {
      uuid
      paused
    }
  }
}
```
