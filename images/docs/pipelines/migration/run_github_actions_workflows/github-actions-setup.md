# GitHub Actions setup screenshot

## Purpose

Show detected workflows and the GitHub Actions pipeline creation option in [Create a GitHub Actions pipeline](/docs/pipelines/migration/run-github-actions-workflows#add-a-github-actions-workflow-to-a-pipeline-create-a-github-actions-pipeline).

## Required state

- Access to an approved development or dedicated test organization with the current pipeline creation interface and permission to create pipelines
- A full-access GitHub repository connection and a repository with three real workflows on its default branch: Docs Lint, iOS Build and Test, and SwiftLint
- No requirement to create a pipeline or provision a webhook just to capture the form

## Capture

1. Open **New Pipeline** and select the connected repository.
1. Keep **Run GitHub Actions workflows on Buildkite** selected and expand the detected workflow count.
1. Frame the workflow names, paths, triggers, **Configure Buildkite pipeline** alternative, and **Create GitHub Actions pipeline** button. Exclude account and repository identifiers. Do not select the create button.
1. Use a desktop viewport, 100% zoom, and a pixel density of two. Preserve the viewport, scroll position, expanded state, and crop for both themes. The existing image is 1480 × 1630 pixels, displayed at 740 × 815.
1. Capture the real light interface using `agent-browser set media light`. If the application's appearance setting overrides the browser, select its light appearance too. Save the crop as `github-actions-setup.png`.
1. Change only appearance using `agent-browser set media dark` and the application's appearance setting if needed. Save the same crop as `github-actions-setup-dark.png`.

## Acceptance and cleanup

Dark capture applies. Both images must show identical labels, values, workflow order, and dimensions. Do not recolor an existing image or change the subject's text. Unrelated UI may be hidden from the DOM; record exactly what was hidden. Do not include credentials or private account names. If the required state is unavailable, request an approved fixture instead of fabricating it.

Record the actual viewport, scroll position, crop coordinates, and any DOM cleanup with the capture evidence. If current UI needs a different crop size or different labels, update both images and the page's display dimensions and alt text together. Leave the form without submitting it. Remove only disposable fixtures created for this capture, if authorized.

## Original source

The existing dark image was extracted from the [published pipeline creation recording](https://www.datocms-assets.com/29977/1791993349-20261014-creating-gha-pipeline.gif). The original method used Pillow to seek a GIF frame, convert it to RGB, crop out account details, and save an optimized PNG. This recording has no light variant; recapture both themes from real UI rather than recoloring its frames.
