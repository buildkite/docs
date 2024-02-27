# Flaky test assignment

Customers on the [Business and Enterprise plans](https://buildkite.com/pricing) can assign flaky tests to [Teams](/docs/team_management/permissions).

## Assigning a test

To enable assignments you must have at least one team that has access to your suite.

<%= image "flaky-test-no-teams.png", width: 1960/2, height: 630/2, alt: "Flaky test page showing dropdown menu prompting user to create teams" %>
<%= image "team-settings.png", width: 1960/2, height: 630/2, alt: "Team page for assigning test suites" %>

When viewing your flaky tests, you should now see a list of teams with suite access permissions listed inside the assignment dropdown. From here you may assign, reassign or remove the assignment.

_Note_: All team members have the ability to update the assignment, this is not restricted to admins.

Tests that are assigned to a team will update to display a badge indicating as such. This badge is also visible on issues in the run page.

<%= image "flaky-test-teams.png", width: 1960/2, height: 630/2, alt: "Flaky test page showing team assignments" %>

## Viewing assignments

Users who belong to the assigned team can check their assignments by clicking "My Assignments" in the side bar.

They can also view assigned tests that are no longer registering as flaky. As we only detect flaky tests that have occurred in the last 7 days, it is possible for an assignment to remain after a flake has resolved, or a pipeline has not run in more than 7 days. Users can remove the assignment if they suspect it has been resolved.

