# Test ownership

Customers on the [Pro and Enterprise plans](https://buildkite.com/pricing) can assign test ownership to [Teams](/docs/team-management/permissions).

Test ownership is assigned to the tests in a specific suite per instructions in your TESTOWNER file. The team that is the default owner of a test [will be auto-assigned to fix any flakes](/docs/test-analytics/flaky-test-assignment) that occur.

> 🚧 Buildkite test ownership is currently in private beta
> Please reach out to our support team to register for early access.

## Setting test ownership

You can upload a TESTOWNER file via this API endpoint:

```bash
curl --location 'https://analytics-api.buildkite.com/v1/test-ownerships' \
     --header "Authorization: Bearer <your-suite-api-token>" \
     -F 'file=@<your-TESTOWNER-file-location>'
```
You might consider creating a new pipeline to automatically upload your TESTOWNER file when changes are detected.

## Your TESTOWNER file

A TESTOWNER file [follows the same rules as a `.gitignore` or `CODEOWNERS` file](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners#example-of-a-codeowners-file), with one exception.

We do not currently support the `.gitignore` rule that allows a file path to have no corresponding team.

```bash
# In a regular .gitignore or COEDOWNER file, the following
# block would set test-analytics as the owner of any file in the `/specs`
# directory in the root of your test directory except for the `/specs/features`
# subdirectory, as its owners are left empty.

# This functionality is not supported in Buildkite TESTOWNERS.
# /spec/features would be owned by the test-analytics team.

/specs/ test-analytics
/specs/features
```

### Example TESTOWNER file

```bash
# This is a comment.
# Each line is a file pattern followed by one or more team slugs.

# These teams will be the owners for everything in
# the repo. While both teams own the test, the first team listed will
# become the default owner for tests in this directory. Unless
# a later match takes precedence, team-slug-1 will have any
# flaky tests assigned to them by default.
*       team-slug-1 team-slug-2

# Order is important; the last matching pattern takes the most
# precedence. Any test file ending with _spec.rb will be assigned
# to the test-analytics team and not team-slug-1.
*_spec.rb    test-analytics #This is an inline comment.

# Only Buildkite teams can be specified as test owners. Teams should
# be identified by their slug. Teams must have
# explicit access to the suite the test belongs to. In this example,
# the pipelines team owns all .rb files.
*.rb pipelines

# In this example, packages owns any files in the spec/packages/
# directory at the root of the test directory and any of its
# subdirectories.
/spec/packages/ packages

# The `spec/features/*` pattern will match files like
# `spec/features/application_spec.rb` but not further nested files like
# `spec/features/pipelines/application_spec.rb`.
spec/features/*  test-analytics

# In this example, pipelines owns any file in a pipelines directory
# anywhere in your test directory.
pipelines/ pipelines

# In this example, packages owns any file in the `/spec/packages`
# directory in the root of your test directory and any of its
# subdirectories.
/spec/packages/ packages

# In this example, test-analytics owns any test in a `/analytics` directory such as
# `/models/analytics`, `/features/analytics`, and `/models/organizations/analytics`. # Any tests in an `/analytics` directory will belong to team test-analytics.
**/analytics test-analytics

# In this example, pipelines owns any test in the `/spec`
# directory in the root of your test directory except for the `/spec/models/packages`
# subdirectory, as this subdirectory has its own owner packages
/spec/ pipelines
/spec/models/packages packages
```
{: codeblock-file="TESTOWNERS"}

### Teams
A TESTOWNER uses Buildkite team slugs instead of user names. Your team slug will be your team name in snake-case. You can view your teams in your organization settings, or fetch them from our API:

- [List teams from REST API](/docs/apis/rest_api/teams)</li>
- [List teams from Graphql API](/docs/apis/graphql/schemas/object/team)</li>

> 🚧 Team permissions
>It is important to [ensure these teams have permission to access the suite](/docs/test-analytics/permissions#manage-teams-and-permissions) the file is uploaded to, otherwise these ownership records will not be created. You can check these permissions in your organization's team settings.

More than 1 team may own a test, and the order of teams in your TESTOWNER file is important. The first team listed will be the default owner, and they will be auto-assigned to the test if it flakes. Any team with suite access can override this auto-assignment.

### Suites
A suite only has one active TESTOWNER file at a time. A TESTOWNER must be uploaded per suite for it to be applied.




