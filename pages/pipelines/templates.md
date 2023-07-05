# Pipeline templates

> 📘 Enterprise feature
> Pipeline templates are only available on an [Enterprise](https://buildkite.com/pricing) plan.

## Overview

Pipeline templates allow you to define standard pipeline step configurations to use across all the pipelines in your organization.

When a pipeline has a template assigned, the pipeline inherits its step configuration from the template. Configuring a custom step configuration for that pipeline in the Buildkite dashboard is no longer possible.

## Creating a pipeline template

Only administrators can create or update pipeline templates.

To create a template:

1. Navigate to your [organization’s pipeline templates](https://buildkite.com/organizations/-/pipeline-templates).
1. If this is your first template, select _Create a Template_. Otherwise, select _New Template_.
1. Enter the name and description for your new template, update the default step configuration and select _Create Template_ to create the template.

An administrator can add multiple templates to use across the organization. Making changes and saving a template will apply those changes to all pipelines using that template.

## Testing a pipeline template

An administrator can test a pipeline template against a pipeline using the _New Build_ button on the pipeline page.

If a template exists for the organization, it can be selected from the _Pipeline template_ dropdown to create a new build using the step configuration from that template.

## Requiring pipeline templates

The power of pipeline templates comes from how much you require their use. Administrators can select from the following options, listed in increasing strictness:

1. **Do not require pipeline templates:** Pipeline steps remain editable for any user with permission to create or update a pipeline. Templates can be tested (by administrators) against pipelines but cannot be assigned to them.
1. **Require a pipeline template on new pipelines:** A template must be selected when creating a new pipeline. The step configuration of existing pipelines will become read-only. Pipelines can be assigned a template individually, making a gradual migration to pipeline templates possible.
1. **Requiring a pipeline template for everything:** Templates are mandatory on all new and existing pipelines. When choosing this setting, you will select a pipeline template to apply to any pipeline that does not already have a template assigned.

>🚧 Changing requirements
> When updating the requirements, you can only update the setting to an option that is more strict. Take care to test your pipeline templates before enforcing them on all pipelines.

To change your organization's requirements for pipeline templates:

1. Navigate to your [organization's pipeline templates](https://buildkite.com/organizations/-/pipeline-templates).
1. Check you have at least one template. If you don't have a template, create one.
1. Select _Settings_.
1. Select the requirement you want to set.

## Assigning a pipeline template to a pipeline

After an administrator requires pipelines to use a template, anyone with permission to create or change a pipeline can assign a template. Assigning a template overrides the pipeline's step configuration with the template.

Once pipeline templates are required, you can use the following methods to assign a template to individual pipelines:

- On the step settings for the pipeline (_Pipeline_ > _Settings_ > _Steps_), select the template to assign.
- Using the REST API, [update the pipeline](https://buildkite.com/docs/apis/rest-api/pipelines#update-a-pipeline) with the appropriate `pipeline_template_uuid`.
- Using the GraphQL API, run the [`pipelineUpdate` mutation](https://buildkite.com/docs/apis/graphql/schemas/mutation/pipelineupdate) with the appropriate `pipelineTemplateId`.

You can find the IDs to use for a template with the APIs on the template page in the Buildkite dashboard.

>📘 Web steps editor compatibility
> Pipelines defined using the web steps editor cannot be assigned templates through the Buildkite dashboard. These pipelines must be either [migrated to YAML steps first](https://buildkite.com/docs/tutorials/pipeline-upgrade), updated using the APIs, or bulk-assigned a template when selecting the _Require a pipeline template for everything_ setting.
