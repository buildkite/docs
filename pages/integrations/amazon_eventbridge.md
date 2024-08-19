# Amazon EventBridge

The [Amazon EventBridge](https://aws.amazon.com/eventbridge/) notification service in Buildkite lets you stream events in real-time from your Buildkite account to your AWS account.


## Events

Once you've configured an Amazon EventBridge notification service in Buildkite, the following events are published to the partner event bus:

<table>
<thead>
  <tr><th>Detail Type</th><th>Description</th></tr>
</thead>
<tbody>
  <tr><th><a href="#events-build-created">Build Created</a></th><td>A build has been created</td></tr>
  <tr><th><a href="#events-build-started">Build Started</a></th><td>A build has started</td></tr>
  <tr><th><a href="#events-build-finished">Build Finished</a></th><td>A build has finished</td></tr>
  <tr><th><a href="#events-job-scheduled">Job Scheduled</a></th><td>A job has been scheduled</td></tr>
  <tr><th><a href="#events-job-started">Job Started</a></th><td>A command step job has started running on an agent</td></tr>
  <tr><th><a href="#events-job-finished">Job Finished</a></th><td>A job has finished. To check a job's result, use the <code>passed</code> field. The value is <code>true</code> when the job passed, and <code>false</code> otherwise.</td></tr>
  <tr><th><a href="#events-job-activated">Job Activated</a></th><td>A block step job has been unblocked using the web or API</td></tr>
  <tr><th><a href="#events-agent-connected">Agent Connected</a></th><td>An agent has connected to the API</td></tr>
  <tr><th><a href="#events-agent-lost">Agent Lost</a></th><td>An agent has been marked as lost. This happens when Buildkite stops receiving pings from the agent</td></tr>
  <tr><th><a href="#events-agent-disconnected">Agent Disconnected</a></th><td>An agent has disconnected. This happens when the agent shuts down and disconnects from the API</td></tr>
  <tr><th><a href="#events-agent-stopping">Agent Stopping</a></th><td>An agent is stopping. This happens when an agent is instructed to stop from the API. It first transitions to stopping and finishes any current jobs</td></tr>
  <tr><th><a href="#events-agent-stopped">Agent Stopped</a></th><td>An agent has stopped. This happens when an agent is instructed to stop from the API. It can be graceful or forceful</td></tr>
  <tr>
    <th><a href="#events-agent-blocked">Agent Blocked</a></th>
    <td>An agent has been blocked. This happens when an agent's IP address is no longer included in the agent token's <a href="/docs/clusters/manage-clusters#restrict-an-agent-tokens-access-by-ip-address">allowed IP addresses</a></td>
  </tr>
  <tr>
    <th><a href="#events-cluster-token-registration-blocked">Cluster Token Registration Blocked</a></th>
    <td>An attempted agent registration is blocked because the request IP address is not included in the agent token's <a href="/docs/clusters/manage-clusters#restrict-an-agent-tokens-access-by-ip-address">allowed IP addresses</a></td>
  </tr>
  <tr>
    <th><a href="#audit-event-logged">Audit Event Logged</a></th>
    <td>An audit event has been logged for the organization</td>
  </tr>
</tbody>
</table>

See [build states](/docs/pipelines/defining-steps#build-states) and [job states](/docs/pipelines/defining-steps#job-states) to learn more about the sequence of these events.

## Configuring

In your Buildkite [Organization's Notification Settings](https://buildkite.com/organizations/-/services), add an Amazon EventBridge notification service:

<%= image "buildkite-add-eventbridge.png", width: 1458/2, height: 208/2, alt: "Screenshot of Add Buildkite Amazon EventBridge Button" %>

Once you've entered your AWS region and AWS Account ID, a Partner Event Source will be created in your AWS account matching the **Partner Event Source Name** shown on the settings page:

<%= image "buildkite-amazon-eventbridge-settings.png", width: 1458/2, height: 1254/2, alt: "Screenshot of Buildkite Amazon EventBridge Notification Settings" %>

You can then start consuming the events in your AWS account. The links to **Partner Event Sources Console** and **Event Rules** take you to the relevant pages in your AWS Console.

## Filtering

When creating your EventBridge rule you can specify an **Event pattern** filter to limit which events will be processed. You can use this to respond only to certain events based on the type, or any attribute from within the event payload.

For example, to only process [Build Finished](#events-build-finished) events you'd configure your rule with the following event pattern:

<%= image "cloudwatch-event-pattern.png", width: 1636/2, height: 786/2, alt: "Screenshot of configuring an EventBridge Event Pattern filter" %>

You can use any event property in your custom event pattern. For example, the following event pattern allows only "Build Started" and "Build Finished" events containing a particular pipeline slug:

```json
{
  "detail-type": [ "Build Started", "Build Finished" ],
  "detail": {
    "pipeline": {
      "slug": [ "some-pipeline" ]
    }
  }
}
```

See the [Example Event Payloads](#example-event-payloads) for full list of properties, and the [AWS EventBridge Event Patterns documentation](https://docs.aws.amazon.com/eventbridge/latest/userguide/filtering-examples-structure.html) for full details on the pattern syntax.

## Logging

To debug your EventBridge events you can configure a rule to route the event bus directly to AWS CloudWatch Logs:

<%= image "cloudwatch-logs.png", width: 1636/2, height: 992/2, alt: "Screenshot of configuring an EventBridge Rule to send to CloudWatch Logs" %>

You can then use [CloudWatch Logs Insights](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AnalyzingLogData.html) to query and inspect the live events from your event bus, by choosing the event log group configured above:

<%= image "cloudwatch-insights.png", width: 2280/2, height: 998/2, alt: "Screenshot of CloudWatch Logs Insights" %>

## Lambda example: Track agent wait times using CloudWatch metrics

You can use the following [AWS Lambda](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html) and <a href="#events-job-started">Job Started</a> event to publish a [CloudWatch metric](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/working_with_metrics.html) which tracks how long jobs are waiting for agents to become available:

```js
const AWS = require("aws-sdk");
const cloudWatch = new AWS.CloudWatch();

exports.handler = (event, context, callback) => {
  const waitTime =
    new Date(event.detail.job.started_at) -
    new Date(event.detail.job.runnable_at);

  console.log(`Job started after waiting ${waitTime} seconds`);

  cloudWatch.putMetricData(
    {
      Namespace: "Buildkite",
      MetricData: [
        {
          MetricName: "Job Agent Wait Time",
          Timestamp: new Date(),
          StorageResolution: 1,
          Unit: "Seconds",
          Value: waitTime,
          Dimensions: [
            {
              Name: "Pipeline",
              Value: event.detail.pipeline.slug
            }
          ]
        }
      ]
    },
    (err, data) => {
      if (err) console.log(err, err.stack);
      callback(null, "Finished");
    }
  );
};
```

## Official AWS quick start examples

AWS have published three example implementations of using Buildkite with Amazon EventBridge:

<a class="Docs__example-repo" href="https://aws.amazon.com/quickstart/eventbridge/buildkite-build-workflow/">
  <span class="icon">:aws:</span>
  <span class="detail">
    <strong>Build Workflows with Amazon SNS</strong>
    <span class="description">Combine EventBridge with a workflow to evaluate, store, and publish build events.</span>
    <span class="repo">aws.amazon.com/quickstart/eventbridge/buildkite-build-workflow/</span>
  </span>
</a>

<a class="Docs__example-repo" href="https://aws.amazon.com/quickstart/eventbridge/buildkite-visualization/">
  <span class="icon">:aws:</span>
  <span class="detail">
    <strong>Build Event Visualization with Amazon QuickSight</strong>
    <span class="description">Store and visualize build events from continuous-integration pipelines.</span>
    <span class="repo">aws.amazon.com/quickstart/eventbridge/buildkite-visualization/</span>
  </span>
</a>

<a class="Docs__example-repo" href="https://aws.amazon.com/quickstart/eventbridge/buildkite-pipeline-alerts/">
  <span class="icon">:aws:</span>
  <span class="detail">
    <strong>Build Alerts with Amazon SNS and Webhooks</strong>
    <span class="description">Send customized notifications when builds complete.</span>
    <span class="repo">aws.amazon.com/quickstart/eventbridge/buildkite-pipeline-alerts/</span>
  </span>
</a>

Each AWS Quick Start example has a corresponding GitHub repository with full example code.

## Example event payloads

AWS EventBridge has strict limits on the size of the payload as documented in [Amazon EventBridge quotas](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-quota.html). As such, the information included in payloads is restricted to basic information about the event. If you need more information, you can query from the Buildkite [APIs](/docs/apis) using the data in the event.

<a id="events-build-created"></a>

### Build Created

```json
{
  "detail-type": "Build Created",
  "detail": {
    "version": 1,
    "build": {
      "uuid": "8fcaa7b9-e175-4110-9f48-f79949806a31",
      "graphql_id": "QnVpbGQtLS04ZmNhYTdiOS1lMTc1LTQxMTAtOWY0OC1mNzk5NDk4MDZhMzE=",
      "number": 123456,
      "commit": "5a741616cdf07dc87c5adafe784321eeeb639e33",
      "message": "Merge pull request #456 from my-org/chore/update-deps",
      "branch": "main",
      "state": "scheduled",
      "started_at": null,
      "finished_at": null,
      "source": "webhook"
    },
    "pipeline": {
      "uuid": "88d73553-5533-4f56-9c16-fb38d7817d8f",
      "graphql_id": "UGlwZWxpbmUtLS04OGQ3MzU1My01NTMzLTRmNTYtOWMxNi1mYjM4ZDc4MTdkOGY=",
      "slug": "my-pipeline",
      "repo": "git@somewhere.com:project.git"
    },
    "organization": {
      "uuid": "a98961b7-adc1-41aa-8726-cfb2c46e42e0",
      "graphql_id": "T3JnYW5pemF0aW9uLS0tYTk4OTYxYjctYWRjMS00MWFhLTg3MjYtY2ZiMmM0NmU0MmUw",
      "slug": "my-org"
    }
  }
}
```

<a id="events-build-started"></a>

### Build Started

```json
{
  "version": "1",
  "source": "aws.partner/buildkite.com/buildkite/0000-123c-12ab4cd",
  "account": "354123020283",
  "time": "2023-03-07T23:14:43Z",
  "region": "us-east-1",
  "resources": [],
  "id": "01234567-0123-0123-0123-012345678901",
  "detail-type": "Build Started",
  "detail": {
    "version": 1,
    "build": {
      "uuid": "8fcaa7b9-e175-4110-9f48-f79949806a31",
      "graphql_id": "QnVpbGQtLS04ZmNhYTdiOS1lMTc1LTQxMTAtOWY0OC1mNzk5NDk4MDZhMzE=",
      "number": 123456,
      "commit": "5a741616cdf07dc87c5adafe784321eeeb639e33",
      "message": "Merge pull request #456 from my-org/chore/update-deps",
      "branch": "main",
      "state": "started",
      "started_at": "2019-08-11 06:01:16 UTC",
      "finished_at": null,
      "source": "webhook"
    },
    "pipeline": {
      "uuid": "88d73553-5533-4f56-9c16-fb38d7817d8f",
      "graphql_id": "UGlwZWxpbmUtLS04OGQ3MzU1My01NTMzLTRmNTYtOWMxNi1mYjM4ZDc4MTdkOGY=",
      "slug": "my-pipeline",
      "repo": "git@somewhere.com:project.git"
    },
    "organization": {
      "uuid": "a98961b7-adc1-41aa-8726-cfb2c46e42e0",
      "graphql_id": "T3JnYW5pemF0aW9uLS0tYTk4OTYxYjctYWRjMS00MWFhLTg3MjYtY2ZiMmM0NmU0MmUw",
      "slug": "my-org"
    }
  }
}
```

<a id="events-build-finished"></a>

### Build Finished

```json
{
  "detail-type": "Build Finished",
  "detail": {
    "version": 1,
    "build": {
      "uuid": "8fcaa7b9-e175-4110-9f48-f79949806a31",
      "graphql_id": "QnVpbGQtLS04ZmNhYTdiOS1lMTc1LTQxMTAtOWY0OC1mNzk5NDk4MDZhMzE=",
      "number": 123456,
      "commit": "5a741616cdf07dc87c5adafe784321eeeb639e33",
      "message": "Merge pull request #456 from my-org/chore/update-deps",
      "branch": "main",
      "state": "passed",
      "started_at": "2019-08-11 06:01:16 UTC",
      "finished_at": "2019-08-11 06:01:35 UTC",
      "source": "webhook"
    },
    "pipeline": {
      "uuid": "88d73553-5533-4f56-9c16-fb38d7817d8f",
      "graphql_id": "UGlwZWxpbmUtLS04OGQ3MzU1My01NTMzLTRmNTYtOWMxNi1mYjM4ZDc4MTdkOGY=",
      "slug": "my-pipeline",
      "repo": "git@somewhere.com:project.git"
    },
    "organization": {
      "uuid": "a98961b7-adc1-41aa-8726-cfb2c46e42e0",
      "graphql_id": "T3JnYW5pemF0aW9uLS0tYTk4OTYxYjctYWRjMS00MWFhLTg3MjYtY2ZiMmM0NmU0MmUw",
      "slug": "my-org"
    }
  }
}
```

<a id="events-build-blocked"></a>

### Build Blocked

```json
{
    "version": "0",
    "id": "...",
    "detail-type": "Build Finished",
    "source": "...",
    "account": "...",
    "time": "2022-01-30T04:32:06Z",
    "region": "us-east-1",
    "resources": [],
    "detail": {
        "version": 1,
        "build": {
            "uuid": "...",
            "graphql_id": "...",
            "number": 23,
            "commit": "...",
            "message": "Update index.html",
            "branch": "main",
            "state": "blocked",
            "blocked_state": null,
            "source": "ui",
            "started_at": "2022-01-30 04:31:59 UTC",
            "finished_at": "2022-01-30 04:32:06 UTC"
        },
        "pipeline": {
            "uuid": "...",
            "graphql_id": "...",
            "slug": "webhook-test",
            "repo": "git@github.com:nithyaasworld/add-contact-chip.git"
        },
        "organization": {
            "uuid": "...",
            "graphql_id": "...",
            "slug": "nithya-bk"
        }
    }
}
```

<a id="events-job-scheduled"></a>

### Job Scheduled

```json
{
  "detail-type": "Job Scheduled",
  "detail": {
    "version": 1,
    "job": {
      "uuid": "9e6c3f19-4fdb-4e8e-b925-28cd7504e17f",
      "graphql_id": "Sm9iLS0tOWU2YzNmMTktNGZkYi00ZThlLWI5MjUtMjhjZDc1MDRlMTdm",
      "type": "script",
      "label": "\:nodejs\: Test",
      "step_key": "node_test",
      "command": "yarn test",
      "agent_query_rules": [
        "queue=default"
      ],
      "exit_status": null,
      "passed": false,
      "soft_failed": false,
      "state": "assigned",
      "runnable_at": "2019-08-11 06:01:14 UTC",
      "started_at": null,
      "finished_at": null,
      "unblocked_by": null
    },
    "build": {
      "uuid": "8fcaa7b9-e175-4110-9f48-f79949806a31",
      "graphql_id": "QnVpbGQtLS04ZmNhYTdiOS1lMTc1LTQxMTAtOWY0OC1mNzk5NDk4MDZhMzE=",
      "number": 123456,
      "commit": "5a741616cdf07dc87c5adafe784321eeeb639e33",
      "message": "Merge pull request #456 from my-org/chore/update-deps",
      "branch": "main",
      "state": "started",
      "source": "webhook"
    },
    "pipeline": {
      "uuid": "88d73553-5533-4f56-9c16-fb38d7817d8f",
      "graphql_id": "UGlwZWxpbmUtLS04OGQ3MzU1My01NTMzLTRmNTYtOWMxNi1mYjM4ZDc4MTdkOGY=",
      "slug": "my-pipeline",
      "repo": "git@somewhere.com:project.git"
    },
    "organization": {
      "uuid": "a98961b7-adc1-41aa-8726-cfb2c46e42e0",
      "graphql_id": "T3JnYW5pemF0aW9uLS0tYTk4OTYxYjctYWRjMS00MWFhLTg3MjYtY2ZiMmM0NmU0MmUw",
      "slug": "my-org"
    }
  }
}
```

<a id="events-job-started"></a>

### Job Started

```json
{
  "detail-type": "Job Started",
  "detail": {
    "version": 1,
    "job": {
      "uuid": "9e6c3f19-4fdb-4e8e-b925-28cd7504e17f",
      "graphql_id": "Sm9iLS0tOWU2YzNmMTktNGZkYi00ZThlLWI5MjUtMjhjZDc1MDRlMTdm",
      "type": "script",
      "label": "\:nodejs\: Test",
      "step_key": "node_test",
      "command": "yarn test",
      "agent_query_rules": [
        "queue=default"
      ],
      "exit_status": null,
      "passed": false,
      "soft_failed": false,
      "state": "started",
      "runnable_at": "2019-08-11 06:01:14 UTC",
      "started_at": "2019-08-11 06:01:16 UTC",
      "finished_at": null,
      "unblocked_by": null
    },
    "build": {
      "uuid": "8fcaa7b9-e175-4110-9f48-f79949806a31",
      "graphql_id": "QnVpbGQtLS04ZmNhYTdiOS1lMTc1LTQxMTAtOWY0OC1mNzk5NDk4MDZhMzE=",
      "number": 123456,
      "commit": "5a741616cdf07dc87c5adafe784321eeeb639e33",
      "message": "Merge pull request #456 from my-org/chore/update-deps",
      "branch": "main",
      "state": "started",
      "source": "webhook"
    },
    "pipeline": {
      "uuid": "88d73553-5533-4f56-9c16-fb38d7817d8f",
      "graphql_id": "UGlwZWxpbmUtLS04OGQ3MzU1My01NTMzLTRmNTYtOWMxNi1mYjM4ZDc4MTdkOGY=",
      "slug": "my-pipeline",
      "repo": "git@somewhere.com:project.git"
    },
    "organization": {
      "uuid": "a98961b7-adc1-41aa-8726-cfb2c46e42e0",
      "graphql_id": "T3JnYW5pemF0aW9uLS0tYTk4OTYxYjctYWRjMS00MWFhLTg3MjYtY2ZiMmM0NmU0MmUw",
      "slug": "my-org"
    }
  }
}
```

<a id="events-job-finished"></a>

### Job Finished

These types of events [may contain a `signal_reason` field value](#signal-reason).

```json
{
  "detail-type": "Job Finished",
  "detail": {
    "version": 1,
    "job": {
      "uuid": "9e6c3f19-4fdb-4e8e-b925-28cd7504e17f",
      "graphql_id": "Sm9iLS0tOWU2YzNmMTktNGZkYi00ZThlLWI5MjUtMjhjZDc1MDRlMTdm",
      "type": "script",
      "label": "\:nodejs\: Test",
      "step_key": "node_test",
      "command": "yarn test",
      "agent_query_rules": [
        "queue=default"
      ],
      "exit_status": 0,
      "signal_reason": "see-reason-below",
      "passed": true,
      "soft_failed": false,
      "state": "finished",
      "runnable_at": "2019-08-11 06:01:14 UTC",
      "started_at": "2019-08-11 06:01:16 UTC",
      "finished_at": "2019-08-11 06:01:35 UTC",
      "unblocked_by": null
    },
    "build": {
      "uuid": "8fcaa7b9-e175-4110-9f48-f79949806a31",
      "graphql_id": "QnVpbGQtLS04ZmNhYTdiOS1lMTc1LTQxMTAtOWY0OC1mNzk5NDk4MDZhMzE=",
      "number": 123456,
      "commit": "5a741616cdf07dc87c5adafe784321eeeb639e33",
      "message": "Merge pull request #456 from my-org/chore/update-deps",
      "branch": "main",
      "state": "started",
      "source": "webhook"
    },
    "pipeline": {
      "uuid": "88d73553-5533-4f56-9c16-fb38d7817d8f",
      "graphql_id": "UGlwZWxpbmUtLS04OGQ3MzU1My01NTMzLTRmNTYtOWMxNi1mYjM4ZDc4MTdkOGY=",
      "slug": "my-pipeline",
      "repo": "git@somewhere.com:project.git"
    },
    "organization": {
      "uuid": "a98961b7-adc1-41aa-8726-cfb2c46e42e0",
      "graphql_id": "T3JnYW5pemF0aW9uLS0tYTk4OTYxYjctYWRjMS00MWFhLTg3MjYtY2ZiMmM0NmU0MmUw",
      "slug": "my-org"
    }
  }
}
```

<a id="signal-reason"></a>

#### Signal reason in job finished events

The `signal_reason` field of a [job finished](#example-event-payloads-job-finished) event is only be present when the `exit_status` field value in the same event is not `0`. The `signal_reason` field's value indicates the reason why a job was either stopped, or why the job never ran.

| Signal Reason | Description |
| --- | --- |
| `agent_refused` | The agent refused to run the job, as it was not allowed by a [pre-bootstrap hook](/docs/agent/v3/securing#restrict-access-by-the-buildkite-agent-controller-strict-checks-using-a-pre-bootstrap-hook) |
| `agent_stop` | The agent was stopped while the job was running |
| `cancel` | The job was cancelled by a user |
| `signature_rejected` | The job was rejected due to a mismatch with the [step's signature](/docs/agent/v3/signed-pipelines) |
| `process_run_error` | The job failed to start due to an error in the process run. This is usually a bug in the agent, contact support if this is happening regularly. |

<a id="events-job-activated"></a>

### Job Activated

```json
{
  "detail-type": "Job Activated",
  "detail": {
    "version": 1,
    "job": {
      "uuid": "9e6c3f19-4fdb-4e8e-b925-28cd7504e17f",
      "graphql_id": "Sm9iLS0tOWU2YzNmMTktNGZkYi00ZThlLWI5MjUtMjhjZDc1MDRlMTdm",
      "type": "manual",
      "label": "\:rocket\: Deploy",
      "step_key": "manual_deploy",
      "command": null,
      "agent_query_rules": [],
      "exit_status": null,
      "passed": false,
      "soft_failed": false,
      "state": "finished",
      "runnable_at": null,
      "started_at": null,
      "finished_at": null,
      "unblocked_by": {
        "uuid": "c07c69c6-11d2-4375-9148-9d0338b0a836",
        "graphql_id": "VXNlci0tLWMwN2M2OWM2LTExZDItNDM3NS05MTQ4LTlkMDMzOGIwYTgzNg==",
        "name": "bell"
      }
    },
    "build": {
      "uuid": "8fcaa7b9-e175-4110-9f48-f79949806a31",
      "graphql_id": "QnVpbGQtLS04ZmNhYTdiOS1lMTc1LTQxMTAtOWY0OC1mNzk5NDk4MDZhMzE=",
      "number": 123456,
      "commit": "5a741616cdf07dc87c5adafe784321eeeb639e33",
      "message": "Merge pull request #456 from my-org/chore/update-deps",
      "branch": "main",
      "state": "started",
      "source": "webhook"
    },
    "pipeline": {
      "uuid": "88d73553-5533-4f56-9c16-fb38d7817d8f",
      "graphql_id": "UGlwZWxpbmUtLS04OGQ3MzU1My01NTMzLTRmNTYtOWMxNi1mYjM4ZDc4MTdkOGY=",
      "slug": "my-pipeline",
      "repo": "git@somewhere.com:project.git"
    },
    "organization": {
      "uuid": "a98961b7-adc1-41aa-8726-cfb2c46e42e0",
      "graphql_id": "T3JnYW5pemF0aW9uLS0tYTk4OTYxYjctYWRjMS00MWFhLTg3MjYtY2ZiMmM0NmU0MmUw",
      "slug": "my-org"
    }
  }
}
```

<a id="events-agent-connected"></a>

### Agent Connected

```json
{
  "detail-type": "Agent Connected",
  "detail": {
    "version": 1,
    "agent": {
      "uuid": "288139c5-728d-4c22-88e3-5a926b6c4a51",
      "graphql_id": "QWdlbnQtLS0yODgxMzljNS03MjhkLTRjMjItODhlMy01YTkyNmI2YzRhNTE=",
      "connection_state": "connected",
      "name": "my-agent-1",
      "version": "3.13.2",
      "ip_address": "3.80.193.183",
      "hostname": "ip-10-0-2-73.ec2.internal",
      "pid": "18534",
      "priority": 0,
      "meta_data": [
        "aws:instance-id=i-0ce2c738afbfc6c83"
      ],
      "connected_at": "2019-08-10 09:44:40 UTC",
      "disconnected_at": null,
      "lost_at": null
    },
    "organization": {
      "uuid": "a98961b7-adc1-41aa-8726-cfb2c46e42e0",
      "graphql_id": "T3JnYW5pemF0aW9uLS0tYTk4OTYxYjctYWRjMS00MWFhLTg3MjYtY2ZiMmM0NmU0MmUw",
      "slug": "my-org"
    },
    "token": {
      "uuid": "df75860c-94f9-4275-91cb-3986590f45b5",
      "created_at": "2019-08-10 07:44:40 UTC",
      "description": "Default agent token"
    }
  }
}
```

<a id="events-agent-disconnected"></a>

### Agent Disconnected

```json
{
  "detail-type": "Agent Disconnected",
  "detail": {
    "version": 1,
    "agent": {
      "uuid": "288139c5-728d-4c22-88e3-5a926b6c4a51",
      "graphql_id": "QWdlbnQtLS0yODgxMzljNS03MjhkLTRjMjItODhlMy01YTkyNmI2YzRhNTE=",
      "connection_state": "disconnected",
      "name": "my-agent-1",
      "version": "3.13.2",
      "ip_address": "3.80.193.183",
      "hostname": "ip-10-0-2-73.ec2.internal",
      "pid": "18534",
      "priority": 0,
      "meta_data": [
        "aws:instance-id=i-0ce2c738afbfc6c83"
      ],
      "connected_at": "2019-08-10 09:44:40 UTC",
      "disconnected_at": "2019-08-10 09:54:40 UTC",
      "lost_at": null
    },
    "organization": {
      "uuid": "a98961b7-adc1-41aa-8726-cfb2c46e42e0",
      "graphql_id": "T3JnYW5pemF0aW9uLS0tYTk4OTYxYjctYWRjMS00MWFhLTg3MjYtY2ZiMmM0NmU0MmUw",
      "slug": "my-org"
    },
    "token": {
      "uuid": "df75860c-94f9-4275-91cb-3986590f45b5",
      "created_at": "2019-08-10 07:44:40 UTC",
      "description": "Default agent token"
    }
  }
}
```

<a id="events-agent-lost"></a>

### Agent Lost

```json
{
  "detail-type": "Agent Lost",
  "detail": {
    "version": 1,
    "agent": {
      "uuid": "288139c5-728d-4c22-88e3-5a926b6c4a51",
      "graphql_id": "QWdlbnQtLS0yODgxMzljNS03MjhkLTRjMjItODhlMy01YTkyNmI2YzRhNTE=",
      "connection_state": "lost",
      "name": "my-agent-1",
      "version": "3.13.2",
      "ip_address": "3.80.193.183",
      "hostname": "ip-10-0-2-73.ec2.internal",
      "pid": "18534",
      "priority": 0,
      "meta_data": [
        "aws:instance-id=i-0ce2c738afbfc6c83"
      ],
      "connected_at": "2019-08-10 09:44:40 UTC",
      "disconnected_at": "2019-08-10 09:54:40 UTC",
      "lost_at": "2019-08-10 09:54:40 UTC"
    },
    "organization": {
      "uuid": "a98961b7-adc1-41aa-8726-cfb2c46e42e0",
      "graphql_id": "T3JnYW5pemF0aW9uLS0tYTk4OTYxYjctYWRjMS00MWFhLTg3MjYtY2ZiMmM0NmU0MmUw",
      "slug": "my-org"
    },
    "token": {
      "uuid": "df75860c-94f9-4275-91cb-3986590f45b5",
      "created_at": "2019-08-10 07:44:40 UTC",
      "description": "Default agent token"
    }
  }
}
```

<a id="events-agent-stopping"></a>

### Agent Stopping

```json
{
  "detail-type": "Agent Stopping",
  "detail": {
    "version": 1,
    "agent": {
      "uuid": "288139c5-728d-4c22-88e3-5a926b6c4a51",
      "graphql_id": "QWdlbnQtLS0yODgxMzljNS03MjhkLTRjMjItODhlMy01YTkyNmI2YzRhNTE=",
      "connection_state": "stopping",
      "name": "my-agent-1",
      "version": "3.13.2",
      "ip_address": "3.80.193.183",
      "hostname": "ip-10-0-2-73.ec2.internal",
      "pid": "18534",
      "priority": 0,
      "meta_data": [
        "aws:instance-id=i-0ce2c738afbfc6c83"
      ],
      "connected_at": "2019-08-10 09:44:40 UTC",
      "disconnected_at": null,
      "lost_at": null
    },
    "organization": {
      "uuid": "a98961b7-adc1-41aa-8726-cfb2c46e42e0",
      "graphql_id": "T3JnYW5pemF0aW9uLS0tYTk4OTYxYjctYWRjMS00MWFhLTg3MjYtY2ZiMmM0NmU0MmUw",
      "slug": "my-org"
    },
    "token": {
      "uuid": "df75860c-94f9-4275-91cb-3986590f45b5",
      "created_at": "2019-08-10 07:44:40 UTC",
      "description": "Default agent token"
    }
  }
}
```

<a id="events-agent-stopped"></a>

### Agent Stopped

```json
{
  "detail-type": "Agent Stopped",
  "detail": {
    "version": 1,
    "agent": {
      "uuid": "288139c5-728d-4c22-88e3-5a926b6c4a51",
      "graphql_id": "QWdlbnQtLS0yODgxMzljNS03MjhkLTRjMjItODhlMy01YTkyNmI2YzRhNTE=",
      "connection_state": "stopped",
      "name": "my-agent-1",
      "version": "3.13.2",
      "ip_address": "3.80.193.183",
      "hostname": "ip-10-0-2-73.ec2.internal",
      "pid": "18534",
      "priority": 0,
      "meta_data": [
        "aws:instance-id=i-0ce2c738afbfc6c83"
      ],
      "connected_at": "2019-08-10 09:44:40 UTC",
      "disconnected_at": "2019-08-10 09:54:40 UTC",
      "lost_at": null
    },
    "organization": {
      "uuid": "a98961b7-adc1-41aa-8726-cfb2c46e42e0",
      "graphql_id": "T3JnYW5pemF0aW9uLS0tYTk4OTYxYjctYWRjMS00MWFhLTg3MjYtY2ZiMmM0NmU0MmUw",
      "slug": "my-org"
    },
    "token": {
      "uuid": "df75860c-94f9-4275-91cb-3986590f45b5",
      "created_at": "2019-08-10 07:44:40 UTC",
      "description": "Default agent token"
    }
  }
}
```

<a id="events-agent-blocked"></a>

### Agent Blocked

```json
{
    "detail-type": "Agent Blocked",
    "detail": {
        "version": 1,
        "blocked_ip": "204.124.80.36",
        "cluster_token": {
            "uuid": "c1164b28-bace-436-ac44-4133e1d18ca5",
            "description": "Default agent token",
            "allowed_ip_addresses": "202.144.160.0/24",
        },
        "agent": {
            "uuid": "0188f51c-7bc8-4b14-a702-002c485ae2dc",
            "graphql_id": "QWdlbnQtLSOMTg4ZjUxYy03YmM4LTRiMTQtYTcwMi@ MDJjNDg1YWUyZGM=",
            "connection_state": "disconnected",
            "name": "rogue-agent-1",
            "version": "3.40.0",
            "token": null,
            "ip_address": "127.0.0.1",
            "hostname": "rogue-agent",
            "pid": "26089",
            "priority": 0,
            "meta_data": ["queues=default"],
            "connected_at": "2023-06-26 00:31:04 UTC",
            "disconnected_at": "2023-06-26 00:31:18 UTC",
            "Lost_at": null,
        },
        "organization": {
            "uuid": "a98961b7-adc1-41aa-8726-cfb2c46e42e0",
            "graphql_id": "T3JnYW5pemF0aW9uLS0tYTk4OTYxYjctYWRjMS00MWFhLTg3MjYtY2ZiMmM0NmU0MmUw",
            "slug": "my-org"
        }
    }
}
```
<!-- vale off -->

<a id="events-cluster-token-registration-blocked"></a>

### Cluster Token Registration Blocked

<!-- vale on -->

```json
{
    "detail-type": "Cluster Token Registration Blocked",
    "detail": {
        "version": 1,
        "blocked_ip": "204.124.80.36",
        "cluster_token": {
            "uuid": "c1164b28-bace-436-ac44-4133e1d18ca5",
            "description": "Default agent token",
            "allowed_ip_addresses": "202.144.160.0/24",
        },
        "organization": {
            "uuid": "a98961b7-adc1-41aa-8726-cfb2c46e42e0",
            "graphql_id": "T3JnYW5pemF0aW9uLS0tYTk4OTYxYjctYWRjMS00MWFhLTg3MjYtY2ZiMmM0NmU0MmUw",
            "slug": "my-org"
        }
    }
}
```

<a id="audit-event-logged"></a>

### Audit Event Logged

[Audit log](/docs/pipelines/security/audit-log) is only available to Buildkite customers on the [Enterprise](https://buildkite.com/pricing) plan.

```json
{
    "version": "0",
    "id": "8212ed90-edcc-0936-187c-d466e46575b6",
    "detail-type": "Audit Event Logged",
    "source": "aws.partner/buildkite.com/buildkite/0106-187c-12cd4fe",
    "account": "354123020283",
    "time": "2023-03-07T23:14:43Z",
    "region": "us-east-1",
    "resources": [],
    "detail": {
        "version": 1,
        "organization": {
            "uuid": "ae85860c-94f9-4275-91cb-3986590f45b5",
            "graphql_id": "T3JnYWMDE4NjDAtNzk1YS00YWMwLWE112jUtM12jEGMzYTNkZDQx",
            "slug": "buildkite"
        },
        "event": {
            "uuid": "da55860c-94f9-4275-91cb-3986590f45b5",
            "occurred_at": "2023-03-25 23:14:43 UTC",
            "type": "ORGANIZATION_UPDATED",
            "data": {
                "name": "Buildkite"
            },
            "subject_type": "Organization",
            "subject_uuid": "af7e863c-94f9-4275-91sb-3986590f45b5",
            "subject_name": "Buildkite",
            "context": "{\"request_id\":\"pemF0aW9uLStMDE4NjDAtNzk1YS00YW\",\"request_ip\":\"127.0.0.0\",\"session_key\":\"pemF0aW9uLStMDE4NjDAtNzk1YS00YW\",\"session_user_uuid\":\"da55860c-94f9-4275-91cb-3986590f45b5\",\"request_user_agent\":\"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36\",\"session_created_at\":\"2023-03-25T23:30:54.559Z\"}"
        },
        "actor": {
            "name": "Buildkite member",
            "type": null,
            "uuid": "df75860c-94f9-4275-91cb-3986590f45b5"
        }
    }
}
```
