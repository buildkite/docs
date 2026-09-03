# Test ownership

Test ownership is critical in adopting a healthy testing culture at your organization. Defining one or more teams as test owners allows these teams to become accountable for maintaining tests within your test suite, ensuring it is fast and reliable, and providing confidence when you deploy your code.

Test ownership can be assigned to [teams](/docs/platform/team-management/permissions#manage-teams-and-permissions), and is managed through team assignments in a TESTOWNERS file.

## How ownership is assigned

TESTOWNERS patterns match against each test's **location** — the top-level `location` field from your [JSON test uploads](/docs/pipelines/configure/tests/test-collection/importing-json#json-test-results-data-reference-test-result-objects) (or the equivalent location from a collector or JUnit import). Ownership is not configured in pipeline YAML, and a tag named `location` is not used for matching.

For ownership (and the **My teams** view) to work:

1. Every upload path that reports those tests must include top-level `location` on each test. Later uploads overwrite the test record; an upload without `location` clears it.
2. Upload a TESTOWNERS file whose patterns match those `location` values.
3. Assign the teams listed in TESTOWNERS to the test suite before ownership records are created.

Path-only locations (without a line number) are valid. After a successful match, open a test's details page — you should see **Location** and **Owners** in the header. **My teams** on the suite Tests page shows tests owned by teams you belong to that are also assigned to the suite.

## TESTOWNERS file format

A TESTOWNERS file uses Buildkite team slugs instead of user names. Your team slug will be your team name in [kebab-case](https://en.wikipedia.org/wiki/Letter_case#Kebab_case). You can view your teams in your organization settings, or fetch them from our API:

- [List teams from REST API](/docs/apis/rest-api/teams#list-teams)
- [List teams from GraphQL API](/docs/apis/graphql/schemas/object/team)

```bash
# Example team name to slug
Pipelines => pipelines
Test Engine => test-engine
📦 Package Registries => package-registries
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
# this file.
*                     team-slug-1 team-slug-2

# In this example, any test file ending with `_spec.rb` will be
# assigned to the `test-engine` team and not `team-slug-1`.
*_spec.rb             test-engine # This is an inline comment.

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
spec/features/*       test-engine

# In this example, the `pipelines` team owns any test file in any
# `pipelines` directory, anywhere within the test location.
pipelines/            pipelines

# In this example, the `test-engine` team owns any test files
# within an `/test-engine` directory such as `/models/test-engine`,
# `/features/test-engine`, and `/models/organizations/test-engine`.
# Any test files directly within the `/test-engine` directory itself
# will also belong to the `test-engine` team.
**/test-engine        test-engine

# In this example, the `pipelines` team owns any test files in the
# `/spec` directory at the root of the test location. However, the
# test files contained within the `/spec/models/packages`
# subdirectory, are owned by the `packages` team.
/spec/                pipelines
/spec/models/packages packages
```
{: codeblock-file="TESTOWNERS"}

### Permission requirements

The teams listed in your TESTOWNERS file must have [permission to access the test suite](/docs/pipelines/security/permissions#manage-teams-and-permissions-test-suite-level-permissions) _before_ ownership records are created.

## Setting test ownership

You can upload a TESTOWNERS file using this API endpoint:

```bash
curl --location 'https://analytics-api.buildkite.com/v1/test-ownerships' \
     --header "Authorization: Bearer <your-suite-api-token>" \
     -F 'file=@<your-TESTOWNERS-file-location>'
```

You can upload the same TESTOWNERS file to multiple test suites. However, a test suite can only have one active TESTOWNERS file.

Uploading a **changed** TESTOWNERS file re-runs ownership matching for recent tests in the suite that already have a `location`. Identical file content is skipped. Tests without `location` still do not receive owners.

> 📘
> You can also create a new pipeline to automatically upload your TESTOWNERS file when changes are detected.

## Viewing test ownership

You can view the current test ownership rules for a test suite in your **Test Suite** > **Settings** > **Test ownership** page.

<%= image "test-ownership.png", width: 2572/2, height: 1386/2, alt: "Suite settings page showing test ownership" %>

To confirm ownership was applied to a specific test, open that test's details page and check for **Location** and **Owners** under the test name. The **My teams** preset on the suite Tests page filters to tests owned by your teams (intersected with teams assigned to the suite).

## Troubleshooting

### Location missing or My teams empty

If **Location** does not appear on the test details page, TESTOWNERS cannot assign owners (even with a catch-all `*` rule), and **My teams** stays empty for those tests.

Common causes:

- `location` was sent only as an execution tag, not as the top-level test field.
- One upload path includes `location`, but a later CI upload of the same tests omits it and clears the field.
- Teams in TESTOWNERS are not yet assigned to the suite.

### TESTOWNERS syntax

A TESTOWNERS file [follows the same rules as a `.gitignore` or `CODEOWNERS` file](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners#example-of-a-codeowners-file), with the exception of the `.gitignore` rule that allows a file path to have no corresponding team.

```bash
# In a regular `.gitignore` or `CODEOWNER` file, the following
# block would set the `test-engine` team as the owner of any
# file in the `/specs` directory at the root of your test location
# except for the `/specs/features` subdirectory, as its owners are
# left empty.

# This functionality is not supported in a Buildkite `TESTOWNERS`
# file, where `/spec/features` would be also be owned by the
# `test-engine` team.

/specs/         test-engine
/specs/features
```
