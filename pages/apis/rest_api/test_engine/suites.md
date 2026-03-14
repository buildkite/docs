# Suites API

## List all suites

Returns a [paginated list](<%= paginated_resource_docs_url %>) of an organization's suites.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/analytics/organizations/{org.slug}/suites"
```

```json
[
  {
    "id": "3e979a94-a479-4a6e-ab8d-8b6607ffb62c",
    "graphql_id": "U3VpdGUtLS0zZTk3OWE5NC1hNDc5LTRhNmUtYWI4ZC04YjY2MDdmZmI2MmM=",
    "slug":"my_suite_slug",
    "name":"My suite name",
    "url":"https://api.buildkite.com/v2/analytics/organizations/my_great_org/suites/my_suite_slug",
    "web_url":"https://buildkite.com/organizations/my_great_org/analytics/suites/my_suite_slug",
    "default_branch":"main"
  }
]
```

Optional [query string parameters](/docs/api#query-string-parameters):

<%= render_markdown partial: 'apis/rest_api/test_engine/suites_query_strings' %>

Required scope: `read_suites`

Success response: `200 OK`

## Get a suite

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/analytics/organizations/{org.slug}/suites/{suite.slug}"
```

```json
{
  "id": "3e979a94-a479-4a6e-ab8d-8b6607ffb62c",
  "graphql_id": "U3VpdGUtLS0zZTk3OWE5NC1hNDc5LTRhNmUtYWI4ZC04YjY2MDdmZmI2MmM=",
  "slug":"my_suite_slug",
  "name":"My suite name",
  "url":"https://api.buildkite.com/v2/analytics/organizations/my_great_org/suites/my_suite_slug",
  "web_url":"https://buildkite.com/organizations/my_great_org/analytics/suites/my_suite_slug",
  "default_branch":"main"
}
```

Optional [query string parameters](/docs/api#query-string-parameters):

<%= render_markdown partial: 'apis/rest_api/test_engine/suites_query_strings' %>

Required scope: `read_suites`

Success response: `200 OK`

## Create a suite

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/analytics/organizations/{org.slug}/suites" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Jasmine",
    "default_branch": "main",
    "application_name": "Buildkite",
    "color": "#FFF700",
    "emoji": "🍋",
    "show_api_token": true,
    "team_ids": ["3f4aa5ee-671b-41b0-9b44-b94831db6cc8"]
  }'
```

```json
{
  "id": "3e979a94-a479-4a6e-ab8d-8b6607ffb62c",
  "graphql_id": "U3VpdGUtLS0zZTk3OWE5NC1hNDc5LTRhNmUtYWI4ZC04YjY2MDdmZmI2MmM=",
  "slug": "jasmine",
  "name": "Jasmine",
  "url": "https://api.buildkite.com/v2/analytics/organizations/my_great_org/suites/jasmine",
  "web_url": "https://buildkite.com/organizations/my_great_org/analytics/suites/jasmine",
  "default_branch": "main",
  "application_name": "Buildkite",
  "color": "#FFF700",
  "emoji": "🍋",
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
    <tr><th><code>show_api_token</code></th><td>Return the suite's API token in the response.<br><em>Default value:</em> <code>false</code>.</td></tr>
    <tr>
      <th><code>teams_ids</code></th>
      <td>
        <p>An array of team UUIDs to add this suite to. You can find your team's UUID either using the <a href="/docs/apis/graphql-api">GraphQL API</a>, or on the Settings page for a team. This property is only available if your organization has enabled Teams, in which case it is a required field.</p>
        <em>Example:</em> <code>"team_ids": ["3f4aa5ee-671b-41b0-9b44-b94831db6cc8"]</code></td></tr>
      </td>
    </tr>
    <tr><th><code>application_name</code></th><td>Application name for the suite.<br><em>Example:</em> <code>"Buildkite"</code></td></tr>
    <tr><th><code>color</code></th><td>Color for the suite navatar.<br><em>Example:</em> <code>"#FFF700"</code></td></tr>
    <tr><th><code>emoji</code></th><td>Emoji for the suite navatar. Check out our <a href="https://github.com/buildkite/emojis?tab=readme-ov-file#emoji-reference">documentation for supported emoji</a>.<br><em>Example:</em> <code>"🍋"</code>, <code>"\:lemon\:"</code></td></tr>
  </tbody>
</table>

Required scope: `write_suites`

Success response: `201 Created`

## Update a suite

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X PATCH "https://api.buildkite.com/v2/analytics/organizations/{org.slug}/suites/{suite.slug}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Jasmine",
    "default_branch": "main"
  }'
```

```json
{
  "id": "3e979a94-a479-4a6e-ab8d-8b6607ffb62c",
  "graphql_id": "U3VpdGUtLS0zZTk3OWE5NC1hNDc5LTRhNmUtYWI4ZC04YjY2MDdmZmI2MmM=",
  "slug": "jasmine",
  "name": "Jasmine",
  "url": "https://api.buildkite.com/v2/analytics/organizations/my_great_org/suites/jasmine",
  "web_url": "https://buildkite.com/organizations/my_great_org/analytics/suites/jasmine",
  "default_branch": "main"
}
```

Optional [request body properties](/docs/api#request-body-properties):

<table class="responsive-table">
<tbody>
  <tr><th><code>name</code></th><td>Name of the suite.<br><em>Example:</em> <code>"Jasmine"</code>.</td></tr>
  <tr><th><code>default_branch</code></th><td>Your test suite will default to showing trends for this default branch, but collect data for all test runs.<br><em>Example:</em> <code>"main"</code> or <code>"master"</code>.</td></tr>
  <tr><th><code>application_name</code></th><td>Application name for the suite.<br><em>Example:</em> <code>"Buildkite"</code></td></tr>
  <tr><th><code>color</code></th><td>Color for the suite navatar.<br><em>Example:</em> <code>"#ffb7c5"</code></td></tr>
  <tr><th><code>emoji</code></th><td>Emoji for the suite navatar. Check out our <a href="https://github.com/buildkite/emojis?tab=readme-ov-file#emoji-reference">documentation for supported emoji.</a><br><em>Example:</em> <code>"🌸"</code>, <code>"\:cherry_blossom\:"</code></td></tr>
  <tr><th><code>show_api_token</code></th><td>Return the suite's API token in the response.<br><em>Default value:</em> <code>false</code>.</td></tr>
</tbody>
</table>


Required scope: `write_suites`

Success response: `200 OK`

## Delete a suite

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X DELETE "https://api.buildkite.com/v2/analytics/organizations/{org.slug}/suites/{suite.slug}"
```

Required scope: `write_suites`

Success response: `204 No Content`
