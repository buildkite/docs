# Passing Build Metadata as Environment Variables

## Overview

This section shall showcase and present the overview of the piece of functionality that is being explored, and any potential callouts/prerequisites/links.

## Option 1: Via the `trigger` env attribute

Utilising a [trigger step](/docs/pipelines/trigger-step) - Environment variables are able to be defined as parameters that will be present in the corresponding triggered builds that are kicked off.

### Step 1. Create the Pipeline YAML

Create a `pipeline.yml` that includes a `trigger` step. Below is a snippet of a triggering pipeline that triggers a subsequent pipeline called `pipeline-b` and sets a `EXAMPLE_ENVIRONMENT_VARIABLE` in the `build` attribute (underneath `env`).

```
steps:
  - label: "Triggering Pipeline B"
    trigger: pipeline-b
    branches: master
    build:
      env:
        EXAMPLE_ENVIRONMENT_VARIABLE: 123
```

>🚧 The `trigger` parameter
> The [kebab-case](https://en.wikipedia.org/wiki/Letter_case#Kebab_case) slug of the pipeline is required when passing it to the `trigger` step. This can be found in the URL of the pipeline when viewed in a browser.

The steps of `pipeline-b` can be anything at this point: its only what is desired to be passed to a build of it as environment variables that counts!

### Step 2. Run the triggering Pipeline

In Step 1 above, the triggering pipeline sets the `EXAMPLE_ENVIRONMENT_VARIABLE` to value `123`. Run a new build with a desired message once the pipeline has been saved.

<%= image "running-triggering-pipeline.png", alt: "Running the triggering Pipeline" %>

When the new builld of the triggering pipeline is created, the `trigger` step will execute and will contain a clickable link to `pipeline-b` once it is triggered.

<%= image "pipeline-b-triggered.png", alt: "Triggered Pipeline B" %>

### Step 3. View the Environment variables of the triggered Pipeline

Pipeline B's (with slug `pipeline-b`) triggered build will be clickable from Step 2 - and will state that the build was "Triggered From Pipeline" in the main information panel 

<%= image "triggered-from-pipeline-label.png", alt: "Triggered From Pipeline label" %>

Inspecting a step of `pipeline-b`, the passed environment variable will be stated and available to utilise along with the standard array:

<%= image "env-var-passed-through.png", alt: "Passed through environment variable" %>

### Additional Information

- Utilising the passed through Environment variable will need interpolation if needing to use it at build time.
- [Additional parameters](/docs/pipelines/trigger_step#trigger-step-attributes) for the `trigger` step exist which can be specified along the example given in Step 1.

## Method 2 - Utilising Dynamic Pipelines

To be filled with steps

### Additional Information

- Dot point 1
- Dot point 2

