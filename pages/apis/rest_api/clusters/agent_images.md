# Agent images

Agent images let you define custom Dockerfile bodies for [Buildkite hosted agents](/docs/agent/buildkite-hosted). Each agent image is associated with a cluster and is built on top of a Buildkite-managed base image.

This API is available to organizations with Buildkite hosted agents enabled. Non-hosted clusters return an empty list for [list](#list-agent-images) requests, and `404 Not Found` for [get](#get-an-agent-image) and [delete](#delete-an-agent-image) requests.

## Agent image data model

<table class="responsive-table">
  <tbody>
    <tr>
      <th><code>id</code></th>
      <td>ID of the agent image (the Namespace profile ID)</td>
    </tr>
    <tr>
      <th><code>name</code></th>
      <td>Name of the agent image</td>
    </tr>
    <tr>
      <th><code>status</code></th>
      <td>Build status of the agent image. Possible values: <code>BUILDING</code>, <code>READY</code>, <code>FAILED</code></td>
    </tr>
    <tr>
      <th><code>image_ref</code></th>
      <td>The fully qualified image URL once the agent image has been built. <code>null</code> while the image is still building</td>
    </tr>
    <tr>
      <th><code>version</code></th>
      <td>Version number of the agent image</td>
    </tr>
    <tr>
      <th><code>last_build_error</code></th>
      <td>Error message from the most recent failed build, or <code>null</code> if no error</td>
    </tr>
    <tr>
      <th><code>dockerfile</code></th>
      <td>The user-supplied Dockerfile body (without the <code>FROM</code> instruction). This is the content you would submit in a <a href="#create-an-agent-image">create</a> request</td>
    </tr>
    <tr>
      <th><code>base_image</code></th>
      <td>The Buildkite-managed base image <code>FROM</code> line prepended to every agent image Dockerfile</td>
    </tr>
    <tr>
      <th><code>composed_dockerfile</code></th>
      <td>The full Dockerfile sent to the image builder: <code>base_image</code> followed by <code>dockerfile</code></td>
    </tr>
    <tr>
      <th><code>url</code></th>
      <td>Canonical API URL of the agent image</td>
    </tr>
    <tr>
      <th><code>web_url</code></th>
      <td>URL of the agent image on Buildkite</td>
    </tr>
    <tr>
      <th><code>cluster_url</code></th>
      <td>API URL of the cluster the agent image belongs to</td>
    </tr>
  </tbody>
</table>

## List agent images

Returns the list of a cluster's agent images, sorted alphabetically by name. Non-hosted clusters return an empty list.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/agent-images"
```

```json
[
  {
    "id": "abc123def4567",
    "name": "my-custom-image",
    "status": "READY",
    "image_ref": "nscr.io/nde1af6lccoqo/buildkite/abc123def4567:v1",
    "version": 1,
    "last_build_error": null,
    "dockerfile": "RUN apt-get update && apt-get install -y curl",
    "base_image": "FROM docker.io/buildkite/hosted-agent-base:ubuntu-v1.0.1@sha256:f1378abd34fccb2b7b661aaf3b06394509a4f7b5bb8c2f8ad431e7eaa1cabc9c",
    "composed_dockerfile": "FROM docker.io/buildkite/hosted-agent-base:ubuntu-v1.0.1@sha256:f1378abd34fccb2b7b661aaf3b06394509a4f7b5bb8c2f8ad431e7eaa1cabc9c\nRUN apt-get update && apt-get install -y curl",
    "url": "https://api.buildkite.com/v2/organizations/my-org/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf/agent-images/abc123def4567",
    "web_url": "https://buildkite.com/organizations/my-org/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf/agent_images/abc123def4567",
    "cluster_url": "https://api.buildkite.com/v2/organizations/my-org/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf"
  }
]
```

Required scope: `read_clusters`

Success response: `200 OK`

## Get an agent image

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/agent-images/{id}"
```

```json
{
  "id": "abc123def4567",
  "name": "my-custom-image",
  "status": "READY",
  "image_ref": "nscr.io/nde1af6lccoqo/buildkite/abc123def4567:v1",
  "version": 1,
  "last_build_error": null,
  "dockerfile": "RUN apt-get update && apt-get install -y curl",
  "base_image": "FROM docker.io/buildkite/hosted-agent-base:ubuntu-v1.0.1@sha256:f1378abd34fccb2b7b661aaf3b06394509a4f7b5bb8c2f8ad431e7eaa1cabc9c",
  "composed_dockerfile": "FROM docker.io/buildkite/hosted-agent-base:ubuntu-v1.0.1@sha256:f1378abd34fccb2b7b661aaf3b06394509a4f7b5bb8c2f8ad431e7eaa1cabc9c\nRUN apt-get update && apt-get install -y curl",
  "url": "https://api.buildkite.com/v2/organizations/my-org/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf/agent-images/abc123def4567",
  "web_url": "https://buildkite.com/organizations/my-org/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf/agent_images/abc123def4567",
  "cluster_url": "https://api.buildkite.com/v2/organizations/my-org/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf"
}
```

Required scope: `read_clusters`

Success response: `200 OK`

## Create an agent image

Buildkite manages the base image for all hosted agent images. Submit only the Dockerfile body — the instructions to layer on top of the base image. Do not include a `FROM` instruction; Buildkite prepends the managed base image automatically.

Image builds are asynchronous. The response returns immediately with `status: "BUILDING"`. Poll [get an agent image](#get-an-agent-image) until `status` is `READY` or `FAILED`.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/agent-images" \
  -H "Content-Type: application/json" \
  -d '{ "name": "my-custom-image", "dockerfile": "RUN apt-get update && apt-get install -y curl" }'
```

```json
{
  "id": "abc123def4567",
  "name": "my-custom-image",
  "status": "BUILDING",
  "image_ref": null,
  "version": 1,
  "last_build_error": null,
  "dockerfile": "RUN apt-get update && apt-get install -y curl",
  "base_image": "FROM docker.io/buildkite/hosted-agent-base:ubuntu-v1.0.1@sha256:f1378abd34fccb2b7b661aaf3b06394509a4f7b5bb8c2f8ad431e7eaa1cabc9c",
  "composed_dockerfile": "FROM docker.io/buildkite/hosted-agent-base:ubuntu-v1.0.1@sha256:f1378abd34fccb2b7b661aaf3b06394509a4f7b5bb8c2f8ad431e7eaa1cabc9c\nRUN apt-get update && apt-get install -y curl",
  "url": "https://api.buildkite.com/v2/organizations/my-org/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf/agent-images/abc123def4567",
  "web_url": "https://buildkite.com/organizations/my-org/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf/agent_images/abc123def4567",
  "cluster_url": "https://api.buildkite.com/v2/organizations/my-org/clusters/42f1a7da-812d-4430-93d8-1cc7c33a6bcf"
}
```

Required [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
  <tbody>
    <tr>
      <th><code>name</code></th>
      <td>Name for the agent image. Must be unique within the cluster.<br><em>Example:</em> <code>"my-custom-image"</code></td>
    </tr>
  </tbody>
</table>

Optional [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
  <tbody>
    <tr>
      <th><code>dockerfile</code></th>
      <td>Dockerfile body to layer on top of the Buildkite-managed base image. Must not contain a <code>FROM</code> instruction.<br><em>Example:</em> <code>"RUN apt-get update &amp;&amp; apt-get install -y curl"</code></td>
    </tr>
  </tbody>
</table>

Required scope: `write_clusters`

Success response: `201 Created`

Error responses:

<table class="responsive-table">
  <tbody>
    <tr>
      <th><code>409 Conflict</code></th>
      <td><code>{ "message": "an agent image named \"my-custom-image\" already exists in this cluster" }</code></td>
    </tr>
    <tr>
      <th><code>422 Unprocessable Entity</code></th>
      <td><code>{ "message": "Reason for failure" }</code></td>
    </tr>
  </tbody>
</table>

## Delete an agent image

Deleting an agent image that is currently assigned to one or more queues returns `409 Conflict`. Reassign those queues to a different agent image before deleting.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/agent-images/{id}"
```

Required scope: `write_clusters`

Success response: `204 No Content`

Error responses:

<table class="responsive-table">
  <tbody>
    <tr>
      <th><code>404 Not Found</code></th>
      <td><code>{ "message": "No agent image found with the given ID." }</code></td>
    </tr>
    <tr>
      <th><code>409 Conflict</code></th>
      <td><code>{ "message": "this agent image is in use by one or more queues; reassign those queues before deleting it" }</code></td>
    </tr>
  </tbody>
</table>
