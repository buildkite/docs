---
#  _____   ____    _   _  ____ _______   ______ _____ _____ _______
#  |  __  / __   |  | |/ __ __   __| |  ____|  __ _   _|__   __|
#  | |  | | |  | | |  | | |  | | | |    | |__  | |  | || |    | |
#  | |  | | |  | | | . ` | |  | | | |    |  __| | |  | || |    | |
#  | |__| | |__| | | |  | |__| | | |    | |____| |__| || |_   | |
#  |_____/ ____/  |_| _|____/  |_|    |______|_____/_____|  |_|
#  This file is auto-generated by script/generate_graphql_api_content.sh,
#  please build the schema.graphql by running `rails graphql:update_reference_schema`
#  with https://github.com/buildkite/buildkite/,
#  replace the content in data/schema.graphql
#  and run the generation script `./scripts/generate-graphql-api-content.sh`.

title: HostedAgentInstanceShape – Objects – GraphQL API
toc: false
---
<!-- vale off -->
<h1 class="has-pills">
  HostedAgentInstanceShape
  <span data-algolia-exclude><span class="pill pill--object pill--normal-case pill--large"><code>OBJECT</code></span></span>
</h1>
<!-- vale on -->


The hosted agent instance configuration for this cluster queue

<table class="responsive-table responsive-table--single-column-rows">
  <thead>
    <th>
      <h2 data-algolia-exclude>Fields</h2>
    </th>
  </thead>
  <tbody>
    <tr><td><h3 class="is-small has-pills"><code>architecture</code><a href="/docs/apis/graphql/schemas/enum/hostedagentarchitecture" class="pill pill--enum pill--normal-case pill--medium" title="Go to ENUM HostedAgentArchitecture"><code>HostedAgentArchitecture</code></a></h3><p>Specifies the architecture of the hosted agent instance, such as AMD64 (x86_64) or ARM64 (AArch64), used in this cluster queue.</p></td></tr><tr><td><h3 class="is-small has-pills"><code>machineType</code><a href="/docs/apis/graphql/schemas/enum/hostedagentmachinetype" class="pill pill--enum pill--normal-case pill--medium" title="Go to ENUM HostedAgentMachineType"><code>HostedAgentMachineType</code></a></h3><p>Specifies the type of machine used for the hosted agent instance in this cluster queue (e.g., Linux or MacOS).</p></td></tr><tr><td><h3 class="is-small has-pills"><code>memory</code><a href="/docs/apis/graphql/schemas/scalar/int" class="pill pill--scalar pill--normal-case pill--medium" title="Go to SCALAR Int"><code>Int</code></a></h3><p>The amount of memory (in GB) available on each hosted agent instance in this cluster queue.</p></td></tr><tr><td><h3 class="is-small has-pills"><code>name</code><a href="/docs/apis/graphql/schemas/enum/hostedagentinstanceshapename" class="pill pill--enum pill--normal-case pill--medium" title="Go to ENUM HostedAgentInstanceShapeName"><code>HostedAgentInstanceShapeName</code></a></h3><p>Name of the instance shape</p></td></tr><tr><td><h3 class="is-small has-pills"><code>size</code><a href="/docs/apis/graphql/schemas/enum/hostedagentsize" class="pill pill--enum pill--normal-case pill--medium" title="Go to ENUM HostedAgentSize"><code>HostedAgentSize</code></a></h3><p>The overall size classification of the hosted agent instance, combining vCPU and memory, used in this cluster queue.</p></td></tr><tr><td><h3 class="is-small has-pills"><code>vcpu</code><a href="/docs/apis/graphql/schemas/scalar/int" class="pill pill--scalar pill--normal-case pill--medium" title="Go to SCALAR Int"><code>Int</code></a></h3><p>The number of CPU cores allocated to the hosted agent instance in this cluster queue.</p></td></tr>
  </tbody>
</table>