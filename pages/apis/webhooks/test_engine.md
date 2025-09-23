# Test Engine webhooks

You can configure webhooks to be triggered by the following events in Test Engine:

- When a [test's state](/docs/test-engine/glossary#test-state) is changed.
- When a [label](/docs/test-engine/test-suites/labels) is added to or removed from a test.

Webhooks are delivered to an HTTP POST endpoint of your choosing with a `Content-Type: application/json` header and a JSON encoded request body.

## Add a webhook

To add a webhook for your test suite:

1. Select **Test Suites** in the global navigation > your test suite to configure webhooks on.
1. Select **Settings** > **Notifications** tab.
1. Select the **Add** button on **Webhooks**.
1. Specifying your webhook's **Description** and **Webhook URL**.
1. Select one or more of the following **Events** that will trigger this webhook:
    * **Test state changed**
    * **Test label added**
    * **Test label removed**

1. If the [teams feature](/docs/platform/team-management/permissions#manage-teams-and-permissions) has been enabled for your Buildkite organization, select the **Teams** whose test executions for this test suite can trigger this webhook. The webhook is only triggered when the [test ownership](/docs/test-engine/test-suites/test-ownership) feature has been configured for this test suite, and the test is owned by one of the selected teams.

    **Notes:**
    * If the **No owner** checkbox is selected, then the webhook is triggered when the test does not have an owner.
    * If no checkbox is selected, then the webhook is triggered on all selected **Events** (above).

1. Select the **Save** button to save these changes and add the webhook.

### Test state changed

If [test state management](/docs/test-engine/test-suites/test-state-and-quarantine) is enabled for your test suite, you can configure a webhook to be sent on **Test state changed** events.

The webhook is triggered when a test's state is changed [manually through the Buildkite interface](/docs/test-engine/test-suites/test-state-and-quarantine#manual-quarantine), through [automatic quarantine](/docs/test-engine/test-suites/test-state-and-quarantine#automatic-quarantine), or using the [REST API](/docs/apis/rest-api/test-engine/quarantine) when a [test state is updated](/docs/apis/rest-api/test-engine/quarantine#update-test-state).

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

### Test label added or removed

You can configure a webhook to be sent on **Test label added** and **Test label removed** events.

The webhook is triggered sent when a label is added [manually through the Buildkite interface](/docs/test-engine/test-suites/labels#label-a-test-using-the-buildkite-interface), using [automatic quarantine](/docs/test-engine/test-suites/labels#label-a-test-using-automatic-quarantine), using [test execution tags](/docs/test-engine/test-suites/labels#label-a-test-using-execution-tags), or using the [REST API](/docs/test-engine/test-suites/labels#label-a-test-using-the-rest-api).

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

In the case of a **Test Label Removed** webhook, the request payload will be identical to **Test Label Added** except the the `event` property's value indicates:

```json
  "event": "test.label_removed"
```

## Edit, disable, re-enable or delete a webhook

To do any of these actions a webhook:

1. Select **Test Suites** in the global navigation > your test suite with configured webhooks.
1. Select **Settings** > **Notifications** tab to open its page.
1. Select the webhook to open its page, and to:
    * Edit the webhook, alter the **Description**, **Webhook URL**, **Events** and **Teams** fields as required (see [Add a webhook](#add-a-webhook) for details), then select the **Save** button.
    * Disable the webhook, select its **Disable** button and confirm the action. Disabled webhooks have a note at their top to indicate this state.
        - To re-enable the disabled webhook, select its **Enable** button.
    * Delete the webhook, select its **Delete** button and confirm the action. The webhook is removed from the **Notifications** page.
