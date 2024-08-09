# Service quotas

> 📘 Need a limit increased?
> You can request a limit increase by [contacting support](mailto:support@buildkite.com), and providing details about your use case.

## Overview

Service quotas are put in place to ensure that Buildkite can provide a reliable service to all customers. These quotas are all scoped to your organization, but calculated depending on the quota type.
There are three types of quotas: per organization, per build, and per job.

## Per organization quotas

<table>
  <thead>
    <tr>
      <th>Name</th>
      <th style="text-align: right; white-space: nowrap;">Default value</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
        <strong>Number of invitations</strong><br/>
        <i>The maximum number of pending invitations for an organization</i>
      </td>
      <td style="text-align: right;">20</td>
    </tr>
    <tr>
      <td>
        <strong>REST API rate limit</strong><br/>
        <i>The number of requests an organization can make to Organization endpoints on the REST API, per minute</i>
      </td>
      <td style="text-align: right;">200</td>
    </tr>
    <tr>
      <td>
        <strong>Number of Slack services</strong><br/>
        <i>The maximum number of Slack services that can be added to an organization</i>
      </td>
      <td style="text-align: right;">50</td>
    </tr>
    <tr>
      <td>
        <strong>Number of teams</strong><br/>
        <i>The maximum number of teams that an organization can have</i>
      </td>
      <td style="text-align: right;">250</td>
    </tr>
    <tr>
      <td>
        <strong>Number of Webhook services</strong><br/>
        <i>The maximum number of Webhook services that can be added to an organization</i>
      </td>
      <td style="text-align: right;">15</td>
    </tr>
    <tr>
      <td>
        <strong>Artifact retention</strong><br/>
        <i>The maximum time we'll store artifacts for, in days, before assuming it has been deleted by an S3 Lifecycle rule, which must be configured separately</i>
      </td>
      <td style="text-align: right;">180</td>
    </tr>
  </tbody>
</table>

## Per build quotas

<table>
  <thead>
    <tr>
      <th>Name</th>
      <th style="text-align: right; white-space: nowrap;">Default value</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
        <strong>Number of jobs</strong><br/>
        <i>The maximum number of jobs that can be created in a single pipeline build (including job retries)</i>
      </td>
      <td style="text-align: right;">4,000</td>
    </tr>
    <tr>
      <td>
        <strong>Jobs created per pipeline upload</strong><br/>
        <i>The maximum number of jobs that can be created in a single pipeline upload</i>
      </td>
      <td style="text-align: right;">500</td>
    </tr>
    <tr>
      <td>
        <strong>Number of pipeline uploads</strong><br/>
        <i>The maximum number of pipeline uploads that can be performed in a single build</i>
      </td>
      <td style="text-align: right;">500</td>
    </tr>
    <tr>
      <td>
        <strong>Maximum trigger build depth</strong><br/>
        <i>The maximum depth of a chain of trigger builds</i>
      </td>
      <td style="text-align: right;">10</td>
    </tr>
  </tbody>
</table>

## Per job quotas

<table>
  <thead>
    <tr>
      <th>Name</th>
      <th style="text-align: right; white-space: nowrap;">Default value</th>
    </tr>
  </thead>
    <tr>
      <td>
        <strong>Number of artifacts</strong><br/>
        <i>The maximum number of artifacts that can be uploaded to Buildkite per job</i>
      </td>
      <td style="text-align: right;">250,000</td>
    </tr>
    <tr>
      <td>
        <strong>Log size</strong><br/>
        <i>The maximum file-size of a job's log (uploaded by an agent to Buildkite in chunks)</i>
      </td>
      <td style="text-align: right;">1,024 MiB</td>
    </tr>
  </tbody>
</table>
