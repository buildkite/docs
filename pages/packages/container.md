# Container

Buildkite Packages provides registry support for container-based (Docker) images.

Once your container registry has been [created](/docs/packages/manage-registries#create-a-registry), you can publish/upload images (generated from your application's build) to this registry via relevant `docker` commands presented on your container registry's details page.

To view and copy these `docker` commands:

1. Select **Packages** in the global navigation to access the **Registries** page.
1. Select your container registry on this page.
1. Select **Publish a Container Package** and in the resulting dialog, for each required `docker` command set in the relevant code snippets, copy the relevant code snippet (using the icon at the top-right of its code box), paste it into your terminal, and submit it.

These Docker commands are used to:

- Log in to your Buildkite container registry with the API write token.
- Tag your container image to be published.
- Publish the image to your container registry.

## Publish an image

The following steps describe the process above:

1. Copy the following `docker login` command, paste it into your terminal, and modify as required before submitting to log in to your container registry:

    ```bash
    docker login packages.buildkite.com/{org.slug}/{registry.slug} -u buildkite -p registry-write-token
    ```

    where:
    * `registry-write-token` is your [API access token](https://buildkite.com/user/api-access-tokens) used to publish/upload packages to your container registry. Ensure this access token has the **Write Packages** REST API scope, which allows this token to publish packages to any registry your user account has access to within your Buildkite organization.

    <%= render_markdown partial: 'packages/org_slug' %>
    <%= render_markdown partial: 'packages/container_registry_slug' %>

1. Copy the following `docker tag` command, paste it into your terminal, and modify as required before submitting to tag your container image as required:

    ```bash
    docker tag current-image-name:tag packages.buildkite.com/{org.slug}/{registry.slug}/package-name:tag
    ```

    where:
    * `current-image-name:tag` is the existing `image-name:tag` combination of your container image name and its current tag to published to your container registry. The `:tag` component can be optional. This component of this command also supports the other tag syntax references mentioned in the [`docker tag` documentation](https://docs.docker.com/reference/cli/docker/image/tag/).
    * `image-name:tag` is the image name and tag to provide to this image when it is published to your container registry, where the `:tag` part of this command is optional.

1. Copy the following `docker push` command, paste it into your terminal, and modify as required before submitting to push your container image as required:

    ```bash
    docker push packages.buildkite.com/{org.slug}/{registry.slug}/package-name:tag
    ```

    where `package-name:tag` is the image name and tag combination you configured in the previous step.

## Access an image's details

A container image's details can be accessed from this registry using the **Packages** section of your container registry page.

To access your container image's details page:

1. Select **Packages** in the global navigation to access the **Registries** page.
1. Select your container registry on this page.
1. On your container registry page, select the image to display its details page.

The image's details page provides the following information in the following sections:

- **Installation** (tab): the [installation instructions](#access-an-images-details-installing-an-image).
- **Contents** (tab, where available): a list of directories and files contained within the image.
- **Details** (tab): a list of checksum values for this image—MD5, SHA1, SHA256, and SHA512.
- **About this version**: a brief (metadata) description about the image.
- **Details**: details about:

    * the name of the image (typically the file name excluding any version details and extension).
    * the image version.
    * the registry the image is located in.
    * the image's visibility (based on its registry's visibility)—whether the image is **Private** and requires authentication to access, or is publicly accessible.
    * the distribution name / version.
    * additional optional metadata contained within the image, such as a homepage, licenses, etc.

- **Pushed**: the date when the last image was uploaded to the registry.
- **Total files**: the total number of files (and directories) within the image.
- **Dependencies**: the number of dependency images required by this image.
- **Package size**: the storage size (in bytes) of this image.
- **Downloads**: the number of times this image has been downloaded.

### Downloading an image

A container image can be downloaded from the image's details page. To do this:

1. [Access the package's details](#access-an-images-details).
1. Select **Download**.

### Installing an image

A container image can be obtained using code snippet details provided on the image's details page. To do this:

1. [Access the image's details](#access-an-images-details).
1. Ensure the **Installation** > **Installation instructions** section is displayed.
1. For each required command in the relevant code snippets, copy the relevant code snippet, paste it into your terminal, and submit it.

The following set of code snippets are descriptions of what each code snippet does and where applicable, its format:

#### Registry configuration

If your registry is _private_ (that is, the default registry configuration), log in to the container registry containing the image to obtain with the following `docker login` command:

```bash
docker login packages.buildkite.com/{org.slug}/{registry.slug} -u buildkite -p registry-read-token
```

where:

<%= render_markdown partial: 'packages/org_slug' %>

<%= render_markdown partial: 'packages/container_registry_slug' %>

- `registry-read-token` is your [API access token](https://buildkite.com/user/api-access-tokens) used to download packages from your container registry. Ensure this access token has the **Read Packages** REST API scope, which allows this token to download packages from any registry your user account has access to within your Buildkite organization.

> 📘
> This step is not required for public container registries.

#### Package installation

Use the following `docker pull` command to obtain the image:

```bash
docker pull packages.buildkite.com/{org.slug}/{registry.slug}/image-name:tag
```

where:

<%= render_markdown partial: 'packages/org_slug' %>

<%= render_markdown partial: 'packages/container_registry_slug' %>

- `image-name` is the name of your image.

- `tag` is the tag associated with this image.
