---
toc: false
---

# Collecting test data from other test runners

If a native Buildkite test collector is not available for your language or test runner, you can instead use any of the following mechanisms to integrate your particular test runner with Test Engine:

- Importing your test run data from:

  * [JUnit XML](/docs/pipelines/configure/tests/test-collection/importing-junit-xml)
  * [JSON](/docs/pipelines/configure/tests/test-collection/importing-json)

- [Writing your own test collector](/docs/pipelines/configure/tests/test-collection/your-own-collectors).
