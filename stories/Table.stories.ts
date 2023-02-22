import { Meta, StoryFn } from '@storybook/html';
import cn from 'classnames';

enum TableType {
  Default = 'Default',
  NoFormatting = 'NoFormatting',
  TwoColumn = 'TwoColumn',
  NoWrap = 'NoWrap',
  FixedWidth = 'FixedWidth',
  Responsive = 'Responsive',
  Attribute = 'Attribute',
}

type TableArgs = {
  type: TableType;
  innerHtml: string;
}

const simpleTable = `
  <thead>
    <tr>
      <th>Package</th>
      <th>Size</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>at-least-node</code></td>
      <td>2.6 kB</td>
    </tr>
    <tr>
      <td><code>semver</code></td>
    </tr>
    <tr>
      <td>75.5 kB</td>
    </tr>
  </tbody>
`;

export default { 
  title: 'Components/Table',
  argTypes: {
    type: {
      control: false,
    },
    innerHtml: {
      control: false,
    },
  },
} as Meta;

const Template: StoryFn<TableArgs> = (args): HTMLElement => {
  const TextContent = document.createElement('div');
  TextContent.className = 'TextContent';
  
  const Table = document.createElement('table');
  Table.innerHTML = args.innerHtml;
  Table.className = cn(
    args.type === TableType.NoFormatting && 'no-formatting',
    args.type === TableType.TwoColumn && 'two-column',
    args.type === TableType.NoWrap && 'table--nowrap',
    args.type === TableType.FixedWidth && 'fixed-width',
    args.type === TableType.Responsive && 'responsive-table',
    args.type === TableType.Attribute && 'Docs__attribute__table'
  );

  TextContent.innerHTML = Table.outerHTML;
  return TextContent;
}

export const Default = Template.bind({});
Default.args = {
  type: TableType.Default,
  innerHtml: simpleTable,
};

export const NoFormatting = Template.bind({});
NoFormatting.args = {
  ...Default.args,
  type: TableType.NoFormatting,
};

export const TwoColumn = Template.bind({});
TwoColumn.args = {
  ...Default.args,
  type: TableType.TwoColumn,
  innerHtml: `
    <thead>
      <tr>
        <th>can progress to <code>skipped</code></th>
        <th>can progress to <code>canceling</code> or <code>canceled</code></th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><code>pending</code></td>
        <td><code>accepted</code></td>
      </tr>
      <tr>
        <td><code>waiting</code></td>
        <td><code>pending</code></td>
      </tr>
      <tr>
        <td><code>blocked</code></td>
        <td><code>limiting</code></td>
      </tr>
      <tr>
        <td><code>limiting</code></td>
        <td><code>limited</code></td>
      </tr>
      <tr>
        <td><code>limited</code></td>
        <td><code>blocked</code></td>
      </tr>
      <tr>
        <td><code>accepted</code></td>
        <td><code>unblocked</code></td>
      </tr>
      <tr>
        <td><code>broken</code></td>
        <td></td>
      </tr>
    </tbody>
  `
};

