# Test Scheduler API v2

## Draft API Specification

[Chris Atkins](mailto:chris.a@buildkite.com) [Matthew Borden](mailto:matt@buildkite.com) [Pablo Annesley](mailto:paul@buildkite.com)

## Implementation status

This document describes the customer-facing prototype API. The API remains behind the `test_scheduler_api` feature flag and may still evolve. Routes or behavior that remain design proposals are called out explicitly rather than being presented as available.

When the contract settles, we intend to share an OpenAPI specification and potentially a Go client library as a sub-package in [test-engine-client](https://github.com/buildkite/test-engine-client).

## Context

Buildkite is designing a Test Engine capability called Test Scheduler that implements a pull-based queue for running tests in Buildkite jobs.

## Terminology

* `TestPool`: A suite- and build-scoped pool containing multiple entries. A non-destroyed pool is unique by organization, pipeline, build, and case-insensitive pool key.  
* `TestPool.Entry`: A persisted definition of schedulable work. Each entry has a runner-understood `selector_type` and `selector`, plus optional costs, priority, affinity group, attempt-policy key, and metadata.
  - A selector identifies a reportable test or a runnable target such as a file, package, Python `node_id`, or Bazel target.
  - Selector types are `custom` and `test_plan_test_case_v1`.
* `TestPool.Entry.Attempt`: A leasable invocation of an entry. Attempts reference the entry's selector and expose scheduling attributes and an `initial` flag.
* `Lease`: A persisted, time-bounded worker claim over one or more attempts, with its own job ownership and timing.
* `Worker`: The Buildkite job identified by the OIDC token's `job_id` claim.

Attempt policies and automatic retries are implemented. Upload creates the configured initial attempts with zero-based `attempt_index` values. The default policy creates one attempt and does not retry.

## API Routes

All implemented routes are JSON over HTTP beneath this organization-scoped prefix:

`/v2/organizations/{org-slug}/test-scheduler`

OIDC requests obtain build context from token claims, except the pool index also requires matching `pipeline_id` and `build_id` query parameters. Pool creation requires `build_id` in the body. REST API access tokens are accepted for pool index, show, and metrics only; show and metrics require a `build_id` query parameter for these tokens.

| Method and path | Scope | Behavior |
| :---- | :---- | :---- |
| `GET /pools?pipeline_id=...&build_id=...&key=...` | `read_test_pool` | Lists pools for the token's suite, pipeline, and build. `key` is optional and matched case-insensitively. |
| `POST /pools` | `write_test_pool` | Creates a pool. |
| `GET /pools/{pool_id}` | `read_test_pool` | Gets one pool. |
| `PATCH /pools/{pool_id}` | `write_test_pool` | Finishes population with `{ "populating": false }`. |
| `POST /pools/{pool_id}/entries` | `write_test_pool` | Uploads entries and creates initial waiting attempts. |
| `GET /pools/{pool_id}/entries` | `read_test_pool` | Lists entries and their attempt counts. |
| `POST /pools/{pool_id}/leases` | `write_test_pool` | Leases a cost-bounded batch of waiting attempts to the authenticated job. |
| `POST /pools/{pool_id}/leases/heartbeat` | `write_test_pool` | Extends active leases owned by the authenticated job. |
| `POST /pools/{pool_id}/leases/complete` | `write_test_pool` | Completes selected attempts from one or more leases. |
| `POST /pools/{pool_id}/leases/release` | `write_test_pool` | Releases selected attempts or all active attempts from one or more leases. |
| `GET /pools/{pool_id}/metrics` | `read_test_pool` | Returns aggregate progress for a pool. REST API access tokens require `build_id`. |

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
4. Upload atomically creates each entry and its initial waiting attempts, according to the selected policy.
5. The producer calls `PATCH /pools/{pool_id}` with `{ "populating": false }` when upload is complete.

### Test execution

* Workers call `POST /pools/{pool_id}/leases` to acquire a batch of attempts under one lease ID.  
* Attempts are considered in descending priority, then FIFO by `created_at`, with UUID as the final tie-breaker.  
* An attempt without an affinity group is a batch of one. Selecting an attempt with an affinity group expands the batch to all currently visible waiting attempts in that group, excluding additional attempts for an entry already selected for the lease.  
* During concurrent lease requests, if another request has locked any visible member of an affinity group, that group is skipped for the current request and the scheduler continues considering other work.  
* The first batch is always leased, even if it exceeds the pool's cost budget or attempt limit. Later batches are added only when the whole batch fits both limits. Selection stops at the first batch that does not fit.
* The default lease attempt limit is 300. The first affinity-group batch may exceed the pool's configured limit so the group is not split.
* Attempts with no custom cost have an effective custom cost of `0`.  
* Completion and release requests are authorized against the OIDC token's `job_id`. A stale or different worker cannot mutate the attempt after it has been released and leased again.

Expired leases are reclaimed asynchronously. Their unfinished attempts return to `waiting` and can be leased again. Heartbeat, completion, and release cannot mutate expired leases. Reclamation is not immediate at the expiry timestamp.

### Drain semantics

A pool is drained when it has no waiting or leased attempts and no completed attempts awaiting asynchronous policy evaluation. Drain only changes pool state after population has ended:

* Ending population on an already drained pool transitions it directly from `populating` to `consumed`.  
* Ending population on a pool with active attempts transitions it from `populating` to `consuming`.  
* The final completion in a `consuming` pool leads to `consumed` only after policy evaluation determines that no further attempts are needed.
* A temporarily empty `populating` pool remains `populating`.

### Retry pools

Automatic retries use the pool's attempt policies. Clients that need a separate baseline retry pool can list terminal failed entries with `GET /pools/{pool_id}/entries?state=completed&result=failed`, then upload their selectors to another pool through `POST /pools/{pool_id}/entries`. There is no `/uploads` scheduler endpoint or endpoint listing individual failed attempts.

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
| `state` | `Enum` | `populating`, `consuming`, or `consumed`. Pools start in `populating`. | false |
| `attempt_policy` | `TestPool.AttemptPolicy` or keyed object | Fully populated policy; keyed by policy name when the pool has multiple policies. | false |
| `lease` | `Object` | Immutable lease settings: one cost dimension in `costs` and `max_attempts`. | false |
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
  "ttl_seconds": 3600,
  "attempt_policy": {
    "max_attempts": 2,
    "max_failed": 2
  }
}
```

`ttl_seconds` is optional. It defaults to the organization's pool-TTL quota, which is 24 hours unless lowered. Explicit values must be integers between 300 seconds and that quota. In the current implementation, 24 hours is both the default and the hard maximum; an organization quota override may only reduce it.

The optional `attempt_policy` controls initial attempts and retries. The optional `lease` object fixes the lease cost budget and attempt limit for the life of the pool. `lease.costs` accepts at most one dimension: `custom` (finite, non-negative number, default `1`) or `duration_p90_ms` (finite, non-negative integer milliseconds). `lease.max_attempts` defaults to the lower of `300` and the organization quota and must be between `1` and that quota. The first selected affinity group may exceed either limit.

The response is an unwrapped pool object and includes the fully populated `attempt_policy` and `lease` settings. Unknown top-level creation fields are rejected.

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
    "min_failed": null,
    "parallel_attempts": 1,
    "initial_attempts": null
  },
  "lease": {
    "costs": {
      "custom": 1.0
    },
    "max_attempts": 300
  },
  "expires_at": "2026-06-10T13:00:00Z",
  "created_at": "2026-06-10T12:00:00Z"
}
```

