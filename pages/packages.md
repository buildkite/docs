# Packages

Buildkite Packages helps you manage artifacts built from your [Buildkite pipelines](/docs/pipelines).

## An introduction to packages

A _package_ is a combination of _metadata_, _configuration_, and _software_ that is prepared in a way that a package management program can use to properly and reliably install software and related configuration data on a computer. For example:

- [apt](https://help.ubuntu.com/community/Repositories/CommandLine) on Ubuntu
- [yum](https://access.redhat.com/site/documentation/en-US/Red_Hat_Enterprise_Linux/5/html/Deployment_Guide/c1-yum.html) on RedHat Enterprise Linux
- [pip](https://pip.pypa.io/) for Python packages
- [gem](http://guides.rubygems.org/) for RubyGems

Packages are useful because their:

- Version information helps keep software up to date
- Metadata offers visibility in what's installed to which locations and why
- Software installations are reproducible in different environments.

### Package creation tools

There are many tools for creating packages. Some of these tools are provided directly by Linux distributions, while many other third-party packaging tools are also available.

Some popular package creation tools include:

- [rpmbuild](http://wiki.centos.org/HowTos/SetupRpmBuildEnvironment) (CentOS) for RPM packages. Also, refer to the [Packaging Tutorial: GNU Hello](https://docs.fedoraproject.org/en-US/package-maintainers/Packaging_Tutorial_GNU_Hello/) for Fedora
- [debuild](https://wiki.debian.org/Packaging/Intro) for DEB packages
- [distutils](https://docs.python.org/2/distutils/builtdist.html) for Python packages
- [gem](http://guides.rubygems.org/make-your-own-gem/) for RubyGems

Some advanced package creation tools include:

- [Mock](https://rpm-software-management.github.io/mock/), a chroot-based system for building RPM packages in a clean room environment
- [pbuilder](https://wiki.ubuntu.com/PbuilderHowto), a chroot-based system for building DEB packages in a clean room environment. Useful tips about pbuilder can also be found in its [user manual](http://www.netfort.gr.jp/~dancer/software/pbuilder-doc/pbuilder-doc.html)
- [git-buildpackage](http://honk.sigxcpu.org/projects/git-buildpackage/manual-html/gbp.html), a set of scripts that can be used to build DEB packages directly from git repositories
- [fpm](https://github.com/jordansissel/fpm), a third-party tool that allows users to quickly and easily make a variety of packages (including RPM and DEB packages)
- [PackPack](https://github.com/packpack/packpack), a simple tool to build RPM and Debian packages from git repositories.

## Buildkite Packages

Buildkite Packages provides a repository for your [packages](#an-introduction-to-packages) which, in addition to holding a collection of packages, also contains metadata describing a variety of attributes for these packages such as, package versions, supported operating system versions and processor architecture, dependencies, and so on. Buildkite packages may:

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
