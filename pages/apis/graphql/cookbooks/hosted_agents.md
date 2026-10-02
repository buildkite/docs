# Hosted agents

A collection of common tasks with [Hosted agents](/docs/agent/buildkite-hosted) using the GraphQL API.

<%= render_markdown partial: 'apis/graphql/cookbooks/graphql_console_link' %>

## Create a Buildkite hosted queue

Create a new _Buildkite hosted queue_ in a cluster, which are queues created for Buildkite hosted agents.

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

Learn more about the instance shapes available for [Linux](#instance-shape-values-for-linux), [macOS](#instance-shape-values-for-macos), and [Windows](#instance-shape-values-for-windows) Buildkite hosted agents.

> 📘 Windows availability
> Windows has no automatic or included allowance. Buildkite must allocate Windows access and capacity to your organization before you can create a Windows hosted queue.

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

Learn more about the instance shapes available for [Linux](#instance-shape-values-for-linux), [macOS](#instance-shape-values-for-macos), and [Windows](#instance-shape-values-for-windows) Buildkite hosted agents.

> 📘
> It is only possible to change the _size_ of the current instance shape assigned to this queue. It is not possible to change the current instance shape's machine type (for example, from macOS to Linux), or for a Linux machine, its architecture (from AMD64 to ARM64, or vice versa).

## Set a custom image URL for a Buildkite hosted queue

You can configure a Buildkite hosted queue to use a [custom image URL](/docs/agent/buildkite-hosted/linux/custom-agent-images#use-an-agent-image-specify-a-custom-image-for-a-queue). When set, this overrides the agent image selected through the Buildkite interface.

```graphql
mutation {
  clusterQueueUpdate(
    input: {
      organizationId: "organization-id"
      id: "cluster-queue-id"
      hostedAgents: {
        platformSettings: {
          linux: {
            agentImageRef: "my-custom-image:latest"
          }
        }
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
        platformSettings {
          linux {
            agentImageRef
          }
        }
      }
    }
  }
}
```

The `agentImageRef` value is a URL or reference to a custom image. The image must be publicly available or pushed to the [internal container registry](/docs/pipelines/hosted-agents/internal-container-registry). Setting it requires access to the custom agent images feature.

> 📘
> The `hostedAgents.agentImageRef` input field is deprecated; use `platformSettings.linux.agentImageRef` instead. Only one of the two can be provided in a single mutation, and providing both results in a validation error.

## Instance shape values for Linux

Specify the appropriate **Instance shape** for the `instanceShape` value in your GraphQL API mutation.

<%= render_markdown partial: 'shared/buildkite_hosted_agents/instance_shape_table_linux' %>

## Instance shape values for macOS

Specify the appropriate **Instance shape** for the `instanceShape` value in your GraphQL API mutation.

<%= render_markdown partial: 'shared/buildkite_hosted_agents/instance_shape_table_mac' %>

## Instance shape values for Windows

Specify the appropriate **Instance shape** for the `instanceShape` value in your GraphQL API mutation. Buildkite must allocate Windows access and capacity to your organization before you can use these values.

<%= render_markdown partial: 'shared/buildkite_hosted_agents/instance_shape_table_windows' %>
