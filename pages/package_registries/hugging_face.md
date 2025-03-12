# Hugging Face

Buildkite Package Registries provides registry support for [Hugging Face models](https://huggingface.co/models), which are essentially Git repositories aimed for developing [machine learning models](https://en.wikipedia.org/wiki/Machine_learning#Models). Learn more about Hugging Face's machine learning (ML) models from their [Hugging Face Hub documentation](https://huggingface.co/docs/hub/en/index#models).

Since Hugging Face models are open source, you can develop your models privately, by publishing a model's Git commits as a 'package' to your (private) Hugging Face registry in Buildkite Packages. Each such package contains its latest Git commit hash as part of its file name.

Once your Hugging Face source registry has been [created](/docs/package-registries/manage-registries#create-a-source-registry), you can publish/upload packages (generated from your application's build) to this registry via the relevant `huggingface-cli` command presented on your Hugging Face registry's details page. Learn more about installing the Hugging Face command line interface (CLI) tool from their [Hub Python Library CLI documentation](https://huggingface.co/docs/huggingface_hub/main/en/guides/cli).

To view and copy these `huggingface-cli` commands:

1. Select **Package Registries** in the global navigation to access the **Registries** page.
1. Select your Hugging Face source registry on this page.
1. Select the **Publish Instructions** tab and on the resulting page, for each required `huggingface-cli` command in code snippets provided, copy the relevant code snippet (using the icon at the top-right of its code box), paste it into your terminal, and run it with the appropriate values to publish the model's Git commits to this source registry.

These Hugging Face commands are used to:

- Set the API access token required to publish the model's Git commits as a package to your specific Hugging Face source registry to the [`HF_TOKEN` environment variable](https://huggingface.co/docs/huggingface_hub/main/en/package_reference/environment_variables#hftoken).
- Set the URL for this source registry to the [`HF_ENDPOINT` environment variable](https://huggingface.co/docs/huggingface_hub/v0.16.3/en/package_reference/environment_variables#hfendpoint)
- Publish your model's Git commits (cached locally) to this source registry.

## Publish a model snapshot

