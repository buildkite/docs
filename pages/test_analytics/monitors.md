# Monitors and alerts

Monitors track what matters to you. They trigger alerts under conditions that you decide.


## Monitors

>🚧 Feature temporarily unavailable
> Monitors and alerts for Test Analytics are unavailable as of right. We are working on this, but do not have a concrete timeline for when it will be released

There are three different types of monitors in Test Analytics:

- **Duration**. Trigger alerts for increases, decreases, or changes compared to a median duration of previous days or runs.
- **Number**. Trigger alerts on consecutive failures of the same test.
- **Reliability**. Trigger alerts when a test drops below your target reliability percentage over a selected number of days or runs.

These can be set to monitor data from all branches, or only your configured default branch.

The number of available monitors depends on your [Buildkite payment plan](https://buildkite.com/pricing). You can configure up to 5 monitors with the Developer Plan and up to 20 with any of the paid plans. (Archived monitors do not count against this limit.)

<%= image "monitors.png", width: 851, height: 559, alt: "Screenshot of monitor settings showing the ability to alert on changes to test duration, reliability, and consecutive failures." %>

## Alerts

When you get an alert from one of your monitors, see

- when it was last seen
- when it was first seen
- how many times it has happened

Mark it as resolved, mute it, or leave it open.

**Added new Features:** web hooks and integrations with platforms such as Slack, GitHub, and issue tracking tools so you can assign ownership of problematic tests, and see alerts in your preferred platform.
