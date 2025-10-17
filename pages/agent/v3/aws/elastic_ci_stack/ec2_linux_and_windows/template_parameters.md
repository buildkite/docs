---
toc: false
---

# Template parameters in the Elastic CI Stack for AWS

To create an Auto Scaling group and the launch template for the Elastic CI Stack for AWS deployment, you can either use the default YAML config file, or you can copy it, and substitute that YAML config file with your own configuration file when you create new instances.

The following tables list all the available parameters for the [`aws-stack.yml` template](https://github.com/buildkite/elastic-ci-stack-for-aws/blob/-/templates/aws-stack.yml) which creates an Auto Scaling group and the launch template for the Elastic CI Stack for AWS deployment.

You can use these parameters to configure the EC2 instances to suit your needs.

Note that you must provide a value for one of [`BuildkiteAgentTokenParameterStorePath`](#BuildkiteAgentTokenParameterStorePath)
or [`BuildkiteAgentToken`](#BuildkiteAgentToken) to be able to use `aws-stack.yml` template, all other parameters are optional.


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
			<th>Parameter</th>
			<th>Description</th>
		</tr>
		<% group['Parameters'].each do |parameter_name| %>
			<% parameter = parameters[parameter_name] %>
			<tr id="<%= parameter_name %>">
				<td>
					<code><%= parameter_name %></code>
					<br><code>(<%= parameter['Type'] %>)</code>
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
