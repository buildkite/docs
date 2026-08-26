<table class="responsive-table">
<tbody>
  <tr>
    <th><code>labels</code></th>
    <td>
      <span>Filters the results by a comma-separated list of test labels. Cannot be combined with <code>label</code>.</span>
      <p class="Docs__api-param-eg"><em>Example:</em> <code>?labels=flaky,!slow</code></p>
      <p><em>Supported operators:</em> <code>!</code></p>
      <p>Available with <code>Buildkite-Version</code> header >= <code>2026-08-01</code></p>
    </td>
  </tr>
  <tr>
    <th><code>label</code></th>
    <td>
      <span>Filters the results by a single test label. This parameter is a legacy alternative to <code>labels</code> and cannot be combined with it.</span>
      <p class="Docs__api-param-eg"><em>Example:</em> <code>?label=flaky</code></p>
    </td>
  </tr>
  <tr>
    <th><code>branch</code></th>
    <td>
      <span>Only aggregates executions from the branch whose name is specified by the <code>branch</code> value.</span>
      <p class="Docs__api-param-eg"><em>Example:</em> <code>?branch=main</code></p>
      <p><em>Supported operators:</em> <code>! *</code></p>
      <p>Available with <code>Buildkite-Version</code> header >= <code>2026-08-01</code></p>
    </td>
  </tr>
  <tr>
    <th><code>owners</code></th>
    <td>
      <span>Filters the results by a comma-separated list of test owner slugs.</span>
      <p class="Docs__api-param-eg"><em>Example:</em> <code>?owners=my-team,another-team</code></p>
      <p><em>Supported operators:</em> <code>!</code></p>
      <p>Available with <code>Buildkite-Version</code> header >= <code>2026-08-01</code></p>
    </td>
  </tr>
  <tr>
    <th><code>state</code></th>
    <td>
      <span>Filters the results by test state. Valid values are <code>enabled</code>, <code>muted</code>, and <code>skipped</code>.</span>
      <p class="Docs__api-param-eg"><em>Example:</em> <code>?state=muted</code></p>
      <p>Available with <code>Buildkite-Version</code> header >= <code>2026-08-01</code></p>
    </td>
  </tr>
  <tr>
    <th><code>tags</code></th>
    <td>
      <span>Filters the results by a comma-separated list of execution tags, using <code>key:value</code> syntax.</span>
      <p class="Docs__api-param-eg"><em>Example:</em> <code>?tags=framework:rspec,ci:true</code></p>
      <p><em>Supported operators:</em> <code>! *</code>. The <code>result</code> tag also supports <code>^ ~</code>.</p>
      <p>Available with <code>Buildkite-Version</code> header >= <code>2026-08-01</code></p>
    </td>
  </tr>
  <tr>
    <th><code>sort_by</code></th>
    <td>
      <span>The metric to sort the results by. Valid values are <code>duration_avg</code>, <code>duration_sum</code>, <code>duration_min</code>, <code>duration_max</code>, and <code>reliability</code>. The default value is <code>duration_avg</code>.</span>
      <p class="Docs__api-param-eg"><em>Example:</em> <code>?sort_by=reliability</code></p>
      <p>Available with <code>Buildkite-Version</code> header >= <code>2026-08-01</code></p>
    </td>
  </tr>
  <tr>
    <th><code>order</code></th>
    <td>
      <span>The direction to sort the results in. Valid values are <code>asc</code> and <code>desc</code>. The default value is <code>desc</code>.</span>
      <p class="Docs__api-param-eg"><em>Example:</em> <code>?order=asc</code></p>
      <p>Available with <code>Buildkite-Version</code> header >= <code>2026-08-01</code></p>
    </td>
  </tr>
  <tr>
    <th><code>page</code></th>
    <td>The page number to return. Defaults to <code>1</code>.</td>
  </tr>
  <tr>
    <th><code>per_page</code></th>
    <td>The number of results to return per page. Defaults to <code>30</code> and has a maximum of <code>100</code>.</td>
  </tr>
  <tr>
    <th><code>min_executions</code></th>
    <td>
      <span>Only returns tests with at least this many executions in the requested time window, after the filters are applied. Must be a positive integer.</span>
      <p class="Docs__api-param-eg"><em>Example:</em> <code>?min_executions=10</code></p>
      <p>Available with <code>Buildkite-Version</code> header >= <code>2026-08-01</code></p>
    </td>
  </tr>
</tbody>
</table>
