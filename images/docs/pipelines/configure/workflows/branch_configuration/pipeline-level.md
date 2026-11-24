# Pipeline-level branch filtering

Recreate the [pipeline-level branch filtering](/docs/pipelines/configure/workflows/branch-configuration#pipeline-level-branch-filtering) example, following the [shared screenshot guidance](../../../../../../styleguides/working-with-docs-site.md#screenshots).

Use an existing GitHub-linked pipeline in a development or dedicated integration-test organization where you can manage pipeline settings. Do not save settings or create builds.

1. Use Chrome for Testing 158 on macOS 27.2 with a 1150 × 1450 CSS-pixel viewport, 100% zoom, and DPR 2. Start in macOS Light with Chrome's `prefers-color-scheme` set to `light`. Verify native Light rendering, wait for `document.fonts.ready`, and verify `.SF NS` for the UI and Monaco for inline code.
1. Open pipeline **Settings → GitHub**. Note the saved **Branch Filter Pattern** in **Branch Limiting**. Enter `main stable-* !unstable` without saving.
1. Scroll to the complete **Branch Limiting** card. Move the pointer outside the crop and clear input focus by clicking blank page space. At scroll (0, 915), crop the viewport from (328, 127), 718 × 332 CSS pixels. If the layout changes, measure the complete card border and leave about 8 CSS pixels of surrounding space. Exclude nearby cards and navigation by cropping only. Do not edit the page.
1. Convert the crop to sRGB without resampling and save `pipeline-level.png`. Leave without saving and reopen **GitHub** to verify that the saved branch pattern matches its starting value. Repeat from fresh navigation in macOS Dark with Chrome's `prefers-color-scheme` set to `dark`. Verify native Dark rendering, save `pipeline-level-dark.png`, and repeat the saved-state check.

Accept two sRGB PNGs at 1436 × 664 pixels, displayed at up to 718 × 332 CSS pixels. Both show the entire native card, help and example, full entered branch pattern, and **Save Branch Limiting**, with identical geometry. No recoloring, callouts, browser chrome, clipping or identity.
