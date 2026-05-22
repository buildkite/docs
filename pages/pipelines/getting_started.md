---
keywords: docs, pipelines, tutorials, getting started, test engine, test suite
---

# Getting started with Pipelines

👋 Welcome to Buildkite Pipelines! You can use Pipelines to build your dream CI/CD workflows on a secure, scalable, and flexible platform.

This tutorial walks you through the fundamentals of Buildkite Pipelines in three stages:

1. [Create a new pipeline](#create-a-new-pipeline) from one of the Buildkite-provided examples, to learn the **New Pipeline** page and see how a build runs.
1. [Create your own pipeline](#create-your-own-pipeline) by adding a pipeline definition to your own repository.
1. [Add a test suite](#add-a-test-suite) using [Test Engine](/docs/pipelines/configure/tests), the testing layer of Buildkite Pipelines, to collect test results from your project's test runners.

## Before you start

This tutorial assumes that you're new to Buildkite Pipelines. To begin, [create a free, personal Buildkite account](<%= buildkite_url.signup_path %>).

From the **Start building for free** page, do either of the following:

- Select **Sign up with GitHub** and then **Authorize Buildkite** to access your GitHub account.

    If prompted with the **Install Buildkite** page in GitHub, ensure **All repositories** is selected (recommended), although choose **Only select repositories** if you need to limit the scope of the installation.

    You should then be taken to the **New Pipeline** page, where you can begin [creating your new pipeline](#create-a-new-pipeline).

- Select **Continue with Email**, then enter your **Full name**, **Email** address and **Password**, and select **Sign up**.
    1. Follow the instructions on the **Verify your email** page, and select the Buildkite verification link in the email message sent to this address.
    1. On the resulting Buildkite **Create organization** page, enter the name for your Buildkite organization.

        You should then be taken to the **New Pipeline** page, where you can begin [creating your new pipeline](#create-a-new-pipeline).

## Create a new pipeline

A [_pipeline_](/docs/pipelines/glossary#pipeline) is what represents a CI/CD workflow in Buildkite Pipelines. You define each pipeline with a series of [_steps_](/docs/pipelines/glossary#step) to run. When you trigger a pipeline, you create a [_build_](/docs/pipelines/glossary#build), and steps are dispatched as [_jobs_](/docs/pipelines/glossary#job), which are run on [agents](/docs/pipelines/glossary#agent). Jobs are independent of each other and can run on different agents.

If you signed up:

- With GitHub, the **New Pipeline** page's **Git scope** is set to your GitHub account, and its most recently updated repository is automatically selected in the **Repository** field.

    **Note:**

    * If you're new to Buildkite Pipelines and want to learn more about creating some pipelines, select **Or try an example** to examine the list of existing example pipelines you can build.

    * If your GitHub account is new and contains no repositories, the **Starter pipeline** of the **Buildkite Examples** is automatically selected.

- By email, the **New Pipeline** page presents the **Starter pipeline** of the **Buildkite Examples**.

Ensure you familiarize yourself with the **New Pipeline** page's functionality in [Understanding the New Pipeline page](#create-a-new-pipeline-understanding-the-new-pipeline-page) before proceeding to build some [example pipelines](#create-a-new-pipeline-example-pipelines).

### Understanding the New Pipeline page

<%= image "new-pipeline-page.png", alt: "New Pipeline page" %>

The **New Pipeline** page has the following fields:

- **Git scope**: Allows you to select from the following list of options:

    * Your GitHub account or organization.
    * A selection of **Buildkite Examples** to start with, which allows you to learn more about how Buildkite Pipelines builds projects for a variety of different use cases.
    * The **Use remote URL** options allow you to select a **GitLab**, **Bitbucket**, or **Any account**, for any other remotely accessible Git repository. The **Manage accounts** option further down this list also allows you to configure connections to these repository providers. See the [Source control](/docs/pipelines/source-control) section for more information.
    * The **Connect GitHub account** option allows you to do just that. This option is useful if you signed up by email, and need to connect your GitHub account to the Buildkite platform, and generates the [same **Install Buildkite** step as part of the GitHub sign-up process](#before-you-start).

- **Repository**: Select the Git repository available to your selected **Git scope**. Upon selecting a repository:

    * The **Checkout using** option appears, where you can select between **SSH** or **HTTPS**.
    * If you selected a repository which is not one of the **Buildkite Examples**, then the **Build Triggers** section may appear, which shows the actions that trigger a build of this pipeline. You can disable this triggering by clearing the **Trigger builds when** checkbox.

- **Pipeline name**: Buildkite Pipelines automatically generates a name for your pipeline, which is based on your repository's name. However, you can change this default name using this field.
- **Description** ( _optional_ ): Enter a description for your pipeline, which will appear under the pipeline name on the main **Pipelines** page.
- **Default Branch**: The repository branch that your pipeline will build, unless instructed otherwise. Leave this unchanged for this tutorial.
- **Teams**: The Buildkite teams that have permission to build your pipeline.

    **Note:** If you just [signed up to Pipelines](#before-you-start), then this field won't be visible, as it's only shown once [teams](/docs/platform/team-management) have been configured in your Buildkite account/organization. If this field is shown, leave it unchanged for this tutorial.

- **Cluster**: The Buildkite cluster whose configured agents will build your pipeline. Leave this unchanged for this tutorial.
- **YAML Steps editor**: This field allows you to define steps within your main Buildkite pipeline. To make things easier though, you can start with an initial pipeline from the **Template** dropdown. Using this dropdown, you can select from the following options:

    * **Helper templates**:
        - **Hello world**: For a simple example of how to structure commands in Buildkite pipeline YAML syntax.
        - **Pipeline upload**: To upload a Buildkite pipeline stored in your repository.
    * **Example templates**: This section lists pipelines which are used to build example projects available from the **Repository** field, when the **Git scope** has been set to **Buildkite Examples**.

> 📘
> If you're already familiar with creating Buildkite pipelines and have created one at `.buildkite/pipeline.yml` from the root of your selected **Repository**, then ensure the **Pipeline upload** option has been selected from the **Template** dropdown of the **YAML Steps editor**. This option generates a pipeline step within your main Buildkite pipeline, which uploads the rest of your pipeline (defined in the `.buildkite/pipeline.yml` file from your repository), and uses the steps in that file to build your project. Learn more about this in [Create your own pipeline](#create-your-own-pipeline).
> If you already have a Buildkite account/organization and user account, you can access the **New Pipeline** page by selecting **Pipelines** from the global navigation > **New pipeline**.

### Example pipelines

Ensure you're already familiar with the **New Pipeline** page's functionality (described in [Understanding the New Pipeline page](#create-a-new-pipeline-understanding-the-new-pipeline-page)) before proceeding.

1. Ensure **Buildkite Examples** is selected in **Git scope** and select **Starter pipeline**.
1. In the **YAML Steps editor**, note the three steps that constitute this pipeline: `build`, `test`, and `deploy`, and the dependency order in which these steps' jobs will be run.

    **Note:** Without analyzing the pipeline syntax in too much detail, take note the annotation-related command that's part of the `deploy` step.

1. Select **Create and run** to create your first **Starter pipeline**. This button creates your **Starter pipeline** and runs its first build.
1. Once your build has completed, check its **Annotations** tab, which displays the content of the repository's `.buildkite/annotation.md` file.

Once you've seen how Buildkite Pipelines builds a simple pipeline like **Starter pipeline**, try creating and building other pipelines from the **Buildkite Examples** provided, which suit the technologies you've been working with.

> 📘
> For each repository of the **Buildkite Examples** selected in the **Repository** field, the pipeline shown in the **YAML Steps editor** field is retrieved from that repository's `.buildkite/pipeline.yml` file.
> Also be aware that a Buildkite pipeline commits nothing to your repository, unless you explicitly instruct your pipeline to do so.

More Buildkite example repositories are available from the [Buildkite Resources Examples](https://buildkite.com/resources/examples/) page.

## Create your own pipeline

Now that you've built one of the Buildkite Examples, this section walks you through writing a pipeline definition for your own code—stored as a `.buildkite/pipeline.yml` file in your repository—and creating a Buildkite pipeline that uploads and runs it. While the specifics may vary based on your code and goal, this flow can be adapted to your needs.

You'll need:

- The code you plan to create a pipeline for. This could be an example you put together to test different functionality or your real repository.
- A task you want to perform with the code. For example, run some tests or a script.

### Define the steps

Define the steps you want in your pipeline. These steps could be anything from building and testing your code, to deploying it. Buildkite recommends you start simple and iterate to add complexity, running the pipeline to verify it works as you go.

To define the steps:

1. Decide the goal of the pipeline.
1. Look for an [example pipeline](https://buildkite.com/resources/examples/) closest to that goal or a [pipeline template](https://buildkite.com/pipelines/templates) relevant to your technology stack and use case. (You can copy parts of the pipeline definition as a starting point.)

    **Note:** If you have a pipeline or workflow defined in another CI/CD platform, such as GitHub Actions, Jenkins, CircleCI, or Bitbucket Pipelines, you can use the [Pipeline converter](/docs/pipelines/converter) to help you convert your pipeline or workflow syntax into Buildkite pipeline syntax.

1. In the root of your repository, create a file named `pipeline.yml` in a `.buildkite` directory.
1. In `pipeline.yml`, define your pipeline steps. Here's an example:

    ```yaml
    steps:
      - label: "\:hammer\: Build"
        command: "scripts/build.sh"
        key: build

      - label: "\:test_tube\: Test"
        command: "scripts/test.sh"
        key: test
        depends_on: build

      - label: "\:rocket\: Deploy"
        command: "scripts/deploy.sh"
        key: deploy
        depends_on: test
      ```

    Follow [Defining steps](/docs/pipelines/configure/defining-steps) and surrounding documentation to learn how to customize the pipeline definition to meet your needs.

1. Commit and push this file to your repository.

### Create a pipeline

Next, create a new pipeline that uploads the pipeline definition from your repository:

1. Select **Pipelines** to navigate to the [Buildkite dashboard](https://buildkite.com/).
1. Select **New pipeline**.

    **Note:** On this page, you can connect your Git repositories from any remotely accessible Git repository through one of the **Git scope** > **Use remote URL** options (for example, from a Bitbucket, GitLab, or GitHub account, or, if you'd already [signed up with GitHub](#before-you-start), a different GitHub account). After connecting your account, you can select its repositories from the **Repository** dropdown during pipeline creation.

1. If you connected your account (in the **Git scope** field), select the appropriate **Repository** from the list of existing ones in your account.
1. Enter your pipeline's details in the respective **Pipeline name** and **Description** fields. You can always change these details later from your pipeline's settings.
1. In the **YAML Steps editor** field, ensure there's a step to upload the definition from your repository, which you can generate automatically using the **Pipeline upload** option from the **Template** dropdown:

    ```yaml
    steps:
      - label: "\:pipeline\:"
        command: buildkite-agent pipeline upload
    ```

1. Select **Create pipeline**.
1. On the next page showing your pipeline name, select **New Build**. In the resulting dialog, create a build using the pre-filled details.

   1. In the **Message** field, enter a short description for the build. For example, **My first build**.
   1. Select **Create Build**.

    The page for the build then opens and begins running.

Run the pipeline whenever you make changes you want to verify. If you want to add more functionality, go back to editing your steps and repeat.

If you've configured webhooks, your pipeline will trigger when you push updates to the repository. Otherwise, select **New Build** in the Buildkite dashboard to trigger the pipeline.

If you have trouble getting your pipeline to work, don't hesitate to reach out to support at support@buildkite.com for help.

> 📘 Pipeline slugs and names
> A pipeline's _slug_, which forms part of the pipeline's URL, is [derived from the pipeline's **Name**](#create-your-own-pipeline-deriving-a-pipeline-slug-from-the-pipelines-name). If a pipeline's **Name** is changed, this action also changes the pipeline's slug accordingly. Be aware, however, that any previous pipeline slug that a pipeline had (prior to its name being changed), will automatically redirect to the pipeline's current slug.

### Using private repositories

When you create a new pipeline with a private repository URL, you'll see instructions for configuring your source control's webhooks. Once you've followed those instructions, ensure your agent's SSH keys are configured for code access (see relevant instructions for [self-hosted](/docs/agent/self-hosted/code-access) or [Buildkite hosted](/docs/agent/buildkite-hosted/code-access) agents) so your agent can check out the repository.

For more advanced pipelines, using your development machine as the agent for your first few builds can be a good idea. That way, all the dependencies are ready, and you'll soon be able to share a link to a green build with the rest of your team.

### Deriving a pipeline slug from the pipeline's name

<%= render_markdown partial: 'platform/deriving_a_pipeline_slug_from_the_pipelines_name' %>

Any attempt to create a new pipeline with a name that matches an existing pipeline's name, results in an error.

## Add a test suite

With a pipeline that builds your project and runs its test runners, you can layer [Test Engine](/docs/pipelines/configure/tests)—the testing layer of Buildkite Pipelines—on top to collect, analyze, and manage your test results. This section walks you through three steps:

1. Create a [test suite](/docs/pipelines/configure/tests/test-suites) in Buildkite.
1. Configure a [test collector](/docs/pipelines/configure/tests/test-collection) in your development project so its test results flow into the suite.
1. Wire the test suite's API token into the pipeline you created above so each build populates the suite.

### Create a test suite

To begin creating a new test suite:

1. Select **Test Suites** in the global navigation to access the **Test Suites** page.
1. Select **New test suite**.
1. On the **Identify, track and fix problematic tests** page, enter an optional **Application name**, for example, `My project`.
1. Enter a mandatory **Test suite name**, for example, `My project test suite`.
1. Enter the **Default branch name**, which is the default branch that Test Engine shows trends for, and can be changed any time, for example (and usually), `main`.
1. Enter an optional **Suite emoji**, using [emoji syntax](/docs/pipelines/emojis), for example, `\:test_tube\:` for a test tube emoji.
1. Enter an optional **Suite color**, using the `#RRGGBB` syntax. See the [HTML Color Codes](https://htmlcolorcodes.com/) page to help you choose a color.

    **Note:** At this point, you can select one of the buttons towards the end of this page which match your project's testing framework (or test runners) for instructions on how to set up [test collection](/docs/pipelines/configure/tests/test-collection) for your project. This opens up the relevant documentation page with detailed instructions on how to set up test collection for your test runners, which you'll be doing in the next section. Otherwise, if your project's testing framework is not listed, see [Collecting test data from other test runners](/docs/pipelines/configure/tests/test-collection/other-collectors) for details on how to implement test collection for other testing frameworks. Regardless, keep the relevant documentation page/s open.

1. Select **Set up suite**.
1. If your Buildkite organization has the [teams feature](/docs/platform/team-management/permissions) enabled, select the relevant **Teams** to be granted access to this test suite, followed by **Continue**.

    The new test suite's **Complete test suite setup** page is displayed, requesting you to [configure your test collector within your development project](#add-a-test-suite-configure-your-project-with-its-test-collector).

### Configure your project with its test collector

Next, configure your project's test runners with its Buildkite test collector:

1. On the **Complete test suite setup** page, under **Set up an integrated test collector**, select the test collector option for your test runners.
1. Follow the instructions on the right of the page (along with the relevant documentation page you opened above for more detailed information) to implement the relevant test collection capabilities for your project.

    **Note:** When instructed to add the `BUILDKITE_ANALYTICS_TOKEN` to your CI environment, this is referring to the **Test Suite API Token** at the top of this **Complete test suite setup** page. You'll be using this in the last step of this section, as well as in the section on how to [Automate your test runner with Buildkite Pipelines](#add-a-test-suite-automate-the-test-runner-with-buildkite-pipelines).

1. Add and commit your test collector changes to your project to a new branch. For example:

    ```bash
    git add .
    git commit -m "Install and set up test collector for Buildkite Test Engine"
    git push
    ```

1. At this point, you can now run your project's test runner at the command line, by passing in `BUILDKITE_ANALYTICS_TOKEN=<your-test-suites-api-token-value>` as an environment variable to the test runner command. Once the test runner has completed running, check your test suite page to see the results collected by your Test Engine test suite!

### Automate the test runner with Buildkite Pipelines

To populate the suite on every build, wire the **Test Suite API Token** into the pipeline you created in [Create your own pipeline](#create-your-own-pipeline):

1. Copy the value of your **Test Suite API Token** (which you can later retrieve through your test suite's **Settings** > **Suite token** page) and configure it as a [Buildkite secret](/docs/pipelines/security/secrets/buildkite-secrets). You can create this secret with a name like `MY_PROJECT_TEST_SUITE_TOKEN`.

1. In your repository's `.buildkite/pipeline.yml`, expose that secret to the step that runs your test command as `BUILDKITE_ANALYTICS_TOKEN`:

    ```yaml
    steps:
      - label: "Run tests"
        command:
          - test-runner-execution-command
          # Assumes your agent is running the required resources for this.
        secrets:
          BUILDKITE_ANALYTICS_TOKEN: MY_PROJECT_TEST_SUITE_TOKEN
    ```

1. Commit and push the change, then trigger a new build. Once the build completes, the test results appear in your test suite.

Learn more about how to create a Buildkite secret and use it in a Buildkite pipeline in [Create a secret](/docs/pipelines/security/secrets/buildkite-secrets#create-a-secret) and [Use a Buildkite secret in a job](/docs/pipelines/security/secrets/buildkite-secrets#use-a-buildkite-secret-in-a-job), respectively.

## Next steps

That's it! 🎉 You've created a pipeline from a Buildkite Example, written and uploaded your own pipeline definition, and added a Test Engine test suite that collects results from every build.

As part of this sign-up process, Pipelines set you up with a few default configurations behind the scenes. These include the following:

- A _Buildkite cluster_: Buildkite Pipelines requires that all of its pipelines are managed through a [Buildkite cluster](/docs/pipelines/glossary#cluster), which is a security feature that's used to organize queues. When a new Buildkite account/organization is created, a single cluster is created, called **Default cluster**. Learn more about Buildkite clusters from the [Clusters overview](/docs/pipelines/security/clusters).
- A _queue_: When the **Default cluster** is created, five [queues](/docs/pipelines/glossary#queue) are also created: **linux-small** (default), **linux-medium**, **linux-large**, **macos-medium**, and **macos-large**. When creating a personal Buildkite account, the default queue is a _Buildkite hosted queue_, which runs _Buildkite hosted agents_. Learn more about queues from [Queues overview](/docs/agent/queues) and Buildkite hosted agents from its [overview](/docs/agent/buildkite-hosted) page.

While creating a new personal Buildkite account automatically sets you up to run Buildkite hosted agents, Buildkite also supports self-hosted agents, which you can manage in your own infrastructure. Learn more about the differences between these agent architectures in [Buildkite Pipelines architecture](/docs/pipelines/architecture).

From here:

- Invite your team to see your build and try Buildkite themselves. Invite users from your [organization's user settings](https://buildkite.com/organizations/-/users/new) by pasting their email addresses into the form. Each of your invited users will receive an email invitation, whose lifespan is 7 days. After this period, the users' invitations will expire. Those users who have not accepted the invitation will need to be sent another, which would in turn need to be accepted within 7 days.

    **Note:** To start inviting other users to your Buildkite organization, your email address first needs to be verified. To verify your email address, go to your [personal email settings](https://buildkite.com/user/emails) and select **Resend Verification**.

- Learn to [create more complex pipelines](/docs/pipelines/configure/defining-steps) with dynamic definitions, conditionals, and concurrency.
- Browse the [pipeline templates](https://buildkite.com/pipelines/templates) to see how Buildkite is used across different technology stacks and use cases.
- Browse the [Test Engine overview](/docs/pipelines/configure/tests) for the full set of test-suite features, including [workflows](/docs/pipelines/configure/tests/workflows) for flaky test detection and [bktec](/docs/pipelines/speed-up-builds-with-bktec) for test splitting.
- Review the [CI environment variables](/docs/pipelines/configure/tests/test-collection/ci-environments) that collectors auto-detect when running under CI/CD.
- If you have configured self-hosted queues with agents, customize your [agent configuration](/docs/agent/self-hosted/configure).
- Learn to use [lifecycle hooks](/docs/agent/hooks).
- Understand how to tailor Buildkite to fit your bespoke workflows with [plugins](/docs/pipelines/integrations/plugins) and the [API](/docs/apis).
- Give AI coding agents the context they need to work with Buildkite in [Getting started with coding agents](/docs/pipelines/getting-started-with-coding-agents).

Remember, this is just the start of your journey with Buildkite. Take time to explore, learn, and experiment to make the most out of your pipelines. Happy building!
