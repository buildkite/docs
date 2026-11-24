# Xcode version screenshot

## Purpose

Show macOS and Xcode image selection in [Generated job requirements](/docs/pipelines/migration/run-github-actions-workflows#requirements-generated-job-requirements).

## Required state

- Access to an approved macOS hosted queue and permission to view its **Base image** settings
- The queue interface offers **Tahoe** and **27** as macOS and Xcode version selections
- No requirement to create a queue, run a build, or save queue settings for this capture

## Capture

1. Open **Agents**, select the macOS queue, and select **Base image**.
1. Show **macOS version** set to **Tahoe (26.6.2)** and **Xcode version** set to **27**. These may be unsaved form selections; do not select **Save base image**.
1. Frame the **Base Image** heading, both version controls, and **Save base image**. Exclude account and queue identifiers outside the subject.
1. Use a 1920 × 1080 CSS pixel viewport, 100% zoom, and a pixel density of two. Keep the scroll position at `(0, 0)` and move the pointer outside the form. Preserve the viewport, scroll position, form selections, and crop for both themes.
1. Capture the real light interface using `agent-browser set media light`. If the application's appearance setting overrides the browser, select its light appearance too. Save the crop as `xcode-version.png`.
1. Change only appearance using `agent-browser set media dark` and the application's appearance setting if needed. Save the same crop as `xcode-version-dark.png`.

Crop each viewport capture with ImageMagick using `-crop 1702x600+1343+458 +repage`. The result is 1702 × 600 pixels, displayed at 851 × 300. At the recorded viewport, the form starts at CSS coordinates `(671.5, 229)` and measures 851 × 298.796875 CSS pixels. If the interface layout changes, measure it again and use one identical crop for both themes rather than including unrelated content to preserve old coordinates.

## Acceptance and cleanup

Dark capture applies. Both images must show identical labels, version selections, and dimensions. Do not change labels or version values in the DOM. Unrelated UI may be hidden from the DOM; record exactly what was hidden. Do not include credentials or private account names.

The current pair was captured from the same unsaved form in system appearance mode. No DOM cleanup, resizing, recoloring, or text changes were applied. Navigating away and reopening the form confirmed that its saved Xcode version remained unchanged. No build was started and no queue setting was saved.

Record any changed capture geometry or DOM cleanup with the capture evidence. If the required versions are unavailable, request an approved fixture or update the page's version example and alt text to match a real supported selection. Update both images and display dimensions together if the crop changes. Leave without saving settings; no shared infrastructure change is authorized by this recipe.

## Original source

The previous dark-only image came from frame 377 of the [published Xcode selection recording](https://www.datocms-assets.com/29977/1791993372-20261014-selecting-xcode-version.gif), cropped to `(1180, 430, 3410, 1390)` in Pillow's left, top, right, bottom coordinates. To reproduce the original extraction, seek the frame with Pillow, convert to RGB, crop, and save an optimized PNG. No UI labels or values were edited. The current light/dark pair replaces that recording frame with real browser captures.
