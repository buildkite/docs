# Pipeline templates

> 📘 Enterprise feature
> Pipeline templates is only available on an [Enterprise](https://buildkite.com/pricing) plan.

## Overview

Pipeline templates allow you to define standard pipeline step configurations to be used by all the pipelines in your organization.

When a pipeline has a pipeline template assigned to it, the step configuration for that pipeline is inherited from the template and it is no longer possible to configure a custom step configuration for that pipeline via the UI.

## Creating a pipeline template

Only administrators can create or update pipeline templates.

1. Open your Buildkite _Organization Settings_ and choose [Templates](https://buildkite.com/organizations/-/pipeline-templates)
1. If this is your first template, click _Create a Template_. Otherwise choose _New Template_. A pipeline template is created automatically for you.
1. Update the name and description of your new template and click _Apply_ to save your changes.
1. You can also click _Edit_ to change the step configuration for the template.

An administrator can add multiple templates to be used across the organization. Making changes and saving a template will apply those changes to all pipelines using that template.

## Testing a pipeline template

At any time an administrator may test a pipeline template against a pipeline via the _New Build_ button on the pipeline page.

If a template exists for the organization then it can be selected from the _Pipeline template_ dropdown to create a new build using the step configuration from that template.

## Assigning a pipeline template to a pipeline

To permanently override a pipeline's step configuration with a pipeline template, administrators must first require pipeline templates via settings (see next section).

Once pipeline templates are required, there are three options for assigning a template to individual pipelines:

1. Selecting the template on the step settings for that pipeline (_Pipeline_ > _Settings_ > _Steps_).
1. Using the REST API to [update the pipeline](https://buildkite.com/docs/apis/rest-api/pipelines#update-a-pipeline) with the appropriate `pipeline_template_uuid`.
1. Using the GraphQL API [pipelineUpdate mutation](https://buildkite.com/docs/apis/graphql/schemas/mutation/pipelineupdate) with the appropriate `pipelineTemplateId`.

The correct IDs to use with the APIs for a template can be found on the template page in the UI.

> Note that pipelines that have not been setup using YAML steps cannot be assigned a pipeline template via the UI.
> These pipelines must be either [migrated to YAML steps first](https://buildkite.com/docs/tutorials/pipeline-upgrade), updated via the APIs, or bulk-assigned a template when selecting the _Require a pipeline template for everything_ setting.

## Requiring pipeline templates

To change your organizations pipeline template settings, first make sure you have created at least one pipeline template.

Navigate to your Buildkite _Organization Settings_ and choose _Templates_ > [Settings](https://buildkite.com/organizations/-/pipeline-templates/settings).

Three options are available:

- **Do not require pipeline templates** <br />
  Pipeline steps remain editable for any user that has permission to create or update a pipeline. Templates can be tested against pipelines but cannot be assigned to them.

- **Require a pipeline template on new pipelines** <br />
  A template must be selected when creating a new pipeline. The step configuration of existing pipelines will become read only. Pipelines can be assigned a template individually, making a gradual migration to pipeline templates possible.
- **Requiring a pipeline template for everything** <br />
  Templates are mandatory on all new and existing pipelines. When choosing this setting you will select a pipeline template that will be applied to any pipeline that does not already have a template assigned.

> Note that once a setting has applied you cannot revert to a more permissive setting. Take care to test your pipeline templates before enforcing them on all pipelines.
