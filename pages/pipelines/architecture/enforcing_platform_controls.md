# Enforcing platform controls in Buildkite

This page aims to cover the best practices for administrating Buildkite in terms of agent controls, platform controls, and controls around cost. Platform engineers and infrastructure teams will benefit from reading this page.

> 📘
> If you're looking for in-depth infomation on best practices for security controls, see [Enforcing security controls](/docs/pipelines/security/enforcing-security-controls).

## Buildkite agent controls

Controls around the agents touch upon using those with different software (?).

### Queues and clusters

Only run in the queues you define, in the cluster.

Have different clusters for different workloads.

Additional info:

Buildkite provides balance between control and controller giveaway - good, as you can run your own agents, decide how much CPU, RAM, other resources the agents can have.
Controls and templates can be used, but initially, someone has to be responsible for the pipeline YAML. A dedicated administration/infrastructure team can do that.

## Platform team controls

Controls for the platform team in terms of how they run different pipelines/workloads.

### Telemetry reporting

Standardise the number of times infrastructure/test flakes are retried and have their custom exit statuses that you can report on with your telemetry provider.

### Custom checkout scripts

Have standard checkout scripts in which you gather the same data as part of every job.

### Private plugins

Build a private plugin if you would like things to be done in a certain way - helps standardize things. For example, some functionality can be offloaded into a plugin and reused.

### Annotations

Standardised annotation can add additional context for the user. You can add internal links for the developers to check from tools.

## Cost and billing controls

Controls and optimization methods around cost.

### Cluster size control

Cluster maintainer can create the allowed queues and only allow the sizes they want to pay for in hosted.

### Agent scaling

Only allow the number of agents you’d like in that queue. Monitor wait times.
Potential lifehack - scale all (AWS agents) to zero and only keep a handful warm during the work/peak hours (could be the ones that are running CloudFormation deploy or Terraform apply).

### User number control

User based cost, do we have any reporting to let you know of the number of user you have? any alerting? (most likely no).
We do have API commands that can show the number of users and active users, in GraphQL.

