# Build page

Buildkite's new build page has been completely reimagined to support modern software delivery at any scale. The redesigned interface brings powerful navigation through a new sidebar and a detailed table view, making it easier than ever to understand and navigate to any specific aspect of a large build.

## Overview of the new build page with sidebar

<%= image "build_page_screenshot.png", alt: "Screenshot showing the parts of the build page" %>

The new build page consists of three main components:

- A _sidebar_ listing all build steps with **Filter**s at the top.
- The main _content area_ showing your selected view (**Summary**, **Canvas**, **Table**, or **Waterfall**).
- A resizable _step drawer_ for viewing logs and step information.

## Core actions

### Navigating your build

The **sidebar** provides a hierarchical view of all steps in your build. Here's how to use it:

- Expand/collapse groups by selecting the arrow icon.
- Filter steps by status using the status dropdown.
- Group steps by state to see important steps (such as blocked or failed) at the top.
- Click any step to view its details.

<%= image "build_page_sidebar.png", alt: "Screenshot showing the sidebar" %>

### Viewing step details

When you select a step, its details appear in the resizable panel. You can:

1. Drag the panel edge to resize.
1. Switch between side and bottom panel positioning using the layout toggle.
1. View logs, artifacts, and environment variables in their respective tabs.

<%= image "build_page_drawer.png", alt: "Screenshot showing the drawer and positioning buttons" %>

### Managing retries

The **sidebar** now shows an indicator for steps with retries. You can access the retried jobs when you open the step details.

1. Look for the retry indicator in the sidebar.
1. Select the step to view the latest attempt.
1. Use the retry selector to switch between attempts.

### Using the table view

The **Table** view provides a detailed list of all jobs in your build. It differs from the sidebar view by showing all jobs in the build, not just the steps. The table view displays all individual jobs in your build, while the sidebar collapses parallel jobs into single steps. This makes it ideal for viewing detailed job information.

Here's how to use it:

- Sort steps by clicking the column header (click three times to remove sorting).
- Filter steps in the table via the sidebar filter.

### Browsing your build on mobile

The new build page works fully on all devices. You can use the **sidebar** to navigate to any step and view its details. We hide only the **Canvas**, **Table**, and **Waterfall** views on mobile.

### Viewing builds in real time

The build page updates in real time when you follow a build. When you follow a build, you'll focus on active steps as they complete.

Turn on follow mode by pressing `j` when the build is in progress on the canvas view.

> **Tip:** Turn on the elevator music for some calming build vibes. Hear your build finish as the music stops.

<%= image "build_page_follow.png", alt: "Screenshot showing the follow mode" %>

## Keyboard shortcuts

We don't have a keyboard shortcut list on the page yet, but available shortcuts include:

- `f`: Go to next failure.
- `j`: Follow build (for in-progress builds, only on canvas view).
- `esc`: Clear active step selection.
- `g`: Toggle collapse groups (early experiment only).

## Tips for large builds

For builds with many steps:

- Use status filtering to focus on specific states.
- Avoid the **Canvas** view on large builds unless you're debugging dependencies between steps.
- Collapse passed and waiting groups to reduce clutter.
- Use browser search to quickly find specific steps (search isn't built in yet).
- Group by state to organize large numbers of steps.

## Best practices

- Keep the sidebar grouped by states and collapse lower priority states such as Waiting and Passed.
- If the build is in progress, use the `j` key to follow the build. Follow mode will automatically focus you on active steps. Plus, you can enable the music mode.
- Use appropriate views for different tasks:

    * **Canvas**: Understanding build structure and dependencies of specific steps. Not so useful when zoomed out on a large number of steps.
    * **Table**: Detailed step information when you need to sort by duration or steps alphabetically.
    * **Waterfall**: Timing and performance analysis.
