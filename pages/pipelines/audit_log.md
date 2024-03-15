---
toc: false
---

# Audit log

Audit Log is an interactive track record of all organization activity. This feature is only available to Buildkite customers on the [Enterprise](https://buildkite.com/pricing) plan, and can be found in Organization Settings in the Audit section.

<%= image "audit-log-in-organization-settings.png", width: 1732/2, height: 1431/2, alt: "Audit Log in Organization Settings" %>

Audit Log contains two tabs:

* **Events** - where you see all the events that take place within your Buildkite organization.

<%= image "organization-activity.png", width: 1752/2, height: 1356/2, alt: "Organization activity in Audit Log" %>

* **Query & Export** - where you can query and export your Buildkite organization's Audit Log using [GraphQL API](https://buildkite.com/docs/graphql-api).

<%= image "query-and-export.png", width: 1752/2, height: 1250/2, alt: "Query and export of Audit Log" %>

The following GraphQL `Audit Event` types are available and you can find more details about them in the [GraphQL explorer](https://buildkite.com/docs/apis/graphql-api#getting-started).

```
API_ACCESS_TOKEN_CREATED
API_ACCESS_TOKEN_DELETED
API_ACCESS_TOKEN_ORGANIZATION_ACCESS_REVOKED
API_ACCESS_TOKEN_UPDATED
AGENT_TOKEN_CREATED
AGENT_TOKEN_REVOKED
AUTHORIZATION_CREATED
AUTHORIZATION_DELETED
CLUSTER_CREATED
CLUSTER_DELETED
CLUSTER_PERMISSION_CREATED
CLUSTER_PERMISSION_DELETED
CLUSTER_PERMISSION_UPDATED
CLUSTER_QUEUE_CREATED
CLUSTER_QUEUE_DELETED
CLUSTER_QUEUE_UPDATED
CLUSTER_TOKEN_CREATED
CLUSTER_TOKEN_DELETED
CLUSTER_TOKEN_UPDATED
CLUSTER_UPDATED
NOTIFICATION_SERVICE_BROKEN
NOTIFICATION_SERVICE_CREATED
NOTIFICATION_SERVICE_DELETED
NOTIFICATION_SERVICE_DISABLED
NOTIFICATION_SERVICE_ENABLED
NOTIFICATION_SERVICE_UPDATED
ORGANIZATION_CREATED
ORGANIZATION_DELETED
ORGANIZATION_INVITATION_ACCEPTED
ORGANIZATION_INVITATION_CREATED
ORGANIZATION_INVITATION_RESENT
ORGANIZATION_INVITATION_REVOKED
ORGANIZATION_MEMBER_CREATED
ORGANIZATION_MEMBER_DELETED
ORGANIZATION_MEMBER_UPDATED
ORGANIZATION_TEAMS_DISABLED
ORGANIZATION_TEAMS_ENABLED
ORGANIZATION_UPDATED
PIPELINE_CREATED
PIPELINE_DELETED
PIPELINE_SCHEDULE_CREATED
PIPELINE_SCHEDULE_DELETED
PIPELINE_SCHEDULE_UPDATED
PIPELINE_UPDATED
PIPELINE_VISIBILITY_CHANGED
PIPELINE_WEBHOOK_URL_ROTATED
SCM_PIPELINE_SETTINGS_CREATED
SCM_PIPELINE_SETTINGS_DELETED
SCM_PIPELINE_SETTINGS_UPDATED
SCM_SERVICE_CREATED
SCM_SERVICE_DELETED
SCM_SERVICE_UPDATED
SECRET_CREATED
SECRET_DELETED
SECRET_QUERIED
SECRET_READ
SECRET_UPDATED
SSO_PROVIDER_CREATED
SSO_PROVIDER_DELETED
SSO_PROVIDER_DISABLED
SSO_PROVIDER_ENABLED
SSO_PROVIDER_UPDATED
TEAM_CREATED
TEAM_DELETED
TEAM_MEMBER_CREATED
TEAM_MEMBER_DELETED
TEAM_MEMBER_UPDATED
TEAM_PIPELINE_CREATED
TEAM_PIPELINE_DELETED
TEAM_PIPELINE_UPDATED
TEAM_UPDATED
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

You can also set up [Amazon EventBridge](/docs/integrations/amazon-eventbridge) to stream Audit Log events.


## Audit logs for secrets

>📘 Audit logs for secrets do not contain the value or sensitive information about the secret.


Audit logs record information of transactions in which secrets are accessed or modified. The following events will be logged:

* `SECRET_CREATED` This triggers an audit log when a user of an organization initiates the creation of a secret. Secrets can only be created by a user. Below are the fields captured in the audit log for this event.

  ```
  {
    "data"=> {
      "auditEvent" => {
        "__typename" => "AuditEvent",
        "id" => "QXVkaXRFdmVudC0tLTAxOGUzZjBkLTIwZGUtNDZhZS1iNTMxLTU5NjRkYWJjY2M2Zg==",
        "uuid" => "018e3f0d-20de-46ae-b531-5964dabccc6f",
        "type" => "SECRET_CREATED",
        "subject" => {
          "id" => "QXVkaXRTdWJqZWN0LS0tMDE4ZTNmMGQtMjBkZS00NmFlLWI1MzEtNTk2NGRhYmNjYzZm",
          "type" => "SECRET",
          "uuid" => "3d01f85a-0436-49cd-a082-6f8e20dd677e",
          "node" => {
            "__typename" => "Secret",
            "uuid" => "3d01f85a-0436-49cd-a082-6f8e20dd677e",
            "organization" => {
              "name" => "Sunny Spot"
            }
          }
        }
      }
    }
  }
  ```

* `SECRET_DELETED` This triggers an audit log when a secret is deleted by a user of an organization. This applies exclusively to the destruction of a secret; events related to the revocation or expiration of a secret will not trigger audit logs. Below are the fields captured in the audit log for this event.

```
{
  "data" => {
    "auditEvent" => {
      "__typename" => "AuditEvent",
      "id" => "QXVkaXRFdmVudC0tLTAxOGUzZjE1LTk0OTEtNGJjMS1iOTY4LWNkYTdkMzk2ZDU0MA==",
      "uuid" => "018e3f15-9491-4bc1-b968-cda7d396d540",
      "type" => "SECRET_DELETED",
      "subject" => {
        "id" => "QXVkaXRTdWJqZWN0LS0tMDE4ZTNmMTUtOTQ5MS00YmMxLWI5NjgtY2RhN2QzOTZkNTQw",
        "type" => "SECRET",
        "uuid" => "d83e4f1f-cc26-43d7-8d2c-d303243d87ee",
        "node" => {
          "__typename" => "Secret",
          "uuid" => "d83e4f1f-cc26-43d7-8d2c-d303243d87ee",
          "organization" => {
            "name" => "Sunny Spot"
          }
        }
      }
    }
  }
}
```

* `SECRET_READ` This triggers an audit event when an actor accesses or reads the value of a secret. Secrets can be read by an agent running a compute job, or read by a user belonging to an organization. Below are the fields captured in the audit log for this event.

```
{
  "data" => {
    "auditEvent" => {
      "__typename" => "AuditEvent",
      "id" => "QXVkaXRFdmVudC0tLTAxOGUzZjE5LTlkODgtNDBmZS1iOGIzLTkxMTk5OWNlMmRmMg==",
      "uuid" => "018e3f19-9d88-40fe-b8b3-911999ce2df2",
      "type" => "SECRET_READ",
      "subject" => {
        "id" => "QXVkaXRTdWJqZWN0LS0tMDE4ZTNmMTktOWQ4OC00MGZlLWI4YjMtOTExOTk5Y2UyZGYy",
        "type" => "SECRET",
        "uuid" => "644771e7-10cf-4784-af97-9fdf70402a1c",
        "node" => {
          "__typename" => "Secret",
          "uuid" => "644771e7-10cf-4784-af97-9fdf70402a1c",
          "organization" => {
            "name" => "Sunny Spot"
          }
        }
      }
    }
  }
}
```

* `SECRET_QUERIED` This triggers an audit event when a user belonging to an organization or system identity (such as an agent) when a query is performed to find a secret (or secrets). This event will be triggered even if a search for a secret yields no results or if the secret does not exist. Below are the fields captured in the audit log for this event.

```
{
  "data" => {
    "auditEvent" => {
      "__typename" => "AuditEvent",
      "id" => "QXVkaXRFdmVudC0tLTAxOGUzZjRlLTdiNGUtNDQ1ZS04MDI3LWQyZGU4ZjY3MDI0Yg==",
      "uuid" => "018e3f4e-7b4e-445e-8027-d2de8f67024b",
      "type" => "SECRET_QUERIED",
      "subject" => {
        "id" => "QXVkaXRTdWJqZWN0LS0tMDE4ZTNmNGUtN2I0ZS00NDVlLTgwMjctZDJkZThmNjcwMjRi",
        "type" => "SECRET",
        "uuid" => "d906f471-92a9-4725-aad5-d7388280e654",
        "node" => {
          "__typename" => "Secret",
          "uuid" => "d906f471-92a9-4725-aad5-d7388280e654",
          "organization" => {
            "name" => "Sunny Spot"
          }
        }
      }
    }
  }
}
```

* `SECRET_UPDATED` This triggers an audit event whenever a user within an organization updates the value or properties of a secret. Given that secrets can exist in multiple versions, the audit logs maintain records of these version identifiers and their corresponding updates. Below are the fields captured in the audit log for this event.

```
{
  "data" => {
    "auditEvent" => {
      "__typename" => "AuditEvent",
      "id" => "QXVkaXRFdmVudC0tLTAxOGUzZjUxLWViNTMtNGVlZC1hZmRjLWE2ZTdhZjcyMDFkOQ==",
      "uuid" => "018e3f51-eb53-4eed-afdc-a6e7af7201d9",
      "type" => "SECRET_UPDATED",
      "subject" => {
        "id" => "QXVkaXRTdWJqZWN0LS0tMDE4ZTNmNTEtZWI1My00ZWVkLWFmZGMtYTZlN2FmNzIwMWQ5",
        "type" => "SECRET",
        "uuid" => "87a44525-2a66-441a-89f6-8b559364aed9",
        "node" => {
          "__typename" => "Secret",
          "uuid" => "87a44525-2a66-441a-89f6-8b559364aed9",
          "organization" => {
            "name" => "Sunny Spot"
          }
        }
      }
    }
  }
}
```
