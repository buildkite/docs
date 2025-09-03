# Enforcing platform controls in Buildkite

This page aims to cover the best practives for administrating Buildkite in terms of agent controls, platorm controls, and controls around cost. Platform engineers and infrastructure teams will benefit from reading this page.

> 📘
> If you're looking for in-depth infomation on best practices for security controls, see [Enforcing security controls](/docs/pipelines/security/enforcing-security-controls).

## Buildkite agent controls
- Controls around the agents they can use with the software
    - Only run in the queues you define, in the cluster
    - Have different clusters for different workloads

## Platform team controls
- Controls for the platform team in terms of how they run different pipelines/workloads
    - Standardise the number of times infrastructure/test flakies are retried and have their custom exit statuses that you can report on with your telemetry provider
    - Have standard checkout scripts in which you gather the same data as part of every job
    - Build a private plugin if you would like things to be done in a certain way
    - Standardised annotation can add additional context for the user. You can add internal links for the developers to check from tools

## Cost and billing controls
- Controls around cost
    - Cluster maintainer can create the allowed queues and only allow the sizes they want to pay for in hosted
    - Only allow the number of agents you’d like in that queue. Monitor wait times
    - User based cost, do you have any reporting to let you know of the number of user you have? any alerting? I think no