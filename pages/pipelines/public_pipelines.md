# Public pipelines

If you're working on an open-source project, and want the whole world to be able to see your builds, you can make your pipeline public.


Making a pipeline public provides read-only public/anonymous access to:

- Pipeline build pages
- Pipeline build logs
- Pipeline build artifacts
- Pipeline build environment config
- Agent version and name

## Make a pipeline public using the UI

Make a pipeline public in the pipeline's **Settings** > **General** page:

<%= image "settings.png", width: 1960/2, height: 630/2, alt: "Public pipeline settings" %>

## Create a public pipeline using the GraphQL API

Use the following mutation in the [GraphQL API](/docs/apis/graphql-api) to create a new public pipeline:

```graphql
mutation {
  pipelineCreate(input: {
    organizationId: $organizationID,
    name: $pipelineName,
    visibility: PUBLIC,
    repository: {
      url: "git@github.com:blerp/goober.git"
    },
    steps: {
      yaml: "steps:\n- command: true"
    }
  }) {
    pipeline {
      public  # true
      visibility # PUBLIC
      organization {
        public # true
      }
    }
  }
}
```
