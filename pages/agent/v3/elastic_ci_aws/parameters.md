# Elastic CI Stack for AWS Parameters

The following tables list all the available template parameters. These can be
used to customise a stack deployment for your needs.

You must provide a value for one of [`BuildkiteAgentTokenParameterStorePath`](#BuildkiteAgentTokenParameterStorePath)
or [`BuildkiteAgentToken`](#BuildkiteAgentToken), all other parameters are
optional.

{:toc}

<!-- vale off -->




<h2>Buildkite Configuration</h2>

<table>
	<tbody>
		<tr>
  			<th>Parameter</th>
  			<th>Description</th>
  			<th>Type</th>
  			<th>Default Value</th>
  			<th>Constraints</th>
		</tr>
		
		
		<tr id="BuildkiteAgentTokenParameterStorePath">
			<td><code>BuildkiteAgentTokenParameterStorePath</code></td>
			<td>AWS SSM path to the Buildkite agent registration token (this takes precedence over BuildkiteAgentToken). Expects a leading slash ('/').</td>
			<td><code>String</code></td>
			<td></td>
			<td>
				<table>
					<tbody>
						

						
							<th>Allowed Pattern</th>
							<td><code>^$|^/[a-zA-Z0-9_.\-/]+$</code></td>
						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="BuildkiteAgentTokenParameterStoreKMSKey">
			<td><code>BuildkiteAgentTokenParameterStoreKMSKey</code></td>
			<td>AWS KMS key ID used to encrypt the SSM parameter (if encrypted)</td>
			<td><code>String</code></td>
			<td></td>
			<td>
				<table>
					<tbody>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="BuildkiteAgentToken">
			<td><code>BuildkiteAgentToken</code></td>
			<td>Buildkite agent registration token. Deprecated, use BuildkiteAgentTokenParameterStorePath instead.</td>
			<td><code>String</code></td>
			<td></td>
			<td>
				<table>
					<tbody>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="BuildkiteQueue">
			<td><code>BuildkiteQueue</code></td>
			<td>Queue name that agents will use, targeted in pipeline steps using "queue={value}"</td>
			<td><code>String</code></td>
			<td>default</td>
			<td>
				<table>
					<tbody>
						

						

						
							<th>Minimum Length</th>
							<td>1</td>
						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
	</tbody>
</table>

<h2>Advanced Buildkite Configuration</h2>

<table>
	<tbody>
		<tr>
  			<th>Parameter</th>
  			<th>Description</th>
  			<th>Type</th>
  			<th>Default Value</th>
  			<th>Constraints</th>
		</tr>
		
		
		<tr id="BuildkiteAgentRelease">
			<td><code>BuildkiteAgentRelease</code></td>
			<td></td>
			<td><code>String</code></td>
			<td>stable</td>
			<td>
				<table>
					<tbody>
						
    						<th>Allowed Values</th>
    						<td>
    							<ul>
    								
    									<li><code>stable</code></li>
									
    									<li><code>beta</code></li>
									
    									<li><code>edge</code></li>
									
    							</ul>
    						</td>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="BuildkiteAgentTags">
			<td><code>BuildkiteAgentTags</code></td>
			<td>Additional tags separated by commas to provide to the agent. E.g os=linux,llamas=always</td>
			<td><code>String</code></td>
			<td></td>
			<td>
				<table>
					<tbody>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="BuildkiteAgentTimestampLines">
			<td><code>BuildkiteAgentTimestampLines</code></td>
			<td>Set to true to prepend timestamps to every line of output</td>
			<td><code>String</code></td>
			<td>false</td>
			<td>
				<table>
					<tbody>
						
    						<th>Allowed Values</th>
    						<td>
    							<ul>
    								
    									<li><code>true</code></li>
									
    									<li><code>false</code></li>
									
    							</ul>
    						</td>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="BuildkiteAgentExperiments">
			<td><code>BuildkiteAgentExperiments</code></td>
			<td>Agent experiments to enable, comma delimited. See https://github.com/buildkite/agent/blob/master/EXPERIMENTS.md.</td>
			<td><code>String</code></td>
			<td></td>
			<td>
				<table>
					<tbody>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="BuildkiteTerminateInstanceAfterJob">
			<td><code>BuildkiteTerminateInstanceAfterJob</code></td>
			<td>Set to "true" to terminate the instance after a job has completed.</td>
			<td><code>String</code></td>
			<td>false</td>
			<td>
				<table>
					<tbody>
						
    						<th>Allowed Values</th>
    						<td>
    							<ul>
    								
    									<li><code>true</code></li>
									
    									<li><code>false</code></li>
									
    							</ul>
    						</td>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="BuildkiteAdditionalSudoPermissions">
			<td><code>BuildkiteAdditionalSudoPermissions</code></td>
			<td>Optional - Comma separated list of commands to allow the buildkite-agent user to run using sudo.</td>
			<td><code>String</code></td>
			<td></td>
			<td>
				<table>
					<tbody>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="BuildkiteWindowsAdministrator">
			<td><code>BuildkiteWindowsAdministrator</code></td>
			<td>Set to "true" to add the local "buildkite-agent" user account to the local Windows Administrator group.</td>
			<td><code>String</code></td>
			<td>true</td>
			<td>
				<table>
					<tbody>
						
    						<th>Allowed Values</th>
    						<td>
    							<ul>
    								
    									<li><code>true</code></li>
									
    									<li><code>false</code></li>
									
    							</ul>
    						</td>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
	</tbody>
</table>

<h2>Network Configuration</h2>

<table>
	<tbody>
		<tr>
  			<th>Parameter</th>
  			<th>Description</th>
  			<th>Type</th>
  			<th>Default Value</th>
  			<th>Constraints</th>
		</tr>
		
		
		<tr id="VpcId">
			<td><code>VpcId</code></td>
			<td>Optional - Id of an existing VPC to launch instances into. Leave blank to have a new VPC created</td>
			<td><code>String</code></td>
			<td></td>
			<td>
				<table>
					<tbody>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="Subnets">
			<td><code>Subnets</code></td>
			<td>Optional - Comma separated list of two existing VPC subnet ids where EC2 instances will run. Required if setting VpcId.</td>
			<td><code>CommaDelimitedList</code></td>
			<td></td>
			<td>
				<table>
					<tbody>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="AvailabilityZones">
			<td><code>AvailabilityZones</code></td>
			<td>Optional - Comma separated list of AZs that subnets are created in (if Subnets parameter is not specified)</td>
			<td><code>CommaDelimitedList</code></td>
			<td></td>
			<td>
				<table>
					<tbody>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="SecurityGroupId">
			<td><code>SecurityGroupId</code></td>
			<td>Optional - Comma separated list of security group ids to assign to instances</td>
			<td><code>String</code></td>
			<td></td>
			<td>
				<table>
					<tbody>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="AssociatePublicIpAddress">
			<td><code>AssociatePublicIpAddress</code></td>
			<td>Associate instances with public IP addresses</td>
			<td><code>String</code></td>
			<td>true</td>
			<td>
				<table>
					<tbody>
						
    						<th>Allowed Values</th>
    						<td>
    							<ul>
    								
    									<li><code>true</code></li>
									
    									<li><code>false</code></li>
									
    							</ul>
    						</td>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
	</tbody>
</table>

<h2>Instance Configuration</h2>

<table>
	<tbody>
		<tr>
  			<th>Parameter</th>
  			<th>Description</th>
  			<th>Type</th>
  			<th>Default Value</th>
  			<th>Constraints</th>
		</tr>
		
		
		<tr id="ImageId">
			<td><code>ImageId</code></td>
			<td>Optional - Custom AMI to use for instances (must be based on the stack's AMI)</td>
			<td><code>String</code></td>
			<td></td>
			<td>
				<table>
					<tbody>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="ImageIdParameter">
			<td><code>ImageIdParameter</code></td>
			<td>Optional - Custom AMI SSM Parameter to use for instances (must be based on the stack's AMI)</td>
			<td><code>String</code></td>
			<td></td>
			<td>
				<table>
					<tbody>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="InstanceType">
			<td><code>InstanceType</code></td>
			<td>Instance type. Comma-separated list with 1-4 instance types. The order is a prioritized preference for launching OnDemand instances, and a non-prioritized list of types to consider for Spot Instances (where used).</td>
			<td><code>String</code></td>
			<td>t3.large</td>
			<td>
				<table>
					<tbody>
						

						
							<th>Allowed Pattern</th>
							<td><code>^[\w\.]+(,[\w\.]*){0,3}$</code></td>
						

						
							<th>Minimum Length</th>
							<td>1</td>
						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="AgentsPerInstance">
			<td><code>AgentsPerInstance</code></td>
			<td>Number of Buildkite agents to run on each instance</td>
			<td><code>Number</code></td>
			<td>1</td>
			<td>
				<table>
					<tbody>
						

						

						
						

						
							<th>Minimum Value</th>
							<td>1</td>
						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="KeyName">
			<td><code>KeyName</code></td>
			<td>Optional - SSH keypair used to access the buildkite instances via ec2_user, setting this will enable SSH ingress</td>
			<td><code>String</code></td>
			<td></td>
			<td>
				<table>
					<tbody>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="SpotPrice">
			<td><code>SpotPrice</code></td>
			<td>Maximum spot price to use for the instances, in instance cost per hour. Values >0 will result in 100% of instances being spot. 0 means only use normal (non-spot) instances. This parameter is deprecated - we recommend setting to 0 and using OnDemandPercentage to opt into spot instances.</td>
			<td><code>String</code></td>
			<td>0</td>
			<td>
				<table>
					<tbody>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="SecretsBucket">
			<td><code>SecretsBucket</code></td>
			<td>Optional - Name of an existing S3 bucket containing pipeline secrets (Created if left blank)</td>
			<td><code>String</code></td>
			<td></td>
			<td>
				<table>
					<tbody>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="ArtifactsBucket">
			<td><code>ArtifactsBucket</code></td>
			<td>Optional - Name of an existing S3 bucket for build artifact storage</td>
			<td><code>String</code></td>
			<td></td>
			<td>
				<table>
					<tbody>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="AuthorizedUsersUrl">
			<td><code>AuthorizedUsersUrl</code></td>
			<td>Optional - HTTPS or S3 URL to periodically download ssh authorized_keys from, setting this will enable SSH ingress. authorized_keys are applied to ec2_user</td>
			<td><code>String</code></td>
			<td></td>
			<td>
				<table>
					<tbody>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="BootstrapScriptUrl">
			<td><code>BootstrapScriptUrl</code></td>
			<td>Optional - HTTPS or S3 URL to run on each instance during boot</td>
			<td><code>String</code></td>
			<td></td>
			<td>
				<table>
					<tbody>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="RootVolumeSize">
			<td><code>RootVolumeSize</code></td>
			<td>Size of each instance's root EBS volume (in GB)</td>
			<td><code>Number</code></td>
			<td>250</td>
			<td>
				<table>
					<tbody>
						

						

						
						

						
							<th>Minimum Value</th>
							<td>10</td>
						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="RootVolumeName">
			<td><code>RootVolumeName</code></td>
			<td>Name of the root block device for your AMI</td>
			<td><code>String</code></td>
			<td></td>
			<td>
				<table>
					<tbody>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="RootVolumeType">
			<td><code>RootVolumeType</code></td>
			<td>Type of root volume to use</td>
			<td><code>String</code></td>
			<td>gp3</td>
			<td>
				<table>
					<tbody>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="ManagedPolicyARN">
			<td><code>ManagedPolicyARN</code></td>
			<td>Optional - Comma separated list of managed IAM policy ARNs to attach to the instance role</td>
			<td><code>CommaDelimitedList</code></td>
			<td></td>
			<td>
				<table>
					<tbody>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="InstanceRoleName">
			<td><code>InstanceRoleName</code></td>
			<td>Optional - A name for the IAM Role attached to the Instance Profile</td>
			<td><code>String</code></td>
			<td></td>
			<td>
				<table>
					<tbody>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="IMDSv2Tokens">
			<td><code>IMDSv2Tokens</code></td>
			<td>Whether IMDSv2 tokens must be used for the Instance Metadata Service.</td>
			<td><code>String</code></td>
			<td>optional</td>
			<td>
				<table>
					<tbody>
						
    						<th>Allowed Values</th>
    						<td>
    							<ul>
    								
    									<li><code>optional</code></li>
									
    									<li><code>required</code></li>
									
    							</ul>
    						</td>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
	</tbody>
</table>

<h2>Auto-scaling Configuration</h2>

<table>
	<tbody>
		<tr>
  			<th>Parameter</th>
  			<th>Description</th>
  			<th>Type</th>
  			<th>Default Value</th>
  			<th>Constraints</th>
		</tr>
		
		
		<tr id="MinSize">
			<td><code>MinSize</code></td>
			<td>Minimum number of instances</td>
			<td><code>Number</code></td>
			<td>0</td>
			<td>
				<table>
					<tbody>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="MaxSize">
			<td><code>MaxSize</code></td>
			<td>Maximum number of instances</td>
			<td><code>Number</code></td>
			<td>10</td>
			<td>
				<table>
					<tbody>
						

						

						
						

						
							<th>Minimum Value</th>
							<td>1</td>
						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="OnDemandPercentage">
			<td><code>OnDemandPercentage</code></td>
			<td>Percentage of total instances that should launch as OnDemand. Default is 100% OnDemand - reduce this to use some Spot Instances when they're available and cheaper than the OnDemand price. A value of 70 means 70% OnDemand and 30% Spot Instances.</td>
			<td><code>Number</code></td>
			<td>100</td>
			<td>
				<table>
					<tbody>
						

						

						
						

						
							<th>Minimum Value</th>
							<td>0</td>
						
						
							<th>Maximum Value</th>
							<td>100</td>
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="ScaleOutFactor">
			<td><code>ScaleOutFactor</code></td>
			<td>A decimal factor to apply to scale out changes to speed up or slow down scale-out</td>
			<td><code>Number</code></td>
			<td>1.0</td>
			<td>
				<table>
					<tbody>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="ScaleInIdlePeriod">
			<td><code>ScaleInIdlePeriod</code></td>
			<td>Number of seconds an agent must be idle before terminating</td>
			<td><code>Number</code></td>
			<td>600</td>
			<td>
				<table>
					<tbody>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="ScaleOutForWaitingJobs">
			<td><code>ScaleOutForWaitingJobs</code></td>
			<td>Whether to scale-out for steps behind wait steps. Make sure you have a long enough idle period!</td>
			<td><code>String</code></td>
			<td>false</td>
			<td>
				<table>
					<tbody>
						
    						<th>Allowed Values</th>
    						<td>
    							<ul>
    								
    									<li><code>true</code></li>
									
    									<li><code>false</code></li>
									
    							</ul>
    						</td>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="InstanceCreationTimeout">
			<td><code>InstanceCreationTimeout</code></td>
			<td>Timeout period for Autoscaling Group Creation Policy</td>
			<td><code>String</code></td>
			<td></td>
			<td>
				<table>
					<tbody>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
	</tbody>
</table>

<h2>Cost Allocation Configuration</h2>

<table>
	<tbody>
		<tr>
  			<th>Parameter</th>
  			<th>Description</th>
  			<th>Type</th>
  			<th>Default Value</th>
  			<th>Constraints</th>
		</tr>
		
		
		<tr id="EnableCostAllocationTags">
			<td><code>EnableCostAllocationTags</code></td>
			<td>Enables AWS Cost Allocation tags for all resources in the stack. See https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/cost-alloc-tags.html</td>
			<td><code>String</code></td>
			<td>false</td>
			<td>
				<table>
					<tbody>
						
    						<th>Allowed Values</th>
    						<td>
    							<ul>
    								
    									<li><code>true</code></li>
									
    									<li><code>false</code></li>
									
    							</ul>
    						</td>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="CostAllocationTagName">
			<td><code>CostAllocationTagName</code></td>
			<td>The name of the Cost Allocation Tag used for billing purposes</td>
			<td><code>String</code></td>
			<td>CreatedBy</td>
			<td>
				<table>
					<tbody>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="CostAllocationTagValue">
			<td><code>CostAllocationTagValue</code></td>
			<td>The value of the Cost Allocation Tag used for billing purposes</td>
			<td><code>String</code></td>
			<td>buildkite-elastic-ci-stack-for-aws</td>
			<td>
				<table>
					<tbody>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
	</tbody>
</table>

<h2>Docker Daemon Configuration</h2>

<table>
	<tbody>
		<tr>
  			<th>Parameter</th>
  			<th>Description</th>
  			<th>Type</th>
  			<th>Default Value</th>
  			<th>Constraints</th>
		</tr>
		
		
		<tr id="EnableDockerUserNamespaceRemap">
			<td><code>EnableDockerUserNamespaceRemap</code></td>
			<td>Enables Docker user namespace remapping so docker runs as buildkite-agent</td>
			<td><code>String</code></td>
			<td>true</td>
			<td>
				<table>
					<tbody>
						
    						<th>Allowed Values</th>
    						<td>
    							<ul>
    								
    									<li><code>true</code></li>
									
    									<li><code>false</code></li>
									
    							</ul>
    						</td>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="EnableDockerExperimental">
			<td><code>EnableDockerExperimental</code></td>
			<td>Enables Docker experimental features</td>
			<td><code>String</code></td>
			<td>false</td>
			<td>
				<table>
					<tbody>
						
    						<th>Allowed Values</th>
    						<td>
    							<ul>
    								
    									<li><code>true</code></li>
									
    									<li><code>false</code></li>
									
    							</ul>
    						</td>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
	</tbody>
</table>

<h2>Docker Registry Configuration</h2>

<table>
	<tbody>
		<tr>
  			<th>Parameter</th>
  			<th>Description</th>
  			<th>Type</th>
  			<th>Default Value</th>
  			<th>Constraints</th>
		</tr>
		
		
		<tr id="ECRAccessPolicy">
			<td><code>ECRAccessPolicy</code></td>
			<td>ECR access policy to give container instances</td>
			<td><code>String</code></td>
			<td>none</td>
			<td>
				<table>
					<tbody>
						
    						<th>Allowed Values</th>
    						<td>
    							<ul>
    								
    									<li><code>none</code></li>
									
    									<li><code>readonly</code></li>
									
    									<li><code>poweruser</code></li>
									
    									<li><code>full</code></li>
									
    							</ul>
    						</td>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
	</tbody>
</table>

<h2>Plugin Configuration</h2>

<table>
	<tbody>
		<tr>
  			<th>Parameter</th>
  			<th>Description</th>
  			<th>Type</th>
  			<th>Default Value</th>
  			<th>Constraints</th>
		</tr>
		
		
		<tr id="EnableSecretsPlugin">
			<td><code>EnableSecretsPlugin</code></td>
			<td>Enables s3-secrets plugin for all pipelines</td>
			<td><code>String</code></td>
			<td>true</td>
			<td>
				<table>
					<tbody>
						
    						<th>Allowed Values</th>
    						<td>
    							<ul>
    								
    									<li><code>true</code></li>
									
    									<li><code>false</code></li>
									
    							</ul>
    						</td>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="EnableECRPlugin">
			<td><code>EnableECRPlugin</code></td>
			<td>Enables ecr plugin for all pipelines</td>
			<td><code>String</code></td>
			<td>true</td>
			<td>
				<table>
					<tbody>
						
    						<th>Allowed Values</th>
    						<td>
    							<ul>
    								
    									<li><code>true</code></li>
									
    									<li><code>false</code></li>
									
    							</ul>
    						</td>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
		
		<tr id="EnableDockerLoginPlugin">
			<td><code>EnableDockerLoginPlugin</code></td>
			<td>Enables docker-login plugin for all pipelines</td>
			<td><code>String</code></td>
			<td>true</td>
			<td>
				<table>
					<tbody>
						
    						<th>Allowed Values</th>
    						<td>
    							<ul>
    								
    									<li><code>true</code></li>
									
    									<li><code>false</code></li>
									
    							</ul>
    						</td>
						

						

						
						

						
						
					</tbody>
				</table>
			</td>
		</tr>
		
	</tbody>
</table>


<!-- vale on -->