# Running Buildkite Agent with Docker

> 🚧 This page references the out-of-date Buildkite Agent v2.
> For docs referencing the Buildkite Agent v3, <a href="/docs/agent/v3/self-hosted/installing/docker">see the latest version of this document</a>.

You can run the Buildkite Agent inside a Docker container using the official Docker images.

> 📘 Running each build in its own container
> These instructions cover how to run the agent using Docker. If you want to learn how to isolate each build using Docker and any of our standard Linux-based installers read the <a href="/docs/pipelines/tutorials/docker-containerized-builds">Docker-Based Builds</a> guide.

## Running using Docker

Start an agent with the [official image](https://hub.docker.com/r/buildkite/agent/) based on Alpine Linux:

```shell
docker run -e BUILDKITE_AGENT_TOKEN="INSERT-YOUR-AGENT-TOKEN-HERE" buildkite/agent
```

A much larger Ubuntu-based image is also available:

```shell
docker run -e BUILDKITE_AGENT_TOKEN="INSERT-YOUR-AGENT-TOKEN-HERE" buildkite/agent:ubuntu
```

## Running on startup

By default Docker [starts containers on restart](https://docs.docker.com/articles/host_integration/) so there's no need for upstart or similar. Start your container with `-d` to daemonize it and it will be restarted on system boot with the same environment variables and arguments.

## SSH keys, configuration and customization

See the [GitHub repository](https://github.com/buildkite/docker-buildkite-agent) for instructions on how to customize the base image. Alternatively you can create your own Docker image using our standard installer packages (see our [Ubuntu Dockerfile](https://github.com/buildkite/agent/blob/main/packaging/docker/ubuntu-22.04/Dockerfile) for an example).
