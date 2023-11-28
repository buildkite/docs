# Public test suites

If you're working on an open-source project, and want the whole world to be able to see your test analytics, you can make your test suite public.


Making a suite public provides read-only public/anonymous access to:

- All test suite data
- Run results
- Tests
- Test executions
- Test execution span data
- Test suite environmental variables
  - `commit_sha` `branch` `message` `url` `number` `job_id`

Before making a suite public, you should verify that runs do not expose sensitive information in their logs or environment variables — this applies to both new and historical runs.

## Make a test suite public using the UI

Make a test suite public in the _Settings_ of your test suite:

<%= image "settings.png", width: 1960/2, height: 630/2, alt: "Public test suite settings" %>

Public test suites can be made private again at any time from within the _Settings_.
