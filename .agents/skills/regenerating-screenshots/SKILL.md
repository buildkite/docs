---
name: regenerating-screenshots
description: Regenerates documentation screenshots from optional Markdown recipes, including matching light and dark captures. Use when creating or replaying screenshot recipes or refreshing recipe-backed images.
---

# Regenerating screenshots

This recipe-based workflow is optional. Other screenshot workflows remain valid.

- Read the [screenshot guide](../../../styleguides/working-with-docs-site.md#screenshot-recipes) and the image's same-name `.md` recipe. If creating a recipe, include the docs section, verified fixture or approved setup, capture geometry, cleanup, acceptance criteria, and whether dark capture applies. Use the [GitHub status recipe](../../../images/docs/pipelines/source_control/github/github-default-status.md) as an example.
- Verify the named fixture's current state before capture. A passing workflow job is not a default Buildkite commit status. If the required state is absent, report the stale fixture or missing access rather than searching unrelated repositories or inventing results.
- Hide unrelated UI in the DOM when the recipe calls for it. Preserve the subject's real labels, results, descriptions, and summary counts. Record the cleanup so another agent can repeat it.
- For theme pairs, capture `foo.png` in light mode and `foo-dark.png` in dark mode with identical viewport, pixel density, zoom, scroll, content, DOM cleanup, and crop. Use `agent-browser set media light`, then `agent-browser set media dark`; account for any application theme override. Both PNGs must have identical even dimensions; only colors differ.
- Inspect the final crops, including full text and lower padding. Update the page's image dimensions and alt text when needed. Preview with the docs theme picker, including explicit choices opposite the operating system theme; the site picker controls which variant readers see.
- Replay a new or changed recipe without earlier capture notes before calling it reproducible. Keep source URLs, commands, measurements, and any deviations as verification evidence; keep private setup details out of the publicly mirrored recipe.
