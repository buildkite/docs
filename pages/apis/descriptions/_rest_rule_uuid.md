- `{rule.uuid}` can be obtained:

    * From the **Rules** section of your **Organization Settings** page, accessed by selecting **Settings** in the global navigation of your organization in Buildkite.

    * By running a [List rules](/docs/apis/rest-api/rules#rules-list-rules) REST API query and obtaining this value from the `uuid` in the response associated with the rule type, source and target of the rule you wish to find (specified by the `type`, `source` and `target` values in the response). For example:

    ```bash
    curl -H "Authorization: Bearer $TOKEN" \
      - X GET "https://api.buildkite.com/v2/organizations/{org.slug}/rules"
    ```
