# Flaky test management

## Detecting flaky tests

Flaky tests are automated tests that produce inconsistent or unreliable results, despite being run on the same code and environment. They cause frustration, decrease confidence in testing, and waste time while you investigate whether the failure is due to a genuine bug.

Test Engine detects flaky tests by surfacing when the same test is run multiple times on the same commit SHA with different results. The tests might run multiple times within a single build or across different builds. Either way, they are detected as flaky if they report both passed and failed results.

If your test suite supports it, we recommend enabling the option to retry failed tests automatically. Automatic retries are typically run more often and provide more data to detect flaky tests. If you can't use automatic retries, Test Engine also detects flaky tests from manual retries.

Alternatively, you can create [scheduled builds](/docs/pipelines/configure/workflows/scheduled-builds) to run your test suite on the default branch. You can schedule them outside your typical development time to run the test suite multiple times against the same commit SHA. You can still enable test retries in this setup, but they're less important. The more builds you run, the more likely you'll detect flaky tests that fail infrequently.

Test Engine reviews the test results to detect flaky tests after every test run.

### Resolving a flaky test

From the **Manage flaky test** dropdown, you can resolve your flaky test. Resolving a flaky test will cause a **Flaky behaviour marked as resolved** badge to display within the flaky index. The test will stay in the flaky index until it has not flaked within 28 days. If the test flakes again, it will be considered a **Reoccurring Flaky** and will receive a corresponding badge in the index.

### Weekly flaky test summary

You're able to schedule a weekly summary of the flakiest tests owned by your teams. Visit the **Suite settings** page to create new notifications, or manage existing ones.

<%= image "flaky-test-summary-mailer.png", width: 1960/2, height: 630/2, alt: "Flaky test page showing team assignments" %>
