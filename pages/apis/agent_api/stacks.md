---
toc: true
---

# Stack API

The Stack API provides endpoints for implementing a stack reliably.
These endpoints require [Agent tokens](/docs/agent/v3/tokens) for authentication.

A stack is defined as a software process that has these two abilities simultaneously:

- The ability to pull/receive new jobs from the Buildkite API.
- The ability to turn those job definitions into running agents.

A stack can also be broadly understood as an orchestrator or a scheduler of Buildkite jobs.

The Stack API powers Buildkite's Agent Kubernetes Stack.
It's designed to give advanced enterprise users custom control over the scheduling of jobs at larger scales.

> 📘 This API is currently available in preview.

## Register a stack

Register a new stack or update an existing one.
You must use this API to register a stack `key` before using any of the following APIs.
You can choose to register a stack key ad-hoc once, or have it as part of your stack implementation.
This endpoint is idempotent.

The register payload includes a mandatory `queue_key` field, which tells Buildkite which cluster queue the stack is intended to serve.
However, such binding isn't enforced so there is a possibility that you could use a single stack implementation to power all cluster queues.

The number of active stacks per organization is limited, and each stack is subject to independent rate limits.

Request payload:

| Field       | Type             | Required | Description                                         |
| ----------- | ---------------- | -------- | --------------------------------------------------- |
| `key`       | string           | Yes      | Unique identifier for the stack in the org.         |
| `type`      | string           | Yes      | Type of stack. 3rd party stack should use "custom". |
| `queue_key` | string           | Yes      | Cluster queue key the stack plans to serve.         |
| `metadata`  | key-value object | Yes      | Additional metadata for the stack                   |

Example:

```bash
curl -H "Authorization: Token $BUILDKITE_CLUSTER_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST "https://agent.buildkite.com/v3/stacks/register" \
  -d '{
    "key": "my-kubernetes-stack",
    "type": "custom",
    "queue_key": "default",
    "metadata": {
      "version": "1.0.0",
      "region": "us-east-1"
    }
  }'
```

```json
{
  "key": "my-kubernetes-stack",
  "type": "kubernetes",
  "cluster_queue_key": "default",
  "metadata": {
    "version": "1.0.0",
    "region": "us-east-1"
  }
}
```

Success response: `201 Created` (new stack) or `200 OK` (existing stack updated)

## De-register a stack

De-register a stack from the cluster.
Ideally, when a stack stops, it should use this API to de-register its `key` from the Buildkite backend.
This will ensure an organization doesn't exceed the stack count quota.

```bash
curl -H "Authorization: Token $BUILDKITE_CLUSTER_TOKEN" \
  -X POST "https://agent.buildkite.com/v3/stacks/my-kubernetes-stack/deregister"
```

Success response: `204 No Content`

## List scheduled jobs (Metadata only)

This is the most important API of the Stack APIs.
It fetches all jobs that have been scheduled to run by Buildkite's internal state machine.
When a cluster queue is paused, `cluster_queue.dispatch_paused` will return `true`, and a stack implementation **must** respect this flag (i.e. avoid starting new jobs whenever the queue is paused).

