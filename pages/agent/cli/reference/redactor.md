# buildkite-agent redactor

The Buildkite Agent automatically redacts some sensitive information from logs, such as secrets fetched with the [`secret get`](/docs/agent/cli/reference/secret) command, and any environment variables that match the value given in the [`--redacted-vars` flag](/docs/agent/cli/reference/start#redacted-vars).

However, sometimes a job will source something sensitive through a side channel - perhaps a third-party secrets storage system like Hashicorp Vault or AWS Secrets Manager. In these cases, you can use the `redactor add` command to add the sensitive information to the redactor, ensuring it is redacted from subsequent logs.

## Adding a value to the redactor

<%= render 'agent/cli/help/redactor_add' %>
