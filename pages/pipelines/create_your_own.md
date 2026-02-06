# Create your own pipeline

So you've created pipelines based on pre-filled examples and are ready to make your own? This is the tutorial for you. You'll continue playing with Buildkite by writing a pipeline definition for your own code.

While the specifics may vary based on your code and goal, this tutorial provides a general flow you can adapt to your needs.

## Before you start

This tutorial assumes you've created a starter pipeline, completed the [Getting started](/docs/pipelines/getting-started) guide, or both.

You'll also need the following:

- The code you plan to create a pipeline for. This could be an example you put together to test different functionality or your real repository.

- A task you want to perform with the code. For example, run some tests or a script.

## Define the steps

Next, define the steps you want in your pipeline. These steps could be anything from building and testing your code, to deploying it. Buildkite recommends you start simple and iterate to add complexity, running the pipeline to verify it works as you go.

To define the steps:

1. Decide the goal of the pipeline.
1. Look for an [example pipeline](https://buildkite.com/resources/examples/) closest to that goal or a [pipeline template](https://buildkite.com/pipelines/templates) relevant to your technology stack and use case. (You can copy parts of the pipeline definition as a starting point.)

    **Note:** If you have a pipeline or workflow defined in another CI/CD platform, such as GitHub Actions, Jenkins, CircleCI, or Bitbucket Pipelines, you can use the [Pipeline converter](/docs/pipelines/migration/pipeline-converter) to help you convert your pipeline or workflow syntax into Buildkite pipeline syntax.

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

## Create a pipeline

You'll create a new pipeline that uploads the pipeline definition from your repository.

To create a new pipeline:

1. Select **Pipelines** to navigate to the [Buildkite dashboard](https://buildkite.com/).
1. Select **New pipeline**.

    **Note:** On this page page, you can connect your Git repositories from any remotely accessible Git repository through one of the **Git scope** > **Use remote URL** options (for example, from a Bitbucket, GitLab, or GitHub account, or, if you'd already [signed up with GitHub](/docs/pipelines/getting-started#before-you-start), a different GitHub account). After connecting your account, you can select its repositories from the **Repository** dropdown during pipeline creation.

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
> A pipeline's _slug_, which forms part of the pipeline's URL, is [derived from the pipeline's **Name**](#create-a-pipeline-deriving-a-pipeline-slug-from-the-pipelines-name). If a pipeline's **Name** is changed, this action also changes the pipeline's slug accordingly. Be aware, however, that any previous pipeline slug that a pipeline had (prior to its name being changed), will automatically redirect to the pipeline's current slug.

### Using private repositories

When you create a new pipeline with a private repository URL, you'll see instructions for configuring your source control's webhooks. Once you've followed those instructions, ensure your [agent's SSH keys](/docs/agent/v3/self-hosted/ssh-keys) are configured so your agent can check out the repository.

For more advanced pipelines, using your development machine as the agent for your first few builds can be a good idea. That way, all the dependencies are ready, and you'll soon be able to share a link to a green build with the rest of your team.

### Deriving a pipeline slug from the pipeline's name

<%= render_markdown partial: 'platform/deriving_a_pipeline_slug_from_the_pipelines_name' %>

Any attempt to create a new pipeline with a name that matches an existing pipeline's name, results in an error.

## Next steps

That's it! You've successfully created your own pipeline! 🎉

We recommend you continue by:

- Inviting your team to see your build and try Buildkite themselves. Invite users from your [organization's user settings](https://buildkite.com/organizations/-/users/new) by pasting their email addresses into the form. Each of your invited users will receive an email invitation, whose lifespan is 7 days. After this period, the users' invitations will expire. Those users who have not accepted the invitation will need to be sent another, which would in turn need to be accepted within 7 days.

    **Note:** To start inviting other users to your Buildkite organization, your email address first needs to be verified. To verify your email address, go to your [personal email settings](https://buildkite.com/user/emails) and select **Resend Verification**.

- Learning to [create more complex pipelines](/docs/pipelines/configure/defining-steps) with dynamic definitions, conditionals, and concurrency.
- Browse the [pipeline templates](https://buildkite.com/pipelines/templates) to see how Buildkite is used across different technology stacks and use cases.
- If you have configured self-hosted queues with agents, customizing your [agent configuration](/docs/agent/v3/self-hosted/configure).
- Learning to use [lifecycle hooks](/docs/agent/v3/self-hosted/hooks).
- Understanding how to tailor Buildkite to fit your bespoke workflows with [plugins](/docs/pipelines/integrations/plugins) and the [API](/docs/apis).

Remember, this is just the start of your journey with Buildkite. Take time to explore, learn, and experiment to make the most out of your pipelines. Happy building!
