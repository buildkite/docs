# Default GitHub commit status

Recreate the screenshot for [Customizing commit statuses](/docs/pipelines/source-control/github#customizing-commit-statuses), following the [shared screenshot guidance](../../../../../styleguides/working-with-docs-site.md#screenshots).

Use the public [Terminal to HTML pull request](https://github.com/buildkite/terminal-to-html/pull/297) and its [Buildkite Pipelines pipeline](https://buildkite.com/buildkite/terminal-to-html) as the fixture. Requires GitHub browser access. Use the real successful default `buildkite/terminal-to-html` status on the pull request's latest commit. No builds or resource changes are needed; do not fabricate statuses.

1. Open the linked pull request > **Conversation**. Scroll to **Merge info** and select **Expand checks** if collapsed. Verify the successful default `buildkite/terminal-to-html` status is present; report a stale fixture if it is absent or no longer passing. Hide unrelated check rows in the browser DOM so it is the first remaining row. Keep the real Buildkite context, result, passed-build description, and summary count unchanged. Record which rows were hidden.
1. Use light appearance, 100% zoom, a 1280 × 633 CSS-pixel viewport, and a pixel density of two. Wait for the checks and fonts to load.
1. Confirm **All checks have passed**, the actual successful-check count, and a green default `buildkite/terminal-to-html` status with its real passed-build description. The count can change; do not alter it.
1. Position the checks section at approximately x=89, y=240 CSS pixels. Save the viewport as `github-default-status-viewport.png` (2560 × 1266 pixels). Crop the summary and complete first status row, stopping before the next row:

    ```bash
    magick github-default-status-viewport.png -crop 1598x266+178+480 +repage github-default-status.png
    ```

Dark capture applies. Capture light and dark appearances with identical viewport, zoom, scroll position, DOM cleanup, and crop. Use `agent-browser set media light`, then `agent-browser set media dark`; if GitHub overrides the browser preference, use its appearance control too. Save the light image as `github-default-status.png` and the dark image as `github-default-status-dark.png`.

Accept two 1598 × 266 PNGs, displayed at 799 × 133, with identical content and dimensions; only the colors differ. Include the full status row and its lower padding. The success heading, count, green check, full `buildkite/terminal-to-html` context, and passed-build description must be legible. Exclude repository and pull request identity, account details, private data, fixture identifiers, the pointer, tooltips, and clipped text. After hiding unrelated rows, crop only; do not change UI text. If the layout changes, measure the section and first-row bounds again and multiply CSS coordinates by two for both captures.
