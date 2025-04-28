# Emojis

Buildkite supports over 300 custom emojis that you can use in your Buildkite [pipelines](/docs/pipelines/configure), including the terminal output of builds, as well as in [test suites](/docs/test-engine/test-suites) and [registries](/docs/package-registries/manage-registries).

To use an emoji, write the name of the emoji in between colons, like `\:buildkite\:` which shows up as :buildkite:.

Explore the full list of Buildkite-specific emojis below or at [emoji.buildkite.com](https://emoji.buildkite.com):

<a class="Frameheader" href='https://emoji.buildkite.com' target='_blank'>
  <span class="Frameheader__address">emoji.buildkite.com</span>
</a>
<iframe
  src='https://emoji.buildkite.com'
  allow="fullscreen" crossorigin="anonymous" width="100%" height="400px"
  style="border-radius:0 0 8px 8px;box-sizing: border-box;"
/>

You can also use other emojis, listed from the [Smileys & Emotion](https://github.com/buildkite/emojis?tab=readme-ov-file#smileys--emotion) section onwards of the [Buildkite emojis README in GitHub](https://github.com/buildkite/emojis#heartpurple_heartblue_heartgreen_heartyellow_heart-buildkite-emojis-yellow_heartgreen_heartblue_heartpurple_heartheart), which contains the full list of emojis available to the Buildkite platform.

## Adding custom emojis

Add your own emoji by opening a [pull request](https://github.com/buildkite/emojis#contributing-new-emoji) containing a 64x64 PNG image and a name to the emoji repository.

> 🚧 Buildkite emojis in other tools
> Buildkite loads custom emojis as <a href="https://github.com/buildkite/emojis">images</a>. Other tools, such as GitHub, might not display the images correctly, and will only show the `:text-form:`.
