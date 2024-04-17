# Create your own pipeline

So you've created pipelines based on pre-filled examples and are ready to make your own? This is the tutorial for you. You'll continue playing with Buildkite by writing a pipeline definition for your own code.

While the specifics may vary based on your code and goal, this tutorial provides a general flow you can adapt to your needs.

## Before you start

This tutorial assumes you've created a starter pipeline, completed the [Getting started](/docs/tutorials/getting-started) guide, or both.

You'll also need the following:

- The code you plan to create a pipeline for. This could be an example you put together to test different functionality or your real repository.
- A task you want to perform with the code. For example, run some tests or a script.
- To enable the YAML steps editor in Buildkite. If you haven't already:

  * Select _Settings_ > _YAML Migration_ to open the [YAML migration settings](https://buildkite.com/organizations/~/pipeline-migration).
  * Select _Use YAML Steps for New Pipelines_, then confirm the action in the modal.

## Continue running an agent

We recommend you continue treating this tutorial as a chance to play and iterate. That means you can continue using the agent you've already set up.

If you want to learn more about the agent and set up something more permanent, see [Agent overview](/docs/agent/v3).

## Define the steps

Next, define the steps you want in your pipeline. These steps could be anything from building and testing your code, to deploying it. We recommend you start simple and iterate to add complexity, running the pipeline to verify it works as you go.

To define the steps:

1. Decide the goal of the pipeline.
1. Look for an [example pipeline](/docs/pipelines/example-pipelines) closest to that goal. You can copy parts of the pipeline definition as a starting point.
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

    Follow [Defining steps](/docs/pipelines/defining-steps) and surrounding documentation to learn how to customize the pipeline definition to meet your needs.

1. Commit and push this file to your repository.

## Create a pipeline

You'll create a new pipeline that uploads the pipeline definition from your repository.

To create a new pipeline:

1. Select _Pipelines_ to navigate to the [Buildkite dashboard](https://buildkite.com/).
1. Select _New pipeline_.

    **Note:** On the _New Pipeline_ page, if you're prompted to connect your Git repositories from an existing account (for example, GitHub, Bitbucket or GitLab), it is recommended you do that first. You can always connect your account later from your pipeline's settings.
    After connecting your account, you can select its repositories from the dropdown during pipeline creation and enable automatic webhook creation.

1. If you connected your account, select the appropriate repository from the list of existing ones in your account. Otherwise, select _Any account_ from the dropdown and type the URL of the repository to be built.
1. Enter your pipeline's details in the respective _Name_ and _Description_ fields. You can always change these details later from your pipeline's settings.
1. In the _Steps_ editor, ensure there's a step to upload the definition from your repository:

    ```yaml
    steps:
      - label: "\:pipeline\:"
        command: buildkite-agent pipeline upload
    ```

1. Select _Create Pipeline_.
1. On the next page showing your pipeline name, click _New Build_. In the modal that opens, create a build using the pre-filled details.

   1. In the _Message_ field, enter a short description for the build. For example, _My first build_.
   1. Select _Create Build_.

    The page for the build then opens and begins running.

Run the pipeline whenever you make changes you want to verify. If you want to add more functionality, go back to editing your steps and repeat.

If you've configured webhooks, your pipeline will trigger when you push updates to the repository. Otherwise, select _New Build_ in the Buildkite dashboard to trigger the pipeline.

If you have trouble getting your pipeline to work, don't hesitate to reach out to [support](https://buildkite.com/support) for help.

### On slug creation conventions

Pipeline slugs are generated based on the pipeline name you provide during the pipeline creation.
The maximum allowed character length for a pipeline slug is `100`.
The supported character format for slug generation is:
`/\A[a-zA-Z0-9]+[a-zA-Z0-9\-]*\z/`.

All the whitespace characters that appear in the pipeline name consecutively will be converted to a single `-` character (so `"Hello there"` and `"Hello   there"` will be equally converted to a `hello-there` slug), and uppercase will be converted to lowercase.

An attempt at creating a new pipeline with a name that matches an existing pipeline name will throw an error.

### Using private repositories

When you create a new pipeline with a private repository URL, you'll see instructions for configuring your source control's webhooks. Once you've followed those instructions, ensure your [agent's SSH keys](/docs/agent/v3/ssh-keys) are configured so your agent can check out the repository.

For more advanced pipelines, using your development machine as the agent for your first few builds can be a good idea. That way, all the dependencies are ready, and you'll soon be able to share a link to a green build with the rest of your team.

## Next steps

That's it! You've successfully created your own pipeline! 🎉

We recommend you continue by:

- Inviting your team to see your build and try Buildkite themselves. Invite users from your [organization's user settings](https://buildkite.com/organizations/-/users/new) by pasting their email addresses into the form. Please note that to be able to start inviting other users to your Buildkite organization, your email needs to be verified. To verify your email, go to your [personal email settings](https://buildkite.com/user/emails) and select _Resend Verification_.
- Learning to [create more complex pipelines](/docs/pipelines/defining-steps) with dynamic definitions, conditionals, and concurrency.
- Customizing your [agent configuration](/docs/agent/v3/configuration) and learning to use [lifecycle hooks](/docs/agent/v3/hooks).
- Understanding how to tailor Buildkite to fit your bespoke workflows with [plugins](/docs/plugins) and the [API](/docs/apis).

Remember, this is just the start of your journey with Buildkite. Take time to explore, learn, and experiment to make the most out of your pipelines. Happy building!
