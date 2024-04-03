# Buildkite Packages

Buildkite Packages manages artifacts and packages from [Buildkite Pipelines](/docs/pipelines), as well as other CI/CD applications that require artifact management.

> 📘 Buildkite Packages is currently in private beta
> Please visit the [Buildkite Packages](https://buildkite.com/packages) page on our website to join the waitlist for this product and register for early access.

## An introduction to packages

A _package_ is a combination of _metadata_, _configuration_, and _software_ that is prepared in a way that a package management tool can use to properly and reliably install software and related configuration data on a computer. Some examples of package management tools include:

- [apt](https://help.ubuntu.com/community/Repositories/CommandLine) on Ubuntu
- [yum](https://access.redhat.com/site/documentation/en-US/Red_Hat_Enterprise_Linux/5/html/Deployment_Guide/c1-yum.html) on RedHat Enterprise Linux
- [pip](https://pip.pypa.io/) for Python packages
- [gem](http://guides.rubygems.org/) for RubyGems

Packages are useful because their:

- Version information helps keep software up to date
- Metadata offers visibility in what's installed to which locations and why
- Software installations are reproducible in different environments.

## Package creation tools

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

Buildkite Packages provides registries for your [packages](/docs/packages#an-introduction-to-packages) and other package-like file formats such as container images and Terraform modules. As well as holding a collection of packages, each registry may also contain metadata describing a variety of attributes for these packages such as, package versions, supported operating system versions and processor architecture, dependencies, and so on.

### Supported package ecosystems

Currently, Buildkite Packages supports the following package ecosystems:

- Alpine
- Docker container images
- deb (Debian and Ubuntu)
- gem (RubyGems)
- Java (Maven and Gradle)
- Node.js (npm)
- Python (PyPI)
- rpm (Fedora and RHEL)
- Terraform (modules)

## Getting started tutorial

Learn more about how:

- The Buildkite Packages product works through this step-by-step [Getting started](/docs/packages/getting-started) tutorial.

- To work with Buildkite Packages registries in [Manage registries](/docs/packages/manage-registries).
