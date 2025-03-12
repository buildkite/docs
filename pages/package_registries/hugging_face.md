# Hugging Face

Buildkite Package Registries provides registry support for [Hugging Face models](https://huggingface.co/models), which are essentially Git repositories for [machine learning models](https://en.wikipedia.org/wiki/Machine_learning#Models). Learn more about Hugging Face's machine learning (ML) models from their [Hugging Face Hub documentation](https://huggingface.co/docs/hub/en/index#models).

Since Hugging Face models are open source, you can develop your models privately, by publishing a model's Git commits as a 'package' to your (private) Hugging Face registry in Buildkite Packages. Each such package contains its latest Git commit hash as part of its file name.

Once your Hugging Face source registry has been [created](/docs/package-registries/manage-registries#create-a-source-registry), you can publish/upload packages (generated from your application's build) to this registry via the relevant `huggingface-cli` command presented on your Hugging Face registry's details page. Learn more about installing the Hugging Face command line interface (CLI) tool from their [Hub Python Library CLI documentation](https://huggingface.co/docs/huggingface_hub/main/en/guides/cli).

To view and copy these `huggingface-cli` commands:

