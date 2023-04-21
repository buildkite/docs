# Build retention

Each [Buildkite plan](https://buildkite.com/pricing) has a maximum build retention period. Once your builds reach the retention period, they will be removed from Buildkite.


## Retention periods

<table width="100%">
  <thead>
    <tr>
      <th>Plan</th>
      <th>Retention period</th>
      <th>Supports build exports</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>Developer/Free Plan</strong></td>
      <td>90 days</td>
      <td>-</td>
    </tr>
    <tr>
    <tr>
      <td><strong>Open Source Plan</strong></td>
      <td>1 year</td>
      <td>-</td>
    </tr>
    <tr>
      <td><strong>Non-Profits & Charities Plan</strong></td>
      <td>1 year</td>
      <td>-</td>
    </tr>
      <td><strong>Team Plan</strong></td>
      <td>1 year</td>
      <td>-</td>
    </tr>
    <tr>
      <td><strong>Business Plan</strong></td>
      <td>1 year</td>
      <td>-</td>
    </tr>
    <tr>
      <td><strong>Enterprise Plan</strong></td>
      <td>1 year</td>
      <td>Yes</td>
    </tr>
  </tbody>
</table>


## Exporting build data
> 📘 Enterprise feature
> Exporting build data is only available on an [Enterprise](https://buildkite.com/pricing) plan.

If you need to retain build data beyond the retention period in your [Buildkite plan](https://buildkite.com/pricing), you can have Buildkite export the data to a private Amazon S3 bucket. As build data is removed, Buildkite exports JSON representations of the builds to the Amazon S3 bucket you provide. [Learn more about Build exports](/docs/pipelines/build-exports).

<%= image "build-retention-flow-chart.png", alt: "Simplified flow chart of the build retention process" %>
