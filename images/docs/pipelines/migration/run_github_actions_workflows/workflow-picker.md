# Workflow picker screenshot

## Purpose

Show workflow names and paths beside **Run workflow** in [Run a workflow manually](/docs/pipelines/migration/run-github-actions-workflows#add-a-github-actions-workflow-to-a-pipeline-run-a-workflow-manually).

## Required state

- Access to an approved GitHub Actions pipeline that has not run its first build
- A connected repository with real Docs Lint, iOS Build and Test, and SwiftLint workflows, with matching default-branch triggers
- Permission to view the pipeline and open its workflow selector

## Capture

1. Open the pipeline's first-build page and expand **Workflow**.
1. Frame the three workflow names and file paths with the **Run workflow** button. Exclude account and repository identifiers. Do not run a workflow for this capture.
1. Use a desktop viewport, 100% zoom, and a pixel density of two. Preserve the viewport, scroll position, open selector, pointer position, and crop for both themes. The existing image is 1250 × 500 pixels, displayed at 625 × 250.
1. Capture the real light interface using `agent-browser set media light`. If the application's appearance setting overrides the browser, select its light appearance too. Save the crop as `workflow-picker.png`.
1. Change only appearance using `agent-browser set media dark` and the application's appearance setting if needed. Reopen the selector if necessary without changing its selection. Save the same crop as `workflow-picker-dark.png`.

## Acceptance and cleanup

Dark capture applies. Both images must show identical workflow names, paths, order, selection, and dimensions. Preserve real labels; do not rename unrelated workflows in the DOM to match this example. Unrelated UI may be hidden from the DOM; record exactly what was hidden. Do not include credentials or private account names.

Record the actual viewport, scroll position, crop coordinates, and any DOM cleanup with the capture evidence. If an appropriate existing fixture has different workflows, update both images and the page's alt text together. Update display dimensions if the crop changes. Close the selector without starting a build. Remove only disposable fixtures created for this capture, if authorized.

## Original source

The existing dark image came from frame 40 of the [published workflow recording](https://www.datocms-assets.com/29977/1791993397-20261014-running-workflow.gif), cropped to `(1280, 1440, 2530, 1940)` in Pillow's left, top, right, bottom coordinates. To reproduce the original extraction, seek the frame with Pillow, convert to RGB, crop, and save an optimized PNG. No UI labels or values were edited. This recording cannot provide a real light variant.