export const NoWrap = Template.bind({});
NoWrap.args = {
  ...Default.args,
  type: TableType.NoWrap,
  innerHtml: `
    <thead>
      <tr>
        <th>Hook</th>
        <th>Location Order</th>
        <th>Description</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><code>environment</code></td>
        <td>
          <span class="add-icon-agent">Agent</span><br />
          <span class="add-icon-plugin">Plugin (non-vendored)</span>
        </td>
        <td>Runs before all other hooks. Useful for <a href="/docs/pipelines/secrets#exporting-secrets-with-environment-hooks">exporting secret keys</a>.</td>
      </tr>
      <tr>
        <td><code>pre-checkout</code></td>
        <td>
          <span class="add-icon-agent">Agent</span><br />
          <span class="add-icon-plugin">Plugin (non-vendored)</span>
        </td>
        <td>Runs before checkout.</td>
      </tr>
      <tr>
        <td><code>checkout</code></td>
        <td>
          <span class="add-icon-plugin">Plugin (non-vendored)</span><br />
          <span class="add-icon-agent">Agent</span>
        </td>
        <td>
          Overrides the default git checkout behavior.<br />
          <em>Note:</em> As of Agent v3.15.0, if multiple checkout hooks are found, only the first will be run.
        </td>
      </tr>
      <tr>
        <td><code>post-checkout</code></td>
        <td>
          <span class="add-icon-agent">Agent</span><br />
          <span class="add-icon-repository">Repository</span><br />
          <span class="add-icon-plugin">Plugin (non-vendored)</span>
        </td>
        <td>Runs after checkout.</td>
      </tr>
      <tr>
        <td><code>environment</code></td>
        <td><span class="add-icon-plugin">Plugin (vendored)</span></td>
        <td>Unlike other plugins, environment hooks for vendored plugins run after checkout.</td>
      </tr>
      <tr>
        <td><code>pre-command</code></td>
        <td>
          <span class="add-icon-agent">Agent</span><br />
          <span class="add-icon-repository">Repository</span><br />
          <span class="add-icon-plugin">Plugin (non-vendored)</span><br />
          <span class="add-icon-plugin">Plugin (vendored)</span>
        </td>
        <td>Runs before the build command</td>
      </tr>
      <tr>
        <td><code>command</code></td>
        <td>
          <span class="add-icon-plugin">Plugin (non-vendored)</span><br />
          <span class="add-icon-plugin">Plugin (vendored)</span><br />
          <span class="add-icon-repository">Repository</span><br />
          <span class="add-icon-agent">Agent</span>
        </td>
        <td>Overrides the default command running behavior. If multiple command hooks are found, only the first will be run.</td>
      </tr>
      <tr>
        <td><code>post-command</code></td>
        <td>
          <span class="add-icon-agent">Agent</span><br />
          <span class="add-icon-repository">Repository</span><br />
          <span class="add-icon-plugin">Plugin (non-vendored)</span><br />
          <span class="add-icon-plugin">Plugin (vendored)</span>
        </td>
        <td>Runs after the command.</td>
      </tr>
      <tr>
        <td><code>pre-artifact</code></td>
        <td>
          <span class="add-icon-agent">Agent</span><br />
          <span class="add-icon-repository">Repository</span><br />
          <span class="add-icon-plugin">Plugin (non-vendored)</span><br />
          <span class="add-icon-plugin">Plugin (vendored)</span>
        </td>
        <td>Runs before artifacts are uploaded, if an artifact upload pattern was defined for the job.</td>
      </tr>
      <tr>
        <td><code>post-artifact</code></td>
        <td>
          <span class="add-icon-agent">Agent</span><br />
          <span class="add-icon-repository">Repository</span><br />
          <span class="add-icon-plugin">Plugin (non-vendored)</span><br />
          <span class="add-icon-plugin">Plugin (vendored)</span>
        </td>
        <td>Runs after artifacts have been uploaded, if an artifact upload pattern was defined for the job.</td>
      </tr>
      <tr>
        <td><code>pre-exit</code></td>
        <td>
          <span class="add-icon-agent">Agent</span><br />
          <span class="add-icon-repository">Repository</span><br />
          <span class="add-icon-plugin">Plugin (non-vendored)</span><br />
          <span class="add-icon-plugin">Plugin (vendored)</span>
        </td>
        <td>Runs before the job finishes. Useful for performing cleanup tasks.</td>
      </tr>
    </tbody>
  `
};

export const FixedWidth = Template.bind({});
FixedWidth.args = {
  ...Default.args,
  type: TableType.FixedWidth,
  innerHtml: `
    <tbody>
      <tr><th><code>X-Buildkite-Token</code></th><td>The webhook's token. <p class="Docs__api-param-eg"><em>Example:</em> <code>309c9c842g8565adecpd7469x6005989</code></p></td></tr>
      <tr><th><code>X-Buildkite-Signature</code></th><td>The signature created from your webhook payload, webhook token, and the SHA-256 hash function.<p class="Docs__api-param-eg"><em>Example:</em> <code>timestamp=1619071700,signature=30222eb518dc3fb61ec9e64dd78d163f62cb134a6ldb768f1d40e0edbn6e43f0</code></p></td></tr>
    </tbody>
  `
}

