<table class="responsive-table">
<tbody>
  <tr>
    <th><code>period</code></th>
    <td>
      <span>Aggregates metrics over the given relative time <code>period</code>, for example <code>7days</code> or <code>28days</code>. The periods available to your organization depend on its maximum time window quota. Cannot be combined with <code>min_timestamp</code> or <code>max_timestamp</code>.</span>
      <p class="Docs__api-param-eg"><em>Example:</em> <code>?period=28days</code></p>
      <p>Available with <code>Buildkite-Version</code> header >= <code>2026-08-01</code></p>
    </td>
  </tr>
  <tr>
    <th><code>min_timestamp</code></th>
    <td>
      <span>The start of the aggregation window, as an ISO 8601 timestamp. Defaults to your organization's default period before the current time. Cannot be combined with <code>period</code>.</span>
      <p class="Docs__api-param-eg"><em>Example:</em> <code>?min_timestamp=2026-07-01T00:00:00Z</code></p>
      <p>Available with <code>Buildkite-Version</code> header >= <code>2026-08-01</code></p>
    </td>
  </tr>
  <tr>
    <th><code>max_timestamp</code></th>
    <td>
      <span>The end of the aggregation window, as an ISO 8601 timestamp. Defaults to the current time. Cannot be combined with <code>period</code>.</span>
      <p class="Docs__api-param-eg"><em>Example:</em> <code>?max_timestamp=2026-07-23T00:00:00Z</code></p>
      <p>Available with <code>Buildkite-Version</code> header >= <code>2026-08-01</code></p>
    </td>
  </tr>
</tbody>
</table>
