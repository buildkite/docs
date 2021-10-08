# AWS VPC Design

Agent orchestration deployments on AWS require a virtual private cloud (VPC)
network.

Your VPC needs to provide routable access to the buildkite.com service
so that `buildkite-agent` processes can connect, and retrieve the jobs assigned
to them. This can be achieved using a public subnet, whose route table has a
default route pointing to an [internet gateway](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html),
or a private subnet, whose route table’s default route points to a
[NAT device](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat.html).

Auxiliary services used by the agent or your jobs such as S3, ECR, or SSM,
can be routed over the public internet, or though a
[VPC Endpoint](https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-endpoints.html).

[AWS VPC QuickStart](https://aws.amazon.com/quickstart/architecture/vpc/)
provides a template for deploying a 2, 3, or 4 Availability Zone VPC with
parameters for whether to make public and private subnets. Once deployed, these
subnets can be provided as parameters to the agent orchestration templates such
as the [Elastic CI Stack for AWS](/docs/agent/v3/elastic_ci_aws).

Use your organisation’s threat model to guide the selection of a solution that
balances operational complexity against acceptable risk for your workload.

## Only public subnets

The simplest VPC subnet design involves using only public subnets whose route
table’s default route points to an internet gateway. Under this design your EC2
instances or ECS tasks are provided with a public IPv4 address in order to
access the internet directly. You can use
[security groups](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html)
to limit traffic and block inbound network connections to your instances.

## Private/public subnets

For an added layer of defence against unwanted external connectivity, you can
place your instances in a private subnet. A private subnet provides the greatest
level of control when seeking to restrict the inbound and outbound network
connections of your instances.

A private subnet’s route table does not grant direct routable access to or from
the internet. Instead, a private subnet’s default route is pointed to a
[NAT instance)(https://docs.aws.amazon.com/vpc/latest/userguide/VPC_NAT_Instance.html)
or a [NAT gateway](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html).
A NAT device lives in the public subnet, and rewrites the private source IP
address of any outbound connections to its own public IP address. NAT devices
statefully limit response traffic to known outbound network connections,
similar to a security group.

### Access

In order to diagnose instance performance and behaviour problems, it is common
to remotely access an interactive prompt on an instance. There are a number of
options available for remote access to instances in a private subnet.

#### SSM

Installing the [AWS SSM Agent](https://docs.aws.amazon.com/systems-manager/latest/userguide/ssm-agent.html)
allows you to initiate sessions on private instances without requiring publicly
routable SSH, or adding a VPN gateway to your VPC.

> Session Manager provides secure and auditable instance management without the need to open inbound ports, maintain bastion hosts, or manage SSH keys. Session Manager also allows you to comply with corporate policies that require controlled access to instances, strict security practices, and fully auditable logs with instance access details, while still providing end users with simple one-click cross-platform access to your managed instances.

See the [AWS Systems Manager Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html) documentation for more details.

#### Bastion

The bastion pattern involves deploying a host to a public subnet with a publicly
routable IP address and security group that allows inbound SSH connections. An
additional security group is then used to permit SSH access from the public
subnet bastion instance to the private subnet agent instances.

This limits the public surface area of your VPC, but still requires exposing
an unmanaged instance to public traffic. Public facing instances should be
patched and updated regularly.

See the [Linux Bastion Hosts on AWS QuickStart](https://aws.amazon.com/quickstart/architecture/linux-bastion/)
for a example of this pattern.

#### VPN

### S3 VPC Endpoint

