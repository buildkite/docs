# Create your own pipeline

So you've created pipelines based on pre-filled examples and are ready to make your own? This is the tutorial for you. You'll continue playing with Buildkite by writing a pipeline definition for your own code.

While the specifics may vary based on your code and goal, this tutorial provides a general flow you can adapt to your needs.

## Before you start

This tutorial assumes you've created a starter pipeline, completed the [Getting started](/docs/pipelines/getting-started) guide, or both.

You'll also need the following:

- The code you plan to create a pipeline for. This could be an example you put together to test different functionality or your real repository.

- A task you want to perform with the code. For example, run some tests or a script.

- To enable the YAML steps editor in Buildkite. If you haven't already done this:
    1. Select **Settings** > **YAML Migration** to open the [**Pipeline YAML Migration**](https://buildkite.com/organizations/~/pipeline-migration) page.
    1. Select **Use YAML Steps for New Pipelines**, then confirm the action in the dialog.

## Continue running an agent

We recommend you continue treating this tutorial as a chance to play and iterate. That means you can continue using the [agent you've already set up](/docs/pipelines/getting-started#set-up-an-agent).

If you want to learn more about the agent and set up something more permanent, see [Agent overview](/docs/agent/v3).

## Define the steps

Next, define the steps you want in your pipeline. These steps could be anything from building and testing your code, to deploying it. We recommend you start simple and iterate to add complexity, running the pipeline to verify it works as you go.

To define the steps:

1. Decide the goal of the pipeline.
1. Look for an [example pipeline](/docs/pipelines/configure/example-pipelines) closest to that goal or a [pipeline template](https://buildkite.com/pipelines/templates) relevant to your technology stack and use case. (You can copy parts of the pipeline definition as a starting point.)
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

    **Note:** On the **New Pipeline** page, if you're prompted to connect your Git repositories from an existing account (for example, GitHub, Bitbucket or GitLab), it is recommended you do that first. You can always connect your account later from your pipeline's settings.
    After connecting your account, you can select its repositories from the dropdown during pipeline creation and enable automatic webhook creation.

1. If you connected your account, select the appropriate repository from the list of existing ones in your account. Otherwise, select **Any account** from the dropdown and type the URL of the repository to be built.
1. Enter your pipeline's details in the respective **Name** and **Description** fields. You can always change these details later from your pipeline's settings.
1. In the **Steps** editor, ensure there's a step to upload the definition from your repository:

    ```yaml
    steps:
      - label: "\:pipeline\:"
        command: buildkite-agent pipeline upload
    ```

1. Select **Create Pipeline**.
1. On the next page showing your pipeline name, select **New Build**. In the modal that opens, create a build using the pre-filled details.

   1. In the **Message** field, enter a short description for the build. For example, **My first build**.
   1. Select **Create Build**.

    The page for the build then opens and begins running.

Run the pipeline whenever you make changes you want to verify. If you want to add more functionality, go back to editing your steps and repeat.

If you've configured webhooks, your pipeline will trigger when you push updates to the repository. Otherwise, select **New Build** in the Buildkite dashboard to trigger the pipeline.

If you have trouble getting your pipeline to work, don't hesitate to reach out to support at support@buildkite.com for help.

### Using private repositories

When you create a new pipeline with a private repository URL, you'll see instructions for configuring your source control's webhooks. Once you've followed those instructions, ensure your [agent's SSH keys](/docs/agent/v3/ssh-keys) are configured so your agent can check out the repository.

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
- Customizing your [agent configuration](/docs/agent/v3/configuration) and learning to use [lifecycle hooks](/docs/agent/v3/hooks).
- Understanding how to tailor Buildkite to fit your bespoke workflows with [plugins](/docs/pipelines/integrations/plugins) and the [API](/docs/apis).

Remember, this is just the start of your journey with Buildkite. Take time to explore, learn, and experiment to make the most out of your pipelines. Happy building!
