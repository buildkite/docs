# About Honeycomb
[Honeycomb](https://www.honeycomb.io/) is an observability and application performance management (APM) platform.

## Honeycomb and Buildkite

Buildkite is a supported CI platform that can be used with Honeycomb’s Buildevents binary. Buildevents is used to instrument build pipeline systems.

Buildevents is a small binary used to help instrument builds to generate trace telemetry. Typically, it is installed during the setup phase and then invoked as part of each step in a build to capture invocation and output details. The trace generated at the end contains details about what occurred throughout the entire build.

Generated traces contain spans for each section and subsection of the build, with each span representing individual or groups of actual commands that are executed. The duration of each span is how long that stage or specific command took to run. Each span also contains data such as whether or not the command succeeded and any additional data you choose to capture. When your build concludes, this integration ensures your trace is sent to Honeycomb.

You can find more information and get started with Honeycomb through the Honeycomb's [Buildkite Buildevents page](https://www.honeycomb.io/integration/buildkite-buildevents).

## Buildkite markers

Honeycomb [Buildkite Markers](https://www.honeycomb.io/integration/buildkite-markers) indicate points in time on your graphs where interesting things happen, such as deploys.

The Buildkite plugin adds a marker in Honeycomb for actions you want to note in Buildkite.

Markers indicate points in time on your graphs where interesting things happen, such as deploys or outages. You can list, create, update, and delete Markers.

The Buildkite Marker plugin uses the Honeycomb Markers API by running JQ and CURL to create markers. It requires configuration of the fields you will set in your markers.

This plugin is community-contributed (open source).
https://github.com/tendnz/honeymarker-buildkite-plugin
