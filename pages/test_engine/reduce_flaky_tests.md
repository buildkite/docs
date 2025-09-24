# Reduce flaky tests

Flaky tests are automated tests that produce inconsistent or unreliable results, despite being run on the same code and environment. Flaky tests cause frustration, decrease confidence in testing, and waste time while you investigate whether the failure is due to a genuine bug.

With Test Engine, you can set up a workflow to manage your flaky tests, by configuring the workflow to automatically detect and label flaky tests, and to notify the relevant people when a new flaky test appears.

## Detecting flaky tests

Workflows has a number of monitors that can be used to detect flaky tests. Choosing the best flaky test monitor for your test suite depends on the shape of your test data and the configuration of your test pipeline. You can read more about the different monitors [here](/docs/test-engine/workflows/monitors). If you're unsure which monitor is best suited for your test suite, we recommend using the transition count monitor.

Once you've chosen your monitor, add a Workflow action to label this test as "flaky". Having the flaky test labelled as such means that Test Engine can drive other automatic behaviour from this, and you can easily surface "flaky" tests in the Test Engine UI and on the Tests tab in the Builds page. By default, Test Engine provides a [saved view](/docs/test-engine/test-suites/saved-views) called "Flaky" which shows you all test with the flaky label.

[some pictures]

## Quarantining flaky tests

Optionally, if your test suite has test state enabled, you can quarantine a flaky test by changing its state to "muted" or "skipped". You can do this manually via the Test Engine UI, via the Test Engine API, or by configuring a Workflow action for this to happen automatically.

Once a test has been quarantined, you can speed up your builds by using bktec to ignore quarantined tests as part of your test suite execution.

You can find more detailed information about quarantining [here](/docs/test-engine/test-suites/test-state-and-quarantine).

## Remediating flaky tests

Once the flaky test has been identified, it needs to be fixed or removed so that it stops impacting everyone. Workflows provides a number of actions to surface the flaky test so that it can be remediated. You can set up a Workflow action to automatically:

- send a webhook
- post a Slack message
- create a Linear issue

This allows the relevant team(s) to be notified about any newly identified flaky tests and prioritise a fix for this.

With Workflow actions, you can set up a trigger to automatically remove the "flaky" label (and transition its state back to "enabled", if applicable) once an acceptable level of reliability has been reached for the given test. This means you don't have to do any manual monitoring of flaky test fixes.

Learn more about setting up a Workflow [here](/docs/test-engine/workflows).

