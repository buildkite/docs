<table>
  <tr>
    <td><code>if_changed</code></td>
    <td>
      A <a href="/docs/pipelines/configure/glob-pattern-syntax">glob pattern</a> that omits the step from a build if it does not match any files changed in the build. <br/>
      <em>Example:</em> <code>"{**.go,go.mod,go.sum,fixtures/**}"</code><br/>
      From version 3.109.0 of the Buildkite agent, <code>if_changed</code> also supports lists of glob patterns and <code>include</code> and <code>exclude</code> attributes.<br/>
      <em>Minimum Buildkite agent versions:</em> 3.99 (with <code>--apply-if-changed</code> flag), 3.103.0 (enabled by default), 3.109.0 (expanded syntax)
    </td>
  </tr>
</table>

For an example pipeline, demonstrating various forms of `if_changed`, see [Using `if_changed`](/docs/pipelines/configure/dynamic-pipelines/if-changed).
