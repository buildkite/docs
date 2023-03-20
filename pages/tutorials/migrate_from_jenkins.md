# Migrate from Jenkins

If you are familiar with Jenkins and are looking to migrate to Buildkite, this guide is for you. Buildkite is a modern and flexible continuous integration and delivery (CI/CD) platform that provides a powerful and scalable build infrastructure for your applications.

[Jenkins](https://www.jenkins.io) and [Buildkite](https://buildkite.com) are platforms that run continuous integration (CI) pipelines, and while the two platforms have similar goals, their approach is vastly different.

Buildkite uses a hybrid model that consists of a software-as-a-service (SaaS) platform for visualization and management of CI pipelines and agents that execute the jobs, either on-premise or in the cloud. This approach makes Buildkite more secure, scalable, and flexible. 

In addition, Buildkite addresses the pain points of Jenkins’ users, namely its security issues (both in its [base code](https://www.cvedetails.com/vulnerability-list/vendor_id-15865/product_id-34004/Jenkins-Jenkins.html) and [plugins](https://securityaffairs.co/wordpress/132836/security/jenkins-plugins-zero-day-flaws.html)), time-consuming setup, and speed. 

This guide walks you through the process of migrating from Jenkins to Buildkite, and provide you with an example pipeline that represents a common use case.

> If you want to jump into the pipeline definitions, see ...

## Key concepts

- Source control
- Pipeline configuration
- Build environemnt / infrastructure

## Set up

The first step in migrating to Buildkite is to set up a Buildkite account. This can be done by visiting the Buildkite website and signing up for a free trial. Once you have an account, you can start creating pipelines and agents to run your builds.

Build agents are the servers that run your builds. To run builds in Buildkite, you will need to set up one or more Build agents. Buildkite provides a variety of options for setting up Build agents, including cloud-based agents and on-premise agents.


- Getting started guide
- Account
- Connect code + trigger builds from webhooks
- Agent
- Integrate with existing tools like notifications etc.

## Translate pipeline definitions

Recommend you think of the goal and how to achieve that in Buildkite rather than automating the migration.

....




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



## Trigger and monitor builds

-> webhooks
Once you have created your pipeline and set up your Build agents, you can trigger builds by pushing code to your source code repository. Buildkite will automatically detect the changes and start a build.

Once you have created your pipeline and set up your Build agents, you can trigger builds by pushing code to your source code repository. Buildkite will automatically detect the changes and start a build.

## Scaling infrasturture

Best practice.......


That's it! 🎉

Migrating from Jenkins to Buildkite is a straightforward process that can provide you with a more flexible and scalable build infrastructure for your applications. By following these steps, you can take advantage of the powerful features and capabilities of Buildkite to streamline your CI/CD process and improve the efficiency and reliability of your builds.