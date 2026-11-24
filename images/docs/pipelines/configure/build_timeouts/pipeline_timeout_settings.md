# Organization build timeouts

Recreate the organization-level example for [Build timeouts](/docs/pipelines/configure/build-timeouts), following the [shared screenshot guidance](../../../../../styleguides/working-with-docs-site.md#screenshots).

Use an existing development or dedicated integration-test organization where you are an organization administrator. Do not save settings or create builds.

1. Use Chrome for Testing 158 on macOS 27.2 with a 1150 × 1450 CSS-pixel viewport, 100% zoom, and DPR 2. Start in macOS Light with Chrome's `prefers-color-scheme` set to `light`. Verify native Light rendering, wait for `document.fonts.ready`, and verify the UI uses `.SF NS`.
1. Open organization **Settings → Pipelines → Settings**. Note the saved values in **Timeouts**. Enter `60` in **Default command step timeout (minutes)**, `720` in **Maximum command step timeout (minutes)**, and `43200` in **Scheduled job expiry (minutes)**. Leave these examples unsaved.
1. Scroll to the complete **Timeouts** card. Move the pointer outside the crop and clear input focus by clicking blank page space. At scroll (0, 735), crop the viewport from (328, 127), 718 × 469 CSS pixels. If the layout changes, measure the full card border and retain about 8 CSS pixels of surrounding space. Do not edit the page or include surrounding navigation or account details.
1. Convert the crop to sRGB without resampling and save `pipeline_timeout_settings.png`. Leave without saving and reopen **Timeouts** to verify that all three saved values match the starting values. Repeat from fresh navigation in macOS Dark with Chrome's `prefers-color-scheme` set to `dark`. Verify native Dark rendering, save `pipeline_timeout_settings-dark.png`, and check the same saved values again.

Accept two sRGB PNGs at 1436 × 938 pixels, displayed at up to 718 × 469 CSS pixels. Both show the entire native card, all three example values and help descriptions, and **Save Timeout Settings**, with identical geometry. No recoloring, callouts, browser chrome, clipping or identity.
