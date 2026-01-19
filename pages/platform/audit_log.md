# Audit log

The **Audit Log** is an interactive track record of all organization activity. This feature is only available to Buildkite customers on the [Enterprise](https://buildkite.com/pricing) plan, and can be accessed by Buildkite organization administrators.

> 📘 Audit log storage period
> Audit logs are stored indefinitely and can be accessed in the Buildkite Pipelines web interface for up to 12 months. After 12 months, audit logs can be accessed by using [GraphQL](/docs/apis/graphql-api).

To access the **Audit Log** feature:

1. Select **Settings** in the global navigation to access the [**Organization Settings**](https://buildkite.com/organizations/~/settings) page.

1. Select **Audit** > **Audit Log** to access your organization's [**Audit Log**](https://buildkite.com/organizations/~/audit-log) page.

<%= image "audit-log-in-organization-settings.png", width: 1732/2, height: 1431/2, alt: "Audit Log in Organization Settings" %>

The Audit Log contains two tabs:

- **Events** - lists all the events that take place within your Buildkite organization. Learn more about which events are logged in [Logged events](#logged-events).

    <%= image "organization-activity.png", width: 1752/2, height: 1356/2, alt: "Organization activity in Audit Log" %>

- **Query & Export** - allows you to query and export your Buildkite organization's audit log using [GraphQL API](/docs/graphql-api).

    <%= image "query-and-export.png", width: 1752/2, height: 1250/2, alt: "Query and export of Audit Log" %>

The following GraphQL `Audit Event` types are available and you can find more details about them in the [GraphQL explorer](/docs/apis/graphql-api#getting-started).

## Logged events

This section lists the events that are currently logged by Buildkite.

### Unclustered agent tokens

```
AGENT_TOKEN_CREATED
AGENT_TOKEN_REVOKED
AGENT_TOKEN_UPDATED
```

### Access tokens

```
API_ACCESS_TOKEN_CREATED
API_ACCESS_TOKEN_DELETED
API_ACCESS_TOKEN_ORGANIZATION_ACCESS_REVOKED
API_ACCESS_TOKEN_UPDATED
USER_API_ACCESS_TOKEN_ORGANIZATION_ACCESS_ADDED
USER_API_ACCESS_TOKEN_ORGANIZATION_ACCESS_REMOVED

AUTHORIZATION_CREATED
AUTHORIZATION_DELETED
```

### User account management

```
USER_EMAIL_CREATED
USER_EMAIL_DELETED
USER_EMAIL_MARKED_PRIMARY
USER_EMAIL_VERIFIED

USER_PASSWORD_RESET
USER_PASSWORD_RESET_REQUESTED

USER_TOTP_ACTIVATED
USER_TOTP_CREATED
USER_TOTP_DELETED

USER_UPDATED
```

### Notifications

```
NOTIFICATION_SERVICE_BROKEN
NOTIFICATION_SERVICE_CREATED
NOTIFICATION_SERVICE_DELETED
NOTIFICATION_SERVICE_DISABLED
NOTIFICATION_SERVICE_ENABLED
NOTIFICATION_SERVICE_UPDATED
```

### Organization management

```
ORGANIZATION_CREATED
ORGANIZATION_DELETED
ORGANIZATION_TEAMS_DISABLED
ORGANIZATION_TEAMS_ENABLED
ORGANIZATION_UPDATED

ORGANIZATION_BANNER_CREATED
ORGANIZATION_BANNER_DELETED
ORGANIZATION_BANNER_UPDATED

ORGANIZATION_INVITATION_ACCEPTED
ORGANIZATION_INVITATION_CREATED
ORGANIZATION_INVITATION_RESENT
ORGANIZATION_INVITATION_REVOKED

ORGANIZATION_MEMBER_CREATED
ORGANIZATION_MEMBER_DELETED
ORGANIZATION_MEMBER_UPDATED

ORGANIZATION_BUILD_EXPORT_UPDATED
```

### Buildkite subscriptions

```
SUBSCRIPTION_PLAN_CHANGED
SUBSCRIPTION_PLAN_CHANGE_SCHEDULED

SUBSCRIPTION_PLAN_ADDED
```

### Pipelines

```
PIPELINE_CREATED
PIPELINE_DELETED
PIPELINE_UPDATED
PIPELINE_WEBHOOK_URL_ROTATED

PIPELINE_SCHEDULE_CREATED
PIPELINE_SCHEDULE_DELETED
PIPELINE_SCHEDULE_UPDATED

PIPELINE_TEMPLATE_CREATED
PIPELINE_TEMPLATE_DELETED
PIPELINE_TEMPLATE_UPDATED

PIPELINE_VISIBILITY_CHANGED
```

### Team management

```
TEAM_CREATED
TEAM_DELETED
TEAM_UPDATED

TEAM_MEMBER_CREATED
TEAM_MEMBER_DELETED
TEAM_MEMBER_UPDATED
```

#### For Buildkite Pipelines

```
TEAM_PIPELINE_CREATED
TEAM_PIPELINE_DELETED
TEAM_PIPELINE_UPDATED
```

#### For Buildkite Package Registries

```
TEAM_REGISTRY_CREATED
TEAM_REGISTRY_UPDATED
TEAM_REGISTRY_DELETED
```

#### For Buildkite Test Engine

```
TEAM_SUITE_CREATED
TEAM_SUITE_UPDATED
TEAM_SUITE_DELETED
```

### Single-sign on provider

```
SSO_PROVIDER_CREATED
SSO_PROVIDER_DELETED
SSO_PROVIDER_DISABLED
SSO_PROVIDER_ENABLED
SSO_PROVIDER_UPDATED
```

### Source control management

```
SCM_SERVICE_CREATED
SCM_SERVICE_DELETED
SCM_SERVICE_UPDATED

SCM_REPOSITORY_HOST_UPDATED
SCM_REPOSITORY_HOST_CREATED
SCM_REPOSITORY_HOST_DESTROYED

SCM_PIPELINE_SETTINGS_CREATED
SCM_PIPELINE_SETTINGS_DELETED
SCM_PIPELINE_SETTINGS_UPDATED
```

### Test Engine

```
SUITE_API_TOKEN_REGENERATED_EVENT
SUITE_CREATED
SUITE_DELETED
SUITE_UPDATED
SUITE_VISIBILITY_CHANGED

SUITE_MONITOR_CREATED
SUITE_MONITOR_DELETED
SUITE_MONITOR_UPDATED
```

### Buildkite secrets

```
SECRET_CREATED
SECRET_DELETED
SECRET_QUERIED
SECRET_READ
SECRET_UPDATED
```

### Cluster management

```
CLUSTER_CREATED
CLUSTER_DELETED
CLUSTER_UPDATED

CLUSTER_QUEUE_CREATED
CLUSTER_QUEUE_DELETED
CLUSTER_QUEUE_UPDATED

CLUSTER_TOKEN_CREATED
CLUSTER_TOKEN_DELETED
CLUSTER_TOKEN_UPDATED

CLUSTER_QUEUE_TOKEN_CREATED
CLUSTER_QUEUE_TOKEN_UPDATED
CLUSTER_QUEUE_TOKEN_DELETED

CLUSTER_PERMISSION_CREATED
CLUSTER_PERMISSION_DELETED
```

### Buildkite Package Registries

```
REGISTRY_CREATED
REGISTRY_UPDATED
REGISTRY_DELETED
```

### Other systems

You can also set up [Amazon EventBridge](/docs/pipelines/integrations/observability/amazon-eventbridge) to stream Audit Log events.
