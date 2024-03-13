# Getting started

Buildkite Packages provides a repository for your [packages](/docs/packages#an-introduction-to-packages) which, in addition to holding a collection of packages, also contains metadata describing a variety of attributes for these packages such as, package versions, supported operating system versions and processor architecture, dependencies, and so on. Buildkite packages may:

- Contain packages of any supported type. For example, Debian, RPM, RubyGem, and Python packages can all coexist in the same Buildkite Packages repository
- Have packages for multiple Linux distributions, for example, if you have a Debian package that works for two versions of Ubuntu and one version of Debian you only need one Packages repository
- Issue _read tokens_ to identify specific nodes and control access to a repository by specific node.

Currently, Buildkite Packages supports the following package formats:

- RPM
- DEB
- Debian source packages (DSCs)
- Java packages (Clojure, SBT, "fatjar")
- Python packages (wheels, eggs, source distributions)
- RubyGems
- Node.js
- Alpine
- Generic files, for example, `.asc` (signature files), `.zip`, and so on
