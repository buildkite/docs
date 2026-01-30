# REST API overview

The Buildkite REST API aims to give you complete programmatic access and control of Buildkite to extend, integrate and automate anything to suit your particular needs.

The current version of the Buildkite API is v2.

For the list of existing disparities between the REST API and the GraphQL API, see [API differences](/docs/apis/api-differences).

## Schema

All API access is over HTTPS, and accessed from the `api.buildkite.com` domain. All data is sent as JSON.

The following `curl` command:

```bash
curl https://api.buildkite.com
```

Generates a response like:

```json
{"message":"🛠","timestamp":1719276157}
```

where the `timestamp` value is the current [Unix time](https://en.wikipedia.org/wiki/Unix_time) value.

## Endpoints

This section lists all the available endpoints organized by resource type. Each endpoint includes its HTTP method, path structure, and links to detailed documentation with request and response examples and additional relevant information.

### Organizations

Method | Endpoint | Description
------ | -------- | -----------
GET | `/v2/organizations` | [List organizations](/docs/apis/rest-api/organizations#list-organizations)
GET | `/v2/organizations/{org.slug}` | [Get an organization](/docs/apis/rest-api/organizations#get-an-organization)
{: class="responsive-table"}

### Organization members

Method | Endpoint | Description
------ | -------- | -----------
GET | `/v2/organizations/{org.slug}/members` | [List organization members](/docs/apis/rest-api/organizations/members#list-organization-members)
GET | `/v2/organizations/{org.slug}/members/{user.uuid}` | [Get an organization member](/docs/apis/rest-api/organizations/members#get-an-organization-member)
{: class="responsive-table"}

### Pipelines

Method | Endpoint | Description
------ | -------- | -----------
GET | `/v2/organizations/{org.slug}/pipelines` | [List pipelines](/docs/apis/rest-api/pipelines#list-pipelines)
GET | `/v2/organizations/{org.slug}/pipelines/{slug}` | [Get a pipeline](/docs/apis/rest-api/pipelines#get-a-pipeline)
POST | `/v2/organizations/{org.slug}/pipelines` | [Create a pipeline](/docs/apis/rest-api/pipelines#create-a-yaml-pipeline)
PATCH | `/v2/organizations/{org.slug}/pipelines/{slug}` | [Update a pipeline](/docs/apis/rest-api/pipelines#update-a-pipeline)
DELETE | `/v2/organizations/{org.slug}/pipelines/{slug}` | [Delete a pipeline](/docs/apis/rest-api/pipelines#delete-a-pipeline)
POST | `/v2/organizations/{org.slug}/pipelines/{slug}/archive` | [Archive a pipeline](/docs/apis/rest-api/pipelines#archive-a-pipeline)
POST | `/v2/organizations/{org.slug}/pipelines/{slug}/unarchive` | [Unarchive a pipeline](/docs/apis/rest-api/pipelines#unarchive-a-pipeline)
POST | `/v2/organizations/{org.slug}/pipelines/{slug}/webhook` | [Add a webhook](/docs/apis/rest-api/pipelines#add-a-webhook)
{: class="responsive-table"}

### Builds

Method | Endpoint | Description
------ | -------- | -----------
GET | `/v2/builds` | [List all builds](/docs/apis/rest-api/builds#list-all-builds)
GET | `/v2/organizations/{org.slug}/builds` | [List builds for an organization](/docs/apis/rest-api/builds#list-builds-for-an-organization)
GET | `/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds` | [List builds for a pipeline](/docs/apis/rest-api/builds#list-builds-for-a-pipeline)
GET | `/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{number}` | [Get a build](/docs/apis/rest-api/builds#get-a-build)
POST | `/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds` | [Create a build](/docs/apis/rest-api/builds#create-a-build)
PUT | `/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{number}/cancel` | [Cancel a build](/docs/apis/rest-api/builds#cancel-a-build)
PUT | `/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{number}/rebuild` | [Rebuild a build](/docs/apis/rest-api/builds#rebuild-a-build)
{: class="responsive-table"}

### Jobs

Method | Endpoint | Description
------ | -------- | -----------
PUT | `/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{number}/jobs/{job.id}/retry` | [Retry a job](/docs/apis/rest-api/jobs#retry-a-job)
PUT | `/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{number}/jobs/{job.id}/reprioritize` | [Reprioritize a job](/docs/apis/rest-api/jobs#reprioritize-a-job)
PUT | `/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{number}/jobs/{job.id}/unblock` | [Unblock a job](/docs/apis/rest-api/jobs#unblock-a-job)
GET | `/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{number}/jobs/{job.id}/log` | [Get a job's log](/docs/apis/rest-api/jobs#get-a-jobs-log-output)
DELETE | `/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{number}/jobs/{job.id}/log` | [Delete a job's log](/docs/apis/rest-api/jobs#delete-a-jobs-log-output)
GET | `/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{number}/jobs/{job.id}/env` | [Get a job's environment](/docs/apis/rest-api/jobs#get-a-jobs-environment-variables)
{: class="responsive-table"}

### Annotations

Method | Endpoint | Description
------ | -------- | -----------
GET | `/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{number}/annotations` | [List annotations](/docs/apis/rest-api/annotations#list-annotations-for-a-build)
POST | `/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{number}/annotations` | [Create an annotation](/docs/apis/rest-api/annotations#create-an-annotation-on-a-build)
DELETE | `/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{number}/annotations/{uuid}` | [Delete an annotation](/docs/apis/rest-api/annotations#delete-an-annotation-on-a-build)
{: class="responsive-table"}

### Artifacts

Method | Endpoint | Description
------ | -------- | -----------
GET | `/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{number}/artifacts` | [List artifacts for a build](/docs/apis/rest-api/artifacts#list-artifacts-for-a-build)
GET | `/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{number}/jobs/{job.id}/artifacts` | [List artifacts for a job](/docs/apis/rest-api/artifacts#list-artifacts-for-a-job)
GET | `/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{number}/jobs/{job.id}/artifacts/{id}` | [Get an artifact](/docs/apis/rest-api/artifacts#get-an-artifact)
GET | `/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{number}/jobs/{job.id}/artifacts/{id}/download` | [Download an artifact](/docs/apis/rest-api/artifacts#download-an-artifact)
DELETE | `/v2/organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{number}/jobs/{job.id}/artifacts/{id}` | [Delete an artifact](/docs/apis/rest-api/artifacts#delete-an-artifact)
{: class="responsive-table"}

### Agents

Method | Endpoint | Description
------ | -------- | -----------
GET | `/v2/organizations/{org.slug}/agents` | [List agents](/docs/apis/rest-api/agents#list-agents)
GET | `/v2/organizations/{org.slug}/agents/{id}` | [Get an agent](/docs/apis/rest-api/agents#get-an-agent)
PUT | `/v2/organizations/{org.slug}/agents/{id}/stop` | [Stop an agent](/docs/apis/rest-api/agents#stop-an-agent)
PUT | `/v2/organizations/{org.slug}/agents/{id}/pause` | [Pause an agent](/docs/apis/rest-api/agents#pause-an-agent)
PUT | `/v2/organizations/{org.slug}/agents/{id}/resume` | [Resume an agent](/docs/apis/rest-api/agents#resume-an-agent)
{: class="responsive-table"}

### Teams

Method | Endpoint | Description
------ | -------- | -----------
GET | `/v2/organizations/{org.slug}/teams` | [List teams](/docs/apis/rest-api/teams#list-teams)
GET | `/v2/organizations/{org.slug}/teams/{team.uuid}` | [Get a team](/docs/apis/rest-api/teams#get-a-team)
POST | `/v2/organizations/{org.slug}/teams` | [Create a team](/docs/apis/rest-api/teams#create-a-team)
PATCH | `/v2/organizations/{org.slug}/teams/{team.uuid}` | [Update a team](/docs/apis/rest-api/teams#update-a-team)
DELETE | `/v2/organizations/{org.slug}/teams/{team.uuid}` | [Delete a team](/docs/apis/rest-api/teams#delete-a-team)
{: class="responsive-table"}

### Team members

Method | Endpoint | Description
------ | -------- | -----------
GET | `/v2/organizations/{org.slug}/teams/{team.uuid}/members` | [List team members](/docs/apis/rest-api/teams/members#list-team-members)
GET | `/v2/organizations/{org.slug}/teams/{team.uuid}/members/{user.uuid}` | [Get a team member](/docs/apis/rest-api/teams/members#get-a-team-member)
POST | `/v2/organizations/{org.slug}/teams/{team.uuid}/members` | [Create a team member](/docs/apis/rest-api/teams/members#create-a-team-member)
PATCH | `/v2/organizations/{org.slug}/teams/{team.uuid}/members/{user.uuid}` | [Update a team member](/docs/apis/rest-api/teams/members#update-a-team-member)
DELETE | `/v2/organizations/{org.slug}/teams/{team.uuid}/members/{user.uuid}` | [Delete a team member](/docs/apis/rest-api/teams/members#delete-a-team-member)
{: class="responsive-table"}

### Team pipelines

Method | Endpoint | Description
------ | -------- | -----------
GET | `/v2/organizations/{org.slug}/teams/{team.uuid}/pipelines` | [List team pipelines](/docs/apis/rest-api/teams/pipelines#list-team-pipelines)
GET | `/v2/organizations/{org.slug}/teams/{team.uuid}/pipelines/{uuid}` | [Get a team pipeline](/docs/apis/rest-api/teams/pipelines#get-a-team-pipeline)
POST | `/v2/organizations/{org.slug}/teams/{team.uuid}/pipelines` | [Create a team pipeline](/docs/apis/rest-api/teams/pipelines#create-a-team-pipeline)
PATCH | `/v2/organizations/{org.slug}/teams/{team.uuid}/pipelines/{uuid}` | [Update a team pipeline](/docs/apis/rest-api/teams/pipelines#update-a-team-pipeline)
DELETE | `/v2/organizations/{org.slug}/teams/{team.uuid}/pipelines/{uuid}` | [Delete a team pipeline](/docs/apis/rest-api/teams/pipelines#delete-a-team-pipeline)
{: class="responsive-table"}

### Team suites

Method | Endpoint | Description
------ | -------- | -----------
GET | `/v2/organizations/{org.slug}/teams/{team.uuid}/suites` | [List team suites](/docs/apis/rest-api/teams/suites#list-team-suites)
GET | `/v2/organizations/{org.slug}/teams/{team.uuid}/suites/{uuid}` | [Get a team suite](/docs/apis/rest-api/teams/suites#get-a-team-suite)
POST | `/v2/organizations/{org.slug}/teams/{team.uuid}/suites` | [Create a team suite](/docs/apis/rest-api/teams/suites#create-a-team-suite)
PATCH | `/v2/organizations/{org.slug}/teams/{team.uuid}/suites/{uuid}` | [Update a team suite](/docs/apis/rest-api/teams/suites#update-a-team-suite)
DELETE | `/v2/organizations/{org.slug}/teams/{team.uuid}/suites/{uuid}` | [Delete a team suite](/docs/apis/rest-api/teams/suites#delete-a-team-suite)
{: class="responsive-table"}

### Clusters

Method | Endpoint | Description
------ | -------- | -----------
GET | `/v2/organizations/{org.slug}/clusters` | [List clusters](/docs/apis/rest-api/clusters#clusters-list-clusters)
GET | `/v2/organizations/{org.slug}/clusters/{id}` | [Get a cluster](/docs/apis/rest-api/clusters#clusters-get-a-cluster)
POST | `/v2/organizations/{org.slug}/clusters` | [Create a cluster](/docs/apis/rest-api/clusters#clusters-create-a-cluster)
PUT | `/v2/organizations/{org.slug}/clusters/{id}` | [Update a cluster](/docs/apis/rest-api/clusters#clusters-update-a-cluster)
DELETE | `/v2/organizations/{org.slug}/clusters/{id}` | [Delete a cluster](/docs/apis/rest-api/clusters#clusters-delete-a-cluster)
{: class="responsive-table"}

### Queues

Method | Endpoint | Description
------ | -------- | -----------
GET | `/v2/organizations/{org.slug}/clusters/{cluster.id}/queues` | [List queues](/docs/apis/rest-api/clusters/queues#list-queues)
GET | `/v2/organizations/{org.slug}/clusters/{cluster.id}/queues/{id}` | [Get a queue](/docs/apis/rest-api/clusters/queues#get-a-queue)
POST | `/v2/organizations/{org.slug}/clusters/{cluster.id}/queues` | [Create a self-hosted queue](/docs/apis/rest-api/clusters/queues#create-a-self-hosted-queue)
POST | `/v2/organizations/{org.slug}/clusters/{cluster.id}/queues` | [Create a Buildkite hosted queue](/docs/apis/rest-api/clusters/queues#create-a-buildkite-hosted-queue)
PUT | `/v2/organizations/{org.slug}/clusters/{cluster.id}/queues/{id}` | [Update a queue](/docs/apis/rest-api/clusters/queues#update-a-queue)
DELETE | `/v2/organizations/{org.slug}/clusters/{cluster.id}/queues/{id}` | [Delete a queue](/docs/apis/rest-api/clusters/queues#delete-a-queue)
POST | `/v2/organizations/{org.slug}/clusters/{cluster.id}/queues/{id}/pause_dispatch` | [Pause a queue](/docs/apis/rest-api/clusters/queues#pause-a-queue)
POST | `/v2/organizations/{org.slug}/clusters/{cluster.id}/queues/{id}/resume_dispatch` | [Resume a paused queue](/docs/apis/rest-api/clusters/queues#resume-a-paused-queue)
{: class="responsive-table"}

### Agent tokens

Method | Endpoint | Description
------ | -------- | -----------
GET | `/v2/organizations/{org.slug}/clusters/{cluster.id}/tokens` | [List agent tokens](/docs/apis/rest-api/clusters/agent-tokens#list-tokens)
GET | `/v2/organizations/{org.slug}/clusters/{cluster.id}/tokens/{id}` | [Get an agent token](/docs/apis/rest-api/clusters/agent-tokens#get-a-token)
POST | `/v2/organizations/{org.slug}/clusters/{cluster.id}/tokens` | [Create an agent token](/docs/apis/rest-api/clusters/agent-tokens#create-a-token)
PUT | `/v2/organizations/{org.slug}/clusters/{cluster.id}/tokens/{id}` | [Update an agent token](/docs/apis/rest-api/clusters/agent-tokens#update-a-token)
DELETE | `/v2/organizations/{org.slug}/clusters/{cluster.id}/tokens/{id}` | [Revoke an agent token](/docs/apis/rest-api/clusters/agent-tokens#revoke-a-token)
{: class="responsive-table"}

### Pipeline templates

Method | Endpoint | Description
------ | -------- | -----------
GET | `/v2/organizations/{org.slug}/pipeline-templates` | [List pipeline templates](/docs/apis/rest-api/pipeline-templates#list-pipeline-templates)
GET | `/v2/organizations/{org.slug}/pipeline-templates/{uuid}` | [Get a pipeline template](/docs/apis/rest-api/pipeline-templates#get-a-pipeline-template)
POST | `/v2/organizations/{org.slug}/pipeline-templates` | [Create a pipeline template](/docs/apis/rest-api/pipeline-templates#create-a-pipeline-template)
PATCH | `/v2/organizations/{org.slug}/pipeline-templates/{uuid}` | [Update a pipeline template](/docs/apis/rest-api/pipeline-templates#update-a-pipeline-template)
DELETE | `/v2/organizations/{org.slug}/pipeline-templates/{uuid}` | [Delete a pipeline template](/docs/apis/rest-api/pipeline-templates#delete-a-pipeline-template)
{: class="responsive-table"}

### Rules

Method | Endpoint | Description
------ | -------- | -----------
GET | `/v2/organizations/{org.slug}/rules` | [List rules](/docs/apis/rest-api/rules#rules-list-rules)
GET | `/v2/organizations/{org.slug}/rules/{uuid}` | [Get a rule](/docs/apis/rest-api/rules#rules-get-a-rule)
POST | `/v2/organizations/{org.slug}/rules` | [Create a rule](/docs/apis/rest-api/rules#rules-create-a-rule)
DELETE | `/v2/organizations/{org.slug}/rules/{uuid}` | [Delete a rule](/docs/apis/rest-api/rules#rules-delete-a-rule)
{: class="responsive-table"}

### Emojis

Method | Endpoint | Description
------ | -------- | -----------
GET | `/v2/organizations/{org.slug}/emojis` | [List emojis](/docs/apis/rest-api/emojis#list-emojis)
{: class="responsive-table"}

### User

Method | Endpoint | Description
------ | -------- | -----------
GET | `/v2/user` | [Get current user](/docs/apis/rest-api/user#get-the-current-user)
{: class="responsive-table"}

### Access token

Method | Endpoint | Description
------ | -------- | -----------
GET | `/v2/access-token` | [Get current token](/docs/apis/rest-api/access-token#get-the-current-token)
DELETE | `/v2/access-token` | [Revoke current token](/docs/apis/rest-api/access-token#revoke-the-current-token)
{: class="responsive-table"}

### Meta

Method | Endpoint | Description
------ | -------- | -----------
GET | `/v2/meta` | [Get meta information](/docs/apis/rest-api/meta#get-meta-information)
{: class="responsive-table"}

## Query string parameters

Some API endpoints accept query string parameters which are added to the end of the URL. For example, the [builds listing APIs](/docs/api/builds#list-all-builds) can be filtered by `state` using the following `curl` command:

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/my-org/pipelines/my-pipeline/builds?state=passed"
```

## Request body properties

Some API requests accept JSON request bodies for specifying data. For example, the [build create API](/docs/api/builds#create-a-build) can be passed the required properties using the following `curl` command:

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X POST "https://api.buildkite.com/v2/organizations/my-org/pipelines/my-pipeline/builds" \
  -H "Content-Type: application/json" \
  -d '{
    "key": "value"
  }'
```

The data encoding is assumed to be `application/json`. Unless explicitly stated you can not encode properties as `www-form-urlencoded` or `multipart/form-data`.

## Authentication

You can authenticate with the Buildkite API using access tokens, represented by the value `$TOKEN` throughout this documentation.

API access tokens authenticate calls to the API and can be created from the <a href="<%= url_helpers.user_access_tokens_url %>" rel="nofollow">API access tokens</a> page. When configuring API access tokens, you can limit their access to individual organizations and permissions, and these tokens can be revoked at any time from the web interface [or the REST API](/docs/apis/rest-api/access-token#revoke-the-current-token).

To authenticate an API call using an access token, set the <code>Authorization</code> HTTP header to the word <code>Bearer</code>, followed by a space, followed by the access token. For example:

```bash
curl -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/user"
```

API access using basic HTTP authentication is not supported.

### Public key

> 📘 This feature is currently available in preview.

API access tokens can be created with a public key pair instead of a static token. The private key can be used to sign [JWTs](https://datatracker.ietf.org/doc/html/rfc7519) to authenticate API calls. You must use the API access token's UUID as the `iss` claim in the JWT, have an `iat` within 10 seconds of the current time, and an `exp` within 5 minutes of your `iat`.

For example, in Ruby - where `private_key.pem` contains the private key corresponding to an access token's public key and `$UUID` is the UUID of the access token:

```ruby
require "net/http"
require "openssl"
require "jwt" # https://rubygems.org/gems/jwt

claims = {
  "iss" => "$UUID",
  "iat" => Time.now.to_i - 5,
  "exp" => Time.now.to_i + 60,
}

private_key = OpenSSL::PKey::RSA.new(File.read("private_key.pem"))

jwt = JWT.encode(claims, private_key, "RS256")

Net::HTTP.get(URI("https://api.buildkite.com/v2/access-token"), "Authorization" => "Bearer #{jwt}")
```

## Pagination

For endpoints which support pagination, the pagination information can be found in the `Link` HTTP response header containing zero or more of `next`, `prev`, `first` and `last`.

```bash
curl -i -H "Authorization: Bearer $TOKEN" \
  -X GET "https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds"
```

```
HTTP/1.1 200 OK
...
Link: <https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds?api_key=f8582f070276d764ce3dd4c6d57be92574dccf86&page=3>; rel="next", <https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds?api_key=f8582f070276d764ce3dd4c6d57be92574dccf86&page=6>; rel="last"
```

You can set the page using the following query string parameters:

<table>
<tbody>
  <tr><th><code>page</code></th><td>The page of results to return<p class="Docs__api-param-eg"><em>Default:</em> <code>1</code></p></td></tr>
  <tr><th><code>per_page</code></th><td>How many results to return per-page<p class="Docs__api-param-eg"><em>Default:</em> <code>30</code></p><p class="Docs__api-param-eg"><em>Maximum:</em> <code>100</code></p></td></tr>
</tbody>
</table>

## CORS headers

API responses include the following [CORS headers](https://developer.mozilla.org/en-US/docs/Web/HTTP/Access_control_CORS) allowing you to use the API directly from the browser:

* `Access-Controller-Allow-Origin: *`
* `Access-Control-Expose-Headers: Link`

For an example of this in use, see the [Emojis API example on CodePen](https://codepen.io/dannymidnight/pen/jOpJpmY) for adding emoji support to your own browser-based dashboards and build screens.

## Migrating from v1 to v2

The following changes were made in v2 of our API:

* <code>POST /v1/organizations/{org.slug}/agents</code> has been removed
* <code>DELETE /v1/organizations/{org.slug}/agents/{id}</code> has been removed
* All project-related properties in JSON responses and requests have been renamed to pipeline
* The <code>featured_build</code> pipeline property has been removed
* The deprecated <code>/accounts</code> URL has been removed
* URLs containing <code>/projects</code> have been renamed to <code>/pipelines</code>

## Clients

To make getting started easier, check out these clients available from our contributors:

<!-- vale off -->

* [Buildkit](https://github.com/Shopify/buildkit) for [Ruby](https://www.ruby-lang.org)
* [go-buildkite](https://github.com/buildkite/go-buildkite) for [Go](https://golang.org)
* [PSBuildkite](https://github.com/felixfbecker/PSBuildkite) for [PowerShell](https://microsoft.com/powershell)
* [pybuildkite](https://github.com/pyasi/pybuildkite) for [Python](https://www.python.org/)
* [buildkite-php](https://github.com/bbaga/buildkite-php) for [PHP](https://www.php.net/)
* [buildkite-swift](https://github.com/aaronsky/buildkite-swift) for [Swift](https://swift.org)
* [buildkite-api-client](https://github.com/SourceLabOrg/Buildkite-Api-Client) for [Java](https://www.java.com)

<!-- vale on -->
