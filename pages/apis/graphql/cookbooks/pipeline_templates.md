# Pipeline templates

A collection of common tasks with pipeline templates using the GraphQL API.

You can test out the Buildkite GraphQL API using the [Buildkite explorer](https://graphql.buildkite.com/explorer). This includes built-in documentation under the _Docs_ panel.

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

## Updating a pipeline template

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

## Deleting a pipeline template

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

## Managing pipeline template assignment on a pipeline

Admins and users with manage pipeline permissions can assign a pipeline template to a pipeline using the `pipelineUpdate` mutation:

```graphql
mutation AssignPipelineTemplate {
  pipelineUpdate(input: {
    id: 'pipeline-id'
    pipelineTemplateId: 'pipeline-template-id'
  }) {
    pipeline {
      id
      name
      pipelineTemplateId
    }
  }
}
```

Conversely, pipeline templates can be removed from a pipeline by specifying `pipelineTemplateId` as `null` in the mutation input:

```graphql
mutation AssignPipelineTemplate {
  pipelineUpdate(input: {
    id: 'pipeline-id'
    pipelineTemplateId: null
  }) {
    pipeline {
      id
      name
      pipelineTemplateId
    }
  }
}
```
