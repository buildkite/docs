# Ruby collectors

To use Test Analytics with your [Ruby](https://www.ruby-lang.org/) projects use the :github: [`test-collectors-ruby`](https://github.com/buildkite/test-collector-ruby) gem with RSpec or minitest.

You can also upload test results by importing [JSON](/docs/test-analytics/importing-json) or [JUnit XML](/docs/test-analytics/importing-junit-xml).


## RSpec collector

[RSpec](https://rspec.info/) is a behaviour-driven development library for Ruby.
If you're already using RSpec for your tests, add the `buildkite-test_collector` gem to your code to collect your test results into your Test Analytics dashboard.

Before you start, make sure RSpec runs with access to [CI environment variables](/docs/test-analytics/ci-environments).

1. Create a new branch:

    ```
    git checkout -b install-buildkite-test-analytics
    ```

2. Add `buildkite-test_collector` to your `Gemfile` in the `:test` group:

    ```rb
    group :test do
      gem "buildkite-test_collector"
    end
    ```

3. Run `bundle` to install the gem and update your `Gemfile.lock`:

    ```sh
    bundle
    ```

3. Add the Test Analytics code to your application in `spec/spec_helper.rb`, and set the BUILDKITE_ANALYTICS_TOKEN [securely](/docs/pipelines/secrets) on your agent or agents. Please ensure gems that patch `Net::HTTP`, like [httplog](https://github.com/trusche/httplog) and [sniffer](https://github.com/aderyabin/sniffer), are required before `buildkite/test_collector` to avoid conflicts.

    ```rb
    require "buildkite/test_collector"

    Buildkite::TestCollector.configure(hook: :rspec)
    ```

4. Commit and push your changes:

    ```sh
    $ git add .
    $ git commit -m "Install and set up Buildkite Test Analytics"
    $ git push
    ```

Once you're done, in your Test Analytics dashboard, you'll see analytics of test executions on all branches that include this code.

If you don't see branch names, build numbers, or commit hashes in the Test Analytics UI, then see [CI environments](/docs/test-analytics/ci-environments) to learn more about exporting your environment to the collector.

### Troubleshooting allow_any_instance_of errors

If you're using RSpec and seeing errors related to `allow_any_instance_of` that look like this:

```ruby
Failure/Error: allow_any_instance_of(Object).to receive(:sleep)
       Using `any_instance` to stub a method (sleep) that has been defined on a prepended module (Buildkite::TestCollector::Object::CustomObjectSleep) is not supported.
```

You can fix them by being more specific in your stubbing by replacing `allow_any_instance_of(Object).to receive(:sleep)` with `allow_any_instance_of(TheClassUnderTest).to receive(:sleep)`.

## minitest collector

[minitest](https://github.com/minitest/minitest) provides a complete suite of testing facilities supporting TDD, BDD, mocking, and benchmarking.

If you're already using minitest for your tests, add the `buildkite-test_collector` gem to your code to collect your test results into your Test Analytics dashboard.

1. Create a new branch:

    ```
    git checkout -b install-buildkite-collector
    ```

2. Add `buildkite-test_collector` to your `Gemfile` in the `:test` group:

    ```rb
    group :test do
      gem "buildkite-test_collector"
    end
    ```

3. Run `bundle` to install the gem and update your `Gemfile.lock`:

    ```sh
    bundle
    ```

3. Add the Test Analytics code to your application in `test/test_helper.rb`, and set the BUILDKITE_ANALYTICS_TOKEN [securely](/docs/pipelines/secrets) on your agent or agents. Please ensure gems that patch `Net::HTTP`, like [httplog](https://github.com/trusche/httplog) and [sniffer](https://github.com/aderyabin/sniffer), are required before `buildkite/test_collector` to avoid conflicts.

    ```rb
    require "buildkite/test_collector"

    Buildkite::TestCollector.configure(hook: :minitest)
    ```

4. Commit and push your changes:

    ```sh
    git add .
    git commit -m "Install and set up Buildkite Test Analytics"
    git push
    ```

Once you're done, in your Test Analytics dashboard, you'll see analytics of test executions on all branches that include this code.

If you don't see branch names, build numbers, or commit hashes in the Test Analytics UI, then see [CI environments](/docs/test-analytics/ci-environments) to learn more about exporting your environment to the minitest collector.

## Adding annotation spans

This gem allows adding custom annotations to the span data sent to Buildkite using the [`.annotate`](https://github.com/buildkite/test-collector-ruby/blob/d9fe11341e4aa470e766febee38124b644572360/lib/buildkite/test_collector.rb#L64) method. For example:

```ruby
Buildkite::TestCollector.annotate("Visiting login")
```

This would appear like so:

<%= image "annotation-span.png", width: 2048/2, height: 880/2, alt: "Screenshot of the span timeline including the 'Rendered OTP Screen' annotation." %>

This is particularly useful for tests that generate a lot of span data such as system/feature tests. You can find all _annotations_ under **Span timeline** at the bottom of every test execution page.

## Tagging duplicate test executions with a prefix/suffix

For builds that execute the same test multiple times it's possible to tag each test execution with a prefix/suffix describing the test environment. This is useful when running a test suite against multiple versions of Ruby or Rails. The prefix/suffix is set using these environment variables:

```
BUILDKITE_ANALYTICS_EXECUTION_NAME_PREFIX
BUILDKITE_ANALYTICS_EXECUTION_NAME_SUFFIX
```

When viewing a _test_ every _execution_ is displayed including its corresponding prefix/suffix. For example:

<%= image "execution-prefix-suffix.png", width: 2048/2, height: 400/2, alt: "Screenshot of test executions including a prefix and suffix." %>
