# Test Scheduler API

The Test Scheduler API dynamically distributes tests across Buildkite Pipelines jobs. As each job becomes available, it requests additional work and reports the results.

> The Test Scheduler API is currently in development. This documentation is currently being drafted. It is only available to design partners on a limited basis. It is subject to change.

<%= image "test-scheduler-overview.png", width: 1406/2, height: 508/2, alt: "Diagram showing a discovery job uploading test entries to a test pool and three jobs leasing and completing test attempts" %>

## Endpoints

The Test Scheduler API provides endpoints for creating and managing a Test Pool:

- Test Pools contain Entries, and each Entry has one or more Attempts.
- Leases assign Attempts to Buildkite Pipelines jobs for execution.

All endpoints on this page use the following base path:

```text
https://api.buildkite.com/v2/organizations/{org.slug}/test-scheduler
```

The Test Scheduler API provides these endpoints:

Method | Endpoint | Description
------ | -------- | -----------
GET | `/pools` | [List pools](#list-pools)
GET | `/pools/{pool.id}` | [Get a pool](#get-a-pool)
POST | `/pools` | [Create a pool](#create-a-pool)
PATCH | `/pools/{pool.id}` | [Update a pool](#update-a-pool)
POST | `/pools/{pool.id}/entries` | [Upload entries](#upload-entries)
GET | `/pools/{pool.id}/entries` | [List entries](#list-entries)
POST | `/pools/{pool.id}/leases` | [Create a lease](#create-a-lease)
POST | `/pools/{pool.id}/leases/heartbeat` | [Heartbeat leases](#heartbeat-leases)
POST | `/pools/{pool.id}/leases/complete` | [Complete attempts](#complete-attempts)
POST | `/pools/{pool.id}/leases/release` | [Release attempts](#release-attempts)
GET | `/pools/{pool.id}/metrics` | [Get pool metrics](#get-pool-metrics)
{: class="responsive-table"}

## Authentication

Test Scheduler API requests require an OpenID Connect (OIDC) token issued to a Buildkite job. [REST API access tokens](/docs/apis/managing-api-tokens) are only accepted on the `metrics` endpoint.

### OIDC authentication

First, create a suite or choose an existing suite. Set the  [OIDC policy](/docs/pipelines/configure/tests/test-collection/oidc) through the suite's Settings page in the Buildkite interface, or using the [suites REST API](https://buildkite.com/docs/apis/rest-api/test-engine/suites) with the `oidc_policy` field on create or update.

```
- iss: "https://agent.buildkite.com"
  claims:
    organization_slug: "your-org"
    pipeline_slug:
      in:
        - "your-pipeline"
        - "another-pipeline"
  scopes:
    - "read_suites"
    - "write_uploads"
    - "read_test_pool"
    - "write_test_pool"
```

Request a token from within a Buildkite Pipelines job using [`buildkite-agent oidc request-token`](/docs/agent/cli/reference/oidc#request-oidc-token):

```bash
TEST_SUITE_SLUG="suite-slug"
SUITE_URL="https://buildkite.com/organizations/${BUILDKITE_ORGANIZATION_SLUG}/analytics/suites/${TEST_SUITE_SLUG}"
LIFETIME=300 # Lifetime of tokens in seconds, set to the expected duration of the longest job.
OIDC_TOKEN=$(buildkite-agent oidc request-token --audience "$SUITE_URL" --lifetime $LIFETIME --claim organization_id,pipeline_id,build_id,job_id)
export OIDC_TOKEN
```

The OIDC token must:

- Match the organization in the request URL, suite in the token audience, and pipeline and build in the request.
- Identify the job that owns a lease through the `job_id` claim. Another job cannot heartbeat, complete, or release that lease.
- Use the test suite URL as its audience: `https://buildkite.com/organizations/{org.slug}/analytics/suites/{suite.slug}`.
- Be permitted by the test suite's [OIDC policy](/docs/pipelines/configure/tests/test-collection/oidc) with the endpoints required scope, either `read_test_pool` or `write_test_pool`.
- Include the `organization_id`, `pipeline_id`, and `build_id` claims. Lease endpoints also require the `job_id` claim.

### REST API authentication

The `GET /pools/{pool.id}/metrics` endpoint accepts a REST API access token with the `read_test_pool` [scope](/docs/apis/managing-api-tokens#token-scopes). The Buildkite user associated with the token must have access to the pool's test suite and build.

Provide the token in the `Authorization` header:

```bash
curl "https://api.buildkite.com/v2/organizations/{org.slug}/test-scheduler/pools/{pool.id}/metrics?build_id={build.id}" \
  --header "Authorization: Bearer $TOKEN"
```

## Core data model

Pools contain entries, entries have attempts, and leases temporarily assign attempts to Buildkite Pipelines jobs.

The Test Scheduler API uses these four resources:

- **Pool:** A build-scoped collection of entries. Its attempt policy controls how many attempts the scheduler creates for each entry and when the scheduler considers the entry finished. Its lease settings control the target custom cost and maximum attempts for every lease created from the pool.
- **Entry:** One unit of work, identified by a selector. An entry belongs to one pool and includes scheduling data such as cost, priority, affinity group, and metadata.
- **Attempt:** One execution of an entry. Creating an entry creates its initial attempts in the `waiting` state. When a job acquires an attempt through a lease, the attempt moves to `leased`. The job executes the work, completes the attempt, and reports its result. Releasing an unfinished attempt or allowing its lease to expire returns the attempt to `waiting`.
- **Lease:** A time-bounded claim by one Buildkite Pipelines job over a batch of waiting attempts. The job can extend the lease, complete attempts and report their results, or release unfinished attempts back to the pool.

### Pool lifecycle

A pool moves through three states:

- `populating`: Entries can be added to the pool, and jobs can lease attempts. The pool remains in this state until the initial set of entries is marked as complete, even when no attempts are waiting or leased.
- `consuming`: All initial entries have been added. Jobs can continue to lease, complete, and release attempts.
- `consumed`: No attempts are waiting or leased. Lease requests return no work and identify the pool as consumed.

New pools start in the `populating` state. After adding the initial entries, [update the pool](#update-a-pool) with `"populating": false`. The pool moves to `consuming` if unfinished attempts remain or directly to `consumed` if it is already drained. A `consuming` pool moves to `consumed` after its final attempts are completed and attempt-policy evaluation determines that no more attempts are needed.

## List pools

Returns a cursor-paginated list of pools for a pipeline and build. Results are ordered by pool UUID in descending order.

```bash
curl "https://api.buildkite.com/v2/organizations/{org.slug}/test-scheduler/pools?pipeline_id={pipeline.id}&build_id={build.id}&key=rspec-main" \
  -H "Authorization: Bearer $OIDC_TOKEN"
```

```json
{
  "items": [
    {
      "id": "0192f2fb-****-****-****-4a0d6a7c1000",
      "organization_id": "01234567-****-****-****-456789abcdef",
      "suite_id": "12345678-****-****-****-56789abcdef0",
      "pipeline_id": "23456789-****-****-****-6789abcdef01",
      "build_id": "3456789a-****-****-****-789abcdef012",
      "key": "rspec-main",
      "state": "populating",
      "attempt_policy": {
        "min_attempts": 1,
        "max_attempts": 1,
        "min_passed": 1,
        "max_passed": 1,
        "min_failed": null,
        "max_failed": 1,
        "parallel_attempts": 1
      },
      "lease": {
        "costs": {
          "custom": 25.0
        },
        "max_attempts": 100
      },
      "expires_at": "2026-07-20T09:00:00.000Z",
      "created_at": "2026-07-20T08:00:00.000Z"
    }
  ],
  "links": {
    "next": "https://api.buildkite.com/v2/organizations/example-org/test-scheduler/pools?pipeline_id=23456789-****-****-****-6789abcdef01&build_id=3456789a-****-****-****-789abcdef012&after=NEXT_CURSOR"
  }
}
```

Required query string parameters:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>pipeline_id</code></th>
    <td>The pipeline UUID. The value must match the <code>pipeline_id</code> claim in the OIDC token.</td>
  </tr>
  <tr>
    <th><code>build_id</code></th>
    <td>The build UUID. The value must match the <code>build_id</code> claim in the OIDC token.</td>
  </tr>
</tbody>
</table>

Optional query string parameters:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>key</code></th>
    <td>Filters pools by an exact, case-insensitive key match.<br><em>Example:</em> <code>rspec-main</code></td>
  </tr>
  <tr>
    <th><code>per_page</code></th>
    <td>The number of results per page. Must be between <code>1</code> and <code>100</code>.<br><em>Default:</em> <code>30</code></td>
  </tr>
  <tr>
    <th><code>after</code></th>
    <td>Returns results after this cursor. Use the <code>links.next</code> URL from the previous response to paginate forward.</td>
  </tr>
  <tr>
    <th><code>before</code></th>
    <td>Returns results before this cursor. Use the <code>links.prev</code> URL from the previous response to paginate backward. You cannot use <code>before</code> with <code>after</code>.</td>
  </tr>
</tbody>
</table>

When no pools match the request, `items` is an empty array.

Required scope: `read_test_pool`

Success response: `200 OK`

## Get a pool

Returns a pool that belongs to the suite, pipeline, and build identified by the OIDC token.

```bash
curl "https://api.buildkite.com/v2/organizations/{org.slug}/test-scheduler/pools/{pool.id}" \
  --header "Authorization: Bearer $OIDC_TOKEN"
```

```json
{
  "id": "0192f2fb-****-****-****-4a0d6a7c1000",
  "organization_id": "01234567-****-****-****-456789abcdef",
  "suite_id": "12345678-****-****-****-56789abcdef0",
  "pipeline_id": "23456789-****-****-****-6789abcdef01",
  "build_id": "3456789a-****-****-****-789abcdef012",
  "key": "rspec-main",
  "state": "populating",
  "attempt_policy": {
    "min_attempts": 1,
    "max_attempts": 1,
    "min_passed": 1,
    "max_passed": 1,
    "min_failed": null,
    "max_failed": 1,
    "parallel_attempts": 1
  },
  "lease": {
    "costs": {
      "custom": 25.0
    },
    "max_attempts": 100
  },
  "expires_at": "2026-07-20T09:00:00.000Z",
  "created_at": "2026-07-20T08:00:00.000Z"
}
```

Required scope: `read_test_pool`

Success response: `200 OK`

## Create a pool

Creates a pool for a build. The combination of build and pool key must be unique.

```bash
curl "https://api.buildkite.com/v2/organizations/{org.slug}/test-scheduler/pools" \
  --request POST \
  --header "Authorization: Bearer $OIDC_TOKEN" \
  --header "Content-Type: application/json" \
  -d '{
    "suite": "example-suite",
    "pipeline": "example-pipeline",
    "build_id": "3456789a-****-****-****-789abcdef012",
    "key": "rspec-main",
    "ttl_seconds": 3600,
    "attempt_policy": {
      "min_attempts": 1,
      "max_attempts": 1,
      "min_passed": 1,
      "max_passed": 1,
      "min_failed": null,
      "max_failed": 1,
      "parallel_attempts": 1
    },
    "lease": {
      "costs": {
        "custom": 25
      },
      "max_attempts": 100
    }
  }'
```

```json
{
  "id": "0192f2fb-****-****-****-4a0d6a7c1000",
  "organization_id": "01234567-****-****-****-456789abcdef",
  "suite_id": "12345678-****-****-****-56789abcdef0",
  "pipeline_id": "23456789-****-****-****-6789abcdef01",
  "build_id": "3456789a-****-****-****-789abcdef012",
  "key": "rspec-main",
  "state": "populating",
  "attempt_policy": {
    "min_attempts": 1,
    "max_attempts": 1,
    "min_passed": 1,
    "max_passed": 1,
    "min_failed": null,
    "max_failed": 1,
    "parallel_attempts": 1
  },
  "lease": {
    "costs": {
      "custom": 25.0
    },
    "max_attempts": 100
  },
  "expires_at": "2026-07-20T09:00:00.000Z",
  "created_at": "2026-07-20T08:00:00.000Z"
}
```

Required [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>suite</code></th>
    <td>The slug or UUID of the test suite. The suite must match the OIDC token audience.<br><em>Example:</em> <code>example-suite</code></td>
  </tr>
  <tr>
    <th><code>pipeline</code></th>
    <td>The slug or UUID of the pipeline. The pipeline must match the <code>pipeline_id</code> claim in the OIDC token.<br><em>Example:</em> <code>example-pipeline</code></td>
  </tr>
  <tr>
    <th><code>build_id</code></th>
    <td>The build UUID. The value must match the <code>build_id</code> claim in the OIDC token.</td>
  </tr>
  <tr>
    <th><code>key</code></th>
    <td>A caller-defined identifier for the pool within the build.<br><em>Example:</em> <code>rspec-main</code></td>
  </tr>
</tbody>
</table>

Optional [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>ttl_seconds</code></th>
    <td>How long the pool remains available, in seconds. Must be an integer of at least <code>300</code> and no greater than the organization's pool time-to-live limit. Defaults to <code>86400</code> seconds, or the organization limit when it is lower.<br><em>Example:</em> <code>3600</code></td>
  </tr>
  <tr>
    <th><code>attempt_policy</code></th>
    <td>Controls how many attempts can run for each entry and when the entry finishes. Omit the object or any of its properties to use the corresponding defaults. See the Attempt policy for the fields of this object.</td>
  </tr>
  <tr>
    <th><code>lease</code></th>
    <td>Controls the size of every lease created from the pool. The settings cannot be changed after the pool is created. Omit this object or either of its properties to use the corresponding defaults.</td>
  </tr>
  <tr>
    <th><code>lease.costs.custom</code></th>
    <td>The target maximum combined custom cost for each lease. Must be a finite, non-negative number. The first selected attempt or affinity group is leased even when its cost exceeds this target. Later work is only added while it fits.<br><em>Default:</em> <code>1</code></td>
  </tr>
  <tr>
    <th><code>lease.max_attempts</code></th>
    <td>The maximum number of attempts in each lease. Must be an integer from <code>1</code> through <code>300</code>. The first affinity group is leased as a whole even when it exceeds this maximum.<br><em>Default:</em> <code>300</code></td>
  </tr>
</tbody>
</table>

### Create a pool with multiple attempt policies

To apply different attempt policies to entries in the same pool, set `attempt_policy` to an object keyed by policy name. The object must include a `default` policy. Each policy supports the properties described in the [Attempt policy](#attempt-policy) section.

The following example creates a pool with a `default` policy that runs an entry once and an `alternate` policy that runs an entry three times:

```bash
curl "https://api.buildkite.com/v2/organizations/{org.slug}/test-scheduler/pools" \
  --request POST \
  --header "Authorization: Bearer $OIDC_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "suite": "example-suite",
    "pipeline": "example-pipeline",
    "build_id": "3456789a-****-****-****-789abcdef012",
    "key": "rspec-main",
    "attempt_policy": {
      "default": {
        "max_attempts": 1
      },
      "alternate": {
        "min_attempts": 3,
        "max_attempts": 3,
        "min_passed": 3,
        "max_passed": 3,
        "max_failed": 3,
        "parallel_attempts": 3
      }
    }
  }'
```

Entries use the `default` policy when `entries[].attempt_policy` is omitted or set to `default`. To select another policy, set `entries[].attempt_policy` to that policy's key:

```bash
curl "https://api.buildkite.com/v2/organizations/{org.slug}/test-scheduler/pools/{pool.id}/entries" \
  --request POST \
  --header "Authorization: Bearer $OIDC_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "entries": [
      {
        "selector_type": "custom",
        "selector": {
          "file": "spec/models/user_spec.rb"
        }
      },
      {
        "selector_type": "custom",
        "selector": {
          "file": "spec/features/checkout_spec.rb"
        },
        "attempt_policy": "alternate"
      }
    ]
  }'
```

When a pool has multiple policies, entry upload and list responses include the selected `attempt_policy` key for every entry, including entries that use `default`. An unknown policy key makes the entire entry upload fail.

## Attempt policy

> 🚧 Pending breaking change
The `null` behavior and validation described in this section have not landed yet. Currently, use `0` for `min_passed` or `min_failed` to disable the threshold; the API does not accept `null` for these properties. After the change lands, use `null` instead because `0` will no longer be valid.

The attempt policy defines how many attempts an entry should perform before determining the outcome of the entry. The policy is defined when the pool is created and applies to every entry in the pool. The same policy is evaluated for each entry in the pool.

Property | Type | Description | Validation
-------- | ---- | ----------- | ----------
`attempt_policy.max_attempts` | Integer | Terminal after this many completed attempts of any result. | At least `1` and no greater than the organization's maximum attempts per entry service quota, which defaults to `10`.
`attempt_policy.max_failed` | Integer | Terminal after this many failed completed attempts. | At least `1` and no greater than `max_attempts`.
`attempt_policy.max_passed` | Integer | Terminal after this many passed completed attempts. | At least `1` and no greater than `max_attempts`.
`attempt_policy.min_attempts` | Integer | Minimum completed attempts; terminal only when the other configured `min_` thresholds are also met. | At least `1` and no greater than `max_attempts`.
`attempt_policy.min_passed` | Integer or null | Minimum passed attempts; terminal only when the other configured `min_` thresholds are also met. `null` disables this threshold. | When set, at least `1` and no greater than `max_passed`. When both result minimums are set, their sum must be less than `max_attempts`.
`attempt_policy.min_failed` | Integer or null | Minimum failed attempts; terminal only when the other configured `min_` thresholds are also met. `null` disables this threshold. | When set, at least `1` and no greater than `max_failed`. When both result minimums are set, their sum must be less than `max_attempts`.
`attempt_policy.parallel_attempts` | Integer | Maximum number of waiting and leased attempts for the entry at one time. | At least `1` and no greater than `max_attempts`.
{: class="responsive-table"}

The `attempt_policy` value must be an object containing only the properties listed in this table.

### Policy behavior

- The policy may create multiple attempts for an entry and allow up to `parallel_attempts` attempts to be waiting or leased at one time.
- A value of `null` disables `min_passed` or `min_failed`; `0` is invalid. All configured `min_` thresholds must be met before their minimum condition is terminal. If both result minimums are `null`, satisfying `min_attempts` alone does not make the entry terminal.
- Reaching any configured `max_` threshold makes the entry terminal.
- Once an entry is terminal, any remaining waiting attempts will be canceled.
- Omit the entire `attempt_policy` object or any of its properties to use the corresponding defaults below.

### Evaluation order

The scheduler evaluates the policy in this order:

1. `max_passed` reached: the entry passes.
2. `max_failed` reached: the entry fails.
3. `max_attempts` reached: the entry passes only if it reached a configured `min_passed` threshold; otherwise, it fails.
4. All configured minimum thresholds reached: the entry passes when `min_passed` is configured; otherwise, it fails when `min_failed` is configured. If both result minimums are `null`, evaluation continues until a maximum is reached.

At `max_attempts`, a configured and satisfied `min_passed` threshold is the only path to a passed outcome. If `min_passed` is `null` or has not been reached, the entry fails regardless of whether `min_failed` is configured or reached. Omitting `min_passed` applies its default of `1`; omitting `min_failed` applies its default of `null`.

The default policy creates one attempt per entry and does not retry `failed` or `errored` attempt results.

```json
{
  "attempt_policy": {
    "min_attempts": 1,
    "max_attempts": 1,
    "min_passed": 1,
    "max_passed": 1,
    "min_failed": null,
    "max_failed": 1,
    "parallel_attempts": 1
  }
}
```

Policy evaluation determines the entry's terminal outcome as passed or failed.

### Configuring the attempt policy

The following example configurations cover common attempt policy scenarios:

<table class="responsive-table" style="table-layout:fixed">
  <thead>
    <tr>
      <th style="width:40%">Scenario</th>
      <th style="padding-left:4px;padding-right:4px;white-space:normal"><code>min_<br>attempts</code></th>
      <th style="padding-left:4px;padding-right:4px;white-space:normal"><code>max_<br>attempts</code></th>
      <th style="padding-left:4px;padding-right:4px;white-space:normal"><code>min_<br>passed</code></th>
      <th style="padding-left:4px;padding-right:4px;white-space:normal"><code>max_<br>passed</code></th>
      <th style="padding-left:4px;padding-right:4px;white-space:normal"><code>min_<br>failed</code></th>
      <th style="padding-left:4px;padding-right:4px;white-space:normal"><code>max_<br>failed</code></th>
      <th style="padding-left:4px;padding-right:4px;white-space:normal"><code>parallel_<br>attempts</code></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>No retry</strong><br>Runs each entry once. A <code>passed</code> result passes the entry; a <code>failed</code> or <code>errored</code> result fails it.</td>
      <td><code>1</code></td>
      <td><code>1</code></td>
      <td><code>1</code></td>
      <td><code>1</code></td>
      <td><code>null</code></td>
      <td><code>1</code></td>
      <td><code>1</code></td>
    </tr>
    <tr>
      <td><strong>One retry</strong><br>Runs attempts sequentially and allows one additional attempt after a <code>failed</code> or <code>errored</code> result. The first <code>passed</code> result passes the entry.</td>
      <td><code>1</code></td>
      <td><code>2</code></td>
      <td><code>1</code></td>
      <td><code>1</code></td>
      <td><code>null</code></td>
      <td><code>2</code></td>
      <td><code>1</code></td>
    </tr>
    <tr>
      <td><strong>Parallel capacity of two</strong><br>Creates up to two waiting or leased attempts at once. The first <code>passed</code> result passes the entry; otherwise, the policy allows up to three completed attempts.</td>
      <td><code>1</code></td>
      <td><code>3</code></td>
      <td><code>1</code></td>
      <td><code>1</code></td>
      <td><code>null</code></td>
      <td><code>3</code></td>
      <td><code>2</code></td>
    </tr>
    <tr>
      <td><strong>All three must pass</strong><br>Runs three attempts sequentially and passes only when all three attempts pass.</td>
      <td><code>3</code></td>
      <td><code>3</code></td>
      <td><code>3</code></td>
      <td><code>3</code></td>
      <td><code>null</code></td>
      <td><code>3</code></td>
      <td><code>1</code></td>
    </tr>
  </tbody>
</table>

The policy determines the initial attempt allocation when an entry is uploaded and is evaluated after each attempt completes. When a selector represents a file or another group of tests, the policy uses the aggregate attempt result for the selector, not individual test results within it. While the entry remains unfinished, the scheduler creates attempts without exceeding `max_attempts` total attempts or `parallel_attempts` waiting and leased attempts.

Required scope: `write_test_pool`

Success response: `201 Created`

## Update a pool

Marks the initial entry upload as finished. Send `"populating": false` once the producer has uploaded all initial entries.

```bash
curl "https://api.buildkite.com/v2/organizations/{org.slug}/test-scheduler/pools/{pool.id}" \
  --request PATCH \
  --header "Authorization: Bearer $OIDC_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "populating": false
  }'
```

```json
{
  "id": "0192f2fb-****-****-****-4a0d6a7c1000",
  "organization_id": "01234567-****-****-****-456789abcdef",
  "suite_id": "12345678-****-****-****-56789abcdef0",
  "pipeline_id": "23456789-****-****-****-6789abcdef01",
  "build_id": "3456789a-****-****-****-789abcdef012",
  "key": "rspec-main",
  "state": "consuming",
  "attempt_policy": {
    "min_attempts": 1,
    "max_attempts": 1,
    "min_passed": 1,
    "max_passed": 1,
    "min_failed": null,
    "max_failed": 1,
    "parallel_attempts": 1
  },
  "lease": {
    "costs": {
      "custom": 25.0
    },
    "max_attempts": 100
  },
  "expires_at": "2026-07-20T09:00:00.000Z",
  "created_at": "2026-07-20T08:00:00.000Z"
}
```

Required [request body property](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>populating</code></th>
    <td>Must be <code>false</code>. This marks the initial entry upload as finished.</td>
  </tr>
</tbody>
</table>

The pool moves from `populating` to `consuming` when unfinished attempts remain. The pool moves directly to `consumed` when no attempts are waiting or leased. This transition cannot be reversed or repeated.

Required scope: `write_test_pool`

Success response: `200 OK`

## Upload entries

Uploads a batch of entries to a pool. Each entry describes work that the producer and worker understand. The API creates initial entries from the minimum of `max_attempts` and `parallel_attempts`.

```bash
curl "https://api.buildkite.com/v2/organizations/{org.slug}/test-scheduler/pools/{pool.id}/entries" \
  --request POST \
  --header "Authorization: Bearer $OIDC_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "entries": [
      {
        "selector_type": "custom",
        "selector": {
          "file": "spec/models/user_spec.rb",
          "line": 42
        },
        "costs": {
          "custom": 12.5
        },
        "priority": 5,
        "affinity_group": "database",
        "meta_data": {
          "team": "platform",
          "tags": ["ruby", "model"],
          "retry": 0
        }
      }
    ]
  }'
```

```json
{
  "entries": [
    {
      "id": "0192f2fc-****-****-****-600a780fd001",
      "pool_id": "0192f2fb-****-****-****-4a0d6a7c1000",
      "selector_type": "custom",
      "selector": {
        "file": "spec/models/user_spec.rb",
        "line": 42
      },
      "costs": {
        "custom": 12.5
      },
      "priority": 5,
      "affinity_group": "database",
      "meta_data": {
        "team": "platform",
        "tags": ["ruby", "model"],
        "retry": 0
      },
      "created_at": "2026-07-20T08:01:00.000Z"
    }
  ]
}
```

Required [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>entries</code></th>
    <td>A non-empty array of entry objects. The default maximum is <code>100</code> entries per request.</td>
  </tr>
  <tr>
    <th><code>entries[].selector_type</code></th>
    <td>The selector format. The supported value is <code>custom</code>.</td>
  </tr>
  <tr>
    <th><code>entries[].selector</code></th>
    <td>A non-empty JSON string, array, or object that identifies the work. The producer and worker define its structure. The default maximum encoded size is <code>1024</code> bytes.</td>
  </tr>
</tbody>
</table>

Optional entry properties:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>entries[].attempt_policy</code></th>
    <td>The key of an attempt policy defined by the pool. Omit this property or set it to <code>default</code> to use the pool's default policy. This property is only available when the pool has multiple policies.</td>
  </tr>
  <tr>
    <th><code>entries[].costs.custom</code></th>
    <td>A finite, non-negative number used when selecting work for a lease. A missing or <code>null</code> value has an effective scheduling cost of <code>0</code>.</td>
  </tr>
  <tr>
    <th><code>entries[].priority</code></th>
    <td>An integer from <code>-10</code> through <code>10</code>. Higher values are leased first.<br><em>Default:</em> <code>0</code></td>
  </tr>
  <tr>
    <th><code>entries[].affinity_group</code></th>
    <td>A string of up to 255 characters. Waiting attempts with the same non-empty affinity group are leased together. All entries in an affinity group must be included in the same upload request. A blank or <code>null</code> value means that the entry has no affinity group.</td>
  </tr>
  <tr>
    <th><code>entries[].meta_data</code></th>
    <td>A JSON object containing strings, integers, or arrays of strings. The default limits are 10 keys and <code>1024</code> encoded bytes.</td>
  </tr>
</tbody>
</table>

The request is atomic. If any entry is invalid, the API creates no entries. Entries can only be uploaded while the pool is unexpired and in the `populating` state.

Required scope: `write_test_pool`

Success response: `201 Created`

## List entries

Returns a cursor-paginated list of a pool's entries in descending UUID order. Each entry includes its lifecycle state, terminal result, and attempt counts.

```bash
curl "https://api.buildkite.com/v2/organizations/{org.slug}/test-scheduler/pools/{pool.id}/entries?state=pending&per_page=2" \
  --header "Authorization: Bearer $OIDC_TOKEN"
```

```json
{
  "items": [
    {
      "id": "0192f2fc-****-****-****-600a780fd001",
      "pool_id": "0192f2fb-****-****-****-4a0d6a7c1000",
      "selector_type": "custom",
      "selector": {
        "file": "spec/models/user_spec.rb",
        "line": 42
      },
      "costs": {
        "custom": 12.5
      },
      "priority": 0,
      "affinity_group": "bin-a",
      "state": "pending",
      "result": null,
      "meta_data": {
        "team": "platform"
      },
      "created_at": "2026-08-04T01:00:00.000Z",
      "attempt_counts": {
        "states": {
          "waiting": 1,
          "leased": 0,
          "completed": 0,
          "canceled": 0
        },
        "results": {
          "passed": 0,
          "failed": 0,
          "errored": 0
        }
      }
    }
  ],
  "links": {
    "self": "https://api.buildkite.com/v2/organizations/example-org/test-scheduler/pools/0192f2fb-****-****-****-4a0d6a7c1000/entries?state=pending&per_page=2",
    "next": "https://api.buildkite.com/v2/organizations/example-org/test-scheduler/pools/0192f2fb-****-****-****-4a0d6a7c1000/entries?state=pending&per_page=2&after=NEXT_CURSOR"
  }
}
```

Each entry includes its overall state and result, along with counts for its individual attempts:

- `state`: The entry is `pending` until it has a terminal outcome. It is then `completed`.
- `result`: The result is `null` while the entry is pending. After completion, it is `passed` or `failed`.
- `attempt_counts.states`: The number of attempts in each state: `waiting`, `leased`, `completed`, and `canceled`.
- `attempt_counts.results`: The number of completed attempts with each result: `passed`, `failed`, and `errored`.

Optional query string parameters:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>state</code></th>
    <td>Filters by <code>pending</code> or <code>completed</code>.</td>
  </tr>
  <tr>
    <th><code>result</code></th>
    <td>Filters by <code>passed</code> or <code>failed</code>. You can use <code>result</code> alone or with <code>state=completed</code>. You cannot combine it with <code>state=pending</code>.</td>
  </tr>
  <tr>
    <th><code>per_page</code></th>
    <td>The number of results per page. Must be between <code>1</code> and <code>100</code>.<br><em>Default:</em> <code>30</code></td>
  </tr>
  <tr>
    <th><code>after</code></th>
    <td>Returns results after this cursor. Use the <code>links.next</code> URL from the previous response.</td>
  </tr>
  <tr>
    <th><code>before</code></th>
    <td>Returns results before this cursor. You cannot use <code>before</code> with <code>after</code>.</td>
  </tr>
</tbody>
</table>

Invalid filter values, an incompatible filter combination, invalid pagination, or using `after` and `before` together returns `400 Bad Request`. When no entries match, `items` is an empty array.

Required scope: `read_test_pool`

Success response: `200 OK`

## Create a lease

Claims a time-bounded batch of waiting attempts for the requesting job. Multiple jobs can lease from the same pool. Both `populating` and `consuming` pools can lease attempts. A consumed pool returns a successful response with no lease. The API rejects lease requests for expired or destroyed pools.

```bash
curl "https://api.buildkite.com/v2/organizations/{org.slug}/test-scheduler/pools/{pool.id}/leases" \
  --request POST \
  --header "Authorization: Bearer $OIDC_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "lease_ttl_seconds": 120
  }'
```

The request body is optional. Send an empty JSON object or omit the body to use all defaults.

Optional [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>lease_ttl_seconds</code></th>
    <td>How long the lease is valid, in seconds. Must be an integer from <code>1</code> through <code>600</code> and cannot exceed the organization's maximum lease lifetime.<br><em>Default:</em> <code>60</code></td>
  </tr>
</tbody>
</table>

The API sorts waiting attempts by:

- `priority` in descending order.
- `created_at` in ascending order.
- UUID in ascending order.

Attempts without an affinity group are included in the lease on their own, but attempts belonging to an affinity group are expanded to include a single attempt from each entry in the group. Affinity groups with attempts locked by concurrent leases are not included.

The API applies the pool's `lease.costs.custom` and `lease.max_attempts` settings to each lease:

- The first batch is always leased, even if it exceeds the target cost. When the first batch is an affinity group, the entire group is leased even if it exceeds the attempt limit.
- Each later batch is added only if the entire batch fits within both limits.
- Selection stops at the first later batch that does not fit. The API does not skip that batch to consider lower-priority work.

```json
{
  "lease": {
    "id": "0192f2fd-****-****-****-2c0f3f986001",
    "expires_at": "2026-07-20T08:04:00.000Z",
    "attempts": [
      {
        "id": "0192f2fe-****-****-****-700a780fd001",
        "pool_id": "0192f2fb-****-****-****-4a0d6a7c1000",
        "entry_id": "0192f2fc-****-****-****-600a780fd001",
        "attempt_index": 0,
        "selector_type": "custom",
        "selector": {
          "file": "spec/models/user_spec.rb",
          "line": 42
        },
        "costs": {
          "custom": 12.5
        },
        "priority": 5,
        "affinity_group": "database",
        "state": "leased",
        "result": null,
        "lease_id": "0192f2fd-****-****-****-2c0f3f986001",
        "lease_expires_at": "2026-07-20T08:04:00.000Z",
        "completed_at": null,
        "meta_data": {
          "team": "platform",
          "tags": ["ruby", "model"],
          "retry": 0
        },
        "created_at": "2026-07-20T08:01:00.000Z"
      }
    ]
  },
  "pool": {
    "id": "0192f2fb-****-****-****-4a0d6a7c1000",
    "state": "populating"
  }
}
```

Every successful response includes the pool ID and state. When no attempts are waiting, the endpoint still returns `200 OK`:

```json
{
  "lease": null,
  "pool": {
    "id": "0192f2fb-****-****-****-4a0d6a7c1000",
    "state": "populating"
  }
}
```

A consumed pool also returns `200 OK` with `"lease": null` and `"pool.state": "consumed"`. Clients can use this state to stop polling. Expired and destroyed pools return `409 Conflict`.

Required scope: `write_test_pool`

Success response: `200 OK`

## Heartbeat leases

Extends one or more active leases owned by the requesting job.

```bash
curl "https://api.buildkite.com/v2/organizations/{org.slug}/test-scheduler/pools/{pool.id}/leases/heartbeat" \
  --request POST \
  --header "Authorization: Bearer $OIDC_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "lease_ids": [
      "0192f2fd-****-****-****-2c0f3f986001"
    ],
    "lease_ttl_seconds": 120
  }'
```

```json
{
  "leases": [
    {
      "lease_id": "0192f2fd-****-****-****-2c0f3f986001",
      "expires_at": "2026-07-20T08:05:00.000Z"
    }
  ]
}
```

Required [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>lease_ids</code></th>
    <td>An array containing from one to 100 unique active lease UUIDs. Each lease must belong to the requesting job.</td>
  </tr>
</tbody>
</table>

Optional [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>lease_ttl_seconds</code></th>
    <td>The number of seconds from the heartbeat request time to the requested expiry. Must be an integer from <code>1</code> through <code>600</code> and cannot exceed the organization's maximum lease lifetime.<br><em>Default:</em> <code>60</code></td>
  </tr>
</tbody>
</table>

A heartbeat never shortens a lease and does not add the requested time to the current expiry. The expiry cannot move beyond the lease creation time plus the organization's maximum lease lifetime. The response preserves the order of `lease_ids` in the request.

Heartbeat requests are atomic. If any lease is unknown, expired, released, owned by another job, or already at its maximum lifetime, the API does not extend any lease in the request.

Required scope: `write_test_pool`

Success response: `200 OK`

## Complete attempts

Marks selected leased attempts as completed and records a result for each attempt.

```bash
curl "https://api.buildkite.com/v2/organizations/{org.slug}/test-scheduler/pools/{pool.id}/leases/complete" \
  --request POST \
  --header "Authorization: Bearer $OIDC_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "leases": [
      {
        "lease_id": "0192f2fd-****-****-****-2c0f3f986001",
        "attempts": [
          {
            "attempt_id": "0192f2fe-****-****-****-700a780fd001",
            "result": "passed"
          }
        ]
      }
    ]
  }'
```

```json
{
  "leases": [
    {
      "lease_id": "0192f2fd-****-****-****-2c0f3f986001",
      "attempts": [
        {
          "id": "0192f2fe-****-****-****-700a780fd001",
          "pool_id": "0192f2fb-****-****-****-4a0d6a7c1000",
          "entry_id": "0192f2fc-****-****-****-600a780fd001",
          "attempt_index": 0,
          "selector_type": "custom",
          "selector": {
            "file": "spec/models/user_spec.rb",
            "line": 42
          },
          "costs": {
            "custom": 12.5
          },
          "priority": 5,
          "affinity_group": "database",
          "state": "completed",
          "result": "passed",
          "lease_id": "0192f2fd-****-****-****-2c0f3f986001",
          "lease_expires_at": "2026-07-20T08:05:00.000Z",
          "completed_at": "2026-07-20T08:03:30.000Z",
          "meta_data": {
            "team": "platform",
            "tags": ["ruby", "model"],
            "retry": 0
          },
          "created_at": "2026-07-20T08:01:00.000Z",
          "completion_status": "completed"
        }
      ]
    }
  ],
  "pool": {
    "id": "0192f2fb-****-****-****-4a0d6a7c1000",
    "state": "consuming"
  }
}
```

Required [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>leases</code></th>
    <td>A non-empty array of leases containing attempts to complete.</td>
  </tr>
  <tr>
    <th><code>leases[].lease_id</code></th>
    <td>A unique lease UUID owned by the requesting job.</td>
  </tr>
  <tr>
    <th><code>leases[].attempts</code></th>
    <td>A non-empty array of attempts. A request can complete up to 5,000 attempts across all leases.</td>
  </tr>
  <tr>
    <th><code>leases[].attempts[].attempt_id</code></th>
    <td>A unique UUID for an attempt held by the specified lease.</td>
  </tr>
  <tr>
    <th><code>leases[].attempts[].result</code></th>
    <td>The attempt result: <code>passed</code>, <code>failed</code>, or <code>errored</code>.</td>
  </tr>
</tbody>
</table>

The request is atomic for the attempts listed. If any attempt cannot be completed, no attempts in the request are completed. Duplicate lease or attempt IDs are rejected. Attempts omitted from the request remain leased. After completion, the scheduler evaluates each affected entry asynchronously and may create additional waiting attempts according to the pool's attempt policy.

The response contains the pool state before attempt-policy evaluation. Policy evaluation is triggered by completing an attempt. Completing the final attempt for the last unfinished entry can therefore return a pool state of `consuming`.

Repeating a completion with the same result succeeds and returns `"completion_status": "already_completed"` without changing `completed_at`, even after the pool expires or transitions to `consumed`. Repeating it with a different result returns `409 Conflict`.

Required scope: `write_test_pool`

Success response: `200 OK`

## Release attempts

Returns selected leased attempts to the `waiting` state so they can be leased again. Omit `attempt_ids` to release all active attempts held by a lease.

```bash
curl "https://api.buildkite.com/v2/organizations/{org.slug}/test-scheduler/pools/{pool.id}/leases/release" \
  --request POST \
  --header "Authorization: Bearer $OIDC_TOKEN" \
  --header "Content-Type: application/json" \
  --data '{
    "leases": [
      {
        "id": "0192f2fd-****-****-****-2c0f3f986001",
        "attempt_ids": [
          "0192f2fe-****-****-****-700a780fd001"
        ],
        "reason": "Worker shutdown"
      }
    ]
  }'
```

```json
{
  "leases": [
    {
      "id": "0192f2fd-****-****-****-2c0f3f986001",
      "attempts": [
        "0192f2fe-****-****-****-700a780fd001"
      ]
    }
  ]
}
```

Required [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>leases</code></th>
    <td>A non-empty array containing up to 100 lease release objects.</td>
  </tr>
  <tr>
    <th><code>leases[].id</code></th>
    <td>A unique lease UUID owned by the requesting job.</td>
  </tr>
</tbody>
</table>

Optional [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>leases[].attempt_ids</code></th>
    <td>A non-empty array of attempt UUIDs held by this lease. Omit this property to release all active attempts held by the lease. A request can specify up to 50 attempt IDs across all leases.</td>
  </tr>
  <tr>
    <th><code>leases[].reason</code></th>
    <td>A string that explains why the attempts are being released.<br><em>Example:</em> <code>Worker shutdown</code></td>
  </tr>
</tbody>
</table>

The response groups released attempt IDs by lease. When `attempt_ids` is omitted, the API skips attempts that are already completed. Explicitly requesting a completed attempt returns `409 Conflict`.

The request is atomic. If any requested lease or attempt is invalid, the API releases no attempts.

Required scope: `write_test_pool`

Success response: `200 OK`


## Get pool metrics

Returns aggregate progress for a pool at the time of the request. This endpoint accepts either a Buildkite job OIDC token or a REST API access token. Set `$TOKEN` to the token you want to use.

```bash
curl "https://api.buildkite.com/v2/organizations/{org.slug}/test-scheduler/pools/{pool.id}/metrics?build_id={build.id}" \
  --header "Authorization: Bearer $TOKEN"
```

```json
{
  "observed_at": "2026-07-20T08:03:00.000Z",
  "pool": {
    "id": "0192f2fb-****-****-****-4a0d6a7c1000",
    "state": "consuming",
    "drained": false,
    "expires_at": "2026-07-20T08:05:00.000Z"
  },
  "entries": {
    "total": 5
  },
  "attempts": {
    "total": 5,
    "states": {
      "waiting": {
        "count": 3,
        "costs": {
          "custom": 3.0
        }
      },
      "leased": {
        "count": 2,
        "costs": {
          "custom": 2.0
        }
      },
      "completed": {
        "count": 0,
        "costs": {
          "custom": 0.0
        }
      },
      "canceled": {
        "count": 0,
        "costs": {
          "custom": 0.0
        }
      }
    },
    "results": {
      "passed": 0,
      "failed": 0,
      "errored": 0
    }
  },
  "leases": {
    "active": {
      "count": 1,
      "attempt_count": 2
    },
    "expired": {
      "count": 0,
      "attempt_count": 0
    }
  },
  "timing": {
    "oldest_waiting_attempt_created_at": "2026-07-20T08:01:00.000Z",
    "oldest_active_lease_started_at": "2026-07-20T08:02:00.000Z",
    "oldest_expired_lease_started_at": null,
    "next_active_lease_expires_at": "2026-07-20T08:04:00.000Z"
  }
}
```

Required query string parameter:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>build_id</code></th>
    <td>The build UUID. For OIDC authentication, the value must match the <code>build_id</code> claim in the token. For REST API authentication, the build must be accessible to the user associated with the token.</td>
  </tr>
</tbody>
</table>

The response includes:

<table class="responsive-table">
<tbody>
  <tr>
    <th><code>observed_at</code></th>
    <td>The time used to calculate the metrics.</td>
  </tr>
  <tr>
    <th><code>pool</code></th>
    <td>The pool ID, state, expiry, and whether the pool is drained. A pool is drained when it has no waiting or leased attempts.</td>
  </tr>
  <tr>
    <th><code>entries.total</code></th>
    <td>The number of entries in the pool.</td>
  </tr>
  <tr>
    <th><code>attempts.total</code></th>
    <td>The total number of attempts across all entries.</td>
  </tr>
  <tr>
    <th><code>attempts.states</code></th>
    <td>Attempt counts and total custom costs grouped by <code>waiting</code>, <code>leased</code>, <code>completed</code>, and <code>canceled</code> state.</td>
  </tr>
  <tr>
    <th><code>attempts.results</code></th>
    <td>Completed attempt counts grouped by <code>passed</code>, <code>failed</code>, and <code>errored</code> result.</td>
  </tr>
  <tr>
    <th><code>leases</code></th>
    <td>Active and expired lease counts, with the number of attempts in each group.</td>
  </tr>
  <tr>
    <th><code>timing</code></th>
    <td>The oldest waiting attempt, oldest active and expired leases, and next active lease expiry. A value is <code>null</code> when the corresponding attempt or lease does not exist.</td>
  </tr>
</tbody>
</table>

Entries and attempts are reported separately because an attempt policy can create multiple attempts for one entry. Pending work appears in `attempts.states.waiting`.

Required scope: `read_test_pool`

Success response: `200 OK`

## Error responses

Test Scheduler endpoints can return these errors:

Status | Description
------ | -----------
`400 Bad Request` | The request contains malformed JSON, is not a JSON object, or omits a required query string parameter.
`401 Unauthorized` | Authentication is missing or invalid.
`403 Forbidden` | The token lacks the required scope or claim, or a request value does not match a token claim.
`404 Not Found` | The pool or lease does not exist or is not accessible to the token.
`409 Conflict` | The requested operation conflicts with the current pool, lease, or attempt state. For example, the pool is expired, an entry upload targets a pool that is no longer populating, or a completion changes an already-recorded result.
`422 Unprocessable Entity` | A request property, UUID, limit, or state transition is invalid.
{: class="responsive-table"}

## Breaking changes

Since August 14, 2026, the pool metrics endpoint requires a `build_id` query string parameter. OIDC requests already include build context in the token claims. REST API access-token requests must provide `build_id` so the request can be routed using the owning build instead of searching for a pool by UUID across shards.

Since August 13, 2026, lease configuration is set when creating a pool. The settings apply to every lease from that pool and cannot be changed after creation.

Use `lease.costs.custom` to set the target custom cost. Use `lease.max_attempts` to set the maximum number of attempts. Pool responses include both settings in a `lease` object. Existing pools use the defaults of `1` for custom cost and `300` attempts per lease.

The `target_cost_limit` property is no longer accepted when creating a lease. Requests that include it return `422 Unprocessable Entity`. To migrate, remove `target_cost_limit` from create-lease requests. Set the same custom cost in `lease.costs.custom` when creating the pool.

Since August 10, 2026, all entries that use the same non-empty `affinity_group` must be included in one upload request. After the request succeeds, later entry uploads to the same pool that reuse the affinity group return `409 Conflict`.

Create-lease responses now include a `pool` object containing `id` and `state`. A consumed pool now returns `200 OK` with a null lease instead of `409 Conflict`. Clients that treated 409 as the consumed signal must migrate to checking `pool.state == "consumed"` in successful responses.

The attempt policy validation change described above has not landed in Buildkite yet. When it lands, `min_passed` and `min_failed` will use `null` instead of `0` to disable a threshold. Configured values will need to be integers of at least `1`, and when both thresholds are configured, their sum must be less than `max_attempts`. Until then, use `0` to disable either threshold; the API does not yet accept `null` for these properties.
