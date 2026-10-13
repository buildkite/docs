# Security overview

Customer security is paramount to Buildkite. By design, sensitive data, such as source code and secrets, remain within
your own environment and are not seen by Buildkite.

The hybrid-SaaS model used by Buildkite allows you to maintain tight control over build agents without compromising on scalability.

Buildkite implements a number of measures and mechanisms, both on the control plane and agent, to ensure that customer data remains safe.

To learn how to secure your own Buildkite organization, see the [Security best practices](/docs/platform/security/best-practices). For an overview of all security documentation across Buildkite, see [Security](/docs/platform/security).

## Data flow

Data flows through different systems when a build triggers, both in Buildkite and in environments you manage. The following diagram shows the typical flow of data when a build triggers. The label above each system shows who is responsible for securing it, as described in [Shared responsibility](/docs/platform/security#shared-responsibility).

<%= image "data-flow.png", alt: "Diagram of the data flow between your source control system, Buildkite, the agent, your source code, and the artifact store when a build runs, with each system labeled as customer controlled, Buildkite managed, or dependent on your hosting model or storage choice", class: "no-decoration" %>

The diagram shows that:

1. Buildkite receives a webhook from your SCM when code changes.
1. An agent running on your infrastructure polls Buildkite and detects a job to run.
1. An agent accepts the job and reports that to Buildkite.
1. The agent checks out your source code to run the job.
1. The agent sends the job logs to Buildkite.
1. Any artifacts are managed by the agent and your artifact store.
1. The agent reports that the job finished to Buildkite.
1. Buildkite posts the status update to your SCM.

## Infrastructure

All of Buildkite's services run in the cloud. Buildkite does not run its own routers, load balancers, DNS servers, or physical servers.

## Data encryption

All data transferred in and out of Buildkite is encrypted using hardened TLS. Buildkite is also protected by HTTP Strict Transport Security and is pre-loaded in major browsers. Additionally, data transferred to and from Buildkite's backend database is encrypted using TLS. Finally, all data is encrypted at rest.

## User logins

We protect against brute force attacks with rate-limiting technology. All sensitive data such as passwords and API tokens are filtered out of logs and exception trackers. User passwords are never stored in Buildkite's database - only their salted cryptographic hash.

## Software dependencies

Buildkite keeps up to date with software dependencies and has automated tools scanning for common security issues, including Cross-Site Scripting (XSS), Cross-Site Request Forgery (CSRF), and SQL Injection.

## Code review and testing process

All pull requests are reviewed by senior engineers with security best practice training before being deployed to production systems. [Two-factor authentication (2FA)](/docs/platform/tutorials/2fa) is enabled across GitHub and Buildkite organizations for added security.

An extensive set of automated testing procedures is run for every code change.

## Development and QA environments

Development and QA environments are physically separated from Buildkite's production environment. No customer data is ever used in the development or QA environments.

## Penetration testing

Buildkite performs regular penetration test audits with a contracted third party.
