- `{id}` is that of the agent token, whose value can be obtained:

    * From the Buildkite URL path when editing the agent token. To do this:

        - Select **Agents** (in the global navigation) > the specific cluster > **Agent Tokens** > expand the agent token > **Edit**.
        - Copy the ID value between `/tokens/` and `/edit` in the URL.

    * By running the [List tokens](/docs/apis/rest-api/clusters/agent-tokens#list-tokens) REST API query and obtain this value from the `id` in the response associated with the description of your token (specified by the `description` value in the response). For example:

        ```bash
        curl -H "Authorization: Bearer $TOKEN" \\
          - X GET "https://api.buildkite.com/v2/organizations/{org.slug}/clusters/{cluster.id}/tokens"
        ```
