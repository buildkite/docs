- `name` (required) is the name for the new cluster.

- `description` (optional) is the description that appears under the name of cluster in its tile on the **Clusters** page.

- `emoji` (optional) is the emoji that appears next to the cluster's name in the Buildkite interface and uses the example syntax above.

- `color` (optional) provides the background color for this emoji and uses hex code syntax (for example, `#FFE0F1`).

> 📘 A default queue is not automatically created
> Unlike creating a new cluster through the [Buildkite interface](#create-a-cluster-using-the-buildkite-interface), a default queue is not automatically created using this API call. To create a new/default queue for any new cluster created through an API call, you need to manually [create a new queue](/docs/agent/queues/managing#create-a-self-hosted-queue).
