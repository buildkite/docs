<table class="responsive-table">
<tbody>
  <tr>
    <th><code>Buildkite-Version</code></th>
    <td>
      Request an API version using a date in <code>YYYY-MM-DD</code> format. Set to <code>2026-08-01</code> or a later date to receive test metrics in the response. Without this header, or with a date before <code>2026-08-01</code>, the response uses the legacy format without metrics.
      <p class="Docs__api-param-eg"><em>Example:</em> <code>Buildkite-Version: 2026-08-01</code></p>
    </td>
  </tr>
</tbody>
</table>

> 📘 Invalid format returns an error
> If a non-blank `Buildkite-Version` header value is not in `YYYY-MM-DD` format, the API returns a `400` response with `{"message": "Buildkite-Version must be in format YYYY-MM-DD"}`. A blank value is treated as an omitted header, so the API returns the legacy `200` response instead.
