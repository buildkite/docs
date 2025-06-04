# Flaky test management

## Detecting flaky tests

Flaky tests are automated tests that produce inconsistent or unreliable results, despite being run on the same code and environment. They cause frustration, decrease confidence in testing, and waste time while you investigate whether the failure is due to a genuine bug.

Test Engine detects flaky tests by surfacing when the same test is run multiple times on the same commit SHA with different results. The tests might run multiple times within a single build or across different builds. Either way, they are detected as flaky if they report both passed and failed results.

If your test suite supports it, we recommend enabling the option to retry failed tests automatically. Automatic retries are typically run more often and provide more data to detect flaky tests. If you can't use automatic retries, Test Engine also detects flaky tests from manual retries.

Alternatively, you can create [scheduled builds](/docs/pipelines/configure/workflows/scheduled-builds) to run your test suite on the default branch. You can schedule them outside your typical development time to run the test suite multiple times against the same commit SHA. You can still enable test retries in this setup, but they're less important. The more builds you run, the more likely you'll detect flaky tests that fail infrequently.

Test Engine reviews the test results to detect flaky tests after every test run.

## Assignment

Customers on the [Pro and Enterprise plans](https://buildkite.com/pricing) can assign flaky tests to [teams](/docs/test-engine/permissions#manage-teams-and-permissions).

### Enabling flaky test assignments

To enable assignments, you must have at least one team that has access to your suite. You may need to ask your admin to enable the teams feature, and then create teams via the organization settings page.

<%= image "flaky-test-no-teams.png", width: 1960/2, height: 630/2, alt: "Flaky test page showing dropdown menu prompting user to create teams" %>
<%= image "team-settings.png", width: 1960/2, height: 630/2, alt: "Team page for assigning test suites" %>

### Assigning a test

When viewing your flaky tests, you should now see a list of teams with suite access permissions listed inside the **Manage flaky test** dropdown. From here you may assign, reassign or remove the assignment.

> 🚧 Assignment permissions
> All team members have the ability to create, update or remove an assignment. This feature is not restricted to admins.

Tests that are assigned to a team will be updated to display a badge indicating as such.

<%= image "flaky-test-teams.png", width: 1960/2, height: 630/2, alt: "Flaky test page showing team assignments" %>

### Resolving a flaky test

From the **Manage flaky test** dropdown, you can resolve your flaky test. Resolving a flaky test will remove the test from **My Assignments** and display a **Flaky behaviour marked as resolved** badge within the flaky index. The test will stay in the flaky index until it has not flaked within 28 days. If the test flakes again, it will be considered a **Reoccurring Flaky** and will receive a corresponding badge in the index.

### Viewing assignments

Users can check their test assignments by clicking **My Assignments** in the side bar.

<%= image "recent-assignments.png", width: 1960/2, height: 630/2, alt: "Flaky test page showing team assignments" %>

When an assigned test has not flaked in more than 7 days, it is moved to the **Outdated flaky tests** section. An assignment could become out of date due to a flaky test being fixed, or perhaps it belongs to a pipeline which has not had a build in the last 7 days. Should the flake reoccur, the assignment will be moved back to the **Recent flaky tests** page.

<%= image "outdated-assignments.png", width: 1960/2, height: 630/2, alt: "Flaky test page showing team assignments" %>

### Weekly flaky test summary

You're able to schedule a weekly summary of the flakiest tests assigned to your teams. Visit the **Suite settings** page to create new notifications, or manage existing ones. If you would like to set up auto assignment, check out our [Test ownership](/docs/test-engine/test-ownership) feature.

<%= image "flaky-test-summary-mailer.png", width: 1960/2, height: 630/2, alt: "Flaky test page showing team assignments" %>
