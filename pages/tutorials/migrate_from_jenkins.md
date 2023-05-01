# Migrate from Jenkins

If you are familiar with [Jenkins](https://www.jenkins.io) and are looking to migrate to Buildkite, this guide is for you. Buildkite is a modern and flexible continuous integration and delivery (CI/CD) platform that provides a powerful and scalable build infrastructure for your applications.

While Jenkins and Buildkite have similar goals as CI/CD platforms, they differ in their approach. Buildkite uses a hybrid model consisting of:

- A software-as-a-service (SaaS) platform for visualization and management of CI pipelines.
- Agents that execute jobs on your infrastructure, either on-premise or in the cloud. 

Buildkite addresses the pain points of Jenkins’ users, namely its security issues (both in its [base code](https://www.cvedetails.com/vulnerability-list/vendor_id-15865/product_id-34004/Jenkins-Jenkins.html) and [plugins](https://securityaffairs.co/wordpress/132836/security/jenkins-plugins-zero-day-flaws.html)), time-consuming setup, and speed. This approach makes Buildkite more secure, scalable, and flexible. 

Follow the steps in this guide for a smooth migration from Jenkins to Buildkite.

## 1. Understand the differences

While most of the concepts will be familiar, there are some differences in the approach to understand.

### System architecture

While Jenkins is a general automation engine with plugins to add additional features, Buildkite Pipelines is a product specifically aimed at CI/CD. You can think of Buildkite Pipelines like Jenkins with the Pipeline suite of plugins. To simplify it, we'll refer to Jenkins Pipeline as just _Jenkins_ and Buildkite Pipelines as _Buildkite_.

At a high level, Buildkite follows a similar architecture to Jenkins:

- A central control panel that coordinates work and displays results. 
  - **Jenkins:** A _controller_ shown in the web UI. 
  - **Buildkite:** The _Buildkite dashboard_.
- A program that executes the work it receives from the control panel. 
  - **Jenkins:** A combination of _nodes_, _executors_, and _agents_.
  - **Buldkite:** _Agents_.

However, while you're responsible for scaling and operating both components in Jenkins, Buildkite manages the control panel as a SaaS offering (the Buildkite dashboard). This reduces the operational burden on your team, as Buildkite takes care of platform maintenance, updates, and availability. The Buildkite dashboard also handles monitoring tools like logs, user access, and notifications.

The program that executes work is called an _agent_ in Buildkite. An agent is a small, reliable, and cross-platform build runner that connects your infrastructure to Buildkite. It polls Buildkite for work, runs jobs, and reports results. You can install agents on local machines, cloud servers, or other remote machines.

In Jenkins, you manage concurrency by having multiple executors within a single node. In Buildkite, you run multiple agents on a single machine or across multiple machines.

The following diagram shows the split between the hosted platform and the agents running on your infrastructure.

<svg alt="Diagram showing agent to agent API communication" viewBox="0 0 730 570"><defs><rect id="agent-comms-svg-i" x="11" y="11" width="102" height="65" rx="8"/><rect id="agent-comms-svg-j" x="6" y="6" width="102" height="65" rx="8"/><rect id="agent-comms-svg-k" width="102" height="65" rx="8"/><rect id="agent-comms-svg-l" width="75" height="48" rx="8"/><path d="M0 8.007C0 3.585 3.575 0 7.996 0h165.008C177.42 0 181 3.588 181 8.007v31.986c0 4.422-3.575 8.007-7.996 8.007H7.996C3.58 48 0 44.412 0 39.993V8.007z" id="agent-comms-svg-a"/><mask id="agent-comms-svg-m" x="0" y="0" width="181" height="48" fill="#fff"><use xlink:href="#agent-comms-svg-a"/></mask><path d="M0 8.007C0 3.585 3.575 0 7.997 0h178.006C190.42 0 194 3.588 194 8.007v31.986c0 4.422-3.575 8.007-7.997 8.007H7.997C3.58 48 0 44.412 0 39.993V8.007z" id="agent-comms-svg-b"/><mask id="agent-comms-svg-n" x="0" y="0" width="194" height="48" fill="#fff"><use xlink:href="#agent-comms-svg-b"/></mask><path d="M0 8.007C0 3.585 3.576 0 7.99 0h119.02c4.412 0 7.99 3.588 7.99 8.007v31.986c0 4.422-3.576 8.007-7.99 8.007H7.99C3.579 48 0 44.412 0 39.993V8.007z" id="agent-comms-svg-c"/><mask id="agent-comms-svg-o" x="0" y="0" width="135" height="48" fill="#fff"><use xlink:href="#agent-comms-svg-c"/></mask><path d="M0 8.007C0 3.585 3.575 0 7.996 0h165.008C177.42 0 181 3.588 181 8.007v31.986c0 4.422-3.575 8.007-7.996 8.007H7.996C3.58 48 0 44.412 0 39.993V8.007z" id="agent-comms-svg-d"/><mask id="agent-comms-svg-p" x="0" y="0" width="181" height="48" fill="#fff"><use xlink:href="#agent-comms-svg-d"/></mask><path d="M0 8.007C0 3.585 3.575 0 7.996 0h165.008C177.42 0 181 3.588 181 8.007v31.986c0 4.422-3.575 8.007-7.996 8.007H7.996C3.58 48 0 44.412 0 39.993V8.007z" id="agent-comms-svg-e"/><mask id="agent-comms-svg-q" x="0" y="0" width="181" height="48" fill="#fff"><use xlink:href="#agent-comms-svg-e"/></mask><path d="M0 8.007C0 3.585 3.575 0 7.997 0h178.006C190.42 0 194 3.588 194 8.007v31.986c0 4.422-3.575 8.007-7.997 8.007H7.997C3.58 48 0 44.412 0 39.993V8.007z" id="agent-comms-svg-f"/><mask id="agent-comms-svg-r" x="0" y="0" width="194" height="48" fill="#fff"><use xlink:href="#agent-comms-svg-f"/></mask><path d="M14 8.007C14 3.585 17.576 0 21.99 0h119.02c4.412 0 7.99 3.588 7.99 8.007v31.986c0 4.422-3.576 8.007-7.99 8.007H21.99C17.579 48 14 44.412 14 39.993V8.007z" id="agent-comms-svg-g"/><mask id="agent-comms-svg-s" x="0" y="0" width="135" height="48" fill="#fff"><use xlink:href="#agent-comms-svg-g"/></mask><path d="M0 8.007C0 3.585 3.585 0 7.998 0h151.004C163.419 0 167 3.588 167 8.007v31.986c0 4.422-3.585 8.007-7.998 8.007H7.998C3.581 48 0 44.412 0 39.993V8.007z" id="agent-comms-svg-h"/><mask id="agent-comms-svg-t" x="0" y="0" width="167" height="48" fill="#fff"><use xlink:href="#agent-comms-svg-h"/></mask><rect id="agent-comms-svg-u" width="75" height="48" rx="8"/><rect id="agent-comms-svg-v" x="11" y="11" width="102" height="65" rx="8"/><rect id="agent-comms-svg-w" x="6" y="6" width="102" height="65" rx="8"/><rect id="agent-comms-svg-x" width="102" height="65" rx="8"/><rect id="agent-comms-svg-y" x="11" y="11" width="102" height="65" rx="8"/><rect id="agent-comms-svg-z" x="6" y="6" width="102" height="65" rx="8"/><rect id="agent-comms-svg-A" width="102" height="65" rx="8"/></defs><g fill="none" fill-rule="evenodd"><path d="M-.5 274.5h732.154" stroke="#DCDCDC" stroke-linecap="square" stroke-dasharray="10"/><text font-family="'Maison Neue'" font-size="18" font-weight="400" fill="#666"><tspan x="618" y="305">On-Premises</tspan></text><text font-family="'Maison Neue'" font-size="18" font-weight="400" fill="#666"><tspan x="581" y="32">Hosted Platform</tspan></text><g transform="translate(163 383)"><use fill="#FFF" xlink:href="#agent-comms-svg-i"/><rect stroke="#979797" x="11.5" y="11.5" width="101" height="64" rx="8"/></g><g transform="translate(163 383)"><use fill="#FFF" xlink:href="#agent-comms-svg-j"/><rect stroke="#979797" x="6.5" y="6.5" width="101" height="64" rx="8"/></g><g transform="translate(163 383)"><use fill="#FFF" xlink:href="#agent-comms-svg-k"/><rect stroke="#979797" x=".5" y=".5" width="101" height="64" rx="8"/></g><text font-family="'Maison Neue'" font-size="18" font-weight="bold" letter-spacing="1.125" fill="#2ACE69" transform="translate(163 383)"><tspan x="18.311" y="39">AGENT</tspan></text><g transform="translate(95 312)"><use fill="#FFF" xlink:href="#agent-comms-svg-l"/><rect stroke="#979797" x=".5" y=".5" width="74" height="47" rx="8"/></g><text font-family="'Maison Neue'" font-size="13" font-weight="bold" letter-spacing=".813" fill="#2ACE69" transform="translate(95 312)"><tspan x="14.157" y="30">AGENT</tspan></text><g transform="translate(56 490)"><use stroke="#979797" mask="url(#m)" stroke-width="2" fill="#FFF" stroke-dasharray="3" xlink:href="#agent-comms-svg-a"/><text font-family="'Maison Neue'" font-size="13" font-weight="bold" letter-spacing=".813" fill="#000"><tspan x="20.434" y="30">YOUR SOURCE CODE</tspan></text></g><g transform="translate(275 492)"><use stroke="#979797" mask="url(#n)" stroke-width="2" fill="#FFF" stroke-dasharray="3" xlink:href="#agent-comms-svg-b"/><text font-family="'Maison Neue'" font-size="13" font-weight="bold" letter-spacing=".813" fill="#000"><tspan x="15.187" y="30">YOUR DEPLOY SECRETS</tspan></text></g><g transform="translate(65 67)"><use stroke="#979797" mask="url(#o)" stroke-width="2" fill="#FFF" stroke-dasharray="3" xlink:href="#agent-comms-svg-c"/><text font-family="'Maison Neue'" font-size="13" font-weight="bold" letter-spacing=".813" fill="#000"><tspan x="26.595" y="30">WEBHOOKS</tspan></text></g><g transform="translate(264 43)"><use stroke="#979797" mask="url(#p)" stroke-width="2" fill="#FFF" stroke-dasharray="3" xlink:href="#agent-comms-svg-d"/><text font-family="'Maison Neue'" font-size="13" font-weight="bold" letter-spacing=".813" fill="#000"><tspan x="19.539" y="30">SCM INTEGRATIONS</tspan></text></g><g transform="translate(39 185)"><use stroke="#979797" mask="url(#q)" stroke-width="2" fill="#FFF" stroke-dasharray="3" xlink:href="#agent-comms-svg-e"/><text font-family="'Maison Neue'" font-size="13" font-weight="bold" letter-spacing=".813" fill="#000"><tspan x="16.084" y="30">CHAT INTEGRATIONS</tspan></text></g><g transform="translate(494 185)"><use stroke="#979797" mask="url(#r)" stroke-width="2" fill="#FFF" stroke-dasharray="3" xlink:href="#agent-comms-svg-f"/><text font-family="'Maison Neue'" font-size="13" font-weight="bold" letter-spacing=".813" fill="#000"><tspan x="19.984" y="30">REST &amp; GRAPHQL APIs</tspan></text></g><g transform="translate(507 67)"><use stroke="#979797" mask="url(#s)" stroke-width="2" fill="#FFF" stroke-dasharray="3" xlink:href="#agent-comms-svg-g"/><text font-family="'Maison Neue'" font-size="13" font-weight="bold" letter-spacing=".813" fill="#000"><tspan x="26.849" y="30">WEB INTERFACE</tspan></text></g><g transform="translate(507 490)"><use stroke="#979797" mask="url(#t)" stroke-width="2" fill="#FFF" stroke-dasharray="3" xlink:href="#agent-comms-svg-h"/><text font-family="'Maison Neue'" font-size="13" font-weight="bold" letter-spacing=".813" fill="#000"><tspan x="13.482" y="30">INTERNAL SYSTEMS</tspan></text></g><g transform="translate(526 312)"><use fill="#FFF" xlink:href="#agent-comms-svg-u"/><rect stroke="#979797" x=".5" y=".5" width="74" height="47" rx="8"/></g><text font-family="'Maison Neue'" font-size="13" font-weight="bold" letter-spacing=".813" fill="#2ACE69" transform="translate(526 312)"><tspan x="14.157" y="30">AGENT</tspan></text><g transform="translate(298 383)"><use fill="#FFF" xlink:href="#agent-comms-svg-v"/><rect stroke="#979797" x="11.5" y="11.5" width="101" height="64" rx="8"/></g><g transform="translate(298 383)"><use fill="#FFF" xlink:href="#agent-comms-svg-w"/><rect stroke="#979797" x="6.5" y="6.5" width="101" height="64" rx="8"/></g><g transform="translate(298 383)"><use fill="#FFF" xlink:href="#agent-comms-svg-x"/><rect stroke="#979797" x=".5" y=".5" width="101" height="64" rx="8"/></g><text font-family="'Maison Neue'" font-size="18" font-weight="bold" letter-spacing="1.125" fill="#2ACE69" transform="translate(298 383)"><tspan x="18.311" y="39">AGENT</tspan></text><g transform="translate(228 113)"><rect stroke="#979797" x=".5" y=".5" width="249" height="64" rx="8"/><text font-family="'Maison Neue'" font-size="18" font-weight="bold" letter-spacing="1.125" fill="#2ACE69"><tspan x="18.98" y="39">BUILDKITE AGENT API</tspan></text></g><g transform="translate(430 383)"><use fill="#FFF" xlink:href="#agent-comms-svg-y"/><rect stroke="#979797" x="11.5" y="11.5" width="101" height="64" rx="8"/></g><g transform="translate(430 383)"><use fill="#FFF" xlink:href="#agent-comms-svg-z"/><rect stroke="#979797" x="6.5" y="6.5" width="101" height="64" rx="8"/></g><g transform="translate(430 383)"><use fill="#FFF" xlink:href="#agent-comms-svg-A"/><rect stroke="#979797" x=".5" y=".5" width="101" height="64" rx="8"/></g><text font-family="'Maison Neue'" font-size="18" font-weight="bold" letter-spacing="1.125" fill="#2ACE69" transform="translate(430 383)"><tspan x="18.311" y="39">AGENT</tspan></text><path d="M353.5 185.5l166 119M519.5 304.5l-7.03-8.73-3.495 4.876L519.5 304.5zM353.5 185.5l116 183M469.5 368.5l-3.248-10.728-5.068 3.212 8.316 7.516zM353.5 185.5l-8 181M345.5 366.5l3.474-10.657-5.994-.265 2.52 10.922zM353.5 185.5l-131 184M222.5 369.5l8.708-7.058-4.888-3.48-3.82 10.538zM353.5 185.5l-173 118M180.5 303.5l10.613-3.607-3.381-4.957-7.232 8.564z" stroke="#B4B4B4" fill="#B4B4B4" stroke-linecap="square"/></g></svg>

The diagram shows that Buildkite provides a web interface, handles integrations with third-party tools, and offers APIs and webhooks. Buildkite communicates with the agents on your infrastructure, which access your code, secrets, and internal systems.

This decoupling provides flexibility, as you can scale the build agents independently while Buildkite manages the coordination, scheduling, and web interface.

### Security

Security is crucial in CI/CD, protecting sensitive information, system integrity, and compliance with industry standards. Jenkins and Buildkite have different approaches to security, which will impact how you manage your CI/CD pipeline's security aspects.

Securing a Jenkins instance requires careful configuration, plugin management, and regular updates to address security vulnerabilities. You must consider vulnerabilities in both the [base code](https://www.cvedetails.com/vulnerability-list/vendor_id-15865/product_id-34004/Jenkins-Jenkins.html) and [plugins](https://securityaffairs.co/wordpress/132836/security/jenkins-plugins-zero-day-flaws.html). Additionally, since Jenkins is a self-hosted solution, you are responsible for securing the underlying infrastructure, network, and storage.

Buildkite's hybrid architecture, which combines a centralized SaaS platform with self-hosted build agents, provides a unique approach to security. Buildkite takes care of the security of the SaaS platform, including user authentication, pipeline management, and web interface. Build agents, which run on your infrastructure, allow you to maintain control over the environment, security, and resources. 

Both Jenkins and Buildkite support multiple authentication providers and offer granular access control. However, Buildkite's SaaS platform provides a more centralized and streamlined approach to user management, making it easier to enforce security policies and manage user access across your organization.

With Buildkite, you are responsible for securing the build agents running on your infrastructure, while Buildkite handles the SaaS platform's security. This separation reduces the operational burden and allows you to focus on securing the environments where your code is built and tested.

### Pipeline configuration

When migrating your CI/CD pipelines from Jenkins to Buildkite, one key aspect to understand is the difference in pipeline configuration between these two platforms. 

Like Jenkins, Buildkite lets you create pipeline definitions in the UI or in a file checked into the repo. Most people use the latter to include their pipeline definitions next to the code, managed in source control. The equivalent of a `Jenkinsfile` is a `pipeline.yml`.

Rather than a full programming language like the Groovy-based syntax in Jenkins, Buildkite uses a YAML-based syntax. The YAML definitions are simpler,  more human-readable, and easier to understand. 

The hierarchical structure of Jenkins pipelines, stages, and steps is replaced by a linear sequence of steps in Buildkite, making the pipeline configuration more accessible. You can use the expressive labels and group steps to achieve a similar organization as stages in Jenkins, but it's not required.

### Plugin system

Plugins are an essential part of both Jenkins and Buildkite. Jenkins has a vast plugin ecosystem, with thousands of plugins available to extend its functionality. Jenkins plugins are typically written in Java and tightly integrated with the Jenkins core.

Buildkite has a more streamlined plugin system. Buildkite plugins are focused on essential integrations and frequently used tasks in CI/CD pipelines. The Buildkite plugin system encourages using custom scripts, APIs, or third-party tools to achieve additional functionality, making the system more flexible and less reliant on plugins. Buildkite plugins are typically written in Bash or other scripting languages and hosted on GitHub. They can be easily included in pipeline configuration files using the plugins attribute.

Jenkins has a larger plugin ecosystem with thousands of plugins available for various tools, platforms, and integrations. These plugins may have compatibility issues, security vulnerabilities, or require constant updates. Buildkite has a smaller, more focused set of plugins that cover essential use cases. Buildkite promotes using custom scripts or third-party tools for additional functionality, which may require you to adapt your pipeline configurations during migration.

Jenkins provides a web-based plugin management system for searching, installing, updating, and configuring plugins. Buildkite plugins are managed through pipeline configurations, where you include the desired plugin's GitHub repository and version. This makes Buildkite plugins more decentralized and allows for easier version control.

Jenkins plugins are typically developed in Java and are closely integrated with the Jenkins core, which may lead to compatibility issues when updating Jenkins or its plugins. Buildkite plugins are written in Bash or other scripting languages and are more loosely coupled with the Buildkite core, making them more maintainable and less prone to compatibility issues.

In Jenkins, plugins are configured globally or per project, and their functionality is exposed through pipeline steps or post-build actions. In Buildkite, plugins are included and configured directly in the pipeline configuration file, making it easier to track, version-control, and share plugin configurations across pipelines and teams.

## 2. Try out Buildkite

The first step in migrating to Buildkite is to set up a Buildkite account. This can be done by visiting the Buildkite website and signing up for a free trial. Once you have an account, you can start creating pipelines and agents to run your builds.

Build agents are the servers that run your builds. To run builds in Buildkite, you will need to set up one or more Build agents. Buildkite provides a variety of options for setting up Build agents, including cloud-based agents and on-premise agents.


- Getting started guide
- Account
- Connect code + trigger builds from webhooks
- Agent

Learn the basics with local agents -> Translate a few pipelines. See our examples.

Key takeaways:

- Pipelines model... with steps.
- Running a pipeline creates a build, which you monitor and view in the dashboard.
- You install agents on your infrasturcutee. They receive instructions for the work to complete from BK.
- Agents isolate your code and secrets so BK never sees it.

## 3. Provision agent infrastructure

Ensure that the agents have the necessary dependencies, such as programming languages, build tools, and libraries, to run your pipelines.

Will be similar to your setup with Jenkins except that you don't also have to run a node for the controller.

The agent infrastructure is where your builds, tests, and deployments run. In Buildkite, agents run on your infrastructure, providing flexibility and control over the environment and resources. 

Evaluate your current Jenkins nodes' resource usage (CPU, memory, and disk space) to determine the requirements for your Buildkite agent infrastructure. This assessment will help you plan the right resources and ensure optimal performance for your CI/CD pipelines.

Identify platform dependencies: Take note of the operating systems, libraries, tools, and dependencies installed on your Jenkins nodes. This information will help you configure your Buildkite agents with the required platforms and dependencies for your pipelines.

Examine network configurations: Review the network configurations of your Jenkins nodes, including firewalls, proxy settings, and network access to external resources. These configurations will guide you in setting up the network environment for your Buildkite agents.

Choose the infrastructure type: Buildkite agents can run on various infrastructure types, including on-premises, cloud (AWS, GCP, Azure), or container platforms (Docker, Kubernetes). Based on your analysis of the existing Jenkins nodes, choose the infrastructure type that best suits your organization's needs and constraints.

Determine agent scaling: Evaluate the number of concurrent builds and the build queue length in your Jenkins nodes to estimate the number of Buildkite agents needed. Keep in mind that you can scale Buildkite agents independently, allowing you to optimize resource usage and reduce build times.

Plan for build isolation and security: Consider using separate agents for different projects or environments to ensure build isolation and security. You can use agent tags and target specific agents for specific pipeline steps, allowing for fine-grained control over agent allocation.

Install Buildkite agent software: Follow the Buildkite agent installation guide for your chosen infrastructure type. The agent software is available for various platforms, including Linux, macOS, and Windows.

Configure agent settings: Configure the Buildkite agent settings, including the agent token, name, and tags. Use agent tags to describe the agent's capabilities (e.g., operating system, tools, or environment) to target specific agents in your pipeline steps.

Migrate platform dependencies: Install the necessary platforms, tools, and dependencies identified in step 1.2 on your Buildkite agents to ensure compatibility with your pipelines.

Configure network settings: Apply the network configurations from your existing Jenkins nodes, such as firewall rules, proxy settings, and access to external resources, to your Buildkite agent infrastructure.

Monitor agent performance: Keep an eye on your Buildkite agent infrastructure's performance, resource usage, and build times to identify any bottlenecks or resource constraints.

Optimize resource allocation: Adjust the number of Buildkite agents or their resource allocation based on your monitoring data to optimize build times and resource usage.

## 4. Translate pipeline definitions

Recommend you think of the goal and how to achieve that in Buildkite rather than automating the migration.

Take inventory of your existing Jenkins pipelines, plugins, and integrations. Determine which parts of your Jenkins setup are essential and which can be replaced or removed. This will help you decide what needs to be migrated to Buildkite.


....

Targeting agents.

Customization:
- BK Beyond conditionals to dynamic pipelines -> Beyond Jenkins
- Flexibility through the API, hooks, and plugins. -> Similar to Jenkins



Here is an example pipeline file for a simple Node.js application:

yaml
Copy code
steps:
  - name: "Run tests"
    command: "npm test"
    agents:
      queue: "node"
  - name: "Build and Deploy"
    command: "npm run build && npm run deploy"
    agents:
      queue: "node"
This pipeline defines two steps: "Run tests" and "Build and Deploy". The first step runs the npm test command to run the tests for the Node.js application. The second step runs the npm run build and npm run deploy commands to build and deploy the application.

-> webhooks
Once you have created your pipeline and set up your Build agents, you can trigger builds by pushing code to your source code repository. Buildkite will automatically detect the changes and start a build.

Once you have created your pipeline and set up your Build agents, you can trigger builds by pushing code to your source code repository. Buildkite will automatically detect the changes and start a build.

Identify the Jenkins plugins and integrations you need to migrate to Buildkite. Look for equivalent Buildkite plugins, native integrations, or alternative solutions to replace the functionality provided by your Jenkins plugins. You may need to create custom scripts or use third-party tools to achieve the same functionality in some cases.

Move your environment variables, secrets, and credentials from Jenkins to Buildkite. Buildkite allows you to manage environment variables and secrets on different levels, such as organization, pipeline, and step levels. Store your sensitive data securely using Buildkite's secret management or a third-party secrets management tool.

Test the migrated pipelines:
Run the migrated pipelines on Buildkite to verify that they are working correctly. Monitor the pipeline execution, compare the results with your Jenkins pipelines, and address any issues that may arise.

## 5. Intregrate your tools

Your workflow.
- Integrate with existing tools like notifications etc.

Configure your new Buildkite pipelines to work with your existing development workflow, such as triggering builds on pull requests or commits. Set up notifications to inform your team about build status, test results, and deployments.

Integrating workflow tools and notifications with your CI/CD pipelines helps streamline processes and keeps your team informed about build and deployment status. Buildkite supports various integrations with tools like chat applications, issue trackers, and monitoring systems. In this document, we will provide advice and best practices for integrating your normal workflow tools and notifications with Buildkite.
Identify Your Workflow Tools and Notification Requirements:
1.1. List essential tools: Identify the workflow tools and notification systems that you currently use or need to integrate with your CI/CD pipelines. Common tools include chat applications (e.g., Slack, Microsoft Teams), issue trackers (e.g., Jira, GitHub Issues), and monitoring systems (e.g., Datadog, New Relic).
1.2. Define notification requirements: Determine the types of notifications your team needs, such as build status, deployment updates, test results, and alerts for critical issues. This information will help you configure the appropriate integrations and notification settings.
Choose the Right Integration Approach:
2.1. Use Buildkite plugins: Buildkite provides several plugins to integrate with popular workflow tools and notification systems. Check the Buildkite plugins directory to see if there's a plugin available for your desired tool. If a plugin is available, include it in your pipeline configuration and follow the plugin's documentation for configuration instructions.
2.2. Leverage webhooks and APIs: If no Buildkite plugin is available for your desired tool, consider using webhooks or APIs to create custom integrations. Buildkite supports outgoing webhooks for various pipeline events, and many workflow tools provide APIs to interact with their services. Use custom scripts or tools in your pipeline steps to send notifications and interact with your workflow tools.
2.3. Utilize third-party services: Some third-party services, like Zapier, provide integration platforms that can connect Buildkite with various workflow tools and notification systems. Explore these services to see if they can help you achieve the desired integrations without writing custom scripts or managing complex configurations.
Configure Notifications:
3.1. Set up notification channels: Create dedicated notification channels in your chat applications, such as a Slack channel or a Microsoft Teams group, to receive CI/CD updates. This approach helps keep your team informed without cluttering general communication channels.
3.2. Customize notification content: Tailor the content of your notifications to include relevant information, such as build status, commit details, and links to artifacts or logs. Customize your notifications to be as informative and actionable as possible, so your team can quickly identify and address issues.
3.3. Configure notification triggers: Configure your integrations to send notifications based on specific pipeline events, such as build failures, deployments, or critical alerts. Avoid excessive notifications by focusing on essential events that require your team's attention.
Monitor and Optimize Your Integrations:
4.1. Gather feedback: Collect feedback from your team on the effectiveness and usefulness of your integrations and notifications. Use this feedback to adjust your notification settings, content, and triggers to better serve your team's needs.
4.2. Stay up to date: Keep your integrations up to date by monitoring the release notes and updates for Buildkite plugins and the workflow tools you use. Updating your integrations can help ensure compatibility, fix bugs, and introduce new features.

Conclusion: Integrating your normal workflow tools and notifications with Buildkite requires identifying your needs, choosing the right integration approach, and configuring your notifications to best serve your team. By following these best practices and advice, you can effectively integrate your workflow tools with Buildkite and streamline your CI/CD processes


## 6. Share with your team

Train your team:
Educate your team about the changes in the CI/CD process, the new Buildkite interface, and any new tools or integrations introduced during the migration. Provide documentation and resources to help your team adapt to the new environment.

Continuously monitor your Buildkite pipelines and identify areas for improvement. Optimize your pipelines to reduce build times and resource usage, and maintain the quality and stability of your software.

Prepare Documentation and Resources:
1.1. Internal documentation:
Create internal documentation that outlines your organization's CI/CD processes, Buildkite-specific guidelines, and best practices. Include information on your Buildkite agent infrastructure, pipeline configurations, and integration with workflow tools and notifications. This documentation will serve as a reference for your team members as they get started with Buildkite.

1.2. Gather external resources:
Compile a list of helpful external resources, such as Buildkite's official documentation, blog articles, and community forums. These resources can help your team members familiarize themselves with Buildkite's features and capabilities.

Conduct Training and Workshops:
2.1. Introductory training:
Organize an introductory training session to familiarize your team with Buildkite's features, pipeline configuration, and integrations. Use this opportunity to showcase the benefits of Buildkite compared to your previous CI/CD solution and explain how it aligns with your organization's goals.

2.2. Hands-on workshops:
Host hands-on workshops where team members can practice creating and configuring Buildkite pipelines, using plugins, and integrating with workflow tools. These workshops will help your team gain practical experience and confidence in using Buildkite.

Assign Buildkite Champions:
3.1. Identify champions:
Select one or more team members who are knowledgeable about Buildkite and can serve as "champions" for the platform. These champions will help answer questions, provide guidance, and support their colleagues during the onboarding process.

3.2. Support and recognition:
Provide your Buildkite champions with additional resources, training, and recognition for their efforts. Encourage them to stay up to date with Buildkite's latest features and best practices, and share their knowledge with the rest of the team.

Encourage Collaboration and Knowledge Sharing:
4.1. Share success stories:
Encourage team members to share their experiences and success stories with Buildkite. This can help demonstrate the value of the platform and motivate others to fully utilize its features.

4.2. Organize knowledge-sharing sessions:
Schedule regular knowledge-sharing sessions where team members can discuss their experiences, share tips and tricks, and learn from each other. This can help foster a culture of collaboration and continuous improvement.

Monitor Progress and Gather Feedback:
5.1. Track onboarding progress:
Monitor your team's progress with Buildkite by tracking metrics such as pipeline adoption, build times, and the number of successful integrations. Use this data to identify areas where additional support or training may be needed.

5.2. Collect feedback:
Gather feedback from your team members on their experiences with Buildkite, including any challenges they have faced and suggestions for improvement. Use this feedback to refine your onboarding process and address any concerns.

Conclusion:
Sharing Buildkite with your team and ensuring successful onboarding involves preparing documentation and resources, conducting training and workshops, assigning champions, encouraging collaboration, and monitoring progress. By following these steps, you can help your team onboard smoothly, embrace Buildkite, and fully realize the benefits of your CI/CD pipelines.


## Next steps

That's it! 🎉

Migrating from Jenkins to Buildkite is a straightforward process that can provide you with a more flexible and scalable build infrastructure for your applications. By following these steps, you can take advantage of the powerful features and capabilities of Buildkite to streamline your CI/CD process and improve the efficiency and reliability of your builds.


By following these steps, you can ensure a smooth migration of your CI/CD pipelines from Jenkins to Buildkite. Remember that it may take some time to adapt to the new platform, and be prepared to address any issues or challenges that arise during the migration process.

To keep learning about Buildkite, see:

- ...