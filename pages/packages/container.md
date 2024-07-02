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
    <%= render_markdown partial: 'packages/org_slug' %>
    <%= render_markdown partial: 'packages/container_registry_slug' %>

1. Copy the following `docker tag` command, paste it into your terminal, and modify as required before submitting to tag your container image as required:

    ```bash
    docker tag <tag> packages.buildkite.com/{org.slug}/{registry.slug}/<package name>(:<tag>)?
    ```

    where:
    * `<tag>` is the existing `image-name:tag` combination of your container image name and its current tag to published to your container registry, where the `:tag` component is optional.
    * `<package name>(:<tag>)?` is the image name and tag to provide to this image when it is published to your container registry, where the `(:<tag>)?` part of this command indicates that this is an optional component. This part of the command uses the same `image-name:tag` format.

1. Copy the following `docker push` command, paste it into your terminal, and modify as required before submitting to push your container image as required:

    ```bash
    docker push packages.buildkite.com/{org.slug}/{registry.slug}/<package name>(:<tag>)?
    ```

    where `<package name>(:<tag>)?` is the image name and tag combination you configured in the previous step.

## Access a package's details

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
