# Caching

Caching makes builds faster and cheaper by reusing work across jobs and builds. This guide distills Buildkite’s current capabilities and emerging patterns into practical recommendations with examples you can copy‑paste.

Efficient caching: optimize Dockerfile layering to maximize [cache reuse](https://docs.docker.com/build/cache/).

### What to cache

- Dependency directories for your language or build tool
    * Node.js: node_modules, pnpm or yarn cache
    * Ruby: vendor/bundle
    * Go: GOPATH/pkg/mod
    * Swift/iOS: Swift Package caches, CocoaPods
- Docker build layers when applicable
- Large files repeatedly downloaded from the internet
- Git mirrors on hosted agents are handled for you and benefit from caching automatically[[1]](https://buildkite.com/docs/pipelines/hosted-agents/cache-volumes)

Do not cache:

- Final build artifacts that you publish elsewhere
- Test outputs whose validity depends on the current code

Why: The greatest wins come from restoring dependency trees and Docker layers, not test results or end products.

### Choose the right caching mechanism

- Hosted Agent Cache Volumes

    * Best for simple, fast, shared caching within a pipeline
    * High‑performance NVMe on Linux and sparse bundle images on macOS
    * Best‑effort attachment, shared across steps, scoped to a pipeline
    * Updated only on successful job completion and forked per job for safe concurrency.

- Plugins and registries
    * Use official or community plugins to cache Docker layers externally when needed
    * Example: docker‑ecr‑cache plugin for layer reuse in [ECR/GCR](https://github.com/seek-oss/docker-ecr-cache-buildkite-plugin)

Recommendation: Prefer hosted Cache Volumes for most hosted‑agent pipelines. Layer in key‑based cache where determinism and cross‑build control matter most (for example, lockfile‑keyed dependency caches).
