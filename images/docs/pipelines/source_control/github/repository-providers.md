# GitHub repository provider options

Recreate the provider choices shown in [Connect your Buildkite account to GitHub using the GitHub App](/docs/pipelines/source-control/github#connect-your-buildkite-account-to-github-using-the-github-app), following the [shared screenshot guidance](../../../../../styleguides/working-with-docs-site.md#screenshots).

Use an administrator account in a dedicated Buildkite integration test organization with access to **Repository Providers**. Do not select a provider, connect an account, or install an app.

1. Use Chrome for Testing 158 on macOS with a 1040 × 720 CSS-pixel viewport, 100% zoom, and pixel density two. Use **System** appearance, set browser color-scheme emulation to light, and verify the product renders in light mode. Wait for `document.fonts.ready` and verify the actual rendered heading, labels, and help text use the native system font (`.SF NS` in Chromium).
1. In the organization, select **Settings** > **Repository Providers**. Verify that **Add Provider** offers both **GitHub** and **GitHub (Limited Access)**. The Limited Access description must end with “Works with self-hosted agents only.” If either option is missing, report it and do not capture a substitute.
1. Hide all other rows in **Add Provider** in the browser DOM, leaving the heading, both GitHub rows, and their labels, logos, links, and descriptions unchanged. Do not change **Connected Providers**. Scroll until the top of the **Add Provider** panel is at y=230 CSS pixels. Crop the viewport from (281, 222) at 717 × 195 CSS pixels to include the whole panel with even padding. Move the pointer out of the panel and clear focus styling.
1. Save `repository-providers.png`. Reload to discard the DOM cleanup. Repeat from fresh navigation with dark color-scheme emulation, verifying the actual dark product theme, and save `repository-providers-dark.png`. Use the same viewport, zoom, scroll position relative to the panel, cleanup, and crop. Reload again to restore the original list.

Accept two 1434 × 390 PNGs intended to display at 717 × 195 CSS pixels. The **Add Provider** heading and both rows must be legible, with complete descriptions and the Limited Access restriction. Exclude other providers, connected accounts, organization identity, navigation, the pointer, and hover or focus styling.
