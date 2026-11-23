# Cancel builds for destroyed merge groups

Recreate the setting detail for [Automatic cancellation of redundant builds](/docs/pipelines/tutorials/github-merge-queue#understanding-merge-queue-behavior-automatic-cancellation-of-redundant-builds), following the [shared screenshot guidance](../../../../../styleguides/working-with-docs-site.md#screenshots).

Use a dedicated test organization and an existing GitHub-linked Buildkite Pipelines pipeline with permission to manage pipeline settings. Use a fixture with **Trigger builds after pushing code** selected and all three merge-queue checkboxes clear. No installation changes, webhook changes, or builds are needed.

1. Use Chrome for Testing 158 on macOS with a 1040 × 720 CSS-pixel viewport, 100% zoom, and pixel density two. Wait for `document.fonts.ready`. Verify that the label and help text render in the native system font (reported as `.SF NS` by Chromium).
1. Set browser color-scheme emulation to light before opening the pipeline. Use **System** appearance and verify the product renders in light mode. From the pipeline, select **Settings** in the pipeline tabs, then **GitHub**. Under **Trigger builds after pushing code**, expand **Merge queue checks** and verify all three checkboxes are clear.
1. Select **Build merge queues**, then **Cancel builds for destroyed merge groups** without saving. Leave **Use base commit when making if_changed comparisons** clear.
1. Position the top of the expanded disclosure at y≈100 CSS pixels. The reference scroll position is y=1790; crop the viewport from (344, 367), at 599 × 82 CSS pixels. Keep the checked box, label, and full two-line help text, with balanced space around them. Crop out the parent setting, adjacent option, callouts, navigation, and identifying fields. Do not hide or restyle elements.
1. Save `merge-queue-cancel-builds-setting.png`. Navigate away without saving and reopen **GitHub** to verify all three merge-queue boxes are clear and push triggers are still selected. Repeat from fresh navigation with dark color-scheme emulation, verifying the actual dark product theme, and save `merge-queue-cancel-builds-setting-dark.png`. Use the same viewport, zoom, scroll, crop, and unsaved selections, and verify the same stored state afterward.

Accept two 1198 × 164 PNGs intended to display at 599 × 82 CSS pixels. The only checkbox shown is checked. The help text ends with “merged, removed, or replaced)” and is readable in both themes. Exclude the pointer, hover or focus styling, and any account or repository identity.
