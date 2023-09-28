# Pipeline templates

> 📘 Enterprise feature
> Pipeline templates are only available on an [Enterprise](https://buildkite.com/pricing) plan.

## Overview

Pipeline templates allow you to define standard pipeline step configurations to use across all the pipelines in your organization.

When a pipeline has a template assigned, the pipeline inherits its step configuration from the template.

Before assigning a template to a pipeline, you need to mark that template available for use in your organization.

## Creating a pipeline template

Only administrators can create or update pipeline templates through the Buildkite UI or the REST and GraphQL APIs.

To create a template:

1. Navigate to your [organization’s pipeline templates](https://buildkite.com/organizations/-/pipeline-templates).
1. If this is your first template, select _Create a Template_. Otherwise, select _New Template_.
1. Enter the name and description for your new template.
1. Update the default step configuration.
1. Select _Create Template_.
1. Mark it as available if you would like everyone in your organisation to see it while creating pipelines or editing step configuration of pipelines

An administrator can add multiple templates to use across the organization. Making changes and saving a template will apply those changes to all pipelines using that template.

As an administrator you do not need to mark a template available to see it in the available templates dropdown. You will be able to see all the templates you created while creating a new build, creating a new pipeline or editing steps for an existing pipeline.

## Testing a pipeline template

An administrator can test a pipeline template against a pipeline using the _New Build_ button on the pipeline page.

If a template exists for the organization, it can be selected from the _Pipeline template_ dropdown to create a new build using the step configuration from that template.

## Requiring pipeline templates

The power of pipeline templates comes from how much you require their use. Administrators can select from the following options, listed in increasing strictness:

1. **Do not require pipeline templates:** Pipeline steps remain editable for any user with permission to create or update a pipeline. Templates can be assigned to pipelines if they were marked as available. This is the best option if you would like to have templates to be more like starting guides for users in your organisation so they can create pipelines faster.
1. **Require a pipeline template on new pipelines:** A template must be selected when creating a new pipeline. The step configuration of existing pipelines will become read-only. Pipelines can be assigned a template individually, making a gradual migration to pipeline templates possible.
1. **Requiring a pipeline template for everything:** Templates are mandatory on all new and existing pipelines. When choosing this setting, you will select a pipeline template to apply to any pipeline that does not already have a template assigned.

To change your organization's requirements for pipeline templates:

1. Navigate to your [organization's pipeline templates](https://buildkite.com/organizations/-/pipeline-templates).
1. Check you have at least one template. If you don't have a template, create one.
1. Select _Settings_.
1. Select the requirement you want to set.

If you stop requiring templates for your organisation, all the pipelines that had assigned templates will keep using templates until you change their settings to not require them anymore.

## Assigning a pipeline template to a pipeline

After an administrator marks a template available for use, anyone with permission to create or change a pipeline can assign a template. Assigning a template overrides the pipeline's step configuration with the template.

You can use the following methods to assign a template to individual pipelines:

- On the step settings for the pipeline (_Pipeline_ > _Settings_ > _Steps_), select the template to assign.
- Using the REST API, [update the pipeline](https://buildkite.com/docs/apis/rest-api/pipelines#update-a-pipeline) with the appropriate `pipeline_template_uuid`.
- Using the GraphQL API, run the [`pipelineUpdate` mutation](https://buildkite.com/docs/apis/graphql/schemas/mutation/pipelineupdate) with the appropriate `pipelineTemplateId`.

You can find the IDs in the GET methods from the REST and GraphQL APIs.

>📘 Web steps editor compatibility
> Pipelines defined using the web steps editor cannot be assigned templates through the Buildkite dashboard. These pipelines must be either [migrated to YAML steps first](https://buildkite.com/docs/tutorials/pipeline-upgrade), updated using the APIs, or bulk-assigned a template when selecting the _Require a pipeline template for everything_ setting.
