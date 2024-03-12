# Packages

Buildkite Packages helps you manage artifacts built from your [Buildkite pipelines](/docs/pipelines).

## What is a package?

A _package_ is a combination of _metadata_, _configuration_, and _software_ that is prepared in a way that a package management program can use to properly and reliably install software and related configuration data on a computer. For example:

- <a href="https://help.ubuntu.com/community/Repositories/CommandLine">apt</a> on Ubuntu
- <a href="https://access.redhat.com/site/documentation/en-US/Red_Hat_Enterprise_Linux/5/html/Deployment_Guide/c1-yum.html">yum</a> on RedHat Enterprise Linux
- <a href="https://pip.pypa.io/">pip</a> for Python packages
- <a href="http://guides.rubygems.org/">gem</a> for RubyGems.

Packages are useful because their:

- Version information helps keep software up to date
- Metadata offers visibility in what's installed to which locations and why
- Software installations are reproducible in different environments.
