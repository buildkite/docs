# Choose controls for your risk profile

Choose the closest profile for each workload, then use it to prioritize controls in the [Security checklist](/docs/platform/security/checklist). Consider the code it accepts, the credentials and systems it can access, and the impact of compromise on confidentiality, integrity, and availability. For example, a pipeline that runs untrusted pull requests needs strong isolation even if it doesn't deploy to production.

The following profiles are starting points, not security ratings, compliance certifications, or a formal Buildkite security standard. Your organization's security and compliance requirements determine which controls apply.

## Compare workload profiles

Workload profile | Example workload and impact | Start here
--- | --- | ---
Limited impact | Tests that use non-sensitive data, have no production access, and don't publish artifacts consumed by production. A failed or compromised build has a contained impact. | Review the baseline controls in every area. Prioritize account protection, isolation from sensitive workloads, and restricted credentials. Mark deployment-specific controls as not applicable only after checking that the workload has no path to production.
Production delivery | Builds that publish packages or deploy services. Compromise could alter a release, expose credentials, or interrupt a service. | Complete [Secure your first production pipeline](/docs/platform/security/first-production-pipeline), then apply the relevant baseline and recommended controls. Prioritize [secrets management](/docs/platform/security/checklist#secrets-management), [pipeline and supply chain integrity](/docs/platform/security/checklist#pipeline-and-supply-chain-integrity), and [monitoring and detection](/docs/platform/security/checklist#monitoring-and-detection).
High consequence | Workloads that access regulated or highly sensitive data, sign releases, or deploy critical services. Compromise could cause widespread or lasting harm. | Start with the production delivery controls, then assess advanced controls with your security team. Prioritize [agent isolation](/docs/platform/security/checklist#buildkite-agent-security), independent verification of releases, restricted network access, and tested [incident response](/docs/platform/security/incident-response).
{: class="responsive-table"}

## Turn the profile into a plan

The checklist groups controls into three tiers: _Baseline_ covers foundational protections, _Recommended_ adds protections for production delivery, and _Advanced_ covers specialized threats and higher-consequence workloads. Choose the controls that apply to your workload, hosting model, and plan, rather than trying to complete every item.

1. Review the baseline in each checklist area and use its completion criteria to verify your setup.
1. Add recommended and advanced controls according to the workload profile and your organization's requirements.
1. Record outstanding controls, owners, and review dates in your own tracking system. For controls that don't apply, record why.

## Reassess shared access and changing workloads

One Buildkite organization can contain workloads with different profiles. Assess shared agents, credentials, artifact stores, and network access against the most sensitive workload they can reach. A test pipeline that can modify a release artifact isn't a limited-impact workload just because it doesn't deploy it.

Reassess the profile when a workload gains access to new data, credentials, networks, or deployment targets. Selecting a profile doesn't remove a risk: record any remaining risk, the person authorized to accept it, and a review date.
