# Hugging Face

> 📘
> The _Hugging Face registries_ feature is currently in _customer preview_. To enquire about accessing this feature for your Buildkite organization, please contact support@buildkite.com.

Buildkite Package Registries provides registry support for [Hugging Face models](https://huggingface.co/models), which are essentially Git repositories aimed for developing [machine learning models](https://en.wikipedia.org/wiki/Machine_learning#Models). Learn more about Hugging Face's machine learning (ML) models from their [Hugging Face Hub documentation](https://huggingface.co/docs/hub/en/index#models).

Hugging Face's [open source models](https://huggingface.co/models) can be developed, fine tuned, and published to your (private) Hugging Face registry in Buildkite Package Registries. Each Git commit to a model constitutes a new version of the model (known as a _model version_), which is published as an individual 'package' to your Hugging Face registry, with the Git commit SHA forming part of the package name.

Once your Hugging Face source registry has been [created](/docs/package-registries/registries/manage#create-a-source-registry), you can cache your model locally from the [Hugging Face Hub](https://huggingface.co/docs/hub/index), then publish/upload model versions to this source registry via the relevant `huggingface-cli` commands presented on your Hugging Face registry's details page. Learn more about installing the Hugging Face command line interface (CLI) tool from their [Hub Python Library CLI documentation](https://huggingface.co/docs/huggingface_hub/main/en/guides/cli).

To view and copy these `huggingface-cli` commands:

1. Select **Package Registries** in the global navigation to access the **Registries** page.
1. Select your Hugging Face source registry on this page.
1. Select the **Publish Instructions** tab and on the resulting page, for each required `huggingface-cli` command in code snippets provided, copy the relevant code snippet (using the icon at the top-right of its code box), paste it into your terminal, and run it with the appropriate values to publish the model's new version (in a Git commit) to this source registry.

These Hugging Face commands are used to:

- Set the [`HF_TOKEN` environment variable](https://huggingface.co/docs/huggingface_hub/main/en/package_reference/environment_variables#hftoken)'s value to the required access token used to either access the Hugging Face model from the Hub to cache locally, or publish the model's Git commit as a new model version to your specific Hugging Face source registry in Buildkite Package Registries.
- Set the [`HF_ENDPOINT` environment variable](https://huggingface.co/docs/huggingface_hub/v0.16.3/en/package_reference/environment_variables#hfendpoint)'s value to the (base) URL of the Hugging Face Hub, or the source registry in Buildkite Package Registries.
- Cache the Hugging Face model locally, or publish your model's new version (from a locally cached Git commit) to this source registry.

## Publish a model version

The following steps describe the process above.

### Step 1: Ensure the Hugging Face model is cached locally

If you haven't already done so, run the following `huggingface-cli` command to ensure the Hugging Face model has been cached locally:

```bash
HF_TOKEN=huggingface-token \
HF_ENDPOINT=https://huggingface.co \
huggingface-cli download {huggingface.namespace}/{huggingface.repo.name}
```

where:

- `huggingface-token` is your [Hugging Face user access token](https://huggingface.co/docs/hub/security-tokens) required to access the Hugging Face model from the [Hugging Face Hub](https://huggingface.co/docs/hub/index).

<%= render_markdown partial: 'package_registries/ecosystems/hugging_face_namespace_and_repo' %>

### Step 2: Publish your model version

Use the following `huggingface-cli` command to publish the Hugging Face model version to your Hugging Face source registry:

```bash
HF_TOKEN=registry-write-token \
HF_ENDPOINT=https://packages.buildkite.com/{org.slug}/{registry.slug}/huggingface \
huggingface-cli upload {huggingface.namespace}/{huggingface.repo.name} local-folder
```

where:

- `registry-write-token` is your [API access token](https://buildkite.com/user/api-access-tokens) used to publish/upload a new model version to your Hugging Face source registry. Ensure this access token has the **Read Packages** and **Write Packages** REST API scopes, which allows this token to publish new model versions and other package types to any source registry your user account has access to within your Buildkite organization. Alternatively, you can use an OIDC token that meets your Hugging Face source registry's [OIDC policy](/docs/package-registries/security/oidc#define-an-oidc-policy-for-a-registry). Learn more about these tokens in [OIDC in Buildkite Package Registries](/docs/package-registries/security/oidc).

<%= render_markdown partial: 'package_registries/org_slug' %>

- `{registry.slug}` is the slug of your Hugging Face source registry, which is the [kebab-case](https://en.wikipedia.org/wiki/Letter_case#Kebab_case) version of this registry's name, and can be obtained after accessing **Package Registries** in the global navigation > your Hugging Face source registry from the **Registries** page.

<%= render_markdown partial: 'package_registries/ecosystems/hugging_face_namespace_and_repo' %>

- `local-folder` is the location of the locally cached Hugging Face model version. This can be found in the following path: `~/.cache/huggingface/hub/models--{huggingface.namespace}--{huggingface.repo.name}/snapshots/{commit.sha}/`, where `{commit.sha}` represents the Git commit SHA of model version you want to publish to this repository.

## Access a model version's details

A Hugging Face model version's details can be accessed from its source registry through the **Releases** (tab) section of your Hugging Face source registry page. To do this:

1. Select **Package Registries** in the global navigation to access the **Registries** page.
1. Select your Hugging Face source registry on this page.
1. On your Hugging Face source registry page, select the model version to display its details page.

The model version's details page provides the following information in the following sections:

- **Installation** (tab): the [installation instructions](#access-a-model-versions-details-installing-a-model-version).
- **Contents** (tab, where available): a list of directories and files contained within the model version.
- **Details** (tab): a list of checksum values for this model version—Message and SHA. The **Message** value can be customized using the `--commit-message` option of the `huggingface-cli` command.
- **Details**: details about:

    * the name of the model version, consisting of the model's Hugging Face Hub namespace and name, along with the commit SHA.
    * the source registry the model version is located in.
    * the model version's visibility (based on its registry's visibility)—whether the model version is **Private** and requires authentication to access, or is publicly accessible.

- **Pushed**: the date when the model version was uploaded to the source registry.
- **Package size**: the storage size (in bytes) of this model version.

### Installing a model version

A Hugging Face model version can be downloaded using code snippet details provided on the model version's details page. To do this:

1. [Access the model version's details](#access-a-model-versions-details).
1. Ensure the **Installation** > **Instructions** section is displayed.
1. Copy the relevant code snippet, paste it into your terminal, and run it.
