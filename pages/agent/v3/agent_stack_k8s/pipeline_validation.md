---
toc: false
---

# Validating your pipeline

Buildkite plugin specifications are unstructured by nature, which can lead to configuration errors that cause agent pod startup failures. These issues can be difficult and time-consuming to troubleshoot.

To prevent configuration problems before deployment, we suggest using a linter that uses [JSON Schema](https://json-schema.org/) to validate your pipeline and plugin configurations.

Even such linters currently can't catch every type of error and you might still get a reference to a Kubernetes volume that doesn't exist or other similar errors. However, using a JSON Schema linter will help validating that the fields match the expected API specifications.

The [JSON schema](https://github.com/buildkite/agent-stack-k8s/blob/main/cmd/linter/schema.json) found in the Agent Stack for Kubernetes controller's open source repository, can also be used with editors that support JSON Schema, by configuring your editor to validate against this controller's schema.
