---
toc: false
---

# Your own collectors

Test Engine integrates directly with your test runner to provide in-depth information about your tests (including spans) in real time.

If you're interested in developing your own fully-integrated Buildkite test collector for specific test runners, have a look at the source code for Buildkite's own [Ruby test collector](https://github.com/buildkite/test-collector-ruby) on GitHub, which can collect test data from RSpec and minitest test runners.

The source code for this test collector provides details on how test data is packaged and sent to Test Engine.
