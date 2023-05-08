# Migrate from Jenkins

If you are familiar with [Jenkins](https://www.jenkins.io) and want to migrate to Buildkite, this guide is for you. Buildkite is a modern and flexible continuous integration and deployment (CI/CD) platform that provides a powerful and scalable build infrastructure for your applications.

While Jenkins and Buildkite have similar goals as CI/CD platforms, their approach differs. Buildkite uses a hybrid model consisting of:

- A software-as-a-service (SaaS) platform for visualization and management of CI/CD pipelines.
- Agents for executing jobs, hosted by you, either on-premise or in the cloud.

Buildkite addresses the pain points of Jenkins’ users, namely its security issues (both in its [base code](https://www.cvedetails.com/vulnerability-list/vendor_id-15865/product_id-34004/Jenkins-Jenkins.html) and [plugins](https://securityaffairs.co/wordpress/132836/security/jenkins-plugins-zero-day-flaws.html)), time-consuming setup, and speed. This approach makes Buildkite more secure, scalable, and flexible.

Follow the steps in this guide for a smooth migration from Jenkins to Buildkite.

## Understand the differences

Most of the concepts will likely be familiar, but there are some differences to understand about the approaches.

### System architecture

While Jenkins is a general automation engine with plugins to add additional features, Buildkite Pipelines is a product specifically aimed at CI/CD. You can think of Buildkite Pipelines like Jenkins with the Pipeline suite of plugins. To simplify it, we'll refer to Jenkins Pipeline as just _Jenkins_ and Buildkite Pipelines as _Buildkite_.

At a high level, Buildkite follows a similar architecture to Jenkins:

- A central control panel that coordinates work and displays results.
  * **Jenkins:** A _controller_ shown in the web UI.
  * **Buildkite:** The _Buildkite dashboard_.
- A program that executes the work it receives from the control panel.
  * **Jenkins:** A combination of _nodes_, _executors_, and _agents_.
  * **Buildkite:** _Agents_.

However, while you're responsible for scaling and operating both components in Jenkins, Buildkite manages the control panel as a SaaS offering (the Buildkite dashboard). This reduces the operational burden on your team, as Buildkite takes care of platform maintenance, updates, and availability. The Buildkite dashboard also handles monitoring tools like logs, user access, and notifications.

The program that executes work is called an _agent_ in Buildkite. An agent is a small, reliable, and cross-platform build runner that connects your infrastructure to Buildkite. It polls Buildkite for work, runs jobs, and reports results. You can install agents on local machines, cloud servers, or other remote machines.

In Jenkins, you manage concurrency by having multiple executors within a single node. In Buildkite, you run multiple agents on a single machine or across multiple machines.

The following diagram shows the split in Buildkite between the hosted platform and the agents running on your infrastructure.

<!-- vale off -->

<svg alt="Diagram showing agent to agent API communication" viewBox="0 0 730 570"><defs><rect id="agent-comms-svg-i" x="11" y="11" width="102" height="65" rx="8"/><rect id="agent-comms-svg-j" x="6" y="6" width="102" height="65" rx="8"/><rect id="agent-comms-svg-k" width="102" height="65" rx="8"/><rect id="agent-comms-svg-l" width="75" height="48" rx="8"/><path d="M0 8.007C0 3.585 3.575 0 7.996 0h165.008C177.42 0 181 3.588 181 8.007v31.986c0 4.422-3.575 8.007-7.996 8.007H7.996C3.58 48 0 44.412 0 39.993V8.007z" id="agent-comms-svg-a"/><mask id="agent-comms-svg-m" x="0" y="0" width="181" height="48" fill="#fff"><use xlink:href="#agent-comms-svg-a"/></mask><path d="M0 8.007C0 3.585 3.575 0 7.997 0h178.006C190.42 0 194 3.588 194 8.007v31.986c0 4.422-3.575 8.007-7.997 8.007H7.997C3.58 48 0 44.412 0 39.993V8.007z" id="agent-comms-svg-b"/><mask id="agent-comms-svg-n" x="0" y="0" width="194" height="48" fill="#fff"><use xlink:href="#agent-comms-svg-b"/></mask><path d="M0 8.007C0 3.585 3.576 0 7.99 0h119.02c4.412 0 7.99 3.588 7.99 8.007v31.986c0 4.422-3.576 8.007-7.99 8.007H7.99C3.579 48 0 44.412 0 39.993V8.007z" id="agent-comms-svg-c"/><mask id="agent-comms-svg-o" x="0" y="0" width="135" height="48" fill="#fff"><use xlink:href="#agent-comms-svg-c"/></mask><path d="M0 8.007C0 3.585 3.575 0 7.996 0h165.008C177.42 0 181 3.588 181 8.007v31.986c0 4.422-3.575 8.007-7.996 8.007H7.996C3.58 48 0 44.412 0 39.993V8.007z" id="agent-comms-svg-d"/><mask id="agent-comms-svg-p" x="0" y="0" width="181" height="48" fill="#fff"><use xlink:href="#agent-comms-svg-d"/></mask><path d="M0 8.007C0 3.585 3.575 0 7.996 0h165.008C177.42 0 181 3.588 181 8.007v31.986c0 4.422-3.575 8.007-7.996 8.007H7.996C3.58 48 0 44.412 0 39.993V8.007z" id="agent-comms-svg-e"/><mask id="agent-comms-svg-q" x="0" y="0" width="181" height="48" fill="#fff"><use xlink:href="#agent-comms-svg-e"/></mask><path d="M0 8.007C0 3.585 3.575 0 7.997 0h178.006C190.42 0 194 3.588 194 8.007v31.986c0 4.422-3.575 8.007-7.997 8.007H7.997C3.58 48 0 44.412 0 39.993V8.007z" id="agent-comms-svg-f"/><mask id="agent-comms-svg-r" x="0" y="0" width="194" height="48" fill="#fff"><use xlink:href="#agent-comms-svg-f"/></mask><path d="M14 8.007C14 3.585 17.576 0 21.99 0h119.02c4.412 0 7.99 3.588 7.99 8.007v31.986c0 4.422-3.576 8.007-7.99 8.007H21.99C17.579 48 14 44.412 14 39.993V8.007z" id="agent-comms-svg-g"/><mask id="agent-comms-svg-s" x="0" y="0" width="135" height="48" fill="#fff"><use xlink:href="#agent-comms-svg-g"/></mask><path d="M0 8.007C0 3.585 3.585 0 7.998 0h151.004C163.419 0 167 3.588 167 8.007v31.986c0 4.422-3.585 8.007-7.998 8.007H7.998C3.581 48 0 44.412 0 39.993V8.007z" id="agent-comms-svg-h"/><mask id="agent-comms-svg-t" x="0" y="0" width="167" height="48" fill="#fff"><use xlink:href="#agent-comms-svg-h"/></mask><rect id="agent-comms-svg-u" width="75" height="48" rx="8"/><rect id="agent-comms-svg-v" x="11" y="11" width="102" height="65" rx="8"/><rect id="agent-comms-svg-w" x="6" y="6" width="102" height="65" rx="8"/><rect id="agent-comms-svg-x" width="102" height="65" rx="8"/><rect id="agent-comms-svg-y" x="11" y="11" width="102" height="65" rx="8"/><rect id="agent-comms-svg-z" x="6" y="6" width="102" height="65" rx="8"/><rect id="agent-comms-svg-A" width="102" height="65" rx="8"/></defs><g fill="none" fill-rule="evenodd"><path d="M-.5 274.5h732.154" stroke="#DCDCDC" stroke-linecap="square" stroke-dasharray="10"/><text font-family="'Maison Neue'" font-size="18" font-weight="400" fill="#666"><tspan x="618" y="305">On-Premises</tspan></text><text font-family="'Maison Neue'" font-size="18" font-weight="400" fill="#666"><tspan x="581" y="32">Hosted Platform</tspan></text><g transform="translate(163 383)"><use fill="#FFF" xlink:href="#agent-comms-svg-i"/><rect stroke="#979797" x="11.5" y="11.5" width="101" height="64" rx="8"/></g><g transform="translate(163 383)"><use fill="#FFF" xlink:href="#agent-comms-svg-j"/><rect stroke="#979797" x="6.5" y="6.5" width="101" height="64" rx="8"/></g><g transform="translate(163 383)"><use fill="#FFF" xlink:href="#agent-comms-svg-k"/><rect stroke="#979797" x=".5" y=".5" width="101" height="64" rx="8"/></g><text font-family="'Maison Neue'" font-size="18" font-weight="bold" letter-spacing="1.125" fill="#2ACE69" transform="translate(163 383)"><tspan x="18.311" y="39">AGENT</tspan></text><g transform="translate(95 312)"><use fill="#FFF" xlink:href="#agent-comms-svg-l"/><rect stroke="#979797" x=".5" y=".5" width="74" height="47" rx="8"/></g><text font-family="'Maison Neue'" font-size="13" font-weight="bold" letter-spacing=".813" fill="#2ACE69" transform="translate(95 312)"><tspan x="14.157" y="30">AGENT</tspan></text><g transform="translate(56 490)"><use stroke="#979797" mask="url(#m)" stroke-width="2" fill="#FFF" stroke-dasharray="3" xlink:href="#agent-comms-svg-a"/><text font-family="'Maison Neue'" font-size="13" font-weight="bold" letter-spacing=".813" fill="#000"><tspan x="20.434" y="30">YOUR SOURCE CODE</tspan></text></g><g transform="translate(275 492)"><use stroke="#979797" mask="url(#n)" stroke-width="2" fill="#FFF" stroke-dasharray="3" xlink:href="#agent-comms-svg-b"/><text font-family="'Maison Neue'" font-size="13" font-weight="bold" letter-spacing=".813" fill="#000"><tspan x="15.187" y="30">YOUR DEPLOY SECRETS</tspan></text></g><g transform="translate(65 67)"><use stroke="#979797" mask="url(#o)" stroke-width="2" fill="#FFF" stroke-dasharray="3" xlink:href="#agent-comms-svg-c"/><text font-family="'Maison Neue'" font-size="13" font-weight="bold" letter-spacing=".813" fill="#000"><tspan x="26.595" y="30">WEBHOOKS</tspan></text></g><g transform="translate(264 43)"><use stroke="#979797" mask="url(#p)" stroke-width="2" fill="#FFF" stroke-dasharray="3" xlink:href="#agent-comms-svg-d"/><text font-family="'Maison Neue'" font-size="13" font-weight="bold" letter-spacing=".813" fill="#000"><tspan x="19.539" y="30">SCM INTEGRATIONS</tspan></text></g><g transform="translate(39 185)"><use stroke="#979797" mask="url(#q)" stroke-width="2" fill="#FFF" stroke-dasharray="3" xlink:href="#agent-comms-svg-e"/><text font-family="'Maison Neue'" font-size="13" font-weight="bold" letter-spacing=".813" fill="#000"><tspan x="16.084" y="30">CHAT INTEGRATIONS</tspan></text></g><g transform="translate(494 185)"><use stroke="#979797" mask="url(#r)" stroke-width="2" fill="#FFF" stroke-dasharray="3" xlink:href="#agent-comms-svg-f"/><text font-family="'Maison Neue'" font-size="13" font-weight="bold" letter-spacing=".813" fill="#000"><tspan x="19.984" y="30">REST &amp; GRAPHQL APIs</tspan></text></g><g transform="translate(507 67)"><use stroke="#979797" mask="url(#s)" stroke-width="2" fill="#FFF" stroke-dasharray="3" xlink:href="#agent-comms-svg-g"/><text font-family="'Maison Neue'" font-size="13" font-weight="bold" letter-spacing=".813" fill="#000"><tspan x="26.849" y="30">WEB INTERFACE</tspan></text></g><g transform="translate(507 490)"><use stroke="#979797" mask="url(#t)" stroke-width="2" fill="#FFF" stroke-dasharray="3" xlink:href="#agent-comms-svg-h"/><text font-family="'Maison Neue'" font-size="13" font-weight="bold" letter-spacing=".813" fill="#000"><tspan x="13.482" y="30">INTERNAL SYSTEMS</tspan></text></g><g transform="translate(526 312)"><use fill="#FFF" xlink:href="#agent-comms-svg-u"/><rect stroke="#979797" x=".5" y=".5" width="74" height="47" rx="8"/></g><text font-family="'Maison Neue'" font-size="13" font-weight="bold" letter-spacing=".813" fill="#2ACE69" transform="translate(526 312)"><tspan x="14.157" y="30">AGENT</tspan></text><g transform="translate(298 383)"><use fill="#FFF" xlink:href="#agent-comms-svg-v"/><rect stroke="#979797" x="11.5" y="11.5" width="101" height="64" rx="8"/></g><g transform="translate(298 383)"><use fill="#FFF" xlink:href="#agent-comms-svg-w"/><rect stroke="#979797" x="6.5" y="6.5" width="101" height="64" rx="8"/></g><g transform="translate(298 383)"><use fill="#FFF" xlink:href="#agent-comms-svg-x"/><rect stroke="#979797" x=".5" y=".5" width="101" height="64" rx="8"/></g><text font-family="'Maison Neue'" font-size="18" font-weight="bold" letter-spacing="1.125" fill="#2ACE69" transform="translate(298 383)"><tspan x="18.311" y="39">AGENT</tspan></text><g transform="translate(228 113)"><rect stroke="#979797" x=".5" y=".5" width="249" height="64" rx="8"/><text font-family="'Maison Neue'" font-size="18" font-weight="bold" letter-spacing="1.125" fill="#2ACE69"><tspan x="18.98" y="39">BUILDKITE AGENT API</tspan></text></g><g transform="translate(430 383)"><use fill="#FFF" xlink:href="#agent-comms-svg-y"/><rect stroke="#979797" x="11.5" y="11.5" width="101" height="64" rx="8"/></g><g transform="translate(430 383)"><use fill="#FFF" xlink:href="#agent-comms-svg-z"/><rect stroke="#979797" x="6.5" y="6.5" width="101" height="64" rx="8"/></g><g transform="translate(430 383)"><use fill="#FFF" xlink:href="#agent-comms-svg-A"/><rect stroke="#979797" x=".5" y=".5" width="101" height="64" rx="8"/></g><text font-family="'Maison Neue'" font-size="18" font-weight="bold" letter-spacing="1.125" fill="#2ACE69" transform="translate(430 383)"><tspan x="18.311" y="39">AGENT</tspan></text><path d="M353.5 185.5l166 119M519.5 304.5l-7.03-8.73-3.495 4.876L519.5 304.5zM353.5 185.5l116 183M469.5 368.5l-3.248-10.728-5.068 3.212 8.316 7.516zM353.5 185.5l-8 181M345.5 366.5l3.474-10.657-5.994-.265 2.52 10.922zM353.5 185.5l-131 184M222.5 369.5l8.708-7.058-4.888-3.48-3.82 10.538zM353.5 185.5l-173 118M180.5 303.5l10.613-3.607-3.381-4.957-7.232 8.564z" stroke="#B4B4B4" fill="#B4B4B4" stroke-linecap="square"/></g></svg>

<!-- vale on -->

The diagram shows that Buildkite provides a web interface, handles integrations with third-party tools, and offers APIs and webhooks. Buildkite communicates with the agents on your infrastructure, which access your code, secrets, and internal systems.

This decoupling provides flexibility, as you can scale the build agents independently while Buildkite manages the coordination, scheduling, and web interface.

### Security

Security is crucial in CI/CD, protecting sensitive information, system integrity, and compliance with industry standards. Jenkins and Buildkite have different approaches to security, which will impact how you manage your CI/CD pipeline's security aspects.

Securing a Jenkins instance requires:

- Careful configuration.
- Plugin management.
- Regular updates to address security vulnerabilities.

You must consider vulnerabilities in both the [base code](https://www.cvedetails.com/vulnerability-list/vendor_id-15865/product_id-34004/Jenkins-Jenkins.html) and [plugins](https://securityaffairs.co/wordpress/132836/security/jenkins-plugins-zero-day-flaws.html). Additionally, since Jenkins is a self-hosted solution, you are responsible for securing the underlying infrastructure, network, and storage. Some updates require you to take Jenkins offline to perform, leaving your team without access to CI/CD during that period.

Buildkite's hybrid architecture, which combines a centralized SaaS platform with self-hosted build agents, provides a unique approach to security. Buildkite takes care of the security of the SaaS platform, including user authentication, pipeline management, and the web interface. Build agents, which run on your infrastructure, allow you to maintain control over the environment, security, and resources. This separation reduces the operational burden and allows you to focus on securing the environments where your code is built and tested.

Secret management is more straightforward in Buildkite with environment hooks and native support for third-party tools like AWS Secrets Manager and Hashicorp Vault.

Both Jenkins and Buildkite support multiple authentication providers and offer granular access control. However, Buildkite's SaaS platform provides a more centralized and streamlined approach to user management, making it easier to enforce security policies and manage user access across your organization.

### Pipeline configuration

When migrating your CI/CD pipelines from Jenkins to Buildkite, it's important to understand the differences in pipeline configuration.

Like Jenkins, Buildkite lets you create pipeline definitions in the web interface or a file checked into the repository. Most people use the latter to include their pipeline definitions next to the code, managed in source control. The equivalent of a `Jenkinsfile` is a `pipeline.yml`.

Rather than the Groovy-based syntax in Jenkins, Buildkite uses a YAML-based syntax. The YAML definitions are simpler, more human-readable, and easier to understand. And you can even have code generate those pipelines on the fly if you need the power and flexibility of [dynamic pipelines](/docs/pipelines/defining-steps#dynamic-pipelines).

In Jenkins, the core description of work is a job. Jobs contain stages with steps and can trigger other jobs. You use a job to upload a `Jenkinsfile` from a repository. Installing the Pipeline plugin lets you describe a workflow of jobs as a pipeline. Buildkite uses similar terms in different ways. _Pipelines_ are the core description of work. Pipelines contain different types of _steps_ for different tasks:

- **Command step:** Runs one or more shell commands on one or more agents.
- **Wait step:** Pauses a build until all previous jobs have completed.
- **Block step:** Pauses a build until unblocked.
- **Input step:** Collects information from a user.
- **Trigger step:** Creates a build on another pipeline.
- **Group step:** Displays a group of sub-steps as one parent step.

Triggering a pipeline creates a _build_, and any command steps are dispatched as _jobs_ to run on agents. A common practice is to define a pipeline with a single step that uploads the `pipeline.yml` file in the code repository. The `pipeline.yml` contains the full pipeline definition and can be generated dynamically.

### Plugin system

Plugins are an essential part of both Jenkins and Buildkite. They help you extend the products to customize your CI/CD workflows further.

Rather than a web-based plugin management system like Jenkins, you manage Buildkite plugins directly in pipeline definitions. This makes Buildkite plugins more decentralized and allows for easier version control.

Jenkins plugins are typically developed in Java and are closely integrated with the Jenkins core, which may lead to compatibility issues when updating Jenkins or its plugins. Buildkite plugins are written in Bash and loosely coupled with Buildkite, making them more maintainable and less prone to compatibility issues.

## Try out Buildkite

With a basic understanding of the differences between Buildkite and Jenkins, the next step is to try creating and running a pipeline.

We recommend following the [Getting started](/docs/tutorials/getting-started/) guide to:

1. Sign up for a free account.
1. Set up an agent to execute the pipeline steps.
1. Create a pipeline using an example repository.
1. Run a build and view the output in the Buildkite dashboard.

## Provision agent infrastructure

The agents are where your builds, tests, and deployments run. They run on your infrastructure, providing flexibility and control over the environment and resources. Operating agents is similar in approach to hosting nodes in Jenkins.

You'll need to consider the following:

- **Infrastructure type:** Agents can run on various infrastructure types, including on-premises, cloud (AWS, GCP, Azure), or container platforms (Docker, Kubernetes). Based on your analysis of the existing Jenkins nodes, choose the infrastructure type that best suits your organization's needs and constraints.
- **Resource usage:** Agent infrastructure is similar to the requirements for nodes in Jenkins, without operating the controller. Evaluate your Jenkins nodes' resource usage (CPU, memory, and disk space) to determine the requirements for your Buildkite agent infrastructure.
- **Platform dependencies:** To run your pipelines, you'll need to ensure the agents have the necessary dependencies, such as programming languages, build tools, and libraries. Take note of the operating systems, libraries, tools, and dependencies installed on your Jenkins nodes. This information will help you configure your Buildkite agents.
- **Network configurations:** Review the network configurations of your Jenkins nodes, including firewalls, proxy settings, and network access to external resources. These configurations will guide you in setting up the network environment for your Buildkite agents. The Buildkite agent works by polling Buildkite's agent API over HTTPS.  There is no need to forward ports or provide incoming firewall access.
- **Agent scaling:** Evaluate the number of concurrent builds and the build queue length in your Jenkins nodes to estimate the number of Buildkite agents needed. Keep in mind that you can scale Buildkite agents independently, allowing you to optimize resource usage and reduce build times.
- **Build isolation and security:** Consider using separate agents for different projects or environments to ensure build isolation and security. You can use [agent tags](/docs/agent/v3/cli-start#setting-tags) and [clusters](/docs/agent/clusters) to target specific agents for specific pipeline steps, allowing for fine-grained control over agent allocation.

You'll continue to adjust the agent configuration as you monitor performance to optimize build times and resource usage for your needs.

See the [Installation](/docs/agent/v3/installation/) guides when you're ready to install an agent and follow the instructions for your infrastructure type.

## Translate pipeline definitions

A pipeline is a container for modeling and defining workflows. While that's true for both Buildkite and Jenkins, they look quite different. Both can read a configuration file checked into a repository to define the workflow. In Jenkins, the `Jenkinsfile`. In Buildkite, the `pipeline.yml`. Where the `Jenkinsfile` uses a Groovy-based syntax and strong hierarchy, `pipelines.yml` uses YAML and a flat structure for better readability.

### Audit your pipelines

Before you start moving pipelines, we recommend taking inventory of your existing pipelines, plugins, and integrations. Determine which parts of your Jenkins setup are essential and which can be replaced or removed. This will help you decide what needs to be migrated to Buildkite.

### Translate a pipeline

Since the configuration files are quite different, creating an automated tool to translate between them is difficult. Instead, we recommend assessing the goal of a pipeline and investing the time to see how to achieve the same thing the Buildkite way. This results in clearer pipelines with better performance.

Some Buildkite features you might want to use include [dynamic pipelines](/docs/pipelines/defining-steps#dynamic-pipelines), [lifecycle hooks](/docs/agent/v3/hooks), [conditionals](/docs/pipelines/conditionals), [artifacts](/docs/pipelines/artifacts), [build matrices](/docs/pipelines/build-matrix), and [annotations](/docs/agent/v3/cli-annotate).

A simple pipeline in Buildkite might look like the following:

```yaml
steps:
- label: "Build"
  command: "build.sh"
  key: "build"

- label: "Test"
  command: "test.sh"
  key: "test"
  depends_on: "build"

- label: "Deploy"
  command: "deploy.sh"
  depends_on: "test"
```

To translate a pipeline:

1. Identify the goal of the pipeline.
1. Look for an [example pipeline](/docs/pipelines/example-pipelines) closest to that goal.
1. Follow [Defining steps](/docs/pipelines/defining-steps) and surrounding documentation to learn how to customize the pipeline definition to meet your needs, including:
   * Targeting a specific agent or queue.
   * Replacing any Jenkins plugins and integrations with native integrations, existing Buildkite plugins, custom plugins, or custom scripts.
1. Migrate any environment variables, secrets, or credentials used in the pipeline. Buildkite allows you to manage environment variables and secrets on different levels, such as organization, pipeline, and step levels. Securely store your sensitive data on your preferred secret management tool and integrate them into your agents and pipelines.
1. Run the pipeline to verify it works as expected.
   * If it does, nice work! On to the next one.
   * If it doesn't, check the logs to resolve the issues. If you're having trouble, reach out to [support](https://buildkite.com/support).

Many teams continue running pipelines on their existing infrastructure to verify the results match before removing the pipeline from Jenkins.

## Integrate your tools

Integrating workflow tools and notifications with your CI/CD pipelines helps streamline processes and keeps your team informed about build and deployment status. Buildkite supports various integrations with tools like chat applications, artifact managers, and monitoring systems.

To set up your integrations:

1. **List existing tools:** Identify the workflow tools and notification systems you use or need to integrate with your CI/CD pipelines.
1. **Define notification requirements:** Determine the types of notifications your team needs, such as build status, deployment updates, test results, and alerts for critical issues. This information will help you configure the appropriate integrations and notification settings.
1. **Choose the integration approach:**
   * **Plugins:** Buildkite provides plugins to integrate with popular workflow tools and notification systems. Check the [Plugins directory](/docs/plugins/directory) to see if there's a plugin available for your desired tool. If a plugin is available, include it in your pipeline configuration and follow the plugin's documentation for configuration instructions. If it's not, learn about [writing plugins](/docs/plugins/writing).
   * **Webhooks and APIs:** If no plugin is available for your desired tool, consider using [webhooks](/docs/apis/webhooks) or [APIs](/docs/apis) to create custom integrations. Buildkite supports outgoing webhooks for various pipeline events, and many workflow tools provide APIs to interact with their services. Use custom scripts or tools in your pipeline steps to send notifications and interact with your workflow tools.
   * **Third-party services:** Some third-party services provide direct integrations with Buildkite. Check your tools to see if they can help you achieve the desired integrations without writing custom scripts.
1. **Set up notification channels:** Create dedicated notification channels in your chat applications to receive CI/CD updates. This approach helps keep your team informed without cluttering general communication channels.
1. **Configure notification triggers:** Configure your integrations to send notifications based on specific pipeline events, such as build failures, deployments, or critical alerts. Avoid excessive notifications by focusing on essential events that require your team's attention. See [Triggering notifications](/docs/pipelines/notifications) for more information.
1. **Customize notification content:** Tailor the content of your notifications to include relevant information, such as build status, commit details, and links to artifacts or logs. Customize your notifications to be as informative and actionable as possible, so your team can quickly identify and address issues.

Continue adjusting the settings as you gather feedback from your team on the effectiveness and usefulness of your integrations and notifications.

Keep your integrations up to date by monitoring the release notes and updates for Buildkite plugins and the workflow tools you use. Updating your integrations ensures compatibility, fixes bugs, and introduces new features.

## Share with your team

Buildkite is more fun together, so share the new CI/CD setup with your wider team. Use resources from the [home page](https://buildkite.com/home), [documentation](https://buildkite.com/docs), and [community forum](https://forum.buildkite.community/) to help introduce people to Buildkite and its principles. These will help them adapt to the new CI/CD environment.

Consider also creating internal documentation to outline any information specific to how you're using Buildkite. Include information on your Buildkite agent infrastructure, pipeline configurations, and integration with workflow tools and notifications. Hands-on internal training and workshop sessions have helped people bring the rest of their teams along and explain how Buildkite aligns with your organization's goals.

Some companies assign _Buildkite champions_ who are knowledgeable about Buildkite to each team. These champions help answer questions, provide guidance, and support their colleagues during onboarding.

## Next steps

That's it! 🎉

Migrating from Jenkins to Buildkite provides a more flexible, scalable, and secure build infrastructure for your applications.

Remember that it may take some time to adapt to the new platform, and be prepared to address any issues or challenges that arise during the migration process. We recommend you gather feedback from your team members on their experiences with Buildkite, so you can continually optimize your setup.

After configuring Buildkite Pipelines for your team, you could get actionable insights from the tests running in pipelines using [Test Analytics](/docs/test-analytics).
