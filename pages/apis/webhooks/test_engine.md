# Webhooks

You can configure webhooks to be triggered by the following events in Test Engine:

- When a test's state is changed
- When a label is added to or removed from a test

Webhooks are delivered to an HTTP POST endpoint of your choosing with a `Content-Type: application/json` header and a JSON encoded request body.

To configure webhooks for your suite, navigate to **Test Suites**, select your suite, then click on **Settings** and select the **Notifications** tab.

## Test state changed

If [test state management](/docs/test-engine/test-state-and-quarantine) is enabled for your suite you can configure a webhook to be sent on **Test state changed** events.
The webhook will be sent whether the state change was triggered manually through the [Buildkite interface](/docs/test-engine/test-state-and-quarantine#manual-quarantine), through the [REST API](/docs/apis/rest-api/test-engine/quarantine), or through [automatic quarantine](/docs/test-engine/test-state-and-quarantine#automatic-quarantine)

Example payload:

```json
{
  "timestamp": "2025-05-13T01:54:03.648Z",
  "test_location": "./spec/models/user.rb:23",
  "test_id": "abcdef01-2345-6789-abcd-ef0123456789",
  "test_url": "http://buildkite.com/organizations/my-org/analytics/suites/my-suite/tests/abcdef01-2345-6789-abcd-ef0123456789",
  "actor_type": "system",
  "event": "test.state_changed",
  "test_full_name": "integrate frictionless action-items",
  "actor_system": "auto quarantine",
  "actor_name": "Buildkite",
  "actor_email": "noreply@buildkite.com",
  "test_new_state": "enabled",
  "test_old_state": "muted"
}
```

## Test label added / removed

You can configure a webhook to be sent on **Test label added** and **Test label removed** events.
The webhook will be sent whether the label was added manually through the [Buildkite interface](/docs/test-engine/labels#label-a-test-using-the-buildkite-interface), through the [REST API](/docs/test-engine/labels#label-a-test-using-the-rest-api), through [automatic quarantine](/docs/test-engine/test-state-and-quarantine#automatic-quarantine) or through the [test execution tags](/docs/test-engine/labels#label-a-test-using-execution-tags) feature.

Example payload for when a label is added:

```json
{
  "timestamp": "2025-05-13T01:54:03.648Z",
  "test_location": "./spec/models/user.rb:23",
  "test_id": "abcdef01-2345-6789-abcd-ef0123456789",
  "test_url": "http://buildkite.com/organizations/my-org/analytics/suites/my-suite/tests/abcdef01-2345-6789-abcd-ef0123456789",
  "actor_type": "system",
  "event": "test.label_added",
  "test_full_name": "mesh synergistic relationships",
  "actor_system": "internal system",
  "actor_name": "Buildkite",
  "actor_email": "noreply@buildkite.com",
  "label": "new_label"
}
```

In the case of a **Test Label Removed** webhook the request payload will be identical to **Test Label Added** except for the `event` property:

```json
  "event": "test.label_removed"
```

## Filtering webhooks by team

If [test ownership](/docs/test-engine/test-ownership) is enabled on your suite you can configure webhooks to be sent only when a test is owned by a given team.
One or more teams may be selected.
The **No Owner** option will select tests that do not have an owner.

If no checkbox is selected in the **Teams** section the webhook will be sent on events related to all tests.

## Disabling webhooks

Webhooks can be temporarily disabled with the **Disable** button when editing the webhook.
The webhook and it's configuration will be retained but it will no longer be sent until re-enabled.
Click **Enable** when editing the webhook to re-enable.
