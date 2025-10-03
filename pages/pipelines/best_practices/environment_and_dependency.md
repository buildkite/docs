# Environment and dependency management

## Containerize builds for consistency

* Docker-based builds: ensure environments are reproducible across local and CI.
* [Multi-stage builds in Docker](https://docs.docker.com/build/building/multi-stage/): keep images slim while supporting complex build processes.
* Pin base images: avoid unintended breakage from upstream changes.

## Handle dependencies reliably

* Lock versions: use lockfiles and pin versions to ensure repeatable builds (you can also [pin plugin versions](/docs/pipelines/integrations/plugins/using#pinning-plugin-versions)).
* Cache packages: reuse downloads where possible to reduce network overhead.
* Validate integrity: use checksums or signatures to confirm dependency authenticity.
