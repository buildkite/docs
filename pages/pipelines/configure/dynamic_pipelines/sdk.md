# Buildkite SDK overview

The [Buildkite SDK](https://github.com/buildkite/buildkite-sdk) is an open-source multi-language software development kit (SDK) that makes it easy to script the generation of pipeline steps for dynamic pipelines in native languages. The SDK has simple functions to output these pipeline steps in YAML or JSON format, which you can then upload to your Buildkite pipeline to execute as part of your pipeline build.

## Supported languages

Currently, the Buildkite SDK supports the following languages. Once imported into your script program, you can make the following example function calls to generate a new step:

### Node.js (JavaScript and TypeScript)

```bash
npm install @buildkite/buildkite-sdk
```

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

### Python

```bash
uv add buildkite-sdk
```

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

### Go

```bash
go get github.com/buildkite/buildkite-sdk/sdk/go
```

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

### Ruby

```bash
gem install buildkite-sdk
```

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

Learn more about how to use the Buildkite SDK from its README.

## API documentation

Detailed API documentation is available for each individual language:

- [TypeScript SDK documentation](/docs/sdk/typescript)
- [Python SDK documentation](/docs/sdk/typescript)
- [Go SDK documentation](https://pkg.go.dev/github.com/buildkite/buildkite-sdk/sdk/go)
- [Ruby SDK documentation](/docs/sdk/typescript)
