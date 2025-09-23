# Labels

Labels allow you to:

- Organize tests to be more meaningful to your team and organization.
- Categorize tests, and therefore, can be used to filter tests within Test Engine.

<%= image "labeling.png", width: 938, height: 349, alt: "Screenshot of a test with labels categorizing the test" %>

Labels are created at the [test suite](/docs/test-engine/glossary#test-suite) level. Therefore, labels belonging to one test suite will not impact the labels associated with other test suites.

## Label a test

Labels may be applied to or removed from tests:

- Manually through the [Buildkite interface](#label-a-test-using-the-buildkite-interface).
- Automatically through the [automatic quarantine](#label-a-test-using-automatic-quarantine) or [test execution tags](#label-a-test-using-execution-tags) features.
- The [REST API](#label-a-test-using-the-rest-api).

### Using the Buildkite interface

From the details page of a test (accessible through its test suite's **Test** page), select **Add labels** and either:

- Select a label from the list of existing used in the test's suite.
- Specify a **New label**, select its **Label color**, and select **Save**.

> 📘
> To remove a label from a test, select **Add labels** from the test's details page, and from its drop-down, clear the checkbox next to the label.

### Using automatic quarantine

Using [test states](/docs/test-engine/glossary#test-state), you can automate the addition and removal of labels when a specific test failure threshold is reached.

Learn more about this feature in [Automatic quarantine](/docs/test-engine/test-suites/test-state-and-quarantine#automatic-quarantine).

### Using execution tags

A test execution [tag](/docs/test-engine/glossary#tag) value can be applied as a label on a test.

Also, when Test Engine detects a change to such a tag's value, its label on the respective test is also updated to this value.

Test Engine only labels tests from execution tag values when their test suite is configured to do so in the suite's **Settings** > **Test labels** (tab) page.

<%= image "execution_tags.png", width: 1547, height: 604, alt: "Screenshot of configuring suite settings to copy tags to labels" %>

Learn more about test execution tagging in [Tags](/docs/test-engine/test-suites/tags).

> 📘
> A label added to a test through a test execution tag is automatically removed when the tag is removed from the test execution.

### Using the REST API

You can label tests using the [REST API](/docs/apis/rest-api) with the [Tests API](/docs/apis/rest-api/test-engine/tests) endpoint. Learn more about this in [Add/remove labels from a test](/docs/apis/rest-api/test-engine/tests#add-slash-remove-labels-from-a-test).

## Filter tests

You can filter tests using labels through the [Buildkite interface](#filter-tests-using-the-buildkite-interface) or [REST API](#filter-tests-using-the-rest-api).

### Using the Buildkite interface

On the test suite's **Tests** page, either:

- Enter `label:labelname` in the search field and select **Search**.
- For any existing test with at least one label applied to it, select the test's label > **Filter by** from its drop down to filter the test suite for all tests with that label applied to them.

<%= image "filtering.png", width: 1130, height: 514, alt: "Screenshot of filtering by a test label" %>

### Using the REST API

You can fetch all tests with a label using the [REST API](/docs/apis/rest-api) with the [Tests API](/docs/apis/rest-api/test-engine/tests) endpoint. Learn more about this in [List tests](/docs/apis/rest-api/test-engine/tests#list-tests), and by specifying the optional `label` query string parameter.
