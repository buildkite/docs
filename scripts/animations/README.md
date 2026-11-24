# Dynamic pipeline animations

The two HTML sources use the [animation-hole](https://github.com/buildkite/animation-hole) SVG kit. `dynamic-pipeline.html` shows jobs, matching agents, and two uploads growing one build. `dynamic-pipeline-upload.html` is the supplied generator-output example, showing YAML becoming test steps.

The kit revision used for these exports is [3c07d27](https://github.com/buildkite/animation-hole/commit/3c07d278b1dd185b729b63f32d388263235810ad). Keep its fonts and dependencies in an ignored checkout, not in this repository. From the documentation repository root:

```bash
printf '\n/.amp/in/\n' >> "$(git rev-parse --git-path info/exclude)"
git clone https://github.com/buildkite/animation-hole.git .amp/in/animation-hole
git -C .amp/in/animation-hole checkout 3c07d278b1dd185b729b63f32d388263235810ad
npm --prefix .amp/in/animation-hole/scripts install
npm --prefix .amp/in/animation-hole/scripts run setup
```

Install `ffmpeg` separately. Open either HTML file to preview it. Add `?t=5` to freeze at five seconds. Timings are defined at the top of each animation script.

Before exporting, check the transitions with the kit's layout checker and inspect the resulting stills:

```bash
node .amp/in/animation-hole/scripts/stills.mjs scripts/animations/dynamic-pipeline.html .amp/in/animation-stills 1.35 3.29 3.75 4.75 6.55 7.75 8.09 8.55 9.25 10.5
node .amp/in/animation-hole/scripts/stills.mjs scripts/animations/dynamic-pipeline-upload.html .amp/in/upload-stills 1.35 4.55 6.55 8.05 10.5
```

Export the graph directly to the page's MP4 and PNG assets:

```bash
node .amp/in/animation-hole/scripts/render.mjs scripts/animations/dynamic-pipeline.html --out images/docs/pipelines/configure/dynamic_pipelines --no-stamp --poster 10.5
```

The upload example retains the supplied WebM and PNG. To regenerate them after editing its source, render an intermediate MP4 and convert it:

```bash
node .amp/in/animation-hole/scripts/render.mjs scripts/animations/dynamic-pipeline-upload.html --out .amp/in/animation-renders --no-stamp --poster 10.5
ffmpeg -y -i .amp/in/animation-renders/dynamic-pipeline-upload.mp4 -an -c:v libvpx-vp9 -crf 30 -b:v 0 images/docs/pipelines/configure/dynamic_pipelines/dynamic-pipeline-upload.webm
cp .amp/in/animation-renders/dynamic-pipeline-upload.png images/docs/pipelines/configure/dynamic_pipelines/dynamic-pipeline-upload.png
```

Exports are 1920 pixels wide. If the canvas height changes, update the video's dimensions and PNG fallback dimensions in `pages/pipelines/configure/dynamic_pipelines.md` to match.
