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

API access tokens can be created with a public key pair instead of a static token. The private key can be used to sign JWTs to authenticate API calls. You must use the API access token's UUID as the `iss` claim in the JWT, have an `iat` within 10 seconds of the current time, and an `exp` within 5 minutes of your `iat`.

For example, in Ruby - where `private_key.pem` contains the private key registered against an API access token and `$UUID` is the UUID of the token:

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
