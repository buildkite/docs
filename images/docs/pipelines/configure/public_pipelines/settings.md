# Pipeline visibility settings

Recreate the **Pipeline Management** card for [Public pipelines](/docs/pipelines/configure/public-pipelines#make-a-pipeline-public-using-the-ui), following the [shared screenshot guidance](../../../../../styleguides/working-with-docs-site.md#screenshots).

Use an existing private pipeline in a development or dedicated integration-test organization that allows public pipelines. You need access to manage the pipeline. Do not change its visibility or other settings.

1. Use Chrome 156 on macOS 27.2 at 100% zoom and DPR 2. Set the viewport to 1300 × 950 CSS pixels. Start in macOS Light with Chrome's `prefers-color-scheme` set to `light`. Use the product's native theme, wait for `document.fonts.ready`, and verify that the heading renders in `.SF NS`.
1. Open the pipeline's **Settings** > **General** page. Find **Pipeline Management** and verify that **Make public on the internet** is available. Leave all controls untouched.
1. At scroll (0, 861), crop from (351, 494), 872 × 275 CSS pixels. If the layout differs, measure the entire card border and leave about 10 CSS pixels around it. Move the pointer outside the crop. Keep the full visibility warning and the archive and delete rows. Exclude navigation and account or pipeline identity without editing the page.
1. Save the crop without resampling as `settings.png` in sRGB. Repeat from fresh navigation with macOS Dark and Chrome's `prefers-color-scheme` set to `dark`. Verify native dark rendering and save `settings-dark.png` with the same frame. Reopen **General** and verify that **Make public on the internet** is still available.

Accept two 1744 × 550 sRGB PNGs, displayed at up to 872 × 275 CSS pixels. Both show the full card, complete help text, and all three controls with identical framing. No browser chrome, callouts, clipping, or identity.
