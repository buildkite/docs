# Tags

Tags is a Test Engine feature that adds dimensions to test execution metadata so tests and executions can be better filtered, aggregated, and compared in Test Engine visualizations.

Tagging can be used to observe aggregated data points—for example, to observe aggregated performance across several tests, and (optionally) narrow the dataset further based on specific constraints.

Tags are `key:value` pairs containing two parts:

- The tag's `key` is the identifier, which can only exist once on each test, and is case sensitive.
- The tag's `value` is the specific data or information associated with the `key`.

## Core tags

The following core tags are vital to helping you understand and improve the performance of your test suite. These tags are included in the [managed tests](/docs/test-engine/usage_and_billing#managed-tests) price.

Where possible, Test Engine will automatically ingest this data on your behalf.

<table class="responsive-table">
  <thead>
    <tr>
      <th>Tag key</th>
      <th>Use case</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>build.id</code></td>
      <td>Filtering and aggregating based on the build identifier.</td>
    </tr>
    <tr>
      <td><code>build.job_id</code></td>
      <td>Filtering and aggregating based on the job identifier.</td>
    </tr>
    <tr>
      <td><code>build.step_id</code></td>
      <td>Filtering and aggregating based on the step identifier.</td>
    </tr>
    <tr>
      <td><code>cloud.provider</code></td>
      <td>
        Filtering and aggregating based on your cloud provider to compare cloud provider performance and reliability in your test suite.<br/><em>Example:</em> <code>aws</code> vs <code>gcp</code>.
      </td>
    </tr>
    <tr>
      <td><code>cloud.region</code></td>
      <td>
        Filtering and aggregating based on your cloud region to compare region performance and reliability in your test suite.<br/><em>Example:</em> <code>us-east-1</code> vs <code>us-east-2</code>.
      </td>
    </tr>
    <tr>
      <td><code>code.file.path</code></td>
      <td>
        Filtering and aggregating based on the file path or subsection of the file path.
      </td>
    </tr>
    <tr>
      <td><code>collector.name</code></td>
      <td>
        Filtering and aggregating based on the Test Engine collector you are using. Useful when onboarding or updating your Test Engine collector.
      </td>
    </tr>
    <tr>
      <td><code>collector.version</code></td>
      <td>
        Filtering and aggregating based on the Test Engine collector version you are using. Useful when onboarding or updating your Test Engine collector.
      </td>
    </tr>
    <tr>
      <td><code>host.arch</code></td>
      <td>
        Filtering and aggregating based on the architecture to compare architecture performance and reliability in your test suite.<br/><em>Example:</em> <code>arm64</code> vs <code>x86_64</code>.
      </td>
    </tr>
    <tr>
      <td><code>host.type</code></td>
      <td>
        Filtering and aggregating based on the instance type to compare instance performance and reliability in your test suite.<br/><em>Example:</em> <code>m4.large</code> vs <code>m5.large</code>.
      </td>
    </tr>
    <tr>
      <td><code>language.name</code></td>
      <td>
        Filtering and aggregating based on the programming language to compare language performance and reliability in your test suite.<br/><em>Example:</em> <code>python</code> vs <code>javascript</code>.
      </td>
    </tr>
    <tr>
      <td><code>language.version</code></td>
      <td>
        Filtering and aggregating based on the language version to compare version performance and reliability in your test suite.<br/><em>Example:</em> <code>3.0.2</code> vs <code>2.5.3</code>.
      </td>
    </tr>
    <tr>
      <td><code>scm.branch</code></td>
      <td>
        Filtering and aggregating based on source code branch to compare branch performance and reliability. For example you might be rolling out a new dependency and you are testing this in a branch.
      </td>
    </tr>
    <tr>
      <td><code>scm.commit_sha</code></td>
      <td>
        Filtering and aggregating based on commit_sha to compare specific commit performance and reliability.
      </td>
    </tr>
    <tr>
      <td><code>test.framework.name</code></td>
      <td>
        Filtering and aggregating based on testing framework to compare performance and reliability.
      </td>
    </tr>
    <tr>
      <td><code>test.framework.version</code></td>
      <td>
        Filtering and aggregating based on testing framework version to compare performance and reliability.
      </td>
    </tr>
  </tbody>
</table>

## Custom tags

In addition to the [core tags](#core-tags), you can tag executions with your own custom tags. Test Engine customers can tag executions with an additional 10 custom tags beyond the included core tags.

### Defining tags

Test Engine has the following tagging requirements:

- Up to 10 tags may be specified at the upload level (applying to all executions), per upload.
- Up to 10 tags may be specified on each execution.

#### Tag keys

- Must not be blank.
- Must begin with a letter, and may contain letters, numbers, underscores, hyphens and periods.
- Must be less than 64 bytes of UTF-8 text.

#### Tag values

- Must not be blank.
- Must be less than 128 bytes of UTF-8 text.

### Tagging methods

Tags may be assigned using the following collection methods:

- [Java (using JUnit XML import)](/docs/test-engine/test-collection/importing-junit-xml)
- [JavaScript (Jest, Cypress, Playwright, Mocha, Jasmine, Vitest)](/docs/test-engine/test-collection/javascript-collectors#upload-custom-tags-for-test-executions)
- [Python (PyTest)](/docs/test-engine/test-collection/python-collectors#pytest-collector-upload-custom-tags-for-test-executions)
- [Ruby (RSpec, minitest)](/docs/test-engine/test-collection/ruby-collectors#upload-custom-tags-for-test-executions)
- [Importing JSON](/docs/test-engine/test-collection/importing-json#json-test-results-data-reference-execution-level-custom-tags)

## Usage

After you have assigned tags at the test collection level, start using them to filter and group your test results. Tags are used in the following areas of the Buildkite Platform.

### Test execution drawer

On the test page, you can open the execution drawer by selection an execution.

This presents all the tags which have been applied to the test execution.

<%= image "execution-tags.png", width: 3274, height: 1838, alt: "Screenshot of test page with execution drawer open displaying execution tags available for filtering and aggregtion" %>

### Group by tag

Grouping by tag on the test page breaks down the test reliability and duration (p50, p95), so that you can compare performance across the tag values.

<%= image "group-by-tag.png", width: 3136, height: 966, alt: "Screenshot of test page with a group by tag aggregation applied breaking down metrics by architecture" %>

### Filter by tag

Filtering by tag on the test page will constrain all executions for the test which match the filter conditions.

<%= image "filter-by-tag.png", width: 3146, height: 946, alt: "Screenshot of test page with a tag filter applied restricting executions to just those that ran on t3.large in ruby" %>

Filtering by tag on the test index page will constrain all tests to those that had executions matching the conditions of the filter. In the following case all tests that ran on the `t3.large` instance type.

<%= image "filter-tests-by-tag.png", width: 3134, height: 1442, alt: "Screenshot of test index with a tag filter applied restricting tests to just those running on t3.large instances" %>

You can filter by tag using the "Filter" dropdown.

### Test tab

To filter tests by tags in [Pipelines](/docs/pipelines), select the **Tests** tab in either the job or build interface and apply your desired filters.

<%= image "pipelines-filter-by-tag.png", width: 3800, height: 1764, alt: "Screenshot of filtering tests on a pipeline build" %>
