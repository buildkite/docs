# Pipeline templates

A collection of common tasks with pipeline templates using the GraphQL API.

<%= render_markdown partial: 'apis/graphql/cookbooks/graphql_console_link' %>

## List pipeline templates

Get the first 10 pipeline templates and their information for an organization:

```graphql
query GetPipelineTemplates {
  organization(slug: "organization-slug") {
    pipelineTemplates(first: 10) {
      edges {
        node {
          id
          uuid
          name
          description
          configuration
          available
        }
      }
    }
  }
}
```

## Get a pipeline template

Get information on a pipeline template, specifying the pipeline templates' UUID as the `uuid` argument of the `pipelineTemplate` query:

```graphql
query GetPipelineTemplate {
  pipelineTemplate(uuid: "pipeline-template-uuid") {
    id
    uuid
    name
    description
    configuration
    available
  }
}
```

## Create a pipeline template

Create a pipeline template for an organization using the `pipelineTemplateCreate` mutation:

```graphql
mutation CreatePipelineTemplate {
  pipelineTemplateCreate(input: {
    organizationId: "organization-id",
    name: "template name",
    description: "it does a thing",
    configuration: "steps:\n  - command: deploy.sh",
    available: false
  }) {
    pipelineTemplate {
      id
      uuid
      name
      description
      configuration
      available
    }
  }
}
```

## Update a pipeline template

Update a pipeline template on an organization using the `pipelineTemplateUpdate` mutation, specifying the ID for organization and pipeline template:

```graphql
mutation UpdatePipelineTemplate {
  pipelineTemplateUpdate(input: {
    organizationId: "organization-id",
    id: "pipeline-template-id",
    configuration: "steps:\n - comand: updated_steps.sh"
    available: true
  }) {
    pipelineTemplate {
      id
      uuid
      name
      description
      configuration
      available
    }
  }
}
```

## Delete a pipeline template

Delete a pipeline template using the `pipelineTemplateDelete` mutation, specifying the ID for organization and pipeline template:

```graphql
mutation DeletePipelineTemplate {
  pipelineTemplateDelete(input: {
    organizationId: "organization-id",
    id: "pipeline-template-id"
  }) {
    deletedPipelineTemplateId
  }
}
```

## Assign a template to a pipeline

Admins and users with permission to manage pipelines can assign a pipeline template to a pipeline using the `pipelineUpdate` mutation:

```graphql
mutation AssignPipelineTemplate {
  pipelineUpdate(input: {
    id: "pipeline-id"
    pipelineTemplateId: "pipeline-template-id"
  }) {
    pipeline {
      id
      name
      pipelineTemplate {
        id
      }
    }
  }
}
```

## Remove a template from a pipeline

Admins and users with permission to manage pipelines can remove from a pipeline by specifying `pipelineTemplateId` as `null` in the mutation input:

```graphql
mutation UnassignPipelineTemplate {
  pipelineUpdate(input: {
    id: "pipeline-id"
    pipelineTemplateId: null
  }) {
    pipeline {
      id
      name
      pipelineTemplate {
        id
      }
    }
  }
}
```
