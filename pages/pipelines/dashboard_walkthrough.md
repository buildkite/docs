# Dashboard walkthrough

Once you've set up a few pipelines and have run some builds, you can see an overview of them on the dashboard. Each pipeline has a set of metrics to give you an overview of its health and performance.

<%= image "pipelines.png", width: 2028/2, height: 880/2, alt: "Screenshot of an example pipelines page" %>

## Pipeline status

A visual indication of your pipeline's current status. This icon is based on the latest build on your default branch.

<%= image "build-status.png", width: 2028/2, height: 880/2, alt: "Screenshot of the pipeline status icon" %>

## Build history

The build history visualizes the last 30 builds that have been run on your default branch. The height of each bar reflects the build's running time, and its status is represented by its colour and in the tooltip on hover.

<%= image "graphs.png", width: 2028/2, height: 880/2, alt: "Screenshot of the build history visualization" %>

## Speed

The speed of your pipeline is calculated from the average of your 30 most recent builds. This helps you keep an eye on your pipeline's speed, and compare performance between pipelines.

<%= image "speed.png", width: 2028/2, height: 880/2, alt: "Screenshot of the build speed metric" %>

## Reliability

The reliability of your pipeline is a calculation based on passing vs failing builds over the last 30 days. This metric helps you to understand the overall stability of your pipelines.

<%= image "reliability.png", width: 2028/2, height: 880/2, alt: "Screenshot of the build reliability metric" %>

## Builds per week

The builds per week measurement is calculated based on the average number of builds created over the past 4 weeks. This metric helps you to understand how frequently a pipeline is run.

<%= image "frequency.png", width: 2028/2, height: 880/2, alt: "Screenshot of the builds per week metric" %>

## Starring pipelines

You can keep your most used pipelines at the top of the page by clicking the star on the far right of any pipeline 🌟🔝

<%= image "favorite.png", width: 2028/2, height: 880/2, alt: "Screenshot of the pipeline star button" %>

## Filtering pipelines

You can filter pipelines using the search bar at the top of the page. This will search the titles of pipelines, and return all those matching your search terms.

<%= image "filtering-pipelines.png", width: 2028/2, height: 880/2, alt: "Screenshot of the filtering text input field" %>

If your organization has Teams enabled, you can also filter this page by the teams that you're in. When you have more than one team attached to your Buildkite account, you'll see a dropdown list of teams at the top of the dashboard. This defaults to 'All Teams'. Selecting a specific team will filter the list of pipelines to display only those accessible by the selected team.

## Customizing the page

Your pipeline's name, description, its repository, and your default branch are all editable. After you've clicked on a pipeline, the settings button is in the top right corner.

<%= image "settings.png", width: 2028/2, height: 880/2, alt: "Screenshot of the pipelines settings button" %>

The display settings can be found in the `Pipeline Settings` section. Adding a description for your pipeline is optional, but name, repository, and default branch are all required. Descriptions also have full emoji support 🙌:llama:💯

## Pipeline page

Clicking through to a pipeline page shows the [build history](#build-history) for that pipeline, your starred branches, and the ten most recently built branches for that pipeline.

<%= image "pipelines-detail.png", width: 2048/2, height: 880/2, alt: "Screenshot of the pipelines settings page" %>

## Build page

Clicking through to a build page shows the full list of jobs and other steps in that build, the information about who triggered the build, and the controls for rebuilding or cancelling the build while it's in progress.

On the build page, you can also view _All Builds_, _Edit Steps_ in the current build, open _Pipeline Settings_, or start a _New Build_.

<%= image "inside-build-page.png", width: 2028/2, height: 880/2, alt: "Inside the build page" %>

You can expand the _All Builds_ menu to view _Recent_, _Running_, _Scheduled_, or _All Recent Builds_.

<%= image "all-builds.png", width: 2028/2, height: 880/2, alt: "Screenshot of the All Builds dropdown menu" %>

Each job in a build has a footer that displays the job exit status, which provides more visibility into the outcome of each job. It helps you to diagnose failed builds by finding issues with agents and pipelines.

Job exit status may include the exit signal reason, which indicates whether the Buildkite agent stopped or the job was cancelled.

<%= image "exit-status.png", width: 2048/2, height: 880/2, alt: "Exit status of a job" %>

If you want to access the exit status through an API, it's only available in the [GraphQL API](/docs/apis/graphql-api).

## Supported browsers

Buildkite Pipelines is designed with the latest web browsers in mind. For the sake of security and providing the best experience to most customers, we do not support browsers that are no longer receiving security updates and represent a small minority of traffic.

We support the latest two stable versions of the following desktop browsers:

- [Google Chrome](https://www.google.com/chrome/)
- [Mozilla Firefox](https://mozilla.org/firefox)
- [Apple Safari](https://www.apple.com/safari/)
- [Microsoft Edge](https://www.microsoft.com/en-us/edge)

Browsers not listed as supported or in beta or developer builds may not work as you expect, or at all. For the best experience, we recommend using the latest version of a supported browser.

All versions of Internet Explorer are not supported, and we recommend you migrate to a modern browser.

If you encounter any issues with Buildkite Pipelines on a supported browser, please [contact us](https://buildkite.com/support) so we can improve its support.
