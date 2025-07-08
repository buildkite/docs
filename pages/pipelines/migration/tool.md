# Migration tool overview

The Buildkite Migration tool is a tool to help kick start the transition of pipelines from other CI providers to Buildkite Pipelines.

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
