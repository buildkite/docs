# Remote Docker builders

_Remote Docker builders_ are dedicated machines available to [Buildkite hosted agents](/docs/pipelines/hosted-agents), which are specifically designed and configured to handle the [building of Docker images](https://docs.docker.com/build/) with the `docker build` command.

> 📘 Enterprise feature
> Remote Docker builders is a feature that's available to Buildkite customers on [Enterprise](https://buildkite.com/pricing) plans.

Remote Docker builders maintain their own [caches of image layers](https://docs.docker.com/build/cache/) (also known as _layer caches_), and their resulting images are streamed back to the Buildkite hosted agents making the request, which in turn, speeds up your overall pipeline builds, since these agents are free to build your pipeline and conduct other work. Docker images streamed back in this manner do not need to be re-built or re-downloaded to the agent.

When using remote Docker builders, the first few builds of a pipeline might typically require between 2-4 minutes to complete. However, once subsequent builds are able to receive their Docker images, streamed back from the remote Docker builder's layer cache, these subsequent builds are typically completed within 5-10 seconds.

