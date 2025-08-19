# Migration tool overview

The Buildkite Migration tool is a tool to help kick start the transition of pipelines from other CI providers to Buildkite Pipelines.

It serves as a compatibility layer or transformation tool, enabling the conversion of existing CI configurations into a format compatible with Buildkite's pipeline definition.

The primary purpose of buildkite-compat is to reduce the effort and complexity involved in switching CI/CD platforms by automating the translation of pipeline structures and steps. This tool aims to make the transition to Buildkite smoother for organizations and teams currently using other CI solutions.

It can be used as a standalone tool or potentially integrated into migration workflows, offering a way to leverage existing CI configurations within the Buildkite ecosystem.

## Installing

TBA ...

## Using

```bash
$ buildkite-compat examples/circleci/legacy.yml
---
steps:
- commands:
  - "# No need for checkout, the agent takes care of that"
  - pip install -r requirements/dev.txt
  plugins:
  - docker#v5.7.0:
      image: circleci/python:3.6.2-stretch-browsers
  agents:
    executor_type: docker
  key: build
```

## Using through API/web

Explanation.

## Using through the web example

Instruction, link.

## With exact tool

TODO: cross-link to the existing pages for GHA, BBP, CCI.