export const Responsive = Template.bind({});
Responsive.args = {
  ...Default.args,
  type: TableType.Responsive,
  innerHtml: `
    <tbody>
      <tr>
        <th><code>branch_configuration</code></th>
        <td>
          <p>A <a href="/docs/pipelines/branch-configuration#pipeline-level-branch-filtering">branch filter pattern</a> to limit which pushed branches trigger builds on this pipeline.</p>
          <p><em>Example:</em> <code>"master feature/*"</code><br><em>Default:</em> <code>null</code></p>
        </td>
      </tr>
      <tr>
        <th><code>cancel_running_branch_builds</code></th>
        <td>
          <p>Cancel intermediate builds. When a new build is created on a branch, any previous builds that are running on the same branch will be automatically canceled.</p>
          <p><em>Example:</em> <code>true</code><br><em>Default:</em> <code>false</code></p>
        </td>
      </tr>
      <tr>
        <th><code>cancel_running_branch_builds_filter</code></th>
        <td>
          <p>A <a href="/docs/pipelines/branch-configuration#branch-pattern-examples">branch filter pattern</a> to limit which branches intermediate build cancelling applies to.</p>
          <p><em>Example:</em> <code>"develop prs/*"</code><br><em>Default:</em> <code>null</code></p>
        </td>
      </tr>
      <tr>
        <th><code>default_branch</code></th>
        <td>
          <p>The name of the branch to prefill when new builds are created or triggered in Buildkite. It is also used to filter the builds and metrics shown on the Pipelines page.</p>
          <p><em>Example:</em> <code>"master"</code></p>
        </td>
      </tr>
      <tr>
        <th><code>description</code></th>
        <td>
          <p>The pipeline description.</p>
          <p><em>Example:</em> <code>":package: A testing pipeline"</code></p>
        </td>
      </tr>
      <tr>
        <th><code>env</code></th>
        <td>
          <p>The pipeline environment variables.</p>
          <p><em>Example:</em> <code>{"KEY":"value"}</code></p>
        </td>
      </tr>
      <tr>
        <th><code>provider_settings</code></th>
        <td>
          <p>The source provider settings. See the <a href="#provider-settings-properties">Provider Settings</a> section for accepted properties.</p>
          <p><em>Example:</em> <code>{ "publish_commit_status": true, "build_pull_request_forks": true }</code></p>
        </td>
      </tr>
      <tr>
        <th><code>skip_queued_branch_builds</code></th>
        <td>
          <p>Skip intermediate builds. When a new build is created on a branch, any previous builds that haven't yet started on the same branch will be automatically marked as skipped.</p>
          <p><em>Example:</em> <code>true</code><br><em>Default:</em> <code>false</code></p>
        </td>
      </tr>
      <tr>
        <th><code>skip_queued_branch_builds_filter</code></th>
        <td>
          <p>A <a href="/docs/pipelines/branch-configuration#branch-pattern-examples">branch filter pattern</a> to limit which branches intermediate build skipping applies to.</p>
          <p><em>Example:</em> <code>"!master"</code><br><em>Default:</em> <code>null</code></p>
        </td>
      </tr>
      <tr>
        <th><code>teams</code></th>
        <td>
          <p>An array of team UUIDs to add this pipeline to. Allows you to specify the access level for the pipeline in a team. The available access level options are:
          <ul>
            <li><code>read_only</code></li>
            <li><code>build_and_read</code></li>
            <li><code>manage_build_and_read</code></li>
          </ul>
          You can find your team's UUID either using the <a href="/docs/apis/graphql-api">GraphQL API</a>, or on the Settings page for a team. This property is only available if your organization has enabled Teams. Once your organization enables Teams, only administrators can create pipelines without providing team UUIDs. Replaces deprecated <code>team_uuids</code> parameter.</p>
          <p><em>Example:</em></p>
          <pre class="highlight shell" tabindex="0">
            <code>
              teams: {
                "14e9501c-69fe-4cda-ae07-daea9ca3afd3": "read_only",
                "5b6c4a01-8e4f-49a3-bf88-be0d47ef9c0a": "manage_build_and_read"
              }
            </code>
          </pre>
        </td>
      </tr>
    </tbody>
  `
};

