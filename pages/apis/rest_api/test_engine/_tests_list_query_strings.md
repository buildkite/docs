<table class="responsive-table">
<tbody>
  <tr>
    <th><code>label</code></th>
    <td><span>Filters the results by a single test label. Cannot be combined with <code>labels</code>.</span>
      <p class="Docs__api-param-eg"><em>Example:</em> <code>?label=flaky</code></p></td>
  </tr>
  <tr>
    <th><code>labels</code></th>
    <td><span>Comma-separated test label filters. Prefix a label with <code>!</code> to exclude it.</span>
      <p class="Docs__api-param-eg"><em>Example:</em> <code>?labels=flaky,!slow</code></p></td>
  </tr>
  <tr>
    <th><code>branch</code></th>
    <td><span>Filters the results to executions from the specified branch.</span>
      <p class="Docs__api-param-eg"><em>Example:</em> <code>?branch=main</code></p></td>
  </tr>
  <tr>
    <th><code>owners</code></th>
    <td><span>Comma-separated test owner slugs.</span>
      <p class="Docs__api-param-eg"><em>Example:</em> <code>?owners=frontend-team,backend-team</code></p></td>
  </tr>
  <tr>
    <th><code>state</code></th>
    <td><span>Filters the results by test state: <code>enabled</code>, <code>muted</code>, or <code>skipped</code>.</span>
      <p class="Docs__api-param-eg"><em>Example:</em> <code>?state=muted</code></p></td>
  </tr>
  <tr>
    <th><code>tags</code></th>
    <td><span>Comma-separated execution tag filters using <code>key:value</code> syntax.</span>
      <p class="Docs__api-param-eg"><em>Example:</em> <code>?tags=framework:rspec,language:ruby</code></p></td>
  </tr>
  <tr>
    <th><code>sort_by</code></th>
    <td><span>Metric to sort by: <code>duration_avg</code> (default), <code>duration_sum</code>, <code>duration_min</code>, <code>duration_max</code>, or <code>reliability</code>.</span>
      <p class="Docs__api-param-eg"><em>Example:</em> <code>?sort_by=reliability</code></p></td>
  </tr>
  <tr>
    <th><code>order</code></th>
    <td><span>Sort direction: <code>asc</code> or <code>desc</code> (default).</span>
      <p class="Docs__api-param-eg"><em>Example:</em> <code>?order=asc</code></p></td>
  </tr>
  <tr>
    <th><code>period</code></th>
    <td><span>Relative aggregation period, for example <code>7days</code> or <code>28days</code>. Available periods depend on the organization's maximum time-window quota. Cannot be combined with <code>min_timestamp</code> or <code>max_timestamp</code>.</span>
      <p class="Docs__api-param-eg"><em>Example:</em> <code>?period=7days</code></p></td>
  </tr>
  <tr>
    <th><code>max_timestamp</code></th>
    <td><span>End of the aggregation window as an ISO 8601 timestamp. Defaults to the current time. Cannot be combined with <code>period</code>.</span>
      <p class="Docs__api-param-eg"><em>Example:</em> <code>?max_timestamp=2026-07-23T00:00:00Z</code></p></td>
  </tr>
  <tr>
    <th><code>min_timestamp</code></th>
    <td><span>Start of the aggregation window as an ISO 8601 timestamp. Defaults to the organization's default period before the current time. Cannot be combined with <code>period</code>.</span>
      <p class="Docs__api-param-eg"><em>Example:</em> <code>?min_timestamp=2026-07-16T00:00:00Z</code></p></td>
  </tr>
</tbody>
</table>
