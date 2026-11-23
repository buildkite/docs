# Update commit statuses

Recreate the settings screenshot for [Customizing commit statuses](/docs/pipelines/source-control/github#customizing-commit-statuses), following the [shared screenshot guidance](../../../../../styleguides/working-with-docs-site.md#screenshots).

Use a dedicated test organization and a GitHub-linked Buildkite Pipelines pipeline with permission to manage pipeline settings. Choose an existing fixture with **Update commit statuses** selected, **Show blocked builds in GitHub as** set to **Passed**, and the per-job and pull request status settings clear. Do not change or save settings to fit the screenshot.

1. In **Pipelines**, open the pipeline and select **Settings** in its pipeline tabs, then **GitHub**. Find **GitHub Commit Statuses** and expand **Commit statuses** if necessary. Verify the settings and the actual active count.
1. Use Chromium on macOS with its native system typography. Use a 1040 × 720 CSS-pixel viewport, 100% zoom, and pixel density two. Wait for `document.fonts.ready`. Verify that the label and help text render in the native system font (reported as `.SF NS` by Chromium).
1. Position the top of the expanded disclosure at about y=100 CSS pixels. Crop to its full width and height and retain its native padding and a little surrounding background. The reference crop starts at (296, 94) and measures 687 × 495 CSS pixels. Keep the disclosure title, active count, checked box, dropdown, subordinate controls, and their complete help text and callout. Crop out the outer settings card, save button, navigation, and identifying or sensitive fields. Do not hide any elements or add a frame, shadow, or annotations.
1. Capture `update-commit-statuses-on.png` in light mode and `update-commit-statuses-on-dark.png` in dark mode. Use Buildkite's **System** appearance with browser color-scheme emulation (`set media light`, then `set media dark`). Set the preference before fresh navigation and verify the actual product theme. Keep the same state, scroll, viewport, zoom, and crop in both captures.

Accept two 1374 × 990 PNGs with identical content and geometry, intended to display at 687 × 495 CSS pixels. Keep the checked box and its label easy to find and the last line fully visible with breathing room below it. Exclude the pointer, hover or focus styling, and any account or repository identity.
