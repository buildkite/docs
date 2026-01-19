# Buildkite SDK

> 📘
> The Buildkite SDK feature is currently available as a preview. If you encounter any issues while using the Buildkite SDK, please raise them via a [GitHub Issue](https://github.com/buildkite/buildkite-sdk/issues).

The [Buildkite SDK](https://github.com/buildkite/buildkite-sdk) is an open-source multi-language software development kit (SDK) that makes it easy to script the generation of pipeline steps for dynamic pipelines in native languages. The SDK has simple functions to output and serialize these pipeline steps to YAML or JSON format, which you can then upload to your Buildkite pipeline to execute as part of your pipeline build.

Currently, the Buildkite SDK supports the following languages:

- [JavaScript and TypeScript (Node.js)](#javascript-and-typescript-node-dot-js)
- [Python](#python)
- [Go](#go)
- [Ruby](#ruby)
- [C#](#c-sharp)

Each of the **Installing** sub-sections below assume that your local environment already has the required language tools installed.

## JavaScript and TypeScript (Node.js)

This section explains how to install and use the Buildkite SDK for JavaScript and TypeScript ([Node.js](https://nodejs.org/en)-based) projects.

### Installing

To install the Buildkite SDK for [Node.js](https://nodejs.org/en) to your local development environment, run this command:

```bash
npm install @buildkite/buildkite-sdk
```

### Using

The following code example demonstrates how to import the Buildkite SDK into a simple TypeScript script, which then generates a Buildkite Pipelines step for a simple [command step](/docs/pipelines/configure/step-types/command-step) that runs `echo 'Hello, world!'`, and then outputs this step to either JSON or YAML format:

```typescript
const { Pipeline } = require("@buildkite/buildkite-sdk");

const pipeline = new Pipeline();

pipeline.addStep({
    command: "echo 'Hello, world!'",
});

// JSON output
// console.log(pipeline.toJSON());
// YAML output
console.log(pipeline.toYAML());
```
{: codeblock-file="dynamicPipeline.ts"}

When you're ready to upload your output JSON or YAML steps to Buildkite Pipelines, you can do so from a currently running pipeline step:

```yaml
# For example, in your pipeline's Settings > Steps, and with ts-node installed to your agent:
steps:
  - label: "\:pipeline\: Run dynamic pipeline steps"
    command: ts-node .buildkite/dynamicPipeline.ts | buildkite-agent pipeline upload
```

### API documentation

For more detailed API documentation on the Buildkite SDK for TypeScript, consult the [Buildkite SDK's TypeScript API documentation](https://buildkite.com/docs/sdk/typescript/).

## Python

This section explains how to install and use the Buildkite SDK for Python projects.

### Installing

To install the Buildkite SDK for Python (with [uv](https://docs.astral.sh/uv/)) to your local development environment, run this command:

```bash
uv add buildkite-sdk
```

### Using

The following code example demonstrates how to import the Buildkite SDK into a simple Python script, which then generates a Buildkite Pipelines step for a simple simple [command step](/docs/pipelines/configure/step-types/command-step) that runs `echo 'Hello, world!'`, and then outputs this step to either JSON or YAML format:

```python
from buildkite_sdk import Pipeline

pipeline = Pipeline()
pipeline.add_step({"command": "echo 'Hello, world!'"})

# JSON output
# print(pipeline.to_json())
# YAML output
print(pipeline.to_yaml())
```
{: codeblock-file="dynamic_pipeline.py"}

When you're ready to upload your output JSON or YAML steps to Buildkite Pipelines, you can do so from a currently running pipeline step:

```yaml
# For example, in your pipeline's Settings > Steps:
steps:
  - label: "\:pipeline\: Run dynamic pipeline steps"
    command: python3 .buildkite/dynamic_pipeline.py | buildkite-agent pipeline upload
```

### API documentation

For more detailed API documentation on the Buildkite SDK for Python, consult the [Buildkite SDK's Python API documentation](https://buildkite.com/docs/sdk/python/).

## Go

This section explains how to install and use the Buildkite SDK for [Go](https://go.dev/) projects.

### Installing

To install the Buildkite SDK for [Go](https://go.dev/) to your local development environment, run this command:

```bash
go get github.com/buildkite/buildkite-sdk/sdk/go
```

### Using

The following code example demonstrates how to import the Buildkite SDK into a simple Go script, which then generates a Buildkite Pipelines step for a simple [command step](/docs/pipelines/configure/step-types/command-step) that runs `echo 'Hello, world!'`, and then outputs this step to either JSON or YAML format:

```go
package main

import (
  "fmt"
  "github.com/buildkite/buildkite-sdk/sdk/go/sdk/buildkite"
)

func main() {
    pipeline := buildkite.Pipeline{}

    pipeline.AddStep(buildkite.CommandStep{
        Command: &buildkite.CommandStepCommand{
            String: buildkite.Value("echo 'Hello, world!"),
        },
    })

    // JSON output
    // json, err := pipeline.ToJSON()
    // if err != nil {
    //     log.Fatalf("Failed to serialize JSON: %v", err)
    // }

    // fmt.Println(json)

    // YAML output
    yaml, err := pipeline.ToYAML()
    if err != nil {
        log.Fatalf("Failed to serialize YAML: %v", err)
    }

    fmt.Println(yaml)
}
```
{: codeblock-file="dynamic_pipeline.go"}

When you're ready to upload your output JSON or YAML steps to Buildkite Pipelines, you can do so from a currently running pipeline step:

```yaml
# For example, in your pipeline's Settings > Steps:
steps:
  - label: "\:pipeline\: Run dynamic pipeline steps"
    command: go run .buildkite/dynamic_pipeline.go | buildkite-agent pipeline upload
```

### API documentation

For more detailed API documentation on the Buildkite SDK for Go, consult the [Buildkite SDK's Go API documentation](https://pkg.go.dev/github.com/buildkite/buildkite-sdk/sdk/go).

## Ruby

This section explains how to install and use the Buildkite SDK for [Ruby](https://www.ruby-lang.org/en/) projects.

### Installing

To install the Buildkite SDK for [Ruby](https://www.ruby-lang.org/en/) to your local development environment, run this command:

```bash
gem install buildkite-sdk
```

### Using

The following code example demonstrates how to import the Buildkite SDK into a simple Ruby script, which then generates a Buildkite Pipelines step for a simple [command step](/docs/pipelines/configure/step-types/command-step) that runs `echo 'Hello, world!'`, along with a [label](/docs/pipelines/configure/step-types/command-step#label) attribute, and then outputs this step to either JSON or YAML format:

```ruby
require "buildkite"

pipeline = Buildkite::Pipeline.new

pipeline.add_step(
  label: "some-label",
  command: "echo 'Hello, World!'"
)

# JSON output
# puts pipeline.to_json
# YAML output
puts pipeline.to_yaml
```
{: codeblock-file="dynamic_pipeline.rb"}

When you're ready to upload your output JSON or YAML steps to Buildkite Pipelines, you can do so from a currently running pipeline step:

```yaml
# For example, in your pipeline's Settings > Steps:
steps:
  - label: "\:pipeline\: Run dynamic pipeline steps"
    command: ruby .buildkite/dynamic_pipeline.rb | buildkite-agent pipeline upload
```

### API documentation

For more detailed API documentation on the Buildkite SDK for Ruby, consult the [Buildkite SDK's Ruby API documentation](https://buildkite.com/docs/sdk/ruby/).

## C Sharp

This section explains how to install and use the Buildkite SDK for [C#](https://learn.microsoft.com/en-us/dotnet/csharp/) (.NET) projects.

### Installing

To install the Buildkite SDK for [.NET](https://dotnet.microsoft.com/) to your local development environment, run this command:

```bash
dotnet add package Buildkite.Sdk
```

### Using

The following code example demonstrates how to import the Buildkite SDK into a simple C# script, which then generates a Buildkite Pipelines step for a simple [command step](/docs/pipelines/configure/step-types/command-step) that runs `echo 'Hello, world!'`, and then outputs this step to either JSON or YAML format:

```csharp
using Buildkite.Sdk;
using Buildkite.Sdk.Schema;

var pipeline = new Pipeline();

pipeline.AddStep(new CommandStep
{
    Label = "some-label",
    Command = "echo 'Hello, world!'"
});

// JSON output
// Console.WriteLine(pipeline.ToJson());
// YAML output
Console.WriteLine(pipeline.ToYaml());
```
{: codeblock-file="DynamicPipeline.cs"}

When you're ready to upload your output JSON or YAML steps to Buildkite Pipelines, you can do so from a currently running pipeline step:

```yaml
# For example, in your pipeline's Settings > Steps:
steps:
  - label: "\:pipeline\: Run dynamic pipeline steps"
    command: dotnet run --project .buildkite/DynamicPipeline.csproj | buildkite-agent pipeline upload
```

### API documentation

For more detailed API documentation on the Buildkite SDK for C#, consult the [Buildkite SDK's C# API documentation](https://buildkite.com/docs).

## Developing the Buildkite SDK

Since the Buildkite SDK is open source, you can make your own contributions to this SDK. Learn more about how to do this from the [Buildkite SDK's README](https://github.com/buildkite/buildkite-sdk?tab=readme-ov-file#buildkite-sdk).
