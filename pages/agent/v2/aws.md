# Running Buildkite Agent on AWS

>🚧 This page references the out-of-date Buildkite Agent v2.
> For docs referencing the Buildkite Agent v3, <a href="/docs/agent/v3/aws">see the latest version of this document</a>.

The Buildkite Agent can be run on AWS using our Elastic CI Stack for AWS.

{:toc}

## Install the agent on your own AWS instance

To run the agent on your own AWS instances use whichever installer matches your
instance type. For Amazon Linux use the [Red Hat/CentOS installer].

## Use our pre-built Elastic CI Stack for AWS

The [Elastic CI Stack for AWS][github] is a pre-built CloudFormation template
that gives you an autoscaling Buildkite Agent cluster in your own AWS. The
stack includes Docker, S3 and CloudWatch integration, and is suitable for
parallelizing large legacy test suites, testing any Linux-based project that can run within Docker, and performing AWS ops related tasks.

[Read the documentation][github] on GitHub, and launch it using the
button on your organization's Agents page.

   [github]: https://github.com/buildkite/elastic-ci-stack-for-aws
   [Red Hat/CentOS installer]: /docs/agent/v2/redhat