Creating a duplicate non-destroyed pool returns `409 Conflict`. Pool keys are compared case-insensitively.

#### Find pools

`GET /pools` requires `pipeline_id` and `build_id` query parameters. For OIDC they must match token claims. For REST API access tokens, the build must belong to the pipeline and be accessible to the user. An optional `key` filters case-insensitively. Results are ordered by pool UUID descending and use cursor pagination with optional `after`, `before`, and `per_page` parameters. Only one cursor direction may be supplied. `per_page` defaults to 30 and accepts values from 1 through 100\.

The response wraps pools in an `items` array and includes `links.self`. It also includes `links.next` and `links.prev` cursor URLs when those directions are available.

`GET /pools/{pool_id}` returns one unwrapped pool object. OIDC lookups are constrained to the token's organization, suite, pipeline, and build. REST API access-token lookups require access to both the build and suite. Expired and destroyed pools are unavailable through these routes.

#### Pool lifecycle

New pools start in `populating`. Only `populating` pools accept entry uploads, while both `populating` and `consuming` pools may lease work.

The only implemented update is:

```json
{
  "populating": false
}
```

`PATCH /pools/{pool_id}` transitions a pool with active attempts to `consuming`, or an already drained pool directly to `consumed`. When present, `populating` must be the JSON boolean `false`, and the transition can only be applied once. A body that omits `populating` returns the pool unchanged.