A stack often makes scheduling decisions based on returned metadata and turns this job metadata into running agents using [--acquire-jobs](https://buildkite.com/resources/changelog/129-one-shot-agents-with-the-acquire-job-flag/).

It's worth noting that until these jobs transition into another state, the API will keep returning them.
To avoid starting duplicate jobs, we offer some utility APIs below.

Query parameters:

| Parameter   | Type    | Required | Description                                |
| ----------- | ------- | -------- | ------------------------------------------ |
| `queue_key` | string  | Yes      | Filter jobs by queue key                   |
| `limit`     | integer | No       | Maximum number of jobs to return, max 1000 |

Example:

```bash
curl -H "Authorization: Token $BUILDKITE_CLUSTER_TOKEN" \
  -X GET "https://agent.buildkite.com/v3/stacks/my-kubernetes-stack/scheduled_jobs?queue_key=default&limit=10"
```

```json
{
  "jobs": [
    {
      "id": "01234567-89ab-cdef-0123-456789abcdef",
      "scheduled_at": "2023-10-01T12:00:00.000Z",
      "priority": 1,
      "agent_query_rules": ["test=a"],
      "pipeline_slug": "my-pipeline",
      "pipeline_id": "pipeline-uuid",
      "build_number": 123,
      "build_branch": "main",
      "build_id": "build-uuid",
      "step_key": "test"
    }
  ],
  "page_info": {
    "has_next_page": false,
    "end_cursor": null
  },
  "cluster_queue": {
    "id": "queue-id",
    "dispatch_paused": false
  }
}
```

Success response: `200 OK`

## Get a job (Env + command)

In some cases, the job metadata returned from the API above isn't sufficient to make a full scheduling decision.
In such cases, you can use this API to get the full payload data of a job individually.
Specifically, the job payload data contains `env` and `command`.
Due to the dynamic nature of Buildkite pipelines, these two fields can often grow to above 100KB.

It's useful when you want to make scheduling decisions based on in-depth analysis of a job.

```bash
JOB_UUID="01234567-89ab-cdef-0123-456789abcdef"
curl -H "Authorization: Token $BUILDKITE_CLUSTER_TOKEN" \
  -X GET "https://agent.buildkite.com/v3/stacks/my-kubernetes-stack/jobs/$JOB_UUID"
```

```json
{
  "id": "01234567-89ab-cdef-0123-456789abcdef",
  "env": {
    "BUILDKITE_JOB_ID": "01234567-89ab-cdef-0123-456789abcdef",
    "BUILDKITE_BUILD_NUMBER": "123"
  },
  "command": "echo Hello 👋"
}
```

Success response: `200 OK`

## Reserve jobs

In order to prevent pulling duplicate jobs, a stack can _reserve_ jobs that it has decided to execute.
If this API is called, a stack _should only_ execute jobs that are successfully reserved, as shown in the `reserved` fields in the response.
Until the reservation expires, the reserved jobs will not show up in subsequent list scheduled jobs API calls.
If the reservation expires, the reserved jobs will return to the `scheduled` state.

You can reserve multiple jobs for execution. This API can be repeatedly called to extend the expiration of reservation states.

Alternatively, a stack implementation can maintain its own persistent layer to keep track of job lifecycle, in which case, calling this API will be unnecessary.

Request payload:

| Field                        | Type          | Required | Description                     |
| ---------------------------- | ------------- | -------- | ------------------------------- |
| `job_uuids`                  | array[string] | Yes      | Array of job UUIDs to reserve   |
| `reservation_expiry_seconds` | integer       | No       | Reservation duration in seconds |

Example:

```bash
curl -H "Authorization: Token $BUILDKITE_CLUSTER_TOKEN" \
  -H "Content-Type: application/json" \
  -X PUT "https://agent.buildkite.com/v3/stacks/my-kubernetes-stack/scheduled_jobs/batch_reserve" \
  -d '{
    "job_uuids": [
      "01234567-89ab-cdef-0123-456789abcdef",
      "fedcba98-7654-3210-fedc-ba9876543210"
    ],
    "reservation_expiry_seconds": 1800
  }'
```

```json
{
  "reserved": [
    "01234567-89ab-cdef-0123-456789abcdef",
    "fedcba98-7654-3210-fedc-ba9876543210"
  ],
  "not_reserved": []
}
```

Success response: `200 OK`

## Get job states

Retrieve the current state of multiple jobs.
This is useful when a stack is provisioning infrastructure for a job and the job is cancelled before the infrastructure is ready.
A stack can choose to decommission infrastructure proactively to save cost.

This API is also helpful to inform a stack when a job's responsibility can be safely shifted to the running agent.

This API uses `POST` method for batch data loading.

Request payload:

| Field       | Type          | Required | Description                          |
| ----------- | ------------- | -------- | ------------------------------------ |
| `job_uuids` | array[string] | Yes      | Array of job UUIDs to get states for |

Example:

```bash
curl -H "Authorization: Token $BUILDKITE_CLUSTER_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST "https://agent.buildkite.com/v3/stacks/my-kubernetes-stack/jobs/get-states" \
  -d '{
    "job_uuids": [
      "01234567-89ab-cdef-0123-456789abcdef",
      "fedcba98-7654-3210-fedc-ba9876543210"
    ]
  }'
```

```json
{
  "states": {
    "01234567-89ab-cdef-0123-456789abcdef": "scheduled",
    "fedcba98-7654-3210-fedc-ba9876543210": "running"
  }
}
```

Success response: `200 OK`

## Finish a job

Mark a job as finished when the stack cannot or will not execute it, or when it has completed successfully without spawning an agent.
In some situations, an agent cannot be spawned due to infrastructure or other issues. In this case, for each job, a stack can call this API at most once to finish the job with details.

This is a critical API to shorten the feedback cycle to end users.
For example, in the Kubernetes stack, if a pod has an image pull issue, the k8s stack uses this API to fail a job with feedback.

A job that is finished with this approach will have a special notification on the Buildkite Build page.

Request payload:

| Field         | Type    | Required | Description                                                                                            |
| ------------- | ------- | -------- | ------------------------------------------------------------------------------------------------------ |
| `exit_status` | integer | No       | Exit status code for the job. Defaults to -1 if not provided. Use 0 to indicate successful completion. |
| `detail`      | string  | Yes      | Description of why the job finished (max 4KB)                                                          |

Example:

```bash
curl -H "Authorization: Token $BUILDKITE_CLUSTER_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST "https://agent.buildkite.com/v3/stacks/my-kubernetes-stack/jobs/$JOB_UUID/finish" \
  -d '{
    "exit_status": -1,
    "detail": "Stack failed to start agent: insufficient resources"
  }'
```

Success response: `200 OK`

## Create stack notification

In situations when a stack may take more than a few seconds to provision infrastructure for a job, or when the stack is waiting for some external conditions to be satisfied, a stack can give short textual notifications to the Buildkite Build page.
This can help with visibility and debugging.
A notification `detail` can be a short string.
A job cannot have more than 50 stack notifications, so a stack should use this API judiciously.

### Request payload

| Field    | Type   | Required | Description                                 |
| -------- | ------ | -------- | ------------------------------------------- |
| `detail` | string | Yes      | Short notification message (max length 255) |

```bash
curl -H "Authorization: Token $BUILDKITE_CLUSTER_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST "https://agent.buildkite.com/v3/stacks/my-kubernetes-stack/jobs/$JOB_UUID/stack_notifications" \
  -d '{
    "detail": "Pod is starting up"
  }'
```

Success response: `200 OK`
