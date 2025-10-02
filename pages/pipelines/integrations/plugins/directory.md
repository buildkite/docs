---
template: "landing_page"
---

# Plugins directory

The _plugins directory_ (also accessible from the main [Buildkite website](https://buildkite.com/resources/plugins)), allows you to discover and find all plugins maintained by Buildkite, as well as those from third-party developers.

Once you have [created your own plugin](/docs/pipelines/integrations/plugins/writing), you can add it to this directory. Learn more about this below in [Adding your plugin](#adding-your-plugin).

<a class="Frameheader" href='https://buildkite.com/resources/plugins' target='_blank'>
  <span class="Frameheader__address">buildkite.com/resources/plugins</span>
</a>
<iframe
  src='https://buildkite.com/resources/plugins/embed'
  referrerPolicy='same-origin'
  allow="fullscreen" crossorigin="anonymous" width="100%" height="800px"
  style="border-radius:0 0 8px 8px;box-sizing: border-box;"
/>

Plugins supported by the Buildkite team display the Buildkite logo in the directory, and can be found in the [Buildkite Plugins GitHub organization](https://github.com/buildkite-plugins).

## Adding your plugin

To add your plugin to the plugins directory:

1. Host your plugin in GitHub as a public repository.
1. Ensure your repository contains a valid `plugin.yml` file containing at least the `name` and `description` fields.
1. Add the `buildkite-plugin` [GitHub repository topic](https://help.github.com/en/github/administering-a-repository/classifying-your-repository-with-topics).
1. Wait until the next Sunday (UTC) for the plugins directory to sync with GitHub, and for your plugin to appear.

For example:

<%= image "github-topic.png", width: 1214/2, height: 440/2, alt: "Screenshot of the ECR plugin GitHub repo with the Buildkite-plugin topic highlighted by a red box" %>

Once completed, your plugin will appear in the directory:

<%= image "ecr-plugin-directory-item.png", width: 1014/2, height: 500/2, alt: "Screenshot of ECR plugin in the Buildkite plugins directory" %>

> 🚧
> If you've completed the above steps and your plugin doesn't appear in the directory, send an email to <a href="mailto:support@buildkite.com">support@buildkite.com</a> and we'll investigate it for you.
