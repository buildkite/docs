# Build retention

Each [Buildkite plan](https://buildkite.com/pricing) has a maximum build retention
period, after which your oldest builds will be automatically deleted.


Depending on your plan, you can configure your pipeline to retain builds for
a certain period of time.

You may also choose to retain a minimum number of the latest builds, so you
don't lose context on pipelines that don't move quite so fast.

## Default settings

<table width="100%">
  <thead>
    <tr>
      <th>Plan</th>
      <th>Default Retention for new pipelines</th>
      <th>Options Available</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">Developer Plan & Trial</th>
      <td>30 days</td>
      <td>30 days</td>
    </tr>
    <tr>
      <th scope="row">Team Plan</th>
      <td>6 months</td>
      <td>30 days<br/>60 days<br/>90 days<br/>3 months<br/>6 months</td>
    </tr>
    <tr>
      <th scope="row">Business Plan</th>
      <td>12 months</td>
      <td>30 days<br/>60 days<br/>90 days<br/>3 months<br/>6 months<br/>12 months</td>
    </tr>
    <tr>
      <th scope="row">Enterprise Plan</th>
      <td>2 years</td>
      <td>30 days<br/>60 days<br/>90 days<br/>3 months<br/>6 months<br/>12 months<br/>2 years</td>
    </tr>
  </tbody>
</table>

## Configuring build retention

From the pipeline page, select pipeline settings

<%= image "settings.png", width: 2028/2, height: 880/2, alt: "Screenshot of the pipelines settings button" %>

From the Pipeline Settings menu, select Builds.

Then, under the Build Retention pane, you can select a Build Retention Period
up to the maximum build retention period your plan offers.

<%= image "builds.png", width: 1404/2, height: 1608/2, alt: "Screenshot of the 'Build' settings" %>

## Configuring build export

> 📘 Enterprise feature
> Build export is only available on an [Enterprise](https://buildkite.com/pricing) plan.

If you need to retain build data beyond the retention period in your [Buildkite plan](https://buildkite.com/pricing), you can have Buildkite export the data to a private Amazon S3 bucket. As build data is removed, Buildkite exports JSON representations of the builds to the Amazon S3 bucket you provide.

To enable build exports:

1. Navigate to your [organization's pipeline settings](https://buildkite.com/organizations/~/pipeline-settings).
1. In the _Export Build Data to S3_ section, enter the URL for the Amazon S3 bucket to use.
1. Select _Enable Export_.
