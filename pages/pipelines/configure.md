# Pipeline configuration overview

Pipelines are the top level containers for modelling and defining your workflows. Connecting pipelines to your source control allows you to run builds when your code changes. You can run anything with a Buildkite pipeline! 🚀

## What is a pipeline?

A pipeline is a template of the steps you want to run. There are many types of steps, some run scripts, some define conditional logic, and others wait for user input. When you run a pipeline, a build is created. Each of the steps in the pipeline end up as jobs in the build, which then get distributed to available agents.

## Is this only for running tests and deploying code?

Not at all! You can do all kinds of exciting things with pipelines, like generating static sites, running data imports, provisioning servers, and automating app store submissions. You can even use pipelines to [create other pipelines](/docs/pipelines/uploading-pipelines) 😱

## Where's the best place to start?

If you've completed [Getting started](/docs/pipelines/getting-started) and are looking to learn more about pipelines, we recommend you start with the following:

- [Example pipelines](/docs/pipelines/configure/example-pipelines): Browse examples for various technologies and use cases.
- [Defining steps](/docs/pipelines/configure/defining-steps): Learn how to write pipeline definitions.
- [Step types](/docs/pipelines/configure/step-types): See the actions you can take in a pipeline.
- [Environment variables](/docs/pipelines/configure/environment-variables): All the variables you can access in the build environment.
