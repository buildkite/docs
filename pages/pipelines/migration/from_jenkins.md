# Migrate from Jenkins

This guide is for people who are familiar with or already use [Jenkins](https://www.jenkins.io) and want to migrate to the Buildkite platform.

The Buildkite platform is a modern and flexible continuous integration and deployment (CI/CD) platform that provides a powerful and scalable build infrastructure for your applications.

While Jenkins and the Buildkite platform (which offers Buildkite Pipelines) have similar goals as CI/CD platforms, their approach differs. Buildkite Pipelines uses a hybrid model consisting of the following:

- A software-as-a-service (SaaS) platform for visualization and management of CI/CD pipelines.
- Agents for executing jobs—hosted by you, either on-premises or in the cloud.

Buildkite addresses the pain points of Jenkins' users, namely its security issues (both in its [base code](https://www.cvedetails.com/vulnerability-list/vendor_id-15865/product_id-34004/Jenkins-Jenkins.html) and [plugins](https://securityaffairs.co/wordpress/132836/security/jenkins-plugins-zero-day-flaws.html)), time-consuming setup, and speed. This approach makes Buildkite more secure, scalable, and flexible.

Follow the steps in this guide for a smooth migration from Jenkins to Buildkite Pipelines.

## Understand the differences

Most of the concepts will likely be familiar, but there are some differences to understand about the approaches.

### System architecture

While Jenkins is a general automation engine with plugins to add additional features, Buildkite Pipelines is a product specifically aimed at CI/CD. You can think of Buildkite Pipelines like Jenkins with the Pipeline suite of plugins. To simplify it, we'll refer to Jenkins Pipeline as just _Jenkins_ and Buildkite Pipelines as _Buildkite_.

At a high level, Buildkite follows a similar architecture to Jenkins:

- A central control plane that coordinates work and displays results through a web interface.
    * **Jenkins:** A _controller_.
    * **Buildkite:** The _Buildkite dashboard_.
- A program that executes the work it receives from the control plane.
    * **Jenkins:** A combination of _nodes_, _executors_, and _agents_.
    * **Buildkite:** _Buildkite Agents_.

However, while you're responsible for scaling and operating both components in Jenkins, Buildkite manages the control plane as a SaaS offering (through the Buildkite dashboard). This reduces the operational burden on your team, as Buildkite takes care of platform maintenance, updates, and availability. The Buildkite dashboard also handles monitoring tools like logs, user access, and notifications.

The program that executes work is called an _agent_ in Buildkite (also known as the [_Buildkite Agent_](/docs/agent/v3)). An agent is a small, reliable, and cross-platform build runner that connects your infrastructure to Buildkite. The Buildkite Agent polls Buildkite for work, runs jobs, and reports results. You can install these agents on local machines, cloud servers, or other remote machines. The Buildkite Agent code is open-source, and is [accessible from GitHub](https://github.com/buildkite/agent).

The following diagram shows the split in Buildkite between its SaaS platform and Buildkite Agents running in your infrastructure.

<%= image "buildkite-hybrid-architecture.png", alt: "Shows the hybrid architecture combining a SaaS platform with your infrastructure" %>

The diagram shows that Buildkite provides a web interface, handles integrations with third-party tools, and offers APIs and webhooks. By design, sensitive data, such as source code and secrets, remain within your environment and are not seen by Buildkite. This decoupling provides flexibility, as you can scale your agents and build environment independently, while Buildkite manages the coordination of these agents, build scheduling, as well as associated metrics and insights available through its web interface.

In Jenkins, concurrency is managed through multiple executors within a single node. In Buildkite, multiple agents can run on either a single machine or across multiple machines.

See [Buildkite Pipelines architecture](/docs/pipelines/architecture) to learn more about how you can set up Buildkite to work with your organization.

### Security

Security is crucial in CI/CD, protecting sensitive information, system integrity, and compliance with industry standards. Jenkins and Buildkite have different approaches to security, which impacts how you manage your CI/CD pipelines' security.

Securing a Jenkins instance requires:

- Careful configuration.
- Plugin management.
- Regular updates to address security vulnerabilities.

You must consider vulnerabilities in both Jenkins' own [code base](https://www.cvedetails.com/vulnerability-list/vendor_id-15865/product_id-34004/Jenkins-Jenkins.html) and [plugins](https://securityaffairs.co/wordpress/132836/security/jenkins-plugins-zero-day-flaws.html). Additionally, since Jenkins is a self-hosted solution, you are responsible for securing the underlying infrastructure, network, and storage. Some updates require you to take Jenkins offline to perform them, leaving your team without access to CI/CD resources during that period.

Buildkite's hybrid architecture, which combines a centralized SaaS platform with [self-hosted Buildkite Agents](/docs/pipelines/architecture#self-hosted-hybrid-architecture) (and more recently, [Buildkite hosted agents](/docs/pipelines/architecture#buildkite-hosted-architecture)), provides a unique approach to security. Buildkite takes care of the security of the SaaS platform, including user authentication, pipeline management, and the web interface. Self-hosted Buildkite Agents, which run on your infrastructure, allow you to maintain control over the environment, security, and other build-related resources. This separation reduces the operational burden and allows you to focus on securing the environments where your code is built and tested.

Buildkite does not have or need access to your source code. Only the agents you host on your infrastructure need access to clone your repositories. This gives you all the benefits of a SaaS platform without many of the common security concerns.

Buildkite also doesn't store your secrets. Instead, Buildkite integrates with best-in-class tools like [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/) and [Hashicorp Vault](https://www.vaultproject.io/) to use in your pipelines.

Both Jenkins and Buildkite support multiple authentication providers and offer granular access control. However, Buildkite's SaaS platform provides a more centralized and streamlined approach to user management, making it easier to enforce security policies and manage user access across your organization.

See the [Security](/docs/pipelines/security) section of these docs to learn more about how you can secure your Buildkite build environment.

### Pipeline configuration

When migrating your CI/CD pipelines from Jenkins to Buildkite, it's important to understand the differences in pipeline configuration.

Like Jenkins, Buildkite lets you create pipeline definitions in the web interface or one or more related files checked into a repository. Most people prefer the latter, which allows pipeline definitions to be kept with the code base it builds, managed in source control. The equivalent of a `Jenkinsfile` in Buildkite is a `pipeline.yml`.

Rather than the Groovy-based syntax in Jenkins, Buildkite uses a YAML-based syntax. The YAML definitions are simpler, more human-readable, and easier to understand. And you can even generate pipeline definitions at runtime with the power and flexibility of [dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines).

In Jenkins, the core description of work is a _job_. A job contains stages with steps and can trigger other jobs. You use a job to upload a `Jenkinsfile` from a repository. Installing the Pipeline plugin lets you describe a workflow of jobs as a pipeline. Buildkite uses similar terms in different ways, where a _pipeline_ is the core description of work.

A Buildkite pipeline contains different types of [_steps_](/docs/pipelines/configure/step-types) for different tasks:

- **Command step:** Runs one or more shell commands on one or more agents.
- **Wait step:** Pauses a build until all previous jobs have completed.
- **Block step:** Pauses a build until unblocked.
- **Input step:** Collects information from a user.
- **Trigger step:** Creates a build on another pipeline.
- **Group step:** Displays a group of sub-steps as one parent step.

Triggering a Buildkite pipeline creates a _build_, and any command steps are dispatched as _jobs_ to run on agents. A common practice is to define a pipeline with a single step that uploads the `pipeline.yml` file in the code repository. The `pipeline.yml` contains the full pipeline definition and can be generated dynamically.

Unlike the terms _job_ and _pipeline_, the term _step_ in both Jenkins and Buildkite is analogous.

### Plugin system

Plugins are an essential part of both Jenkins and Buildkite, and they help you extend these products to further customize your CI/CD workflows.

Rather than managing plugins through a web-based system like Jenkins, in Buildkite, you manage plugins directly in pipeline definitions. This means that teams can manage plugins at the pipeline level, rather than there being a need to manage plugins at a monolithic system-wide level.

Jenkins plugins are typically Java-based, run in the Jenkins controller's Java virtual machine, and are shared across all pipelines. Therefore, a failure with one of these plugins can crash your entire Jenkins instance. Furthermore, since Jenkins plugins are closely integrated with Jenkins core, compatibility issues can often be encountered when either Jenkins core or its plugins are upgraded.

Buildkite plugins are shell-based, run on individual Buildkite Agents, and are pipeline-specific with independent versioning, such that plugins are only loosely coupled with Buildkite. Therefore, plugin failures are isolated to individual builds, and issues are rare whenever you use newer versions of plugins in Buildkite pipelines.

### Try out Buildkite

With a basic understanding of the differences between Buildkite and Jenkins, if you haven't already done so, the next step is to try creating and running a pipeline in Buildkite. Run through the [Getting started with Pipelines](/docs/pipelines/getting-started/) guide to get yourself set up to run pipelines in Buildkite.

## Provision agent infrastructure

Buildkite Agents:

- Are where your builds, tests, and deployments run.
- Can either run as [Buildkite hosted agents](/docs/pipelines/hosted-agents), or on your infrastructure (known as _self-hosted_), providing flexibility and control over the environment and resources. Operating agents in a self-hosted environment is similar in approach to hosting nodes in Jenkins.

If running self-hosted Buildkite Agents, you'll need to consider the following:

- **Infrastructure type:** Agents can run on various infrastructure types, including on-premises, cloud (AWS, GCP, Azure), or container platforms (Docker, Kubernetes). Based on your analysis of the existing Jenkins nodes, choose the infrastructure type that best suits your organization's needs and constraints.

- **Resource usage:** Agent infrastructure is similar to the requirements for nodes in Jenkins, without operating the controller. Evaluate your Jenkins nodes' resource usage (CPU, memory, and disk space) to determine the requirements for your Buildkite Agent infrastructure.

- **Platform dependencies:** To run your pipelines, you'll need to ensure the agents have the necessary dependencies, such as programming languages, build tools, and libraries. Take note of the operating systems, libraries, tools, and dependencies installed on your Jenkins nodes. This information will help you configure your Buildkite Agents.

- **Network configurations:** Review the network configurations of your Jenkins nodes, including firewalls, proxy settings, and network access to external resources. These configurations will guide you in setting up the network environment for your Buildkite Agents. The Buildkite Agent works by polling Buildkite's [agent API](/docs/apis/agent-api) over HTTPS. There is no need to forward ports or provide incoming firewall access.

- **Agent scaling:** Evaluate the number of concurrent builds and the build queue length in your Jenkins nodes to estimate the number of Buildkite Agents needed. Keep in mind that you can scale Buildkite Agents independently, allowing you to optimize resource usage and reduce build times.

- **Build isolation and security:** Consider using separate agents for different projects or environments to ensure build isolation and security. You can use [agent tags](/docs/agent/v3/cli-start#setting-tags) and [clusters](/docs/pipelines/clusters) to target specific agents for specific pipeline steps, allowing for fine-grained control over agent allocation.

You'll continue to adjust the agent configuration as you monitor performance to optimize build times and resource usage for your needs.

See the [Installation](/docs/agent/v3/installation/) guides when you're ready to install an agent and follow the instructions for your infrastructure type.

## Translate pipeline definitions

This section covers how to translate your Jenkins pipelines over to Buildkite.

A pipeline is a container for modeling and defining workflows. While that's true for both Buildkite and Jenkins, they look quite different. Both can read a pipeline (configuration) file checked into a repository, which defines the workflow. In Jenkins, this is the `Jenkinsfile`, whereas in Buildkite, it's the `pipeline.yml` file. Where a `Jenkinsfile` uses a Groovy-based syntax and strong hierarchy, `pipelines.yml` uses YAML syntax, with a flat structure for better readability.

### Audit your pipelines

First, take an inventory of your existing pipelines, plugins, and integrations. Determine which parts of your Jenkins setup are essential and which can be replaced or removed. This will help you decide what needs to be migrated to Buildkite.

### Understand the fundamental differences

Before translating any pipeline over from Jenkins to Buildkite, you'll need to understand the following fundamental differences in processing and building pipelines between these products:

- [Step execution](#step-execution)
- [Workspace state](#workspace-state)
- [Agent targeting](#agent-targeting)
- [Plugins](#plugins)

Once you've understood these differences, you can then assess the goal of the Jenkins pipeline to see how you can translate it to achieve the same goal with Buildkite.

<h4 id="step-execution">Step execution</h4>

By default, Jenkins runs its pipeline steps in sequence, whereas Buildkite farms out all of its steps simultaneously (that is, in parallel) to any available agents that can run them. However, you can achieve the opposite of these default behaviors in each products' pipelines.

To make a Jenkins pipeline run its steps in parallel, the [`parallel` directive](https://www.jenkins.io/doc/book/pipeline/syntax/#parallel) is used explicitly in the Jenkins pipeline. For instance, in the following Jenkins pipeline snippet, the `Lint` and `Unit Tests` steps are run simultaneously.

```groovy
// Jenkins: Explicit parallelization required to run steps in parallel
parallel(
    "Lint": { sh 'npm run lint' },
    "Unit Tests": { sh 'npm test' }
)
```

Conversely, to make a Buildkite pipeline run its steps in a specific order, use the [`depends_on` attribute](/docs/pipelines/configure/dependencies#defining-explicit-dependencies) in the step you want to run after others have run first. For instance, in the following Buildkite pipeline example, the `Lint` and `Test` steps are run in parallel (by default) first, whereas the `Build` step is run after the `Lint` and `Test` steps have completed.

```yaml
# Buildkite: Explicit sequencing is required to make steps run in sequence
steps:
  - label: "Lint"
    id: lint
    commands: [npm run lint]

  - label: "Test"
    id: test
    commands: [npm test]

  - label: "Build"
    depends_on: [lint, test]  # 👈 Explicit dependency
    commands: [npm run build]
```

<h4 id="workspace-state">Workspace state</h4>

In Jenkins, all stages and steps in a pipeline share the same workspace. This means that dependencies installed in one stage are automatically available in subsequent stages. For instance, in the following Jenkins pipeline snippet, the `Test` stage's step can make use of the `node_modules` artifacts installed by the previously executed `Install` stage's step.

```groovy
// Jenkins: All stages share the same workspace.
stage('Install') {
    sh 'npm install' // Creates node_modules
}

stage('Test') {
    sh 'npm test'    // Uses the node_modules installed in the 'Install' stage
}
```

In Buildkite, each step is executed in a fresh workspace. Therefore, even if you implement a [`wait` step](/docs/pipelines/configure/dependencies#implicit-dependencies-with-wait-and-block), artifacts from previously processed steps won't be available in subsequent steps.

```yaml
# ❌ This won't work in Buildkite
steps:
  - label: Install dependencies
    command: npm install

  - wait

  - label: Run tests
    command: npm test # 💥 Fails because node_modules won't be there
```

However, there are have several options for sharing state between steps:

- **Reinstall per step**: Simple for fast-installing dependencies like `npm ci`. For instance, from the example above:

    ```yaml
    steps:
      # Install dependencies step

      - label: Run tests
        commands:
          - "npm ci"   # (Re-)installs node_modules
          - "npm test" # node_modules will be available
    ```

- **Buildkite artifacts**: You can upload [build artifacts](/docs/pipelines/configure/artifacts) from one step, which can be used in a subsequently processed step. This works best with small files and build outputs.

- **Cache plugin**: Similar to build artifacts, you can also use the [Buildkite cache plugin](https://buildkite.com/resources/plugins/buildkite-plugins/cache-buildkite-plugin/), which is ideal for larger dependencies using cloud storage (S3, GCS).

- **External storage**: Custom solutions for complex state management.

<h4 id="agent-targeting">Agent targeting</h4>

Jenkins uses a push-based agent targeting model, where the controller assigns work to pre-registered agents based on labels.

Conversely, Buildkite uses a pull-based agent targeting model, where agents poll queues for work. This pull-based agent targeting model approach provides better security (no incoming connections to agents), easier scaling (through [ephemeral agents](/docs/pipelines/glossary#ephemeral-agent)), and more resilient networking. However, this difference between Jenkins and Buildkite may likely require you to rethink your agent topology when [provisioning your agent infrastructure](#provision-agent-infrastructure).

<h4 id="plugins">Plugins</h4>

Following on from [Plugin system](#understand-the-differences-plugin-system), many popular Jenkins plugins become unnecessary in Buildkite due to native features like artifact handling, build visualization, and emoji support.

### Translate an example Jenkins pipeline

This section is a guide how to translate an example of a [declarative Jenkins pipeline](https://www.jenkins.io/doc/book/pipeline/syntax/#declarative-pipeline) into a Buildkite pipeline. This pipeline implements typical use cases found in many Jenkins pipelines, such as:

- Multiple [`stage` directives](https://www.jenkins.io/doc/book/pipeline/syntax/#stage) to group [steps](https://www.jenkins.io/doc/book/pipeline/syntax/#steps) for the install, test, and build stages of the pipeline (executed sequentially).
- The [`matrix` directive](https://www.jenkins.io/doc/book/pipeline/syntax/#declarative-matrix) to process this set of sequential stages in parallel using different versions of a build tool ([Node.js](https://nodejs.org/)).
- A [`post` section](https://www.jenkins.io/doc/book/pipeline/syntax/#post) that uses the Jenkins core [`archiveArtifacts` step](https://www.jenkins.io/doc/pipeline/steps/core/#archiveartifacts-archive-the-artifacts) to save the artifact to storage.

This guide consists of the following steps:

1. [Copy or fork the `jenkins-to-buildkite` repository](#copy-or-fork-the-jenkins-to-buildkite-repository).
1. [Examine the Jenkins pipeline](#examine-the-jenkins-pipeline).

<h4 id=""></h4>

<h4 id="copy-or-fork-the-jenkins-to-buildkite-repository">Step 1: Copy or fork the jenkins-to-buildkite repository</h4>

<h4 id="examine-the-jenkins-pipeline">Step 2: Examine the Jenkins pipeline</h4>

1. Follow [Defining steps](/docs/pipelines/configure/defining-steps) and surrounding documentation to learn how to customize the pipeline definition to meet your needs, including:
   * Targeting a specific agent or queue.
   * Replacing any Jenkins plugins and integrations with Buildkite features, existing Buildkite plugins, custom plugins, or custom scripts.

1. Migrate any environment variables, secrets, or credentials used in the pipeline. Buildkite allows you to manage environment variables and secrets on different levels, such as organization, pipeline, and step levels. Securely store your sensitive data on your preferred secret management tool and integrate them into your agents and pipelines. See [Managing pipeline secrets
](/docs/pipelines/security/secrets/managing) to learn more.

1. Run the pipeline to verify it works as expected.
   * If it does, nice work! On to the next one.
   * If it doesn't, check the logs to resolve the issues. If you're having trouble, reach out to support at support@buildkite.com.

Many teams continue running pipelines on their existing infrastructure to verify the results match before removing the pipeline from Jenkins.

Some Buildkite features you might want to use include [dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines), [lifecycle hooks](/docs/agent/v3/hooks), [conditionals](/docs/pipelines/configure/conditionals), [artifacts](/docs/pipelines/configure/artifacts), [build matrices](/docs/pipelines/configure/workflows/build-matrix), and [annotations](/docs/agent/v3/cli-annotate).

## Integrate your tools

Integrating workflow tools and notifications with your CI/CD pipelines helps streamline processes and keeps your team informed about build and deployment status. Buildkite supports various integrations with tools like chat applications, artifact managers, and monitoring systems.

To set up your integrations:

1. **List existing tools:** Identify the workflow tools and notification systems you use or need to integrate with your CI/CD pipelines.
1. **Define notification requirements:** Determine the types of notifications your team needs, such as build status, deployment updates, test results, and alerts for critical issues. This information will help you configure the appropriate integrations and notification settings.
1. **Choose the integration approach:**
   * **Plugins:** Buildkite provides plugins to integrate with popular workflow tools and notification systems. Check the [Plugins directory](/docs/pipelines/integrations/plugins/directory) to see if there's a plugin available for your desired tool. If a plugin is available, include it in your pipeline configuration and follow the plugin's documentation for configuration instructions. If it's not, learn about [writing plugins](/docs/pipelines/integrations/plugins/writing).
   * **Third-party services:** Some third-party services provide direct integrations with Buildkite. Check your tools to see if they can help you achieve the desired integrations without writing custom scripts.
   * **Webhooks and APIs:** If you need a custom integration, consider using [webhooks](/docs/apis/webhooks/pipelines) or [APIs](/docs/apis). Buildkite supports outgoing webhooks for various pipeline events, and many workflow tools provide APIs to interact with their services. Use custom scripts or tools in your pipeline steps to send notifications and interact with your workflow tools.
1. **Set up notification channels:** Create dedicated notification channels in your chat applications to receive CI/CD updates. This approach helps keep your team informed without cluttering general communication channels.
1. **Configure notification triggers:** Configure your integrations to send notifications based on specific pipeline events, such as build failures, deployments, or critical alerts. Avoid excessive notifications by focusing on essential events that require your team's attention. See [Triggering notifications](/docs/pipelines/configure/notifications) for more information.
1. **Customize notification content:** Tailor the content of your notifications to include relevant information, such as build status, commit details, and links to artifacts or logs. Customize your notifications to be as informative and actionable as possible, so your team can quickly identify and address issues.

Continue adjusting the settings as you gather feedback from your team on the effectiveness and usefulness of your integrations and notifications.

Keep your integrations up to date by monitoring the release notes and updates for Buildkite plugins and the workflow tools you use. Updating your integrations ensures compatibility, fixes bugs, and introduces new features.

## Share with your team

Buildkite is more fun together, so share the new CI/CD setup with your wider team. Use resources from the [home page](https://buildkite.com/home), [documentation](/docs), and [community forum](https://forum.buildkite.community/) to help introduce people to Buildkite and its principles. These will help them adapt to the new CI/CD environment.

Consider also creating internal documentation to outline any information specific to how you're using Buildkite. Include information on your Buildkite Agent infrastructure, pipeline configurations, and integration with workflow tools and notifications. Hands-on internal training and workshop sessions have helped people bring the rest of their teams along and explain how Buildkite aligns with your organization's goals.

Some companies assign _Buildkite champions_ who are knowledgeable about Buildkite to each team. These champions help answer questions, provide guidance, and support their colleagues during onboarding.

## Next steps

That's it! 🎉

Migrating from Jenkins to Buildkite provides a more flexible, scalable, and secure build infrastructure for your applications.

Remember that it may take some time to adapt to the new platform, and be prepared to address any issues or challenges that arise during the migration process. We recommend you gather feedback from your team members on their experiences with Buildkite, so you can continually optimize your setup.

If you need further assistance or have any questions, please don't hesitate to reach out to support at support@buildkite.com. We're here to help you use Buildkite to build your dream CI/CD workflows.

After configuring Buildkite Pipelines for your team, you could get actionable insights from the tests running in pipelines using [Test Engine](/docs/test-engine).
