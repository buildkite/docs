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

## Configuring build backups

> 📘 Enterprise feature
> Build backups is only available on an [Enterprise](https://buildkite.com/pricing) plan.

If you require to keep builds longer than your [Buildkite plan](https://buildkite.com/pricing)
allows you can setup build backups using your private Amazon S3 bucket.

Select organization settings

<%= image "organization-settings.png", width: 1404/2, height: 1608/2, alt: "Screenshot of the 'Build' settings" %>

From the Organization Settings menu, select Settings under the Pipelines heading

<%= image "organization-pipeline-settings.png", width: 1404/2, height: 1608/2, alt: "Screenshot of the 'Build' settings" %>

Then, under the *Back Up Builds to S3 pane*, you can input your private Amazon S3 bucket location and
click *Enable Backup*.
