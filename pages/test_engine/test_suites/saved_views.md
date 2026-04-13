# Saved views

Saved views let you create, name, and easily access custom test views within Buildkite Test Engine. This is useful for teams who frequently search using the same set of tags or labels.

You can create saved views from three locations:

- The test suite's **Summary** page in Test Engine
- The test suite's **Tests** page in Test Engine
- The **Tests** tab on a build page in [Buildkite Pipelines](/docs/pipelines)

Saved views created from any of these locations are shared across the organization or test suite and visible to all users.

## Creating views from the Summary or Tests page

1. On the test suite's **Summary** or **Tests** page, select **Filter**, then select as many filter values as you would like.
1. Select **Display**, then select the columns you would like to appear in your view.
1. Select **Save** in the filter bar.
1. Select one of the following options:
    + **Save as default view:** Available on the **Summary** page only. Sets the view as the default for the test suite.
    + **Create a new view:** Available on both the **Summary** and **Tests** pages. Give your view a name, then select **Save view**.

<%= image "saved-views-test-index.png", width: 3144/2, height: 988/2, alt: "Screenshot of test index saved view" %>

## Creating views from the build Tests tab

You can also create a default saved view directly from the **Tests** tab on a build page.

> 📘
> This is only available to admin users.

1. Navigate to a build page and select the **Tests** tab.
1. Select **Filter**, then select your desired filter values.
1. Select **Display**, then select the columns you would like to appear in your view.
1. Select **Save** in the filter bar.
1. Select **Save as default view**.

This view will now be the default **Tests** tab view for all builds in your organization.

## Deleting views

Saved views can be deleted from the test suite's settings:

1. Navigate to the test suite's **Settings** > **Saved Views**.
1. On the view to be deleted, select its **Delete** button.
