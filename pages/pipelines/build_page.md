# Build page

Buildkite's new build page provides a more comprehensive and navigable experience for (enterprise-level?) customers with many, large and complex pipelines, making it easier for you to navigate to any aspect of a complex pipeline being built.

## Overview of the new build page with sidebar

(Screenshot here)

The new build page consists of three main components:

- A sidebar listing all build steps
- The main content area showing your selected view (Canvas, Table, or Waterfall)
- A resizable detail panel for viewing logs and step information

## Core actions

### Navigating your build

The sidebar provides a hierarchical view of all steps in your build. Here's how to use it:

- Expand/collapse groups by clicking the arrow icon
- Filter steps by status using the status dropdown
- Group steps by state to quickly find failed or cancelled steps
- Click any step to view its details

(Screenshot: Sidebar with annotations showing these key interactions)

### Viewing step details

When you select a step, its details appear in the resizable panel. You can:

1. Drag the panel edge to resize
1. Switch between side and bottom panel positioning using the layout toggle
1. View logs, artifacts, and environment variables in their respective tabs

(Screenshot: Detail panel with tabs and resize handle highlighted)

### Working with triggered builds

For steps that trigger other pipelines:

1. Click the trigger step to expand
1. View the downstream build's progress directly in the panel
1. Navigate to the full build by clicking "View Build"

(Screenshot: Expanded trigger step showing downstream build status)

### Managing retries

When a step has been retried:

1. Look for the retry indicator in the sidebar
1. Click the step to view all retry attempts
1. Use the retry selector to switch between attempts
1. Compare logs between retries in the detail panel

(Screenshot: Retry indicator and retry selection UI)

## Keyboard shortcuts

There is not yet a keyboard shortcut list on the page, but common shortcuts include:

- `j`/`k`: Navigate between steps
- `f`: Go to failure
- `j`: Follow build (for in progress builds)
- `esc`: Clear selection
- `G`: toggle collapse groups

## Tips for large builds

For builds with many steps:

- Use status filtering to focus on specific states
- Collapse passed groups to reduce clutter
- Use search to quickly find specific steps
- Group by state to organize large numbers of steps

## Best practices

- Keep the sidebar grouped by states and collapse lower priority states such as Waiting and Passed.
- Use appropriate views for different tasks:

    * Canvas: Understanding build structure and dependencies of specific steps. Not so useful when zoomed out on a large number of steps.
    * Table: Detailed step information when you need to sort by duration or steps alphabetically
    * Waterfall: Timing and performance analysis
