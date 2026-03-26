# Manage teams

The [Buildkite Terraform provider](/docs/platform/terraform-provider) supports managing [teams](/docs/platform/team-management/permissions) and their members as Terraform resources. This page covers how to define and configure these resources in your Terraform configuration files.

## Define your team resources

Define resources for the [teams](/docs/platform/team-management/permissions) in your Buildkite organization that you want to manage in Terraform, in HCL (for example, `teams.tf`).

The `buildkite_team` resource is used to create and manage teams. Each team requires a `name`, `privacy`, `default_team`, and `default_member_role` argument, and can optionally include a `description`.

In the following example, the **Platform** and **Frontend** teams will be created with `terraform plan` and `terraform apply`.

```hcl
# Define the platform team
resource "buildkite_team" "platform" {
  name                         = "Platform"
  description                  = "Platform team responsible for infrastructure."
  privacy                      = "VISIBLE"
  default_team                 = false
  default_member_role          = "MEMBER"
  members_can_create_pipelines = true
}

# Define the frontend team
resource "buildkite_team" "frontend" {
  name                = "Frontend"
  description         = "Frontend team responsible for frontend development projects."
  privacy             = "VISIBLE"
  default_team        = false
  default_member_role = "MEMBER"
}
```

The required arguments for each team are:

- `name`: The name of the team.
- `privacy`: The visibility of the team, either `VISIBLE` (all organization members can see the team) or `SECRET` (only team members and organization administrators can see the team).
- `default_team`: Makes this team the default for new Buildkite organization members. Set to `true` to automatically add new users to this team, or `false` if otherwise.
- `default_member_role`: The role assigned to new team members, either `MEMBER` or `MAINTAINER`.

You can also optionally set the following arguments to control what team members can do:

- `members_can_create_pipelines` with a value of `true` to allow team members to create pipelines.
- `members_can_create_suites` with a value of `true` to allow team members to create test suites.
- `members_can_create_registries` with a value of `true` to allow team members to create package registries.
- `members_can_destroy_registries` with a value of `true` to allow team members to destroy package registries.
- `members_can_destroy_packages` with a value of `true` to allow team members to destroy packages.

If you don't have any pre-existing teams in your Buildkite organization but want to associate a pipeline in your [pipeline resources (`pipelines.tf` file)](/docs/platform/terraform-provider/getting-started-with-managing-pipelines#define-your-initial-pipeline-resources) with new teams managed by the Terraform provider, you can define the new teams in your team resources (`teams.tf`) file and reference it from the pipeline resource's `default_team_id` argument, along with [any other teams to add to your pipelines](/docs/platform/terraform-provider/getting-started-with-managing-pipelines#add-any-other-teams-to-your-pipelines).

Following on from the [pipeline resources example](/docs/platform/terraform-provider/getting-started-with-managing-pipelines#define-your-initial-pipeline-resources), if you wanted to make the **Frontend** team the initial owner of **Frontend pipeline** instead of **Engineering**, you would change this pipeline resource's `default_team_id` argument's value to `data.buildkite_team.frontend.id`. If no pipelines under Terraform management are accessed by the **Engineering** team, you could remove its data source from your pipeline resources `pipelines.tf` file. You can also add more teams to pipelines—see [Add any other teams to your pipelines](/docs/platform/terraform-provider/getting-started-with-managing-pipelines#add-any-other-teams-to-your-pipelines) for details.

Learn more about this resource in the [`buildkite_team` resource](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs/resources/team) documentation.

## Add members to a team

Use the `buildkite_team_member` resource to add existing organization users to a team. Each team member requires a `team_id`, `user_id`, and `role`.

The `user_id` is the GraphQL ID of the user, which you can obtain using the following GraphQL query:

```graphql
query {
  organization(slug: "your-buildkite-org-slug") {
    members(first: 100) {
      edges {
        node {
          user {
            id
            name
            email
          }
        }
      }
    }
  }
}
```

In the following example, two users are added to the **Frontend** team defined above:

```hcl
# Add a user as a team member
resource "buildkite_team_member" "alice" {
  team_id = buildkite_team.frontend.id
  user_id = "user-graphql-id-for-alice"
  role    = "MEMBER"
}

# Add a user as a team maintainer
resource "buildkite_team_member" "bob" {
  team_id = buildkite_team.frontend.id
  user_id = "user-graphql-id-for-bob"
  role    = "MAINTAINER"
}
```

The `role` argument can be either `MEMBER` (standard team member) or `MAINTAINER` (can manage team settings and membership).

Learn more about this resource in the [`buildkite_team_member` resource](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs/resources/team_member) documentation.

## Verify your completed configuration

The following example shows a complete team configuration with two teams, member permissions, and team membership:

```hcl
# Define the platform team
resource "buildkite_team" "platform" {
  name                         = "Platform"
  description                  = "Platform team responsible for infrastructure."
  privacy                      = "VISIBLE"
  default_team                 = false
  default_member_role          = "MEMBER"
  members_can_create_pipelines = true
}

# Define the frontend team
resource "buildkite_team" "frontend" {
  name                = "Frontend"
  description         = "Frontend team responsible for frontend development projects."
  privacy             = "VISIBLE"
  default_team        = false
  default_member_role = "MEMBER"
}

# Add members to the frontend team
resource "buildkite_team_member" "alice" {
  team_id = buildkite_team.frontend.id
  user_id = "user-graphql-id-for-alice"
  role    = "MEMBER"
}

resource "buildkite_team_member" "bob" {
  team_id = buildkite_team.frontend.id
  user_id = "user-graphql-id-for-bob"
  role    = "MAINTAINER"
}

# Add a member to the platform team
resource "buildkite_team_member" "charlie" {
  team_id = buildkite_team.platform.id
  user_id = "user-graphql-id-for-charlie"
  role    = "MEMBER"
}
```

## Further reference

For the full list of team resources, data sources, and their configuration options, see the [Buildkite provider documentation](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs) on the Terraform Registry.
