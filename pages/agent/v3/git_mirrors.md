# Git mirrors

Implementing Git mirrors within your own self-hosted build infrastructure allows you to reduce both network bandwidth and disk usage, when running multiple agents.

Git mirroring is set up by mirroring the repository in a central location (known as the _git mirror directory_), and making each checkout us a `--reference` clone of the mirror.
