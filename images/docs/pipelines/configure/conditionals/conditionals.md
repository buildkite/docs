# Pipeline conditional filtering

Recreate the example for [Conditionals in pipelines](/docs/pipelines/configure/conditionals#conditionals-in-pipelines), following the [shared screenshot guidance](../../../../../styleguides/working-with-docs-site.md#screenshots).

Use an existing GitHub-linked pipeline in a development or dedicated integration-test organization. You need permission to manage the pipeline and a fixture with **Trigger builds after pushing code** already selected. Do not save settings, deliver webhooks or create builds.

1. Use Chrome for Testing 158 on macOS 27.2 with a 1150 × 1450 CSS-pixel viewport, 100% zoom, and DPR 2. Start in macOS Light with Chrome's `prefers-color-scheme` set to `light`. Verify native Light rendering, wait for `document.fonts.ready`, and verify the UI uses `.SF NS`.
1. Open pipeline **Settings → GitHub**. In **GitHub Settings**, note the saved trigger and conditional values. Under **Trigger builds after pushing code**, select **Filter builds using a conditional**, then enter `build.pull_request.base_branch == "main"` without saving.
1. Move the pointer outside the crop and clear input focus by clicking blank page space. At scroll (0, 1297), crop the viewport from (341, 127), 692 × 237 CSS pixels. If the layout changes, measure from the complete push-trigger choice and help through the bottom of the conditional textarea, with about 8 CSS pixels of surrounding space. Exclude other setting groups by cropping only. Do not edit the page.
1. Convert the crop to sRGB without resampling and save `conditionals.png`. Leave without saving and reopen **GitHub** to compare the saved trigger and conditional fields with their starting values. Repeat from fresh navigation in macOS Dark with Chrome's `prefers-color-scheme` set to `dark`. Verify native Dark rendering, save `conditionals-dark.png`, and repeat the saved-state check.

Accept two sRGB PNGs at 1384 × 474 pixels, displayed at up to 692 × 237 CSS pixels. Both show the full selected push trigger, checked conditional, help and exact expression, with identical geometry. No recoloring, callouts, browser chrome, clipping or identity.
