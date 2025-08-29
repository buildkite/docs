# Hosted agents

A collection of common tasks with [Hosted agents](/docs/pipelines/hosted-agents) using the GraphQL API.

<%= render_markdown partial: 'apis/graphql/cookbooks/graphql_console_link' %>

## Create a Buildkite hosted queue

```graphql
mutation {
  clusterQueueCreate(
    input: {
      organizationId: "organization-id"
      clusterId: "cluster-id"
      key: "hosted_linux_small"
      description: "Small AMD64 Linux agents hosted by Buildkite."
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

Creates a small Buildkite hosted queue using AMD64-based Linux Buildkite hosted agents. The `instanceShape` value is referenced from the [InstanceShape](/docs/apis/graphql/schemas/enum/hostedagentinstanceshapename) enum, and represents the combination of machine type, architecture, CPU and Memory available to each job running on a hosted queue. The `LINUX_AMD64_2X4` value is a Linux AMD64 2 vCPU and 4 GB memory instance.

Learn more about the instance shapes available for [Linux](#instance-shape-values-for-linux) and [macOS](#instance-shape-values-for-macos) Buildkite hosted agents.

## Change the instance shape of a Buildkite hosted queue's agents

```graphql
mutation {
  clusterQueueUpdate(
    input: {
      organizationId: "organization-id"
      id: "cluster-queue-id"
      hostedAgents: {
        instanceShape: LINUX_AMD64_4X16
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

To increase the size of the AMD64-based Linux agent instances for a Buildkite hosted queue, update the `instanceShape` value to a one of a greater size, such as `LINUX_AMD64_4X8`, which is a 4 vCPU and 8 GB memory. This allows you to scale the resources available to each job running on this Buildkite hosted queue.

Learn more about the instance shapes available for [Linux](#instance-shape-values-for-linux) and [macOS](#instance-shape-values-for-macos) Buildkite hosted agents.

> 📘
> It is only possible to change the _size_ of the current instance shape assigned to this queue. It is not possible to change the current instance shape's machine type (from macOS to Linux, or vice versa), or for a Linux machine, its architecture (from AMD64 to ARM64, or vice versa).

## Instance shape values for Linux

Specify the appropriate **Instance shape** for the `instanceShape` value in your GraphQL API mutation.

<%= render_markdown partial: 'shared/hosted_agents/hosted_agents_instance_shape_table_linux' %>

## Instance shape values for macOS

Specify the appropriate **Instance shape** for the `instanceShape` value in your GraphQL API mutation.

<%= render_markdown partial: 'shared/hosted_agents/hosted_agents_instance_shape_table_mac' %>
