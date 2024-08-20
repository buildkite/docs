# Test ownership

Test ownership is critical in adopting a healthy testing culture at your organization. Defining one or more teams as test owners allows these teams to become accountable for maintaining a fast and reliable test suite, ensuring confidence when you deploy your code.

Customers on the [Pro and Enterprise plans](https://buildkite.com/pricing) can assign test ownership to [teams](/docs/test-analytics/permissions#manage-teams-and-permissions).

Test ownership is managed via team assignments in a TESTOWNERS file. The team that is the default owner of a test [will be automatically assigned flaky tests](/docs/test-analytics/flaky-test-assignment) to triage.

> 🚧 Buildkite test ownership is currently in private beta
> Please reach out to our support team to register for early access.

## TESTOWNERS file format

A TESTOWNERS file uses Buildkite team slugs instead of user names. Your team slug will be your team name in [kebab-case](https://en.wikipedia.org/wiki/Letter_case#Kebab_case). You can view your teams in your organization settings, or fetch them from our API:

- [List teams from REST API](/docs/apis/rest_api/teams#list-teams)
- [List teams from GraphQL API](/docs/apis/graphql/schemas/object/team)

```bash
# Example team name to slug
Pipelines => pipelines
Test Analytics => test-analytics
📦 Packages => packages
```

The following example TESTOWNERS file, which you can copy as a starting point, explains the syntax of this file and how it works:

```bash
# This is a comment.
# Only Buildkite teams can be specified as test owners.
# Teams must have explicit access to the suite the test belongs to.
# Each line is a file pattern followed by one or more team slugs.

# The following example teams will be the test owners for all test
# location metadata (that is, test files) from your pipeline builds
# in this repository. While both these example teams own these
# tests, the first team specified in this file pattern is the
# default owner for all test files from your pipeline builds and
# will be notified about issues with their corresponding tests.
# Other teams specified from the second position onwards will also
# be identified as owners and appear in reports about the
# reliability of these tests. However, unlike the default team
# owner, these additional teams will not be notified about test
# issues. Any file pattern matches defined later in this file take
# precedence and override any file patterns defined further up
# this file. Therefore, unless a subsequent file pattern match
# takes precedence, `team-slug-1` will have any flaky tests
# assigned to them and the team's users notified by default.
*                     team-slug-1 team-slug-2

# In this example, any test file ending with `_spec.rb` will be
# assigned to the `test-analytics` team and not `team-slug-1`.
*_spec.rb             test-analytics # This is an inline comment.

# In this example, the `pipelines` team owns all `.rb` test files.
*.rb                  pipelines

# In this example, the `packages` team owns any test files in the
# `spec/packages/` directory at the root of the test location and
# in any of its subdirectories.
/spec/packages/       packages

# In this example, the `spec/features/*` pattern matches test files
# like `spec/features/application_spec.rb`, but not any test files
# nested in any subdirectories of `spec/features`, such as
# `spec/features/pipelines/application_spec.rb`.
spec/features/*       test-analytics

# In this example, the `pipelines` team owns any test file in any
# `pipelines` directory, anywhere within the test location.
pipelines/            pipelines

# In this example, the `test-analytics` team owns any test files
# within an `/analytics` directory such as `/models/analytics`,
# `/features/analytics`, and `/models/organizations/analytics`.
# Any test files directly within the `/analytics` directory itself
# will also belong to the `test-analytics` team.
**/analytics          test-analytics

# In this example, the `pipelines` team owns any test files in the
# `/spec` directory at the root of the test location. However, the
# test files contained within the `/spec/models/packages`
# subdirectory, are owned by the `packages` team.
/spec/                pipelines
/spec/models/packages packages
```
{: codeblock-file="TESTOWNERS"}

### Permission requirements

The teams listed in your TESTOWNERS file must have [permission to access the test suite](/docs/test-analytics/permissions#manage-teams-and-permissions-test-suite-level-permissions) _before_ ownership records are created.

## Setting test ownership

You can upload a TESTOWNERS file via this API endpoint:

```bash
curl --location 'https://analytics-api.buildkite.com/v1/test-ownerships' \
     --header "Authorization: Bearer <your-suite-api-token>" \
     -F 'file=@<your-TESTOWNERS-file-location>'
```

You can upload the same TESTOWNERS file to multiple test suites. However, a test suite can only have one active TESTOWNERS file.

> 📘
> You can also create a new pipeline to automatically upload your TESTOWNERS file when changes are detected.

## Viewing test ownership

You can view the current test ownership rules for a test suite in your **Test Suite** > **Test Ownership** page.

<%= image "test-ownership.png", width: 1500/2, height: 1180/2, alt: "Suite settings page showing test ownership" %>

## Troubleshooting

A TESTOWNERS file [follows the same rules as a `.gitignore` or `CODEOWNERS` file](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners#example-of-a-codeowners-file), with the exception of the `.gitignore` rule that allows a file path to have no corresponding team.

```bash
# In a regular `.gitignore` or `CODEOWNER` file, the following
# block would set the `test-analytics` team as the owner of any
# file in the `/specs` directory at the root of your test location
# except for the `/specs/features` subdirectory, as its owners are
# left empty.

# This functionality is not supported in a Buildkite `TESTOWNERS`
# file, where `/spec/features` would be also be owned by the
# `test-analytics` team.

/specs/         test-analytics
/specs/features
```