### TestPool.Entry

A pool entry is an opaque selector plus scheduling attributes understood by the producer and worker.

| Request field | Type | Required | Default | Description |
| :---- | :---- | :---- | :---- | :---- |
| `selector_type` | `String` | true |  | `custom` or `test_plan_test_case_v1`. |
| `selector` | `String`, `Array`, or `Object` | true |  | Non-empty payload. `test_plan_test_case_v1` requires the structured object below. Its JSON-encoded size is quota-controlled and defaults to 1 KiB. |
| `costs.custom` | `Number` | false | `null` | Finite, non-negative custom scheduling cost. A null or omitted cost has effective scheduling cost `0`. |
| `costs.duration_p90_ms` | `Integer` | false | omitted | Finite, non-negative duration in milliseconds. Explicit null is invalid. |
| `attempt_policy` | `String` | false | `default` | Case-insensitive key of a policy defined by the pool. Unknown keys fail the whole upload. |
| `priority` | `Integer` | false | `0` | Scheduling priority from `-10` through `10`; higher values are leased first. |
| `affinity_group` | `String` | false | `null` | Client-defined group of at most 255 characters. Empty strings are normalized to null. |
| `meta_data` | `Object` | false | `null` | Customer-controlled metadata. Values may be strings, integers, or arrays of strings. Defaults allow 10 keys and 1 KiB of JSON-encoded data. |

`POST /pools/{pool_id}/entries` accepts a non-empty `entries` array. The default organization quota allows 100 entries per request. The whole upload is atomic.

All entries with the same non-empty affinity group must be in one upload. Reusing that group in a later upload returns `409 Conflict`.

For `test_plan_test_case_v1`, `selector.format` is `file`, `selector`, or `example`. File selectors require a non-empty `path`; selector selectors require a non-empty `value`; examples require non-empty `scope` and `name` and may include non-empty `path` and `identifier`. All three formats accept non-negative integer `estimated_duration` and `timing_sample_size`; unknown fields are rejected.

The optional `Idempotency-Key` header must be a UUIDv7. A successful upload is remembered for five minutes: retrying with the same key and unchanged entries returns `204 No Content`; a changed payload or pending/unknown outcome returns `409 Conflict`. Without a key, or after it expires, retries may duplicate entries. Idempotency storage failures return `503 Service Unavailable`; retry with the same key.

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

