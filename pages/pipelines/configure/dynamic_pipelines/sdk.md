# Buildkite SDK

The [Buildkite SDK](https://github.com/buildkite/buildkite-sdk) is an open-source multi-language software development kit (SDK) that makes it easy to script the generation of pipeline steps for dynamic pipelines in native languages. The SDK has simple functions to output these pipeline steps in YAML or JSON format, which you can then upload to your Buildkite pipeline to execute as part of your pipeline build.

Currently, the Buildkite SDK supports the following languages:

- [JavaScript and TypeScript (Node.js)](#javascript-and-typescript-node-dot-js)
- [Python](#python)
- [Go](#go)
- [Ruby](#ruby)

Each of the **Installation** sub-sections below assume that your local environment already has the required language tools installed.

## JavaScript and TypeScript (Node.js)

### Installing

To install the Buildkite SDK for [Node.js](https://nodejs.org/en) to your local environment, run this command:

```bash
npm install @buildkite/buildkite-sdk
```

### Using

The following code example demonstrates how to import the Buildkite SDK into a simple TypeScript script, which then generates a Buildkite Pipelines step for a simple [command step](/docs/pipelines/configure/step-types/command-step) that runs `echo 'Hello, world!'`, and then outputs this step in both JSON and YAML format:

```typescript
const { Pipeline } = require("@buildkite/buildkite-sdk");

const pipeline = new Pipeline();

pipeline.addStep({
    command: "echo 'Hello, world!'",
});

console.log(pipeline.toJSON());
console.log(pipeline.toYAML());
```
{: codeblock-file="index.ts"}

## Python

### Installing

To install the Buildkite SDK for Python (with [uv](https://docs.astral.sh/uv/)) to your local environment, run this command:

```bash
uv add buildkite-sdk
```

### Using

The following code example demonstrates how to import the Buildkite SDK into a simple Python script, which then generates a Buildkite Pipelines step for a simple simple [command step](/docs/pipelines/configure/step-types/command-step) that runs `echo 'Hello, world!'`, and then outputs this step in both JSON and YAML format:

```python
from buildkite_sdk import Pipeline, CommandStep

pipeline = Pipeline()
pipeline.add_step(CommandStep(
    commands="echo 'Hello, world!'"
))

print(pipeline.to_json())
print(pipeline.to_yaml())
```
{: codeblock-file="main.py"}

## Go

### Installing

To install the Buildkite SDK for [Go](https://go.dev/) to your local environment, run this command:

```bash
go get github.com/buildkite/buildkite-sdk/sdk/go
```

### Using

The following code example demonstrates how to import the Buildkite SDK into a simple Go script, which then generates a Buildkite Pipelines step for a simple [command step](/docs/pipelines/configure/step-types/command-step) that runs `echo 'Hello, world!'`, and then outputs this step in both JSON and YAML format:

```go
package main

import (
	"fmt"
	"github.com/buildkite/buildkite-sdk/sdk/go/sdk/buildkite"
)

func main() {
	pipeline := buildkite.Pipeline{}
	command := "echo 'Hello, world!"

	pipeline.AddCommandStep(buildkite.CommandStep{
		Command: &buildkite.CommandUnion{
			String: &command,
		},
	})

	fmt.Println(pipeline.ToJSON())
	fmt.Println(pipeline.ToYAML())
}
```
{: codeblock-file="main.go"}

## Ruby

### Installing

To install the Buildkite SDK for [Ruby](https://www.ruby-lang.org/en/) to your local environment, run this command:

```bash
gem install buildkite-sdk
```

### Using

The following code example demonstrates how to import the Buildkite SDK into a simple Ruby script, which then generates a Buildkite Pipelines step for a simple [command step](/docs/pipelines/configure/step-types/command-step) that runs `echo 'Hello, world!'`, along with a [label](/docs/pipelines/configure/step-types/command-step#label) attribute, and then outputs this step in both JSON and YAML format:

```main.rb
require "buildkite"

pipeline = Buildkite::Pipeline.new

pipeline.add_step(
  label: "some-label",
  command: "echo 'Hello, World!'"
)

puts pipeline.to_json
puts pipeline.to_yaml
```

## Developing the Buildkite SDK

Since the Buildkite SDK is open source, you can make your own contributions to this SDK. You can learn more about how to do this from the [Buildkite SDK's README](https://github.com/buildkite/buildkite-sdk?tab=readme-ov-file#buildkite-sdk).

## API documentation

Detailed API documentation is available for each individual language:

- [TypeScript SDK documentation](/docs/sdk/typescript)
- [Python SDK documentation](/docs/sdk/typescript)
- [Go SDK documentation](https://pkg.go.dev/github.com/buildkite/buildkite-sdk/sdk/go)
- [Ruby SDK documentation](/docs/sdk/typescript)
