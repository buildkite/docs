# Securing your setup

Security is paramount when running CI/CD infrastructure in the cloud. This section outlines essential security practices for Buildkite agent deployments in Elastic CI Stack for AWS, focusing on preventing unauthorized access to AWS resources and implementing proper permission boundaries. These configurations help protect your infrastructure from potential security risks while maintaining the functionality your build processes require.

## Preventing builds from accessing Amazon EC2 metadata

If you provision infrastructure like databases, Redis, Amazon SQS, etc. using AWS permission sandboxes, you might want to restrict access to those roles in your builds.

If you run your builds on an AWS EC2 permission sandbox and then allow Buildkite agents to generate and inject some sandboxed AWS credentials into the build secrets, such builds will have access to the EC2 metadata API. They will also be able to access the same permissions as your EC2.

To avoid this, you need to prevent the builds from accessing your EC2 metadata or provide sandboxed AWS credentials for each build and restrict their permissions. There are two main ways to do it:

* Compartmentalizing your Buildkite agents
* Downgrading an instance profile role

If you run all the build steps in Docker containers, take a look at [compartmentalizing your agents](#preventing-builds-from-accessing-amazon-ec2-metadata-restricting-permissions-using-compartmentalization-of-agents). If you are using Kubernetes for your Buildkite CI, use the [same approach](#preventing-builds-from-accessing-amazon-ec2-metadata-restricting-permissions-using-compartmentalization-of-agents) and also check out [this article](https://github.com/blakestoddard/scaledkite) for more information and inspiration.

### Restricting permissions using compartmentalization of agents

This approach suggests the use of Elastic CI Stack for AWS. However, these instructions can also be followed using hooks or scripts.

You can divide your Buildkite agents by responsibilities. For example — agents building for development environments or release, agents deploying for staging or production, etc. This will help reflect multiple AWS environments in your Buildkite organization.

To divide the responsibilities and permissions of Buildkite agents and provide the relevant teams with sandboxed IAM permissions for their own microservices, for each pipeline you will need to use a [third-party AWS AssumeRole Buildkite Plugin](https://github.com/cultureamp/aws-assume-role-buildkite-plugin/). This plugin also takes care of the injection of AWS credentials.

To ensure that the agent in charge of a job, build, pipeline, etc., is allowed to run and will assume the role it has permission to, you can perform a [pre-checkout hook](/docs/agent/v3/self-hosted/hooks) on the agent.

### Restricting permissions by downgrading an instance profile role

This approach is [suggested by Amazon](https://docs.aws.amazon.com/cli/latest/reference/ec2/replace-iam-instance-profile-association.html) and is helpful if you are not using Elastic CI Stack for AWS.

To restrict permissions of an instance, you can permanently downgrade an instance's profile from a high-permission bootstrap role to a low-permission steady-state role. The high-permission role has a policy that allows replacing the instance profile with a low-permission role, but there is no such policy for a low-permission role.

## Further tightening the security around EC2 permissions

For added security, you can expire agents after a job. For example, you can:

1. Create a new agent for a pending job
1. Transition the agent to a sandbox role
1. Terminate the agent instance when the agent completes the job

Starting a new EC2 instance for every job results in a small trade-off of speed in favor of security. However, the Buildkite CI stack for AWS uses a Lambda to start new EC2 instances on demand, and it usually takes around one minute for a typical Linux instance.

A larger trade-off here is the need to keep discarding the cache on the machine — for example, pre-fetched and pre-built Docker images — and start anew every time.

If you're less concerned about the CI spend, new EC2 instance starting time, and other resources, you can specify a minimum stack size large enough to keep a pool of agents ready to go. This way, you can quickly replace any terminated agent instance with a clean instance.
Buildkite uses this approach to secure open-source agent instances as they could be running untrusted code.

For more information on AWS security practices regarding restricting access to the API in EKS, see [Amazon EKS security best practices](https://docs.aws.amazon.com/eks/latest/userguide/best-practices-security.html).