The `201 Created` response contains the persisted entries. Initial attempts are created atomically but are not included. This response excerpt shows one of the returned entries:

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
      "state": "pending",
      "result": null,
      "meta_data": {
        "team": "platform",
        "slack": "#team-platform"
      },
      "created_at": "2026-06-10T12:01:00Z"
    }
  ]
}
```

Entry responses include `state` (`pending` or `completed`) and `result` (`passed`, `failed`, or null). Pools with multiple policies also include the entry's selected `attempt_policy` key.

`GET /pools/{pool_id}/entries` uses descending UUID cursor pagination with the same `after`, `before`, and `per_page` rules as pool index. Each item includes `attempt_counts.states` (`waiting`, `leased`, `completed`, `canceled`) and `attempt_counts.results` (`passed`, `failed`, `errored`). Optional filters are `state=pending|completed` and `result=passed|failed`; a result cannot be combined with `state=pending`. It requires OIDC authentication and `read_test_pool`; expired pools return `404`.

### TestPool.Entry.Attempt

An attempt is an invocation of a pool entry and is the smallest unit of work inside a lease. The lease response and completion response use this shape:

| Response field | Type | Description | Nullable |
| :---- | :---- | :---- | :---- |
| `id` | `UUIDv7` | Attempt identifier. | false |
| `pool_id` | `UUIDv7` | Owning pool identifier. | false |
| `entry_id` | `UUIDv7` | Owning entry identifier. | false |
| `attempt_index` | `Integer` | Zero-based attempt index across initial and retry attempts. | false |
| `initial` | `Boolean` | Whether the attempt belongs to the initial allocation. | false |
| `selector_type` | `String` | Entry selector type: `custom` or `test_plan_test_case_v1`. | false |
| `selector` | JSON | Selector from the entry. | false |
| `costs` | `Object` | The pool's selected lease cost dimension. An absent duration produces an empty object; an absent custom cost is `custom: null`. | false |
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

`GET /pools/{pool_id}/metrics` requires `read_test_pool`. REST API access tokens additionally require a `build_id` query parameter; OIDC requests use token claims. It returns an aggregate point-in-time snapshot, which may lag recent writes. Expired pools return `404`.

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

Entries and attempts are reported separately because attempt policies may create multiple attempts for one entry. Active and expired lease metrics use `observed_at` and lease expiry. Attempt costs use the pool's selected cost dimension.

### Acquire a lease

`POST /pools/{pool_id}/leases` accepts an optional body:

```json
{
  "lease_ttl_seconds": 120
}
```

`lease_ttl_seconds` defaults to `60` and must be an integer from `1` through `600`, not exceeding the organization's maximum lease lifetime. An omitted or empty body uses the default. Lease size comes from the immutable pool `lease` settings; `target_cost_limit` and other request fields are rejected with `422`.

The optional `Idempotency-Key` request header makes acquisition safe to retry after a timeout, dropped connection, or 5xx response: the server may have committed a lease even though the client never received the response. The key must be a UUIDv7; any other value returns `400` with the message `Idempotency-Key must be a UUIDv7`. A lease created by a keyed request uses the key as its `id`. Each key identifies one acquisition by one job in one pool.

Retrying with the same key, job, pool, and `lease_ttl_seconds` returns the original lease: the same `id`, the same attempts in the same order, and its original `expires_at` (leased time plus `lease_ttl_seconds`), even if the lease has since been heartbeated. A retry never leases more entries. This holds for concurrent duplicate requests and when the pool has no work left. An empty response (`"lease": null`) leases nothing and does not use up the key; every new acquisition, including the same job's next lease, needs a new key.

If the key can't be replayed, the endpoint returns `409 Conflict` with `{"message": "...", "code": "LEASE_NOT_REPLAYABLE"}` and leases nothing. The client should not retry that key; it should start a new acquisition with a new key. The API ties each key to the details of its original request, so this happens when the key is used by another job or with a different `lease_ttl_seconds`, or when the lease is no longer active and unchanged: its original deadline or current expiry has passed, one of its attempts was completed or released, or the pool is no longer leasing. Other `409 Conflict` responses, such as an unavailable pool, have no `code`.

There is no separate key store. A key lasts as long as its lease and can only replay until the lease's original deadline. Without the header the endpoint behaves exactly as before, and clients should not retry ambiguous failures.

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
        "initial": true,
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
  },
  "pool": {
    "id": "0192f2fb-3c4d-7bd2-9f0b-4a0d6a7c1000",
    "state": "consuming"
  }
}
```

