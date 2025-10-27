# Remote Docker builders

_Remote Docker builders_ are dedicated machines available to [Buildkite hosted agents](/docs/pipelines/hosted-agents), which are specifically designed and configured to handle the [building of Docker images](https://docs.docker.com/build/) with the `docker build` command. This feature substantially speeds up the build times of pipelines that need to build Docker images.

> 📘 Enterprise plan feature
> The remote Docker builders feature is available to Buildkite customers on the [Enterprise](https://buildkite.com/pricing) plan, and becomes automatically available to existing customers who upgrade to this plan, as well as all new Buildkite customers who sign up to the Enterprise plan.

## How remote Docker builders work

When using the remote Docker builders feature, any `docker build` commands within your pipeline are directed to and run on an external/remote [BuildKit](https://docs.docker.com/build/buildkit/) builder (the remote Docker builder), rather than being run on the Buildkite hosted agent instance itself. While the agent orchestrates the build and streams its context to and from the BuildKit service, the BuildKit service builds the images and returns the images and metadata to the agent.

Remote Docker builders maintain their own [caches of image layers](https://docs.docker.com/build/cache/) (also known as _layer caches_), and their resulting images are streamed back to the Buildkite hosted agents making the request, which in turn, speeds up your overall pipeline builds, since these agents are free to build your pipeline and conduct other work. Docker images streamed back in this manner do not need to be re-built or re-downloaded to the agent.

When using remote Docker builders, the first few builds of a pipeline might typically require between 2-4 minutes to complete. However, once subsequent builds are able to receive their Docker images, streamed back from the remote Docker builder's layer cache, these subsequent builds are typically completed within 5-10 seconds.

