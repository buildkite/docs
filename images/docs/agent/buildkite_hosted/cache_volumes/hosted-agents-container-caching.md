# Enable container caching

Recreate the setting shown in [Enabling container cache volumes](/docs/agent/buildkite-hosted/cache-volumes#container-cache-volumes-enabling-container-cache-volumes), following the [shared screenshot guidance](../../../../../styleguides/working-with-docs-site.md#screenshots).

Use an existing cluster with hosted queues in a dedicated integration test organization. You need permission to manage the cluster's cache settings. No builds, provisioning, or saved changes are needed.

1. Use Chrome for Testing 158 on macOS with a 1040 × 720 CSS-pixel viewport, 100% zoom, and pixel density two. Use **System** appearance, set browser color-scheme emulation to light, and verify the product renders in light mode. Wait for `document.fonts.ready` and verify the actual rendered label and help text use the native system font (`.SF NS` in Chromium).
1. Select **Agents** > your cluster > **Cached Storage** > **Settings**. Note the saved values of both checkboxes in **Hosted Queue Cache**. Select **Enable container caching** without saving; if it is already checked, leave it checked. Verify the full help text: “Speed up Docker builds with container caching. Supported on Linux and macOS.” If the UI differs, report the difference rather than editing the text.
1. At scroll y=0, crop the viewport from (290, 369) at 564 × 61 CSS pixels. Keep the checked box, label, and complete help text with balanced padding. Crop out the other checkbox, **Save cache settings**, navigation, and cluster identity. Do not hide or restyle elements. Move the pointer off the subject and clear focus styling.
1. Save `hosted-agents-container-caching.png`. Navigate away without selecting **Save cache settings**, then reopen **Settings** and verify both saved values are unchanged. Repeat from fresh navigation with dark color-scheme emulation, verifying the actual dark product theme, and save `hosted-agents-container-caching-dark.png`. Match the viewport, zoom, scroll, selection, and crop. Verify the saved values again.

Accept two 1128 × 122 PNGs intended to display at 564 × 61 CSS pixels. In both themes, show only the checked control and its complete, legible help. Exclude pointer, hover, focus, and identifying information.