The response always includes `pool.id` and `pool.state`. When no work can be leased, `lease` is null. A `consumed` pool returns `200 OK` with a null lease, not `409`. Leasing is available for `populating` and `consuming` pools; an expired pool is unavailable (`404` on lookup, or `409` if it expires after lookup).

### Complete attempts

`POST /pools/{pool_id}/leases/complete` completes explicitly named attempts from one or more leases:

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
          "initial": true,
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

Completion is idempotent when retried with the same result; the response uses `completion_status: "already_completed"`. Retrying with a different result returns `409 Conflict`. Same-result retries remain available after completion drains the pool, but requests after pool expiry return `404 Not Found`.

### Lease heartbeat

`POST /v2/organizations/{organization_slug}/test-scheduler/pools/{pool_id}/leases/heartbeat` extends one or more active leases owned by the requesting Buildkite job. The endpoint requires a Buildkite job OIDC token whose policy grants `write_test_pool`; REST API access tokens are not accepted.

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

A heartbeat therefore never shortens a lease and does not add the requested TTL to its current expiry. The expiry is capped at `leased_at` plus the organization's maximum lease lifetime (default: one hour). A partially completed lease extends only its still-active attempts. At the lifetime cap, the `422` response includes `code: "MAXIMUM_LIFETIME"`.

Heartbeat batches are atomic. If any requested lease is unknown, expired, released, owned by another job, or already at its maximum lifetime, no lease in the request is extended.

| Status | Condition |
| :---- | :---- |
| `400 Bad Request` | The request body is malformed JSON or is not a JSON object. |
| `401 Unauthorized` | Authentication is missing, invalid, or is not a Buildkite job OIDC token. |
| `403 Forbidden` | The OIDC token does not grant `write_test_pool` or does not contain the required job identity. |
| `404 Not Found` | The pool is unavailable to the token, or a requested lease is unknown, expired, released, or not owned by the requesting job. |
| `409 Conflict` | The pool is consumed or expires after lookup. A pool already expired at lookup returns `404`. |
| `422 Unprocessable Entity` | The request fields are invalid, the requested TTL exceeds a limit, or a lease has reached its maximum lifetime. |

### Release attempts

`POST /pools/{pool_id}/leases/release` releases selected attempts, or every active attempt in a lease when `attempt_ids` is omitted:

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

A `TestPool.AttemptPolicy` controls initial allocation and retries for each entry. When a selector represents a file or group of tests, evaluation uses the aggregate attempt result, not individual tests inside the selector.

Initial attempts are allocated during upload. Policy evaluation runs asynchronously after completion and considers only attempts belonging to the same entry.

* The initial allocation is `initial_attempts`, or the lesser of `parallel_attempts` and `min_attempts` when null.
* No additional attempts are created until all initial attempts complete, although an entry may become terminal sooner.
* After initial attempts complete, a non-terminal entry fills available waiting/leased capacity up to `parallel_attempts`, bounded by `max_attempts` total attempts.
* All configured minimum thresholds must be met before the minimum condition is terminal. If both result minimums are null, evaluation continues until a maximum is reached.
* Reaching any maximum threshold makes the entry terminal. Remaining waiting attempts are canceled.
* Omitted fields use the defaults below. All non-null values must be integers of at least `1`; `0` is invalid.

