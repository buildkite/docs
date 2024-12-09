<table>
<tbody>
  <tr>
    <th>
      <code>search</code>
    </th>
    <td>
      <span>Returns flaky tests with a <code>name</code> or <code>scope</code> that contains the search string. Users with the <a href="/docs/test-engine/ruby-collectors">Ruby test collector</a> installed can also filter results by <code>location</code>.</span>
      <p class="Docs__api-param-eg"><em>Example:</em> <code>?search="User#find_email"</code>, <code>?search="/billing_spec"</code></p>
    </td>
  </tr>
  <tr>
    <th>
      <code>branch</code>
    </th>
    <td>
      <span>Returns flaky tests for flakes detected one or more times on the branch whose name is specified by the <code>branch</code> value.</span>
      <p class="Docs__api-param-eg"><em>Example:</em> <code>?branch=main</code></p>
    </td>
  </tr>
</tbody>
</table>
