# Labels

Use labels to categorize tests.

<%= image "labelling.png", width: 938, height: 349, alt: "Screenshot of a test with labels categorizing the test" %>

Labels allow you to organize tests in a way that is most meaningful to your
team and organization. They can be used to filter and aggregate tests within
Test Engine.

Labels are created at the suite level, so labels belonging to one suite won't
impact other suites.

## Labelling a test

Labels may be applied to tests using the following methods:

### Via UI

From the test page select **add labels** and either pick from the existing labels
used in the suite or create a new label and select a color.

### Via workflow automation

Using test state you can automate adding and removing labels when the the
threshold is triggered or resolved respectively.

See [automatic quarantine](/docs/test-engine/test-state-and-quarantine#automatic-quarantine) to learn more.

### Via execution tags

Test execution tag values can be applied as a label on the Test.

When Test Engine detects a change to the tag value it will update the label on the respective test.

Test Engine will only label tests based on execution tags when configured to do so in the suite settings under **test labels**.

<%= image "execution_tags.png", width: 1547, height: 604, alt: "Screenshot of configuring suite settings to copy tags to labels" %>

See [Tags](/docs/test-engine/tags) to learn more about execution tagging.

### Via API

You can label tests via the API, to learn more see the [Label API](/docs/apis/rest-api/test-engine/tests#add-slash-remove-labels-from-a-test).

## Filtering

Filtering tests by label by either entering `label:{labelname}` in the search bar of the test index or
by selecting **filter by** in the label drop down on the test.

<%= image "filtering.png", width: 1130, height: 514, alt: "Screenshot of filtering by a test label" %>

### Via API

You can fetch all tests with a label via the API, to learn more see the [Label API](/docs/apis/rest-api/test-engine/tests#list-tests).
