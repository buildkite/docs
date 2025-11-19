# Webhook integrations

There are a number of third party services you can use with Buildkite webhooks. Some services (such as RequestBin and Zapier) are designed specifically with webhooks in mind, and others (such as AWS Lambda and Google Cloud Functions) are general purpose programming platforms which can be triggered with webhook HTTP requests.

## AWS Lambda

[AWS Lambda](https://aws.amazon.com/lambda/) is a service for running functions, and when combined with [AWS API Gateway](https://aws.amazon.com/api-gateway/), can be used to process your Buildkite webhooks.

There are many ways to integrate webhooks with AWS Lambda. The following repositories demonstrate two ways to process Buildkite webhooks using AWS Lambda:

- Rivet's [buildkite-webhook-aws-terraform](https://github.com/rivethealth/buildkite-webhook-aws-terraform) uses [AWS Lambda](https://aws.amazon.com/lambda/) and [AWS API Gateway](https://aws.amazon.com/api-gateway/) to publish Buildkite webhook events to an [AWS SNS](https://aws.amazon.com/sns/) topic.
- Rivet's [buildkite-bitbucket-aws-terraform](https://github.com/rivethealth/buildkite-bitbucket-aws-terraform) demonstrates using [AWS Lambda](https://aws.amazon.com/lambda/), [AWS API Gateway](https://aws.amazon.com/api-gateway/) and [AWS SNS](https://aws.amazon.com/sns/) to send build statuses to an Atlassian Bitbucket Server.

## Google Cloud Run functions

[Google Cloud Run functions](https://cloud.google.com/functions) is a Google Cloud service for hosted code execution, and also supports exposing functions using URLs. See Google Cloud Run's [When should I deploy a function to Cloud Run?](https://docs.cloud.google.com/run/docs/functions-with-run) documentation for more information about its use cases, as well as their Quickstart guides on how to deploy a web app to Cloud Run (for example, [Node.js](https://docs.cloud.google.com/run/docs/quickstarts/build-and-deploy/deploy-nodejs-service)) to get started, and a Cloud Run function using the [Google Cloud console](https://docs.cloud.google.com/run/docs/quickstarts/functions/deploy-functions-console) or [gcloud CLI](https://docs.cloud.google.com/run/docs/quickstarts/functions/deploy-functions-gcloud).

## Zapier

[Zapier](https://zapier.com/) is a system for connecting APIs together, and has built in support for hundreds of services. For example, you could use Zapier to send an email when a build has finished, save a build artifact into a Dropbox folder, or post to a Slack room substituting values such as the build URL and number into the message body.

To use Buildkite webhooks with Zapier create a new Zap and select Webhook.
