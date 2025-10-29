---
toc: false
---

# Configuration parameters

The Elastic CI Stack for AWS can be configured using parameters in AWS CloudFormation or variables in Terraform. This page provides a complete reference of all available configuration options.

> 📘 Deployment method
> If you're using AWS CloudFormation, see the [CloudFormation setup guide](/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/setup). If you're using Terraform, see the [Terraform deployment guide](/docs/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/terraform).

The following tables list all of the available configuration parameters. For CloudFormation deployments, these are parameters in the [`aws-stack.yml` template](https://github.com/buildkite/elastic-ci-stack-for-aws/blob/-/templates/aws-stack.yml). For Terraform deployments, these are variables in the [Terraform module](https://github.com/buildkite/terraform-buildkite-elastic-ci-stack-for-aws).

Note that you must provide a value for the Buildkite Agent token (CloudFormation: [`BuildkiteAgentTokenParameterStorePath`](#BuildkiteAgentTokenParameterStorePath) or [`BuildkiteAgentToken`](#BuildkiteAgentToken); Terraform: `agent_token_parameter_store_path` or `agent_token`) to use the stack. All other parameters are optional.


<!--
  _____   ____    _   _  ____ _______   ______ _____ _____ _______
 |  __ \ / __ \  | \ | |/ __ \__   __| |  ____|  __ \_   _|__   __|
 | |  | | |  | | |  \| | |  | | | |    | |__  | |  | || |    | |
 | |  | | |  | | | . ` | |  | | | |    |  __| | |  | || |    | |
 | |__| | |__| | | |\  | |__| | | |    | |____| |__| || |_   | |
 |_____/ \____/  |_| \_|\____/  |_|    |______|_____/_____|  |_|

The template below provides correct layouts for auto-generated configuration tables based on script/generate-elastic-ci-stack-for-aws-parameters.sh.
Proceed with caution.
-->

<!-- vale off -->

<%
metadata = AWS_STACK['Metadata']
interface = metadata['AWS::CloudFormation::Interface']
parameter_groups = interface['ParameterGroups']

parameters = AWS_STACK['Parameters']
cf_tf_mapping = defined?(CLOUDFORMATION_TERRAFORM_MAPPING) ? CLOUDFORMATION_TERRAFORM_MAPPING : {}

def escape_colons(x)
  if x.is_a? String
    x.gsub(/:(.+?):/, '\:\1\:')
  else
    x
  end
end
%>

<% parameter_groups.each do |group| %>
<h2><%= group['Label']['default'] %></h2>

<table>
	<tbody>
		<tr>
			<th>CloudFormation parameter</th>
			<th>Terraform variable</th>
			<th>Description</th>
		</tr>
		<% group['Parameters'].each do |parameter_name| %>
			<% parameter = parameters[parameter_name] %>
			<% tf_mapping = cf_tf_mapping[parameter_name] %>
			<tr id="<%= parameter_name %>">
				<td>
					<code><%= parameter_name %></code>
					<br><code>(<%= parameter['Type'] %>)</code>
				</td>
				<td style="white-space: nowrap;">
					<% if tf_mapping && tf_mapping != "N/A" %>
						<code><%= tf_mapping['variable'] %></code>
						<br><code>(<%= tf_mapping['type'] %>)</code>
					<% else %>
						<em>N/A</em>
					<% end %>
				</td>
				<td>
					<%= parameter['Description'] %>

					<% if allowed = escape_colons(parameter['AllowedValues']) %>
						<br/><strong>Allowed Values</strong>:
							<ul>
								<% allowed.each do |allow| %>
									<li><code><%= allow %></code></li>
								<% end %>
							</ul>
					<% end %>

					<% if parameter['Default'] && parameter['Default'] != "" %>
						<br/><strong>Default Value:</strong> <code><%= escape_colons(parameter['Default']) %></code>
					<% end %>

					<% if pattern = parameter['AllowedPattern'] %>
						<br/><strong>Allowed Pattern:</strong> <code><%= escape_colons(pattern) %></code>
					<% end %>

					<% if minLength = parameter['MinLength'] %>
						<br/><strong>Minimum Length:</strong> <%= minLength %>
					<% end %>

					<% if maxLength = parameter['MaxLength'] %>
						<br/><strong>Maximum Length:</strong> <%= maxLength %>
					<% end %>

					<% if minValue = parameter['MinValue'] %>
						<br/><strong>Minimum Value:</strong> <%= minValue %>
					<% end %>

					<% if maxValue = parameter['MaxValue'] %>
						<br/><strong>Maximum Value:</strong> <%= maxValue %>
					<% end %>

				</td>
			</tr>
		<% end %>
	</tbody>
</table>
<% end %>

<!-- vale on -->
