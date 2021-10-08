# AWS VPC

AWS QuickStart https://aws.amazon.com/quickstart/architecture/vpc/

Your VPC needs to provide routable access to the buildkite.com service.

This can be achieved using a public subnet, whose route table has a default
route pointing to an Internet Gateway, or using a private subnet, whose route
table’s default route points to a NAT device.

Auxiliary services used by your instances such as S3, ECR, or SSM, can be routed
over the public internet, or by using a VPC Endpoint.

## Only public subnets

## Private/public subnets

- NAT Gateway
- NAT Instances

### Access
#### Bastion
#### VPN

### S3 VPC Endpoint

