# Emojis

Buildkite supports over 300 custom emojis that you can use in your Buildkite [pipelines](/docs/pipelines/configure), including the terminal output of builds, as well as in [test suites](/docs/test-engine/test-suites) and [registries](/docs/package-registries/manage-registries).

To use an emoji, write the name of the emoji in between colons, like `\:buildkite\:` which shows up as :buildkite:.

A few common emojis are listed below, but you can see the [full list of available emoji](https://github.com/buildkite/emojis#emoji-reference) on GitHub.

<table>
  <thead>
    <tr>
      <th>Name</th>
      <th>Emoji</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>\:buildkite\:</code></td>
      <td>:buildkite:</td>
    </tr>
    <tr>
      <td><code>\:one-does-not-simply\:</code></td>
      <td>:one-does-not-simply:</td>
    </tr>
    <tr>
      <td><code>\:nomad\:</code></td>
      <td>:nomad:</td>
    </tr>
    <tr>
      <td><code>\:algolia\:</code></td>
      <!-- vale off -->
      <td>:algolia:</td>
      <!-- vale on -->
    </tr>
  </tbody>
</table>

## Adding custom emojis

Add your own emoji by opening a [pull request](https://github.com/buildkite/emojis#contributing-new-emoji) containing a 64x64 PNG image and a name to the emoji repository.

> 🚧 Buildkite emojis in other tools
> Buildkite loads custom emojis as <a href="https://github.com/buildkite/emojis">images</a>. Other tools, such as GitHub, might not display the images correctly, and will only show the `:text-form:`.
