# Signed pipelines

handy links for writing docs:
https://3.basecamp.com/3453178/buckets/27608512/messages/5774300120
https://3.basecamp.com/3453178/buckets/27608512/messages/5725400045


We know that builds and deploys can be run on highly privileged machines, and that an attacker convincing that machine to run a malicious command could compromise production infrastructure.
As customer secuirty is paramount to Buildkite, and we wish to ensure thata all customers are immune by default from our control plane being compromised.

* link to best practices?
* mention exisitng tool on github? https://github.com/buildkite/buildkite-signed-pipeline
* Maybe this should live in security? Not sure

Sensitive data, such as source code and secrets, remain within your own environment and are not seen by Buildkite. We are aware that many customers invest heavily in configuring their agents to reject jobs that don't match some set of expectations, such as pipeline/repo/branch filtering, limiting to in-repo scripts not arbitrary commands etc.



We know that customers choose Buildkite because our hybrid model gives them a world-class SaaS control plane while keeping most of the trust/risk behind their firewall on their own infrastructure. We encourage customers to not trust Buildkite's control plane, but the tools to do that (agent hooks, allow-listing etc) aren't ergonomic nor robust.

Cryptographically signing and verifying build steps by default would close a big gap in our “you don't even need to trust our servers” story. And if we were ever breached, it could save our customers and enough of our reputation to survive.

Customers can optionally sign pipeline uploads using just the buildkite-agent
The buildkite-agent can optionally verify job signatures, and reject jobs if they don't have the right signature
A malicious actor using buildkite to target an attack against one of our customers cannot successfully run malicious actions on customer agents

Making a pipeline public provides read-only public/anonymous access to:

Targets for signed pipelines includes

- Command
- Pipeline build logs
- Environment variables from the uploaded pipeline
- Plugins


## Pretty diagram of agent/bk interaction with signed pipeline?

## Attack Scenarios (maybe)

Make a pipeline public in the _Pipeline Settings_ in the _General_ tab:

<%= image "settings.png", width: 1960/2, height: 630/2, alt: "Public pipeline settings" %>

## Random headings we might use:

## Handy links about signutures/signing
