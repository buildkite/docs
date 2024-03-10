# Flaky test assignment

Customers on the [Pro and Enterprise plans](https://buildkite.com/pricing) can assign flaky tests to [Teams](/docs/team_management/permissions).

## Enabling flaky test assignments

To enable assignments, you must have at least one team that has access to your suite. You may need to ask your admin to enable the teams feature, and then create teams via the organization settings page.

<%= image "flaky-test-no-teams.png", width: 1960/2, height: 630/2, alt: "Flaky test page showing dropdown menu prompting user to create teams" %>
<%= image "team-settings.png", width: 1960/2, height: 630/2, alt: "Team page for assigning test suites" %>

## Assigning a test

When viewing your flaky tests, you should now see a list of teams with suite access permissions listed inside the assignment dropdown. From here you may assign, reassign or remove the assignment.

>🚧 Assignment permissions
> All team members have the ability to create, update or remove an assignment, this feature is not restricted to admins.

Tests that are assigned to a team will update to display a badge indicating as such. This badge is also visible on issues in the run page.

<%= image "flaky-test-teams.png", width: 1960/2, height: 630/2, alt: "Flaky test page showing team assignments" %>

## Viewing assignments

Users can check their test assignments by clicking _My Assignments_ in the side bar.

<%= image "current-assignments.png", width: 1960/2, height: 630/2, alt: "Flaky test page showing team assignments" %>

When an assigned test has not flaked in more than 7 days, it is moved to the "Stale assignment" section. An assignment could become stale due to a flaky test being fixed, or perhaps it belongs to a pipeline which has not had a build in the last 7 days. Should the flake reoccur, the assignment will be moved back to the "Current assignments" page.

<%= image "stale-assignments.png", width: 1960/2, height: 630/2, alt: "Flaky test page showing team assignments" %>

