# Workflow jobs screenshot

## Purpose

Show workflow preparation and a generated iOS job in [How workflows run](/docs/pipelines/migration/run-github-actions-workflows#how-workflows-run).

## Required state

- Access to an approved existing successful GitHub Actions workflow build
- A real passed preparation step on `linux-small` and a passed **Build and Test iOS Project** job on `macos-medium`
- Permission to view the jobs and their queue information

## Capture

1. Open the successful build and verify the preparation step and generated iOS job passed. Do not create a new macOS build just to capture the screen without approval.
1. Frame the two job rows with their real status icons, labels, and queue names. Exclude the build header, account and repository identifiers, logs, and unrelated jobs.
1. Use a desktop viewport, 100% zoom, and a pixel density of two. Preserve the viewport, scroll position, collapsed job state, and crop for both themes. The existing image is 1644 × 364 pixels, displayed at 822 × 182.
1. Capture the real light interface using `agent-browser set media light`. If the application's appearance setting overrides the browser, select its light appearance too. Save the crop as `workflow-jobs.png`.
1. Change only appearance using `agent-browser set media dark` and the application's appearance setting if needed. Save the same crop as `workflow-jobs-dark.png`.

## Acceptance and cleanup

Dark capture applies. Both images must show identical jobs, results, labels, queues, and dimensions. Never change a failed result to passed or rename a job in the DOM. Unrelated UI or job rows may be hidden from the DOM; record exactly what was hidden. Do not change summary counts. Do not include credentials or private account names.

Record the actual viewport, scroll position, crop coordinates, and any DOM cleanup with the capture evidence. If no appropriate successful build exists, request an approved fixture rather than fabricating jobs or changing shared infrastructure. If the accepted fixture has different labels or queues, update the page's description and alt text to match. Update display dimensions if the crop changes. Leave the existing build unchanged.

## Original source

The existing dark image came from frame 560 of the [published workflow recording](https://www.datocms-assets.com/29977/1791993397-20261014-running-workflow.gif), cropped to `(280, 356, 1924, 720)` in Pillow's left, top, right, bottom coordinates. To reproduce the original extraction, seek the frame with Pillow, convert to RGB, crop, and save an optimized PNG. No UI labels or values were edited. This recording cannot provide a real light variant.