export const Attribute = Template.bind({});
Attribute.args = {
  ...Default.args,
  type: TableType.Responsive,
  innerHtml: `
    <tr id="context"><th><code>--context value</code> <a class="Docs__attribute__link" href="#context">#</a></th><td><p>The context of the annotation used to differentiate this annotation from others<br /><strong>Environment variable</strong>: <code>$BUILDKITE_ANNOTATION_CONTEXT</code></p></td></tr>
    <tr id="style"><th><code>--style value</code> <a class="Docs__attribute__link" href="#style">#</a></th><td><p>The style of the annotation (<code>success</code>, <code>info</code>, <code>warning</code> or <code>error</code>)<br /><strong>Environment variable</strong>: <code>$BUILDKITE_ANNOTATION_STYLE</code></p></td></tr>
    <tr id="append"><th><code>--append </code> <a class="Docs__attribute__link" href="#append">#</a></th><td><p>Append to the body of an existing annotation<br /><strong>Environment variable</strong>: <code>$BUILDKITE_ANNOTATION_APPEND</code></p></td></tr>
    <tr id="job"><th><code>--job value</code> <a class="Docs__attribute__link" href="#job">#</a></th><td><p>Which job should the annotation come from<br /><strong>Environment variable</strong>: <code>$BUILDKITE_JOB_ID</code></p></td></tr>
    <tr id="agent-access-token"><th><code>--agent-access-token value</code> <a class="Docs__attribute__link" href="#agent-access-token">#</a></th><td><p>The access token used to identify the agent<br /><strong>Environment variable</strong>: <code>$BUILDKITE_AGENT_ACCESS_TOKEN</code></p></td></tr>
    <tr id="endpoint"><th><code>--endpoint value</code> <a class="Docs__attribute__link" href="#endpoint">#</a></th><td><p>The Agent API endpoint (default: "<code>https://agent.buildkite.com/v3</code>")<br /><strong>Environment variable</strong>: <code>$BUILDKITE_AGENT_ENDPOINT</code></p></td></tr>
    <tr id="no-http2"><th><code>--no-http2 </code> <a class="Docs__attribute__link" href="#no-http2">#</a></th><td><p>Disable HTTP2 when communicating with the Agent API.<br /><strong>Environment variable</strong>: <code>$BUILDKITE_NO_HTTP2</code></p></td></tr>
    <tr id="debug-http"><th><code>--debug-http </code> <a class="Docs__attribute__link" href="#debug-http">#</a></th><td><p>Enable HTTP debug mode, which dumps all request and response bodies to the log<br /><strong>Environment variable</strong>: <code>$BUILDKITE_AGENT_DEBUG_HTTP</code></p></td></tr>
    <tr id="no-color"><th><code>--no-color </code> <a class="Docs__attribute__link" href="#no-color">#</a></th><td><p>Don't show colors in logging<br /><strong>Environment variable</strong>: <code>$BUILDKITE_AGENT_NO_COLOR</code></p></td></tr>
    <tr id="debug"><th><code>--debug </code> <a class="Docs__attribute__link" href="#debug">#</a></th><td><p>Enable debug mode. Synonym for <code>--log-level debug</code>. Takes precedence over <code>--log-level</code><br /><strong>Environment variable</strong>: <code>$BUILDKITE_AGENT_DEBUG</code></p></td></tr>
    <tr id="log-level"><th><code>--log-level value</code> <a class="Docs__attribute__link" href="#log-level">#</a></th><td><p>Set the log level for the agent, making logging more or less verbose. Defaults to notice. Allowed values are: debug, info, error, warn, fatal (default: "notice")<br /><strong>Environment variable</strong>: <code>$BUILDKITE_AGENT_LOG_LEVEL</code></p></td></tr>
    <tr id="experiment"><th><code>--experiment value</code> <a class="Docs__attribute__link" href="#experiment">#</a></th><td><p>Enable experimental features within the buildkite-agent<br /><strong>Environment variable</strong>: <code>$BUILDKITE_AGENT_EXPERIMENT</code></p></td></tr>
    <tr id="profile"><th><code>--profile value</code> <a class="Docs__attribute__link" href="#profile">#</a></th><td><p>Enable a profiling mode, either cpu, memory, mutex or block<br /><strong>Environment variable</strong>: <code>$BUILDKITE_AGENT_PROFILE</code></p></td></tr>
  `,
}