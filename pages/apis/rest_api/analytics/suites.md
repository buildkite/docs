# Suites API

## List all suites

Returns a [paginated list](<%= paginated_resource_docs_url %>) of an organization's suites.

```bash
curl "https://api.buildkite.com/v2/analytics/organizations/{org.slug}/suites"
```

```json
[
  {
    "slug":"my_suite_slug",
    "name":"My suite name",
    "url":"https://api.buildkite.com/v2/analytics/organizations/my_great_org/suites/my_suite_slug",
    "web_url":"https://buildkite.com/organizations/my_great_org/analytics/suites/my_suite_slug",
    "default_branch":"main"
  }
]
```

Required scope: `read_suites`

Success response: `200 OK`

## Get a suite

```bash
curl "https://api.buildkite.com/v2/analytics/organizations/{org.slug}/suites/{suite.slug}"
```

```json
{
  "slug":"my_suite_slug",
  "name":"My suite name",
  "url":"https://api.buildkite.com/v2/analytics/organizations/my_great_org/suites/my_suite_slug",
  "web_url":"https://buildkite.com/organizations/my_great_org/analytics/suites/my_suite_slug",
  "default_branch":"main"
}
```

Required scope: `read_suites`

Success response: `200 OK`

## Create a suite

```bash
curl -X POST \
  http://api.buildkite.com/v2/analytics/organizations/{org.slug}/suites \
  -d '{
    "name": "Jasmine",
    "default_branch": "main",
    "show_api_token": true,
    "team_ids": ["3f4aa5ee-671b-41b0-9b44-b94831db6cc8"]
  }'
```

```json
{
  "id": "3e979a94-a479-4a6e-ab8d-8b6607ffb62c",
  "slug": "jasmine",
  "name": "Jasmine",
  "url": "http://api.buildkite.com/v2/analytics/organizations/my_great_org/suites/jasmine",
  "web_url": "http://buildkite.com/organizations/my_great_org/analytics/suites/jasmine",
  "default_branch": "main",
  "api_token": "AAAAAAAAAAAAAAAAAAAAAAAA"
}
```

Required [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr><th><code>name</code></th><td>Name of the new suite.<br><em>Example:</em> <code>"Jasmine"</code>.</td></tr>
  <tr><th><code>default_branch</code></th><td>Your test suite will default to showing trends for this default branch, but collect data for all test runs.<br><em>Example:</em> <code>"main"</code> or <code>"master"</code>.</td></tr>
</tbody>
</table>

Optional [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
  <tbody>
    <tr><th><code>show_api_token</code></th><td>Return the suite's api token in the response. This is the only way to view the suite's api token via the REST api.<br><em>Default value:</em> <code>false</code>.</td></tr>
    <tr>
      <th><code>teams_ids</code></th>
      <td>
        <p>An array of team UUIDs to add this suite to. You can find your team's UUID either using the <a href="/docs/apis/graphql-api">GraphQL API</a>, or on the Settings page for a team. This property is only available if your organization has enabled Teams, in which case it is a required field.</p>
        <em>Example:</em> <code>"team_ids": ["3f4aa5ee-671b-41b0-9b44-b94831db6cc8"]</code></td></tr>
      </td>
    </tr>
    <tr>
  </tbody>
</table>

Required scope: `write_suites`

Success response: `201 Created`
