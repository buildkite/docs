<table data-attributes data-attributes-required>
  <thead>
    <tr>
      <th>Claim</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
  <tr>
    <td><code>iss</code></td>
    <td>
      <p>Issuer</p>
      <p>Identifies the entity that issued the JWT.</p>
      <p><em>Example:</em> <code>https://agent.buildkite.com</code></p>
    </td>
  </tr>
   <tr>
    <td><code>sub</code></td>
    <td>
      <p>Subject</p>
      <p>Identifies the subject of the JWT, typically representing the user or entity being authenticated.</p>
      <p><em>Format:</em>
        <code>organization:ORGANIZATION_SLUG:pipeline:PIPELINE_SLUG:ref:REF:commit:BUILD_COMMIT:step:STEP_KEY</code>.
        If the build has a tag, <code>REF</code> is <code>refs/tags/TAG</code>. Otherwise, <code>REF</code> is
        <code>refs/heads/BRANCH</code>.</p>
      <p><em>Example:</em><code>organization:acme-inc:pipeline:super-duper-                app:ref:refs/heads/main:commit:9f3182061f1e2cca4702c368cbc039b7dc9d4485:step:build</code></p>
    </td>
  </tr>
   <tr>
    <td><code>aud</code></td>
    <td>
      <p>Audience</p>
      <p>Identifies the intended audience for the JWT. Defaults to <code>https://buildkite.com/ORGANIZATION_SLUG</code>
         but can be overridden using the <code>--audience</code> flag</p>
    </td>
  </tr>
   <tr>
    <td><code>exp</code></td>
    <td>
      <p>Expiration time</p>
      <p>Specifies the expiration time of the JWT, after which the token is no longer valid. Defaults to 5 minutes in the
        future at generation, but can be overridden using the <code>--lifetime</code> flag.</p>
      <p><em>Example:</em> <code>1669015898</code></p>
    </td>
  </tr>
   <tr>
    <td><code>nbf</code></td>
    <td>
      <p>Not before</p>
      <p>Specifies the time before which the JWT must not be accepted for processing. Set to the current timestamp at generation.</p>
      <p><em>Example:</em> <code>1669014898</code></p>
    </td>
  </tr>
   <tr>
    <td><code>iat</code></td>
    <td>
      <p>Issued at</p>
      <p>Specifies the time at which the JWT was issued. Set to the current timestamp at generation.</p>
      <p><em>Example:</em> <code>1669014898</code></p>
    </td>
  </tr>
   <tr>
    <td><code>organization_slug</code></td>
    <td>
      <p>The organization's slug.</p>
      <p><em>Example:</em> <code>acme-inc</code></p>
    </td>
  </tr>
   <tr>
    <td><code>pipeline_slug</code></td>
    <td>
      <p>The pipeline's slug.</p>
      <p><em>Example:</em> <code>super-duper-app</code></p>
    </td>
  </tr>
   <tr>
    <td><code>build_number</code></td>
    <td>
      <p>The build number.</p>
      <p><em>Example:</em> <code>1</code></p>
    </td>
  </tr>
   <tr>
    <td><code>build_branch</code></td>
    <td>
      <p>The repository branch used in the build.</p>
      <p><em>Example:</em> <code>main</code></p>
    </td>
  </tr>
  <tr>
    <td><code>build_tag</code></td>
    <td>
      <p>The tag of the build if enabled in Buildkite. This claim is only included if the tag is set.</p>
      <p><em>Example:</em> <code>1</code></p>
    </td>
  </tr>
  <tr>
    <td><code>build_commit</code></td>
    <td>
      <p>The SHA commit from the repository.</p>
      <p><em>Example:</em> <code>9f3182061f1e2cca4702c368cbc039b7dc9d4485</code></p>
    </td>
  </tr>
  <tr>
    <td><code>step_key</code></td>
    <td>
      <p>The <code>key</code> attribute of the step from the pipeline. If the key is not set for the step,
        <code>nil</code> is returned.</p>
      <p><em>Example:</em> <code>build_step</code></p>
    </td>
  </tr>
  <tr>
    <td><code>job_id</code></td>
    <td>
      <p>The job UUID.</p>
      <p><em>Example:</em> <code>0184990a-477b-4fa8-9968-496074483cee</code></p>
    </td>
  </tr>
  <tr>
    <td><code>agent_id</code></td>
    <td>
      <p>The agent UUID.</p>
      <p><em>Example:</em> <code>0184990a-4782-42b5-afc1-16715b10b8ff</code></p>
    </td>
  </tr>
  </tbody>
</table>

### Optional claims

Generate these additional claims by adding `--claims` to the `buildkite-agent oidc request-token` command.

<table data-attributes data-attributes-required>
  <thead>
    <tr>
      <th>Claim</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
  <tr>
    <td><code>organization_id</code></td>
    <td>
      <p>The organization UUID.</p>
      <p><em>Example:</em> <code>0184990a-477b-4fa8-9968-496074483k77</code></p>
    </td>
  </tr>
  <tr>
    <td><code>pipeline_id</code></td>
    <td>
      <p>The pipeline UUID.</p>
      <p><em>Example:</em> <code>0184990a-4782-42b5-afc1-16715b10b1l0</code></p>
    </td>
  </tr>
  </tbody>
</table>
