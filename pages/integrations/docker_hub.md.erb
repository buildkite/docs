# Docker Hub

[Docker Hub](https://hub.docker.com/) is a public registry of docker images,
with popular images used in many build pipelines.

On 2nd November 2020, [Docker Hub introduced strict rate
limits](https://docs.docker.com/docker-hub/download-rate-limit/) on image
downloads by unauthenticated clients and authenticated clients on a free plan.
For many Buildkite customers, this may result in some jobs intermittently
failing.

The appropriate mitigation for build failures caused by the rate limits will
vary between customers. Here's a few options.

{:toc}

## Authenticating with a paid Docker Hub account on the Elastic CI Stack for AWS

The [Elastic CI Stack for AWS](https://github.com/buildkite/elastic-ci-stack-for-aws) can [authenticate with Docker Hub by adding two
environment variables to the secrets
bucket](https://github.com/buildkite/elastic-ci-stack-for-aws#docker-registry-support):

Each Elastic CI Stack typically has an S3 bucket for storing secrets used during
builds. At the start of each job, the agent will attempt to download two
environment hooks:

* `/env` - An agent environment hook, run for every job the agent runs
* `/{pipeline-slug}/env` - An agent environment hook, specific to a pipeline

Either one of these could be configured with Docker Hub credentials to ensure
Docker Hub requests are authenticated:

    #!/bin/bash

    DOCKER_LOGIN_USER="the-user-name"
    DOCKER_LOGIN_PASSWORD="the-password"

## Authenticating with a paid Docker Hub account on other agents

All agents will [check the local filesystem for hook scripts to execute during a job](/docs/agent/v3/hooks).

A [pre-command hook](https://buildkite.com/docs/agent/v3/hooks#available-hooks) script like this is one option for authenticating with Docker Hub

    #!/bin/bash

    echo "~~~ Logging into Docker Hub"
    docker login --username "the-user-name" --password-stdin << "the-password"

Depending on your preferences, it's possible to fetch the credentials from
another system (vault, AWS SSM, etc) rather than hard code them into the hook.

## Authenticating with a paid Docker Hub account using docker login plugin

The [docker-login plugin](https://github.com/buildkite-plugins/docker-login-buildkite-plugin/) can perform the authentication in just the jobs that need it.

Start by setting the password in an [agent environment hook](/docs/agent/v3/hooks):

    #!/bin/bash

    DOCKER_HUB_PASSWORD="the-password"

Then add the plugin to pipeline YAML steps that need it:

    steps:
      - command: ./run_build.sh
        plugins:
          - docker-login#v2.0.1:
              username: the-user-name
              password-env: DOCKER_HUB_PASSWORD

## Mirror images into Google Container Registry

For those who use Google Cloud, Google has some [documentation on mirroring
Docker Hub images to a private Google Container Registry
(GCR)](https://cloud.google.com/container-registry/docs/migrate-external-containers).

This approach requires:

1. A regular process (eg. nightly) that mirrors images of interest
2. Updating all pipelines to use the mirrored GCR image (eg from `nginx:1.14.2`
   to `gcr.io/<GCR_PROJECT>/nginx:1.14.2`)

## Mirror images into AWS Elastic Container Registry

AWS doesn't have specific documentation, however the solution proposed by Google Cloud Platform (GCP)
above would work with AWS Elastic Container Registry (ECR) as well.

## Configure docker daemon to try the GCR mirror of popular Docker Hub images

GCP host a mirror of popular Docker Hub images in the mirror.gcr.io registry.

For agents running on GCP, it's possible to configure docker to try the mirror
first, and transparently fall back to the public Docker Hub registry when the
mirror doesn't have an image. Google have [documented how to set this
us](https://cloud.google.com/container-registry/docs/pulling-cached-images).

This will avoid the rate limits for many, but it's not foolproof. Google don't
guarantee which images will be on the mirror, so depending on the specific
images in use you may continue to hit Docker Hub rate limits.

## Run a read-through caching registry

There are two popular options for running a private caching docker registry,
where requests for missing images result in the image being fetched from an
origin registry (like Docker Hub).

1. https://docs.docker.com/registry/recipes/mirror/
2. https://github.com/rpardini/docker-registry-proxy

Once the caching registry is operating, pipelines can be updated to use images
from that registry (eg from `nginx:1.14.2` to `example.com/nginx:1.14.2`) and
new images will be transparently fetched from Docker Hub.
