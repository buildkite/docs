# Test Scheduler API v2

## Draft API Specification

[Chris Atkins](mailto:chris.a@buildkite.com) [Matthew Borden](mailto:matt@buildkite.com) [Pablo Annesley](mailto:paul@buildkite.com)

## Implementation status

This document describes the current prototype implementation. The API remains behind the `test_scheduler_api` feature flag and may still evolve. Routes or behavior that remain design proposals are called out explicitly rather than being presented as available.

When the contract settles, we intend to share an OpenAPI specification and potentially a Go client library as a sub-package in [test-engine-client](https://github.com/buildkite/test-engine-client).

## Context

Buildkite is designing a Test Engine capability called Test Scheduler that implements a pull-based queue for running tests in Buildkite jobs.

## Terminology

* `TestPool`: A suite- and build-scoped pool containing multiple entries. A non-destroyed pool is unique by organization, pipeline, build, and case-insensitive pool key.  
* `TestPool.Entry`: A persisted definition of scheduleable work. Each entry has a runner-understood `selector_type` and `selector`, plus an optional custom cost, priority, affinity group, and metadata.  
  * A selector may identify one reportable test or a broader runnable target such as a file, package, Python `node_id`, or Bazel target.  
  * `custom` is the only currently supported selector type.  
* `TestPool.Entry.Attempt`: A leasable invocation of an entry. Entry fields used for scheduling and execution are copied onto the attempt when the entry is uploaded.  
* `Lease`: A time-bounded worker claim over one or more attempts. A lease is not a separately persisted record in the current implementation; the lease ID, owning job ID, and expiry are stamped onto each leased attempt.  
* `Worker`: The Buildkite job identified by the OIDC token's `job_id` claim.

Execution policies and automatic retry-attempt creation are not implemented. Uploading an entry currently creates exactly one waiting attempt with `attempt_index: 0`.

## API Routes

All implemented routes are JSON over HTTP beneath this organization-scoped prefix:

`/v2/organizations/{org-slug}/test-scheduler`

Every request requires build routing context. Pool-specific routes require a `build_id` query parameter. The pool index requires `pipeline_id` and `build_id` query parameters, and pool creation requires `build_id` in the request body.

| Method and path | Scope | Behavior |
| :---- | :---- | :---- |
| `GET /pools?pipeline_id=...&build_id=...&key=...` | `read_test_pool` | Lists pools for the token's suite, pipeline, and build. `key` is optional and matched case-insensitively. |
| `POST /pools` | `write_test_pool` | Creates a pool. |
| `GET /pools/{pool_id}?build_id=...` | `read_test_pool` | Gets one pool. |
| `PATCH /pools/{pool_id}?build_id=...` | `write_test_pool` | Finishes population with `{ "populating": false }`. |
| `POST /pools/{pool_id}/entries?build_id=...` | `write_test_pool` | Uploads entries and creates initial waiting attempts. |
| `GET /pools/{pool_id}/entries?build_id=...` | `read_test_pool` | Lists entries and their attempt counts. |
| `POST /pools/{pool_id}/leases?build_id=...` | `write_test_pool` | Leases a cost-bounded batch of waiting attempts to the authenticated job. |
| `POST /pools/{pool_id}/leases/heartbeat?build_id=...` | `write_test_pool` | Extends active leases owned by the authenticated job. |
| `POST /pools/{pool_id}/leases/complete?build_id=...` | `write_test_pool` | Completes selected attempts from one or more leases. |
| `POST /pools/{pool_id}/leases/release?build_id=...` | `write_test_pool` | Releases selected attempts or all active attempts from one or more leases. |
| `GET /pools/{pool_id}/metrics?build_id=...` | `read_test_pool` | Returns aggregate progress for a pool. |

### Example end-to-end request flow

A simple flow that finishes discovery before workers begin consuming is:

1. `POST /pools` to create the pool.  
2. If creation reports that the pool already exists, `GET /pools?pipeline_id=...&build_id=...&key=...` to resolve its ID.  
3. `POST /pools/{pool_id}/entries` one or more times to upload discovered work.  
4. `PATCH /pools/{pool_id}` to finish population.  
5. Each worker calls `POST /pools/{pool_id}/leases` to acquire work.  
6. The worker runs the attempts in the returned lease.  
7. The worker calls `POST /pools/{pool_id}/leases/complete` for attempts it completed.  
8. If the worker cannot run some leased attempts, it calls `POST /pools/{pool_id}/leases/release` for those attempts.  
9. Workers repeat steps 5–8 until no work is available and the pool is `consumed`.  
10. `GET /pools/{pool_id}` may be used at any point to observe the pool's lifecycle state.

Workers may instead begin leasing as soon as the pool exists, overlapping steps 3–4 while producers continue uploading entries. An empty lease response while the pool is still `populating` does not mean the overall flow is finished; the worker should retry after more entries may have been uploaded.

### Test discovery and upload

1. A Buildkite job creates a pool with `POST /pools`.  
2. If creation returns `409 Conflict` because the build and key already identify a pool, the client resolves it with `GET /pools`.  
3. The producer uploads entries with `POST /pools/{pool_id}/entries` while the pool is `populating`.  
4. Each uploaded entry atomically creates one entry and one waiting attempt.  
5. The producer calls `PATCH /pools/{pool_id}` with `{ "populating": false }` when upload is complete.

### Test execution

* Workers call `POST /pools/{pool_id}/leases` to acquire a batch of attempts under one lease ID.  
* Attempts are considered in descending priority, then FIFO by `created_at`, with UUID as the final tie-breaker.  
* An attempt without an affinity group is a batch of one. Selecting an attempt with an affinity group expands the batch to all currently visible waiting attempts in that group, excluding additional attempts for an entry already selected for the lease.  
* During concurrent lease requests, if another request has locked any visible member of an affinity group, that group is skipped for the current request and the scheduler continues considering other work.  
* The first batch is always leased, even if it exceeds the requested cost or attempt limit. A later batch is added only when the whole batch fits both limits. Selection stops at the first later batch that does not fit either the requested cost or attempt limit.  
* A lease normally contains at most 300 attempts. The first affinity-group batch may exceed that limit so the group is not split.  
* Attempts with no custom cost have an effective custom cost of `0`.  
* Completion and release requests are authorized against the OIDC token's `job_id`. A stale or different worker cannot mutate the attempt after it has been released and leased again.

Current limitation: lease expiry is enforced by completion and release, but there is no expired-lease reclamation endpoint or worker yet. An expired attempt remains in `leased` state and is not automatically returned to `waiting` by the current implementation.

### Drain semantics

A pool is drained when it has no attempts in `waiting` or `leased` state. Drain only changes pool state after population has ended:

* Ending population on an already drained pool transitions it directly from `populating` to `consumed`.  
* Ending population on a pool with active attempts transitions it from `populating` to `consuming`.  
* Completing the final active attempt in a `consuming` pool transitions it to `consumed`.  
* A temporarily empty `populating` pool remains `populating`.

### Retry pools

Automatic retries and execution-policy evaluation are implemented. The currently implemented API does not list failed attempts, so constructing a second retry pool from scheduler API results is not yet available end-to-end. The client is responsible for creating a second pool (for baseline retries), and populating it with failed attempts from the first pool. The API will provide an endpoint to list failed attempts, and the second pool can be populated with the `/uploads` endpoint.

### Wire format

The implemented API uses JSON over HTTP. Request and response field names in this document are the JSON wire names; they intentionally differ from some internal database column names.

## Data model and endpoint contracts

### TestPool

Non-destroyed pools are unique on the combination of `organization_id`, `pipeline_id`, `build_id`, and case-insensitive `key`.

| Response field | Type | Description | Nullable |
| :---- | :---- | :---- | :---- |
| `id` | `UUIDv7` | Test pool identifier. | false |
| `organization_id` | `UUID` | Organization that owns the pool. | false |
| `suite_id` | `UUID` | Test Engine suite associated with the pool. | false |
| `pipeline_id` | `UUID` | Buildkite pipeline containing the build. | false |
| `build_id` | `UUID` | Buildkite build that owns the pool. | false |
| `key` | `String` | Build-scoped pool key. It must start with a letter or number, be 255 characters or fewer, and otherwise may contain letters, numbers, hyphens, underscores, periods, and colons. | false |
| `state` | `Enum` | `populating`, `consuming`, or `consumed`. | false |
| `attempt_policy` | `TestPool.AttemptPolicy` | Fully populated attempt policy. | false |
| `expires_at` | `Timestamp` | Fixed expiry computed when the pool is created. It is not extended by activity. | false |
| `created_at` | `Timestamp` | Pool creation time. | false |

#### Create a pool

`POST /pools` accepts suite and pipeline slugs or UUIDs. All values must resolve within the suite, pipeline, build, and organization authorized by the OIDC token.

```json
{
  "suite": "snowfort",
  "pipeline": "snowfort-tests",
  "build_id": "018f5f98-6c64-4ecf-9e7a-bc4b0d7a0004",
  "key": "snowfort-main",
  "ttl_seconds": 3600
}
```

`ttl_seconds` is optional. It defaults to the organization's pool-TTL quota, which is 24 hours unless lowered. Explicit values must be integers between 300 seconds and that quota. In the current implementation, 24 hours is both the default and the hard maximum; an organization quota override may only reduce it.

The response is an unwrapped pool object and includes the fully populated `attempt_policy` used by the pool.

```json
{
  "id": "0192f2fb-3c4d-7bd2-9f0b-4a0d6a7c1000",
  "organization_id": "018f5f98-6c64-4ecf-9e7a-bc4b0d7a0001",
  "suite_id": "018f5f98-6c64-4ecf-9e7a-bc4b0d7a0002",
  "pipeline_id": "018f5f98-6c64-4ecf-9e7a-bc4b0d7a0003",
  "build_id": "018f5f98-6c64-4ecf-9e7a-bc4b0d7a0004",
  "key": "snowfort-main",
  "state": "populating",
  "attempt_policy": {
    "max_attempts": 2,
    "max_failed": 2,
    "max_passed": 1,
    "min_attempts": 1,
    "min_passed": 1,
    "min_failed": 0,
    "parallel_attempts": 1
  },
  "expires_at": "2026-06-11T12:00:00Z",
  "created_at": "2026-06-10T12:00:00Z"
}
```

Creating a duplicate non-destroyed pool returns `409 Conflict`. Pool keys are compared case-insensitively.

#### Find pools

`GET /pools` requires `pipeline_id` and `build_id` query parameters that match the token claims. An optional `key` filters case-insensitively. Results are ordered by pool UUID descending and use cursor pagination with optional `after`, `before`, and `per_page` parameters. Only one cursor direction may be supplied. `per_page` defaults to 30 and accepts values from 1 through 100\.

The response wraps pools in an `items` array and includes `links.self`. It also includes `links.next` and `links.prev` cursor URLs when those directions are available.

`GET /pools/{pool_id}` requires a `build_id` query parameter and returns one unwrapped pool object. Both lookup routes are constrained to the token's organization, suite, pipeline, and build.

#### Pool lifecycle

New pools start in `populating`. Only `populating` pools accept entry uploads, while both `populating` and `consuming` pools may lease work.

The only implemented update is:

```json
{
  "populating": false
}
```

`PATCH /pools/{pool_id}` requires a `build_id` query parameter. It transitions a pool with active attempts to `consuming`, or an already drained pool directly to `consumed`. When present, `populating` must be the JSON boolean `false`, and the transition can only be applied once. A body that omits `populating` returns the pool unchanged.

### TestPool.Entry

A pool entry is an opaque selector plus scheduling attributes understood by the producer and worker.

| Request field | Type | Required | Default | Description |
| :---- | :---- | :---- | :---- | :---- |
| `selector_type` | `String` | true |  | Must be `custom`. |
| `selector` | `String`, `Array`, or `Object` | true |  | Non-empty opaque selector payload. Its JSON-encoded size is quota-controlled and defaults to 1 KiB. |
| `costs.custom` | `Number` | false | `null` | Finite, non-negative custom scheduling cost. A null or omitted cost has effective scheduling cost `0`. |
| `priority` | `Integer` | false | `0` | Scheduling priority from `-10` through `10`; higher values are leased first. |
| `affinity_group` | `String` | false | `null` | Client-defined group of at most 255 characters. Empty strings are normalized to null. |
| `meta_data` | `Object` | false | `null` | Customer-controlled metadata. Values may be strings, integers, or arrays of strings. Defaults allow 10 keys and 1 KiB of JSON-encoded data. |

`POST /pools/{pool_id}/entries` requires a `build_id` query parameter and accepts a non-empty `entries` array. The default organization quota allows 100 entries per request. The whole upload is atomic.

```json
{
  "entries": [
    {
      "selector_type": "custom",
      "selector": {
        "node_id": "test/test.py::TestClass::method_a[some_parameter=True]"
      },
      "costs": {
        "custom": 12.5
      },
      "priority": 0,
      "affinity_group": "bin-a",
      "meta_data": {
        "team": "platform",
        "slack": "#team-platform"
      }
    },
    {
      "selector_type": "custom",
      "selector": {
        "node_id": "test/test.py::TestClass::method_b[some_parameter=True]"
      },
      "costs": {
        "custom": 12.5
      },
      "priority": 0,
      "affinity_group": "bin-a",
      "meta_data": {
        "team": "platform",
        "slack": "#team-platform"
      }
    }
  ]
}
```

The `201 Created` response contains the persisted entries. Initial attempts are created atomically but are not included in this response.

```json
{
  "entries": [
    {
      "id": "0192f2fb-7b61-74c6-b893-fb8c5884879d",
      "pool_id": "0192f2fb-3c4d-7bd2-9f0b-4a0d6a7c1000",
      "selector_type": "custom",
      "selector": {
        "node_id": "test/test.py::TestClass::method_a[some_parameter=True]"
      },
      "costs": {
        "custom": 12.5
      },
      "priority": 0,
      "affinity_group": "bin-a",
      "meta_data": {
        "team": "platform",
        "slack": "#team-platform"
      },
      "created_at": "2026-06-10T12:01:00Z"
    }
  ]
}
```

### TestPool.Entry.Attempt

An attempt is an invocation of a pool entry and is the smallest unit of work inside a lease. The lease response and completion response use this shape:

| Response field | Type | Description | Nullable |
| :---- | :---- | :---- | :---- |
| `id` | `UUIDv7` | Attempt identifier. | false |
| `pool_id` | `UUIDv7` | Owning pool identifier. | false |
| `entry_id` | `UUIDv7` | Owning entry identifier. | false |
| `attempt_index` | `Integer` | Zero-based attempt index. Upload currently creates only index `0`. | false |
| `selector_type` | `String` | Selector type copied from the entry. Currently `custom`. | false |
| `selector` | JSON | Selector copied from the entry. | false |
| `costs.custom` | `Number` | Custom cost copied from the entry. | true |
| `priority` | `Integer` | Priority copied from the entry. | false |
| `affinity_group` | `String` | Affinity group copied from the entry. | true |
| `state` | `Enum` | `waiting`, `leased`, `completed`, or `canceled`. There is no public API for canceling an attempt yet. | false |
| `result` | `Enum` | `passed`, `failed`, or `errored`. Required when completed and otherwise null. | true |
| `lease_id` | `UUIDv7` | Lease identifier stamped onto the attempt. It remains present after completion and is cleared on release. | true |
| `lease_expires_at` | `Timestamp` | Expiry of the current lease. | true |
| `completed_at` | `Timestamp` | Time the attempt was completed. | true |
| `meta_data` | `Object` | Metadata copied from the entry. | true |
| `created_at` | `Timestamp` | Attempt creation time. | false |

### Pool metrics

`GET /pools/{pool_id}/metrics` requires a `build_id` query parameter and the `read_test_pool` scope. It returns aggregate progress for a pool.

```json
{
  "observed_at": "2026-07-21T05:30:00Z",
  "pool": {
    "id": "0192f2fb-3c4d-7bd2-9f0b-4a0d6a7c1000",
    "state": "consuming",
    "drained": false,
    "expires_at": "2026-07-22T05:00:00Z"
  },
  "entries": {
    "total": 12500
  },
  "attempts": {
    "total": 14025,
    "states": {
      "waiting": {
        "count": 1374,
        "costs": { "custom": 11732.5 }
      },
      "leased": {
        "count": 621,
        "costs": { "custom": 5340.0 }
      },
      "completed": {
        "count": 12000,
        "costs": { "custom": 99543.0 }
      },
      "canceled": {
        "count": 30,
        "costs": { "custom": 210.0 }
      }
    },
    "results": {
      "passed": 11500,
      "failed": 450,
      "errored": 50
    }
  },
  "leases": {
    "active": {
      "count": 60,
      "attempt_count": 600
    },
    "expired": {
      "count": 3,
      "attempt_count": 21
    }
  },
  "timing": {
    "oldest_waiting_attempt_created_at": "2026-07-21T05:01:12Z",
    "oldest_active_lease_started_at": "2026-07-21T05:27:03Z",
    "oldest_expired_lease_started_at": "2026-07-21T05:20:41Z",
    "next_active_lease_expires_at": "2026-07-21T05:30:08Z"
  }
}
```

Entries and attempts are reported separately because execution policies may create multiple attempts for one entry. Lease counts are derived from leased attempts because leases are not persisted independently; active and expired leases are classified using `observed_at` and `lease_expires_at`.

### Acquire a lease

`POST /pools/{pool_id}/leases` requires a `build_id` query parameter and accepts an optional body:

```json
{
  "target_cost_limit": {
    "custom": 25
  },
  "lease_ttl_seconds": 120
}
```

`target_cost_limit.custom` defaults to `1` and must be a finite, non-negative number. `lease_ttl_seconds` defaults to `60` and must be an integer from `1` through `600`. An omitted or empty body uses both defaults.

A successful response contains one lease and its attempts:

```json
{
  "lease": {
    "id": "0192f2fb-8c3a-7c1d-9f0b-4a0d6a7c1000",
    "expires_at": "2026-06-10T12:03:00Z",
    "attempts": [
      {
        "id": "0192f2fb-a91f-7c9a-b1d4-a668260f6c87",
        "pool_id": "0192f2fb-3c4d-7bd2-9f0b-4a0d6a7c1000",
        "entry_id": "0192f2fb-7b61-74c6-b893-fb8c5884879d",
        "attempt_index": 0,
        "selector_type": "custom",
        "selector": {
          "node_id": "test/test.py::TestClass::method_a[some_parameter=True]"
        },
        "costs": {
          "custom": 12.5
        },
        "priority": 0,
        "affinity_group": "bin-a",
        "state": "leased",
        "result": null,
        "lease_id": "0192f2fb-8c3a-7c1d-9f0b-4a0d6a7c1000",
        "lease_expires_at": "2026-06-10T12:03:00Z",
        "completed_at": null,
        "meta_data": {
          "team": "platform"
        },
        "created_at": "2026-06-10T12:01:00Z"
      }
    ]
  }
}
```

When there is no waiting work, the response is `{"lease": null}`. Leasing is available for `populating` and `consuming` pools, but an expired or `consumed` pool returns `409 Conflict`.

### Complete attempts

`POST /pools/{pool_id}/leases/complete` requires a `build_id` query parameter and completes explicitly named attempts from one or more leases:

```json
{
  "leases": [
    {
      "lease_id": "0192f2fb-8c3a-7c1d-9f0b-4a0d6a7c1000",
      "attempts": [
        {
          "attempt_id": "0192f2fb-a91f-7c9a-b1d4-a668260f6c87",
          "result": "passed"
        }
      ]
    }
  ]
}
```

Each lease and its `attempts` array must be non-empty. Results are `passed`, `failed`, or `errored`. A request may include at most 5,000 attempts in total; duplicate lease or attempt IDs are rejected. Unlisted attempts remain leased. The request is atomic: if any attempt cannot be completed, no attempt in the request is completed.

The response groups attempts by lease, preserves request order, and includes a snapshot of the pool's state before asynchronous attempt-policy evaluation finishes:

```json
{
  "leases": [
    {
      "lease_id": "0192f2fb-8c3a-7c1d-9f0b-4a0d6a7c1000",
      "attempts": [
        {
          "id": "0192f2fb-a91f-7c9a-b1d4-a668260f6c87",
          "pool_id": "0192f2fb-3c4d-7bd2-9f0b-4a0d6a7c1000",
          "entry_id": "0192f2fb-7b61-74c6-b893-fb8c5884879d",
          "attempt_index": 0,
          "selector_type": "custom",
          "selector": {
            "node_id": "test/test.py::TestClass::method_a[some_parameter=True]"
          },
          "costs": {
            "custom": 12.5
          },
          "priority": 0,
          "affinity_group": "bin-a",
          "state": "completed",
          "result": "passed",
          "lease_id": "0192f2fb-8c3a-7c1d-9f0b-4a0d6a7c1000",
          "lease_expires_at": "2026-06-10T12:03:00Z",
          "completed_at": "2026-06-10T12:02:30Z",
          "meta_data": {
            "team": "platform"
          },
          "created_at": "2026-06-10T12:01:00Z",
          "completion_status": "completed"
        }
      ]
    }
  ],
  "pool": {
    "id": "0192f2fb-3c4d-7bd2-9f0b-4a0d6a7c1000",
    "state": "consuming"
  }
}
```

The pool may transition to `consumed` after the response once asynchronous policy evaluation and draining finish. Clients should use `GET /pools/{pool_id}` to observe the latest pool state.

Completion is idempotent when retried with the same result; the response uses `completion_status: "already_completed"`. Retrying with a different result returns `409 Conflict`. Same-result retries remain available after completion drains the pool or after the pool expires.

### Lease heartbeat

`POST /v2/organizations/{organization_slug}/test-scheduler/pools/{pool_id}/leases/heartbeat` requires a `build_id` query parameter and extends one or more active leases owned by the requesting Buildkite job. The endpoint requires a Buildkite job OIDC token whose policy grants `write_test_pool`; REST API access tokens are not accepted.

Request:

```json
{
  "lease_ids": [
    "0192f2fc-489e-7cab-a8e5-2c0f3f986001",
    "0192f2fc-489e-7cab-a8e5-2c0f3f986002"
  ],
  "lease_ttl_seconds": 120
}
```

| Field | Type | Required | Description |
| :---- | :---- | :---- | :---- |
| `lease_ids` | `Array[UUIDv7]` | true | Between 1 and 100 unique lease IDs. Each lease must be active in this pool and owned by the job identified by the OIDC token. |
| `lease_ttl_seconds` | `Integer` | false | Number of seconds to set the lease expiry after the heartbeat is accepted. Defaults to `60`; must be between `1` and `600` and must not exceed the organization’s maximum lease lifetime quota. If the lease already expires later than the requested expiry, its current expiry is preserved. |

Success response (`200 OK`):

```json
{
  "leases": [
    {
      "lease_id": "0192f2fc-489e-7cab-a8e5-2c0f3f986001",
      "expires_at": "2026-06-10T12:08:00Z"
    },
    {
      "lease_id": "0192f2fc-489e-7cab-a8e5-2c0f3f986002",
      "expires_at": "2026-06-10T12:08:00Z"
    }
  ]
}
```

The response preserves the request order. For each lease, the new expiry is calculated as:

```
min(
  max(current expiry, heartbeat time + lease_ttl_seconds),
  leased_at + maximum lease lifetime
)
```

A heartbeat therefore never shortens a lease and does not add the requested TTL to its current expiry. The expiry is capped at `leased_at` plus the organization’s maximum lease lifetime. A partially completed lease extends only its still-active entries.

Heartbeat batches are atomic. If any requested lease is unknown, expired, released, owned by another job, or already at its maximum lifetime, no lease in the request is extended.

| Status | Condition |
| :---- | :---- |
| `400 Bad Request` | The request body is malformed JSON or is not a JSON object. |
| `401 Unauthorized` | Authentication is missing, invalid, or is not a Buildkite job OIDC token. |
| `403 Forbidden` | The OIDC token does not grant `write_test_pool` or does not contain the required job identity. |
| `404 Not Found` | The pool is unavailable to the token, or a requested lease is unknown, expired, released, or not owned by the requesting job. |
| `409 Conflict` | The pool is expired or consumed. |
| `422 Unprocessable Entity` | The request fields are invalid, the requested TTL exceeds a limit, or a lease has reached its maximum lifetime. |

### Release attempts

`POST /pools/{pool_id}/leases/release` requires a `build_id` query parameter and releases selected attempts, or every active attempt in a lease when `attempt_ids` is omitted:

```json
{
  "leases": [
    {
      "id": "0192f2fb-8c3a-7c1d-9f0b-4a0d6a7c1000",
      "attempt_ids": [
        "0192f2fb-a91f-7c9a-b1d4-a668260f6c87"
      ],
      "reason": "worker shutdown"
    },
    {
      "id": "0192f2fb-9f6d-79bd-8bf9-04be14f6bd31"
    }
  ]
}
```

The request may contain at most 100 leases and at most 50 explicit attempt IDs across all leases. Duplicate lease and attempt IDs are rejected. The optional `reason` field is accepted but is not currently validated, persisted, or returned. The request is atomic.

Released attempts return to `waiting` and have their lease ID, owning job ID, and lease expiry cleared. Only active, unexpired attempts owned by the authenticated job can be released; completion and release do not accept expired leases.

The response lists released attempt IDs by lease:

```json
{
  "leases": [
    {
      "id": "0192f2fb-8c3a-7c1d-9f0b-4a0d6a7c1000",
      "attempts": [
        "0192f2fb-a91f-7c9a-b1d4-a668260f6c87"
      ]
    }
  ]
}
```

### Attempt policy

A `TestPool.AttemptPolicy` will describe how the scheduler creates and manages attempts for each entry. Retry decisions will be made at the entry level: when an entry selector represents a file or another group of tests, the policy will evaluate the aggregate attempt result rather than individual test results within that selector.

The policy is intended to be evaluated when entries are uploaded and after attempts are completed. Evaluation will consider only attempts belonging to the same entry.

* The policy may create multiple attempts for an entry and allow a configured number to run in parallel.  
* All configured `min_` thresholds must be met before their minimum condition is terminal.  
* Reaching any configured `max_` threshold makes the entry terminal.  
* Once an entry is terminal, any remaining waiting attempts will be canceled.  
* Omitted fields will use the defaults below.

| Planned field | Type | Description | Default | Nullable |
| :---- | :---- | :---- | :---- | :---- |
| `max_attempts` | `Integer` | Terminal after this many attempts of any result. | `1` | false |
| `max_failed` | `Integer` | Terminal after this many failed attempts. Must be less than or equal to `max_attempts`. | `1` | false |
| `max_passed` | `Integer` | Terminal after this many passed attempts. Must be less than or equal to `max_attempts`. | `1` | false |
| `min_attempts` | `Integer` | Minimum total attempts; terminal only when the other configured `min_` thresholds are also met. | `1` | false |
| `min_passed` | `Integer` | Minimum passed attempts; terminal only when the other configured `min_` thresholds are also met. | 1 | (currently not-nullable, will be nullable) |
| `min_failed` | `Integer` | Minimum failed attempts; terminal only when the other configured `min_` thresholds are also met. | `0` | (currently not-nullable, will be nullable) |
| `parallel_attempts` | `Integer` | Maximum number of attempts for the entry that may be active in parallel. | `1` | false |

A simple single-retry, non-parallel policy:

```json
{
  "attempt_policy": {
    "max_attempts": 2,
    "max_failed": 2,
    "max_passed": 1,
    "min_attempts": 1,
    "min_passed": 1,
    "min_failed": 0,
    "parallel_attempts": 1
  }
}
```

An example allowing three attempts to run in parallel:

```json
{
  "attempt_policy": {
    "max_attempts": 9,
    "max_failed": 3,
    "max_passed": 1,
    "min_attempts": 1,
    "min_passed": 1,
    "min_failed": 0,
    "parallel_attempts": 3
  }
}
```

We intend to make min\_passed and min\_failed nullable, and not evaluated when unset. Currently they will not be considered when set to 0\.

Evaluation uses this order:

* max\_passed reached → passed  
* max\_failed reached → failed  
* max\_attempts reached → passed only if a positive min\_passed was reached; otherwise failed  
* All minimum thresholds reached → passed when min\_passed \> 0; otherwise failed when min\_failed \> 0\.

## Service quotas and limits

**These values are not yet locked in as product limits.** They are the defaults and hard request bounds enforced by the current prototype and may change as the API is exercised. Organization service quotas can override the quota-controlled values, although a pool-TTL override may only lower its current 24-hour hard maximum.

| Current limit | Implemented value |
| :---- | :---- |
| Entries per upload | Default organization quota: 100 |
| Selector payload size | Default organization quota: 1 KiB of JSON-encoded data |
| Metadata keys per entry | Default organization quota: 10 |
| Metadata size per entry | Default organization quota: 1 KiB of JSON-encoded data |
| Pool TTL | Minimum: 5 minutes; default and hard maximum: 24 hours; an organization override may lower the maximum |
| Lease TTL | Default: 60 seconds; request range: 1–600 seconds |
| Attempts per lease | Normally 300; the first affinity group may exceed this limit |
| Attempts per completion request | 5,000 |
| Leases per release request | 100 |
| Explicit attempt IDs per release request | 50 |
| Pool key length | 255 characters |
| Affinity group length | 255 characters |
| Attempts per entry | 10 |

There is currently no implemented limit for total entries per pool, pools per build, or active leases per pool/build. Attempts per entry is currently fixed by behavior at one initial attempt rather than controlled by a quota, but will be 10 attempts per entry.

## Authentication

Every Test Scheduler route currently requires a suite-scoped Buildkite job OIDC bearer token, except the pool metrics route, which also accepts a REST API access token. The token audience identifies the Test Engine suite, whose OIDC policy must grant:

* `read_test_pool` for pool index and show routes.  
* `write_test_pool` for pool creation/update, entry upload, and every lease route.

The OIDC token must include `organization_id`, `pipeline_id`, and `build_id` claims matching the route and pool. Lease acquisition, completion, and release additionally require a UUID `job_id` claim. Completion and release only mutate active leases owned by that job. REST API access-token requests to pool metrics must provide the build UUID in the required `build_id` query parameter.

```shell
buildkite-agent oidc request-token \
  --audience "$TEST_ENGINE_SUITE_AUDIENCE" \
  --claim build_id,organization_id,pipeline_id,job_id
```
