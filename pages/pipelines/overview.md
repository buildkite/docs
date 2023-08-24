---
toc: false
---

# Pipeline configuration overview

## What is a pipeline?

A pipeline is a template of the steps you want to run. There are many types of steps, some run scripts, some define conditional logic, and others wait for user input. When you run a pipeline, a build is created. Each of the steps in the pipeline end up as jobs in the build, which then get distributed to available agents.

## Is this only for running tests and deploying code?

Not at all! You can do all kinds of exciting things with pipelines, like generating static sites, running data imports, provisioning servers, and automating app store submissions. You can even use pipelines to [create other pipelines](/docs/pipelines/uploading-pipelines) 😱
