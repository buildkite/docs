---
template: "landing_page"
---

# Plugins directory

Use the [Buildkite plugins directory](https://buildkite.com/resources/plugins/) to search for plugins maintained by Buildkite and third-party developers. You can also [browse the categorized plugin listing in Markdown](https://buildkite.com/resources/plugins.md).

Browse a category:

- [Official Buildkite plugins](https://buildkite.com/resources/plugins/category/official/)
- [Deploy](https://buildkite.com/resources/plugins/category/deploy/)
- [Notify](https://buildkite.com/resources/plugins/category/notify/)
- [Observability](https://buildkite.com/resources/plugins/category/observability/)
- [Security and compliance](https://buildkite.com/resources/plugins/category/security-compliance/)
- [Secrets](https://buildkite.com/resources/plugins/category/secrets/)
- [Artifacts](https://buildkite.com/resources/plugins/category/artifacts/)
- [Packages](https://buildkite.com/resources/plugins/category/packages/)

Once you have [created your own plugin](/docs/pipelines/integrations/plugins/writing), you can also [add it to the plugins directory](/docs/pipelines/integrations/plugins/writing#publish-to-the-buildkite-plugins-directory).

<% unless request.format.md? %>
<div>
  <a class="Frameheader" href="https://buildkite.com/resources/plugins/" target="_blank">
    <span class="Frameheader__address">buildkite.com/resources/plugins</span>
  </a>
  <iframe
    src="https://buildkite.com/resources/plugins/embed/"
    title="Buildkite plugins directory"
    referrerpolicy="same-origin"
    allow="fullscreen" crossorigin="anonymous" width="100%" height="800px"
    style="border-radius:0 0 8px 8px;box-sizing: border-box;"
  ></iframe>
</div>
<% end %>

Plugins supported by the Buildkite team display the Buildkite logo in the directory, and can be found in the [Buildkite Plugins GitHub organization](https://github.com/buildkite-plugins).

For the instructions on writing and adding your plugin to the Buildkite plugins directory, see [Writing plugins](/docs/pipelines/integrations/plugins/writing).
