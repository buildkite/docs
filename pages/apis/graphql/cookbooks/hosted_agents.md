# Hosted agents

A collection of common tasks with [Hosted agents](/docs/pipelines/hosted-agents) using the GraphQL API.

## Creating a hosted cluster queue

```graphql
mutation {
  clusterQueueCreate(
    input: {
      organizationId: "organization-id"
      clusterId: "cluster-id"
      key: "hosted_linux_small"
      description: "Small AMD64 Linux agents hosted by Buildkite."
      hosted: true
      hostedAgents: {
        instanceShape: LINUX_AMD64_2X4
      }
    }
  ) {
    clusterQueue {
      id
      uuid
      key
      description
      dispatchPaused
      hosted
      hostedAgents {
        instanceShape {
          name
          size
          vcpu
          memory
        }
      }
      createdBy {
        id
        uuid
        name
        email
        avatar {
          url
        }
      }
    }
  }
}
```

Create a small AMD64 Linux hosted agent cluster queue, which is hosted by Buildkite. The `instanceShape` value is referenced from the [InstanceShape](/docs/apis/graphql/schemas/enum/hostedagentinstanceshapename) enum, and represents the combination of machine type, architecture, CPU and Memory available to each job running on a hosted queue. The `LINUX_AMD64_2X4` value is a 2 vCPU and 4 GB memory.

## Changing the instance shape of a hosted agent cluster queue

```graphql
mutation {
  clusterQueueUpdate(
    input: {
      organizationId: "organization-id"
      id: "cluster-queue-id"
      hostedAgents: {
        instanceShape: LINUX_AMD64_4X8
      }
    }
  ) {
    clusterQueue {
      id
      hostedAgents {
        instanceShape {
          name
          size
          vcpu
          memory
        }
      }
    }
  }
}
```

To increase the size of the agent instances for a hosted agent cluster queue, update the `instanceShape` value to `LINUX_AMD64_4X8`, which is a 4 vCPU and 8 GB memory. This allows you to scale the resources available to each job running on a hosted queue.
