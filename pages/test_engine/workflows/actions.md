# Alarm and recover actions

When conditions in your test suite trigger an _alarm_ or _recover_ workflow event, there are several automatic actions that Test Engine can perform.

## Add/remove label

These action lets you add or remove a label on the test. These two actions are often set as a pair, for example an alarm action will label a test "flaky", and the corresponding recover action will remove the "flaky" label.

## Changing state

This action lets you [change the state](/docs/test-engine/test-suites/test-state-and-quarantine#lifecycle-states) (enabled, muted, skipped) of a test. For example, you can set the alarm action to change the state of a test to "muted", and the recover action to change the state of a test to "enabled", which will allow you to [run builds more reliably](/docs/test-engine/speed-up-builds-with-bktec#increase-build-reliability-with-test-states).

## Send webhook notification

This action lets you send JSON payloads through HTTP requests to specific URL endpoints of third-party applications, which let these applications react to activities on your Workflows as they happen.

Here's an example of a payload that you could expect:

```json
{
  "subject": {
    "type": "test",
    "test_id": "08b99391-8caa-88c7-8d45-98c6fd3f94b7",
    "test_full_name": "Enumerated spec 1",
    "test_location": "./spec/enumerated_spec.rb:22",
    "test_url": "http://buildkite.localhost/organizations/buildkite/analytics/suites/te-sample/tests/08b99391-8caa-88c7-8d45-98c6fd3f94b7"
  },
  "workflow_id": "0198a11d-9486-7ac5-a87a-d55d2642cd3f",
  "workflow_url": "http://buildkite.localhost/organizations/buildkite/analytics/suites/te-sample/workflows/0198a11d-9486-7ac5-a87a-d55d2642cd3f",
  "event": "workflow.alarm",
  "workflow_event": {
    "type": "transition_count"
  }
}
```

## Send Slack notification

This action lets you send a Slack notification about a test. The Slack notification will be sent to a specified Slack channel in a connected Slack workspace, and the message supports [mrkdwn](https://docs.slack.dev/messaging/formatting-message-text/#basic-formatting) for display. The message also supports interpolation of Workflow event information, full variable list available in the UI.

To connect your Slack workspace, go to your organization's settings, and select "Notification Services".

## Creating a Linear issue

This action lets you create a Linear issue about a test. The issue will be created for the specified Linear team, with a custom title and description. Linear issues created for a test are visible in the "Issues" tab on the individual test view page, and its status will be synchronized with Linear so that you know if someone is working on the issue.

The title and description fields support [Linear flavoured Markdown](https://linear.app/docs/editor#text-styling). The message also supports interpolation of Workflow event information, full variable list available in the UI.

[screenshot of Issues tab]

To [connect your Linear account](/docs/platform/integrations/linear-workspace), go to your organization's settings, and select "Notification Services".
