---
keywords: docs, pipelines, tutorials, bazel
---

# Using Bazel on Buildkite

[Bazel](https://www.bazel.build/) is an open-source build and test tool similar to Make, Maven, and Gradle.
Bazel supports large codebases across multiple repositories, and large numbers of users.

## Using Bazel on Buildkite

1. [Install Bazel](https://docs.bazel.build/install.html) on one or more Buildkite Agents.
2. Add an empty [`WORKSPACE` file](https://bazel.build/start/cpp#getting-started) to your project to mark it as a Bazel workspace.
3. Add a [`BUILD` file](https://bazel.build/start/cpp#understand-build) to your project to tell Bazel how to build it.
4. Add the Bazel build target(s) to your Buildkite [Pipeline](/docs/pipelines/configure/defining-steps).

## Buildkite Bazel example

The [Building with Bazel](https://buildkite.com/pipelines/templates/ci/bazel-ci?queryID=2e432af39a35aeac99901b275534243c) example pipeline template demonstrates how a continuous integration pipeline might run on a Bazel project. The visualization below shows the steps in its example pipeline.

<p><iframe src="https://buildkite.com/pipelines/playground/embed?tid=bazel-ci" allow="fullscreen" crossorigin="anonymous" width="100%" height="300px"></iframe></p>

## Buildkite C++ Bazel example

The following repository is a simple Bazel example which you can run and customize.

Make sure you're signed into your [Buildkite account](https://buildkite.com) and have access to a Buildkite Agent [running Bazel](https://docs.bazel.build/install.html), then click through to the example:

<a class="Docs__example-repo" href="https://github.com/buildkite/bazel-example">
  <span class="icon">:memo:</span>
  <span class="detail">
    <strong>Buildkite Bazel Example</strong>
    <span class="description">A Buildkite Bazel Example you can run and customize.</span>
    <span class="repo">github.com/buildkite/bazel-example</span>
  </span>
</a>

## Further reading

- The [Bazel Tutorial: Build a C++ Project](https://bazel.build/start/cpp) goes into more detail about how to configure more complex Bazel builds, covering multiple build targets and multiple packages.
- The Bazel [external dependencies docs](https://bazel.build/external/overview) show you how to build other local and remote repositories.

## Next steps

Now that you've built a simple Bazel example, you can also [use Bazel to create dynamic pipelines and build annotations](/docs/pipelines/tutorials/dynamic-pipelines-and-annotations-using-bazel).
