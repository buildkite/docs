# Pipeline design and structure

## Keep pipelines focused and modular

* Start with static pipelines and gradually move to dynamic pipelines to generate steps programmatically. They latter scale better than static YAML as repositories and requirements grow.
* Use `buildkite-agent pipeline upload` to generate steps programmatically based on code changes. This allows conditional inclusion of steps (e.g., integration tests only when backend code changes). (Further work: reword as `buildkite-agent pipeline upload` does not generate steps programmatically.)

## Use monorepos for change scoping

* Run only what changed. Use a monorepo diff strategy, agent `if_changed`, or official plugins to selectively build and test affected components.
* Two common patterns:
    + One orchestrator pipeline that triggers component pipelines based on diffs.
    + One dynamic pipeline that injects only the steps needed for the change set.

## Prioritize fast feedback loops

* Parallelize where possible: run independent tests in parallel to reduce overall build duration.
* Fail fast: place the fastest, most failure-prone steps early in the pipeline.
* Use conditional steps: skip unnecessary work by using branch filters and step conditions.
* Smart test selection: use test impact analysis or path-based logic to run only the relevant subset of tests.

## Structure YAML for clarity

* Descriptive step names: step labels should be human-readable and clear at a glance.
* Organize with groups: use group steps to keep complex pipelines navigable.
* Emojis for visual cues: quick scanning is easier with consistent iconography.
* Comment complex logic: document non-obvious conditions or dependencies inline.

## Standardize with reusable modules

* Centralized templates: maintain organization-wide pipeline templates and plugins to enforce consistency across teams.
* Shared libraries: package common scripts or Docker images so individual teams don’t reinvent solutions.
* Queue tracking: document how different types of queues could be used and when they should be upgraded.
* Custom plugins: you can turn your regularly reused pieces of code for common use cases into [your own Buildkite plugin](/docs/pipelines/integrations/plugins/writing). Writing your own plugins will help you with standardization.
