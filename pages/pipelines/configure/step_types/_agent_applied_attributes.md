These attributes are only applied by the Buildkite Agent when uploading a pipeline (`buildkite-agent pipeline upload`), since they require direct access to your code or repository to process correctly.

<table>
  <tr>
    <td><code>if_changed</code></td>
    <td>
      A <a href="/docs/pipelines/configure/glob-pattern-syntax">glob pattern</a> that omits the step from a build if it does not match any files changed in the build. <br/>
      <em>Example:</em> <code>{**.go,go.mod,go.sum,fixtures/**}</code><br/>
      <em>Minimum Buildkite Agent version:</em> v3.99 (with <code>--apply-if-changed</code> flag), v3.103.0 (enabled by default)
    </td>
  </tr>
</table>

> 🚧
> Agent-applied attributes are not accepted in pipelines set using the Buildkite interface.
