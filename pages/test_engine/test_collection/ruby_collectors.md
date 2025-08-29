# Ruby collectors

To use Test Engine with your [Ruby](https://www.ruby-lang.org/) projects use the :github: [`test-collectors-ruby`](https://github.com/buildkite/test-collector-ruby) gem with RSpec or minitest.

You can also upload test results by importing [JSON](/docs/test-engine/test-collection/importing-json) or [JUnit XML](/docs/test-engine/test-collection/importing-junit-xml).


## RSpec collector

[RSpec](https://rspec.info/) is a behavior-driven development library for Ruby.
If you're already using RSpec for your tests, add the `buildkite-test_collector` gem to your code to collect your test results into your Test Engine dashboard.

Before you start, make sure RSpec runs with access to [CI environment variables](/docs/test-engine/test-collection/ci-environments).

1. Create a new branch:

    ```
    git checkout -b install-buildkite-test-engine
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

3. Add the Test Engine code to your application in `spec/spec_helper.rb`, and set the BUILDKITE_ANALYTICS_TOKEN [securely](/docs/pipelines/security/secrets/managing) on your agent or agents. Please ensure gems that patch `Net::HTTP`, like [httplog](https://github.com/trusche/httplog) and [sniffer](https://github.com/aderyabin/sniffer), are required before `buildkite/test_collector` to avoid conflicts.

    ```rb
    require "buildkite/test_collector"

    Buildkite::TestCollector.configure(hook: :rspec)
    ```

4. Commit and push your changes:

    ```sh
    $ git add .
    $ git commit -m "Install and set up Buildkite Test Engine"
    $ git push
    ```

Once you're done, in your Test Engine dashboard, you'll see analytics of test executions on all branches that include this code.

If you don't see branch names, build numbers, or commit hashes in the Test Engine UI, then see [CI environments](/docs/test-engine/test-collection/ci-environments) to learn more about exporting your environment to the collector.

> 🚧
> Test Engine identifies tests using their descriptions and example group descriptions. To avoid test identity conflicts, ensure all test descriptions are unique. You can enforce uniqueness by using the RuboCop cops [RSpec/RepeatedDescription](https://docs.rubocop.org/rubocop-rspec/cops_rspec.html#rspecrepeateddescription) and [RSpec/RepeatedExampleGroupDescription](https://docs.rubocop.org/rubocop-rspec/cops_rspec.html#rspecrepeatedexamplegroupdescription), where [RuboCop](https://github.com/rubocop/rubocop) is a static code analyzer for Ruby.

### Troubleshooting allow_any_instance_of errors

If you're using RSpec and seeing errors related to `allow_any_instance_of` that look like this:

```ruby
Failure/Error: allow_any_instance_of(Object).to receive(:sleep)
       Using `any_instance` to stub a method (sleep) that has been defined on a prepended module (Buildkite::TestCollector::Object::CustomObjectSleep) is not supported.
```

You can fix them by being more specific in your stubbing by replacing `allow_any_instance_of(Object).to receive(:sleep)` with `allow_any_instance_of(TheClassUnderTest).to receive(:sleep)`.

### Troubleshooting test grouping issues

RSpec supports anonymous test cases—tests which are automatically named based on the subject and/or inputs to the expectations within the test. However, this can lead to unstable test names across different test runs, incorporating elements such as object IDs, database IDs, timestamps, and more.

As a consequence, each test is assigned a new identity per run within Test Engine. This poses a challenge for using the Test Engine product effectively, as historical data across tests becomes difficult to track and analyze.

To mitigate this issue and ensure the reliability of Test Engine, it's advisable to provide explicit and stable descriptions for each test case within your RSpec test suite. By doing so, you can maintain consistency in test identification across multiple runs, enabling better tracking and analysis of test performance over time.

## minitest collector

[minitest](https://github.com/minitest/minitest) provides a complete suite of testing facilities supporting TDD, BDD, mocking, and benchmarking.

If you're already using minitest for your tests, add the `buildkite-test_collector` gem to your code to collect your test results into your Test Engine dashboard.

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

3. Add the Test Engine code to your application in `test/test_helper.rb`, and set the BUILDKITE_ANALYTICS_TOKEN [securely](/docs/pipelines/security/secrets/managing) on your agent or agents. Please ensure gems that patch `Net::HTTP`, like [httplog](https://github.com/trusche/httplog) and [sniffer](https://github.com/aderyabin/sniffer), are required before `buildkite/test_collector` to avoid conflicts.

    ```rb
    require "buildkite/test_collector"

    Buildkite::TestCollector.configure(hook: :minitest)
    ```

4. Commit and push your changes:

    ```sh
    git add .
    git commit -m "Install and set up Buildkite Test Engine"
    git push
    ```

Once you're done, in your Test Engine dashboard, you'll see analytics of test executions on all branches that include this code.

If you don't see branch names, build numbers, or commit hashes in the Test Engine UI, then see [CI environments](/docs/test-engine/test-collection/ci-environments) to learn more about exporting your environment to the minitest collector.

## Adding annotation spans

This gem allows adding custom annotations to the span data sent to Buildkite using the [`.annotate`](https://github.com/buildkite/test-collector-ruby/blob/d9fe11341e4aa470e766febee38124b644572360/lib/buildkite/test_collector.rb#L64) method. For example:

```ruby
Buildkite::TestCollector.annotate("Visiting login")
```

This would appear like so:

<%= image "annotation-span.png", width: 2048/2, height: 880/2, alt: "Screenshot of the span timeline including the 'Rendered OTP Screen' annotation." %>

This is particularly useful for tests that generate a lot of span data such as system/feature tests. You can find all _annotations_ under **Span timeline** at the bottom of every test execution page.

## Upload custom tags for test executions

You can group test executions using custom tags to compare metrics across different dimensions, such as:

- Language versions
- Cloud providers
- Instance types
- Team ownership
- and more

### Upload-level tags

Tags configured on the collector will be included in each upload batch, and will be applied server-side to every execution therein. This is an efficient way to tag every execution with values that don't vary within one configuration, e.g. cloud environment details, language/framework versions. Upload-level tags may be overwritten by execution-level tags.

```rb
require "buildkite/test_collector"

Buildkite::TestCollector.configure(
  tags: {
    "cloud.provider" => "aws",
    "host.type" => "m5.4xlarge",
    "language.version" => RUBY_VERSION,
  }
)
```

### Execution-level tags

For more granular control, you can programmatically add tags during individual test executions using the `.tag_execution` method. For example, with RSpec:

```rb
RSpec.configuration.before(:each) do |example|
  Buildkite::TestCollector.tag_execution("team", example.metadata[:team])
  Buildkite::TestCollector.tag_execution("feature", example.metadata[:feature])
end
```

## VCR
If your test suites use [VCR](https://github.com/vcr/vcr) to stub network requests, you'll need to modify the config to allow actual network requests to Test Engine.

```ruby
VCR.configure do |c|
  c.ignore_hosts "analytics-api.buildkite.com"
end
```
