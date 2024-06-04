# Test ownership

Customers on the [Pro and Enterprise plans](https://buildkite.com/pricing) can assign test ownership to [Teams](/docs/team-management/permissions).

Test ownership is assigned to the tests in a specific suite per instructions in your TESTOWNER file. When a test flakes it will be automatically assigned to the Buildkite team that owns it.

> 📘 Buildkite test ownership is currently in private beta
> Please reach out to our support team to register for early access.

## Your TESTOWNER file

### Formatting
A TESTOWNER file [follows the same rules as a `.gitignore` or `CODEOWNERS` file](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners#example-of-a-codeowners-file), with a few exceptions.

Order your test paths from least specific to most specific to ensure ownership records are not incorrectly overridden.

```bash
# TESTOWNERS
* everyone
/spec/models pipelines
/spec/models/examples/* test-analytics packages
/spec/models/**/test_spec.rb platform
```

We currently do not support

### Teams
A TESTOWNER uses Buildkite team slugs instead of user names. Your team slug will be your team name in snake-case. You can view your teams in your organization settings, or fetch them from our API:
<ul>
	<li>[List teams from REST API](/docs/apis/rest_api/teams)</li>
	<li>[List teams from Graphql API](/docs/apis/graphql/schemas/object/team)</li>
</ul>


```bash
# TESTOWNERS
/spec/models/* pipelines
# Team Pipelines will own all tests in the models/ directory,
# ignoring sub-directories
```
It is important to [ensure these teams have permission to access the suite](/docs/test-analytics/permissions#manage-teams-and-permissions) the file is uploaded to, otherwise these ownership records will not be created. You can check these permissions in your organization's team settings.

More than 1 team may own a test, and the order of teams in your TESTOWNER file is important. The first team listed will be the default owner, and they will be auto-assigned to the test if it flakes. Any team will access can override this auto-assignment.

### Suites
A suite only has one active TESTOWNER file at a time. You may reuse the same TESTOWNER file across many suites.

## Setting test ownership

You can upload a TESTOWNER file via this API endpoint

```bash
curl --location 'https://analytics-api.buildkite.com/v1/test-ownerships' \
     --header "Authorization: Bearer <your-suite-api-token>" \
     -F 'file=@<your-TESTOWNER-file-location>'
```




