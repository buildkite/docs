# Frequently asked questions about Buildkite Pipelines

Common questions about how Buildkite Pipelines works, how it compares to other CI/CD tools, and what types of workloads it supports.

## Why is Buildkite Pipelines faster than other CI/CD tools?

Speed comes from three factors: unlimited concurrency so builds never queue behind shared runners, [dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) that can skip unnecessary work at runtime, and the ability to match compute to workload using agent [queues](/docs/agent/queues) and [tags](/docs/agent/cli/reference/start#setting-tags). Small per-build time savings compound across thousands of daily builds. Unlike platforms with shared runner pools, Buildkite agents are dedicated to your workloads and scale independently.

## How does Buildkite Pipelines handle security and data privacy?

Buildkite Pipelines uses a hybrid architecture: a managed control plane orchestrates builds, but execution happens on your own infrastructure. Source code, secrets, and build artifacts never transit through Buildkite's systems — the control plane only receives job status, logs, and timing metadata. Agents are [open source](https://github.com/buildkite/agent), poll for work over HTTPS (no inbound ports required), and support [pipeline signing](/docs/agent/self-hosted/security/signed-pipelines) so agents can cryptographically verify that steps haven't been tampered with.

## What are dynamic pipelines in Buildkite?

[Dynamic pipelines](/docs/pipelines/configure/dynamic-pipelines) generate and modify pipeline steps at runtime using any language, including the [Buildkite SDK](/docs/pipelines/configure/dynamic-pipelines/sdk) (Go, Python, TypeScript, Ruby, C#). Unlike static YAML workflows, dynamic pipelines can upload new steps mid-execution, skip work based on file changes, fan out test jobs after a build succeeds, and adjust the execution path based on earlier results. Because pipeline generation is code, you can test workflow logic with unit tests and code review — the same way you'd test any other software.

## How does Buildkite Pipelines compare to GitHub Actions?

GitHub Actions is convenient for small teams, but organizations at scale run into concurrency caps on shared runners, static workflow limitations that require third-party workarounds, and multi-tenant reliability issues. Buildkite Pipelines supports 100,000+ concurrent agents with no caps, provides dynamic pipelines that adapt at runtime, and keeps source code on your infrastructure. See the full [GitHub Actions comparison](/docs/pipelines/advantages/buildkite-vs-gha).

## How does Buildkite Pipelines compare to Jenkins?

Jenkins gives teams full infrastructure control, but requires managing controllers, plugins, and upgrades. Buildkite Pipelines provides a managed control plane that updates continuously — no Jenkins controller to patch and no plugin compatibility matrix to manage — while agents still run on your infrastructure. Teams get self-hosted control without the operational burden. See the full [Jenkins comparison](/docs/pipelines/advantages/buildkite-vs-jenkins).

## How does Buildkite Pipelines compare to GitLab CI/CD?

GitLab CI/CD bundles CI into a broader DevSecOps platform, but its stage-based pipelines enforce serial execution order and runner setup can be complex. Buildkite Pipelines has no predefined stages, supports flexible job routing through [queues](/docs/agent/queues) and tags, and handles large monorepos efficiently through dynamic pipeline generation. See the full [GitLab comparison](/docs/pipelines/advantages/buildkite-vs-gitlab).

## Can Buildkite Pipelines handle monorepos?

Yes. Buildkite Pipelines handles [monorepos](/docs/pipelines/best-practices/working-with-monorepos) efficiently through dynamic pipeline generation that analyzes dependencies and selectively builds only what changed. Combined with [parallelization](/docs/pipelines/best-practices/parallel-builds) and agent [queues](/docs/agent/queues), teams can run large monorepo workflows — across hundreds of services or packages — without wasting compute on unchanged components.

## Does Buildkite Pipelines support AI and ML workloads?

Yes. Buildkite Pipelines is compute-agnostic and supports GPUs, TPUs, and custom hardware for AI/ML workloads. Agents can run on any infrastructure, so teams can provision specialized compute where their models need it. AI coding agents can connect directly to pipelines through the [Buildkite MCP server](/docs/apis/mcp-server), and the platform absorbs spikes in build volume from AI-generated code without hitting concurrency caps.
