# Remote Docker builders

_Remote Docker builders_ are dedicated machines available to [Buildkite hosted agents](/docs/pipelines/hosted-agents), which are specifically designed and configured to handle the [building of Docker images](https://docs.docker.com/build/) with the `docker build` command.

> 📘 Enterprise feature
> Remote Docker builders is a feature that's available to Buildkite customers on [Enterprise](https://buildkite.com/pricing) plans.

Remote Docker builders maintain their own [caches of image layers](https://docs.docker.com/build/cache/), and their resulting images are streamed back to the Buildkite hosted agents making the request, which in turn, speeds up your overall pipeline builds, since these agents are free to build your pipeline and conduct other work.
