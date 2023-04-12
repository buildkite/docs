# Configuring build export

Each [Buildkite plan](https://buildkite.com/pricing) has a maximum build retention
period, after which your oldest builds will be automatically deleted.

> 📘 Enterprise feature
> Build export is only available on an [Enterprise](https://buildkite.com/pricing) plan.

If you need to retain build data beyond the retention period in your [Buildkite plan](https://buildkite.com/pricing), you can have Buildkite export the data to a private Amazon S3 bucket. As build data is removed, Buildkite exports JSON representations of the builds to the Amazon S3 bucket you provide.

To enable build exports:

1. Navigate to your [organization's pipeline settings](https://buildkite.com/organizations/~/pipeline-settings).
1. In the _Export Build Data to S3_ section, enter the URL for the Amazon S3 bucket to use.
1. Select _Enable Export_.
