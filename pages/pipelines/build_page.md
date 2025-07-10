# Build page

Buildkite's new build page has been completely reimagined to support modern software delivery at any scale. The redesigned interface brings powerful navigation through a new sidebar and a detailed table view, making it easier than ever to understand and navigate to any specific aspect of a large build.

## Overview of the new build page with sidebar

<%= image "build_page_screenshot.png", alt: "Screenshot showing the parts of the build page" %>

The new build page consists of three main components:

- A collapsible _sidebar_ to allow for quick navigation between steps in your build.
- The main _content area_ showing your selected view (**Summary**, **Steps**, or **Annotations**).
- A configurable _step panel_ for viewing logs and step information.

## Core actions

### Navigating your build

The _sidebar_ provides a hierarchical view of all steps in your build. Here's how to use it:

- Expand/collapse groups by selecting their arrow icons.
- Group steps by state to see important steps (such as blocked or failed) at the top.
- Select any step to view its details.
- Use the action button (with the curved arrow) or press the `f` key to cycle through failures.
- Use keyword search to quickly open or focus a step.
- Optionally collapse the sidebar to make more room for the content area.

<%= image "build_page_sidebar.png", alt: "Screenshot showing the sidebar" %>

### Searching for steps

Use the search input to find specific steps in your build. Type the name of the step or any relevant keywords, and the sidebar will filter the list to show only steps that match what you've typed.

<%= image "build_step_search.png", alt: "Screenshot showing the search bar" %>

### Viewing step details

When you select a step, its details appear in a resizable step panel. You can:

- Open the step panel on any tab of the build page.
- View **Log**s, **Artifacts**, and **Environment** variables in their respective tabs.
- Drag the panel edge to resize.
- Dock the panel on the right, bottom, or center using the layout toggle.

<%= image "build_page_drawer.png", alt: "Screenshot showing the drawer and positioning buttons" %>

### Managing retries

The sidebar now shows an indicator for steps with retries.

1. Look for the retry indicator in the sidebar.
1. Select the step to view the latest attempt.
1. Use the retry selector to switch between attempts.

You can also access the retried jobs when you open the step details.

### Using the table view

The **Table** view provides a detailed list of all jobs in your build. This view differs from the sidebar view by showing all jobs in the build, not just the steps. The table view displays all individual jobs in your build, while the sidebar collapses parallel jobs into single steps. This makes it ideal for viewing detailed job information.

Here's how to use it:

- Sort steps by selecting the column header (select three times to remove sorting).
- Filter jobs using the state filter.

<%= image "build_table.png", alt: "Screenshot showing the build table" %>

### Browsing your build on mobile

The new build page works fully on all devices. You can use the sidebar to navigate to any step and view its details. On mobile devices, only the **Canvas**, **Table**, and **Waterfall** views are hidden.

### Viewing builds in real time

The build page updates in real time when you follow a build. When you follow a build, you'll focus on active steps as they complete.

Turn on follow mode by pressing `j` when the build is in progress on the canvas view.

> 📘
> Turn on the elevator music for some calming build vibes. Hear your build finish as the music stops.

<%= image "build_page_follow.png", alt: "Screenshot showing the follow mode" %>

## Keyboard shortcuts

The following keyboard shortcuts are currently available:

- `f`: Go to the next failure.
- `j`: Follow the build (for in-progress builds, and only available in the **Canvas** view).
- `esc`: Clear the active step selection.
- `g`: Toggle between collapsing and expanding groups (experimental only).
- `s`: Access step search.

## Tips for large builds

For builds with many steps:

- Use status filtering to focus on specific states.
- Avoid the **Canvas** view on large builds unless you're debugging dependencies between steps.
- Collapse passed and waiting groups to reduce clutter.
- Use browser search to quickly find specific steps (search isn't built in yet).
- Group by state to organize large numbers of steps.

## Best practices

- Keep the sidebar grouped by states and collapse lower priority states such as **Waiting** and **Passed**.
- If the build is in progress, use the `j` key to follow the build. Follow mode will automatically focus you on active steps. You can also enable the music mode.
- Use appropriate views for different tasks:

    * **Canvas**: Understanding build structure and dependencies of specific steps. Be aware that this view is not as useful when zoomed out on a large number of steps.
    * **Table**: Detailed step information when you need to sort by duration or steps alphabetically.
    * **Waterfall**: Timing and performance analysis.