| Field | Type | Description | Default | Nullable |
| :---- | :---- | :---- | :---- | :---- |
| `max_attempts` | `Integer` | Terminal after this many completed attempts of any result; bounded by the organization's attempts-per-entry quota. | `1` | false |
| `max_failed` | `Integer` | Terminal after this many failed attempts. Must be less than or equal to `max_attempts`. | `1` | false |
| `max_passed` | `Integer` | Terminal after this many passed attempts. Must be less than or equal to `max_attempts`. | `1` | false |
| `min_attempts` | `Integer` | Minimum completed attempts; at most `max_attempts`. | `1` | false |
| `min_passed` | `Integer` | Minimum passed attempts; null disables it; at most `max_passed`. | `1` | true |
| `min_failed` | `Integer` | Minimum failed attempts; null disables it; at most `max_failed`. | `null` | true |
| `parallel_attempts` | `Integer` | Maximum waiting and leased attempts for the entry; at most `max_attempts`. | `1` | false |
| `initial_attempts` | `Integer` | Explicit initial allocation; at most `parallel_attempts`. | `null` | true |

When both `min_passed` and `min_failed` are set, their sum must be less than `max_attempts`.

The `TestSchedulerMultipleAttemptPolicies` feature flag permits a keyed `attempt_policy` object containing the exact key `default` and up to five additional policies. Keys use the pool-key format and are unique case-insensitively. Policy keys and definition fields cannot be mixed. Multiple-policy pool responses use a keyed object; a pool with only the default policy uses a flat definition. Entries select keys case-insensitively and default to `default`.

A simple single-retry, non-parallel policy:

```json
{
  "attempt_policy": {
    "max_attempts": 2,
    "max_failed": 2,
    "max_passed": 1,
    "min_attempts": 1,
    "min_passed": 1,
    "min_failed": null,
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
    "min_failed": null,
    "parallel_attempts": 3,
    "initial_attempts": 3
  }
}
```

Evaluation uses this order:

* `max_passed` reached: passed.
* `max_failed` reached: failed.
* `max_attempts` reached: passed only if a configured `min_passed` was reached; otherwise failed.
* All configured minimum thresholds reached: passed when `min_passed` is configured; otherwise failed when `min_failed` is configured.

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
| Maximum lease lifetime | Default organization quota: one hour; hard maximum: 24 hours |
| Attempts per lease | Immutable pool setting; default and default organization quota: 300; the first affinity group may exceed this limit |
| Attempts per completion request | 5,000 |
| Leases per heartbeat request | 100 |
| Leases per release request | 100 |
| Explicit attempt IDs per release request | 50 |
| Pool key length | 255 characters |
| Affinity group length | 255 characters |
| Attempts per entry | Default organization quota: 10 |

There is currently no implemented limit for total entries per pool, pools per build, or active leases per pool/build. Attempts per entry are bounded by the policy's `max_attempts` and the organization quota.

Each operation has organization rate limits, and pool-specific operations also have pool limits. Exceeding either returns `429` with scoped `RateLimit-*` headers. Empty lease responses have an additional default limit of 15 per job per minute; clients must wait for `RateLimit-Job-Reset`, even if work becomes available before the window resets. The public reference page lists the operation-specific defaults. Scheduler storage unavailability returns `503 Service Unavailable`.

## Authentication

Every write and the entry index requires a suite-scoped Buildkite job OIDC bearer token. Pool index, show, and metrics also accept REST API access tokens with `read_test_pool`. Those tokens must allow the organization, and their user must have access to the build and suite; additional `read_builds` and `read_suites` scopes are not required. The OIDC audience identifies the Test Engine suite, whose policy must grant:

* `read_test_pool` for pool index, show, metrics, and entry index.
* `write_test_pool` for pool creation, update, entry upload, and every lease route.

The OIDC token must include `organization_id`, `pipeline_id`, and `build_id` claims matching the route and pool. Every lease endpoint, including heartbeat, additionally requires a UUID `job_id` claim. Lease mutations require job ownership. REST API access-token requests to pool show and metrics require a `build_id` query parameter; pool index requires both `pipeline_id` and `build_id`.

```shell
buildkite-agent oidc request-token \
  --audience "$TEST_ENGINE_SUITE_AUDIENCE" \
  --claim build_id,organization_id,pipeline_id,job_id
```
