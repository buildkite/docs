# Troubleshooting the Elastic CI Stack for GCP

Infrastructure as code isn't always easy to troubleshoot, but here are some ways to debug what's going on inside the [Elastic CI Stack for GCP](https://github.com/buildkite/terraform-buildkite-elastic-ci-stack-for-gcp), and some solutions for troubleshooting specific situations and issues.

## Using Cloud Logging

Elastic CI Stack for GCP sends logs to Cloud Logging via the Ops Agent. The following log sources are available:

### Application logs

- Buildkite Agent logs - log name: `buildkite_agent`

  * Contains agent lifecycle events, job execution, and errors
  * Severity levels: `DEBUG`, `INFO`, `WARNING`, `ERROR`, `CRITICAL`
  * View in Logs Explorer: `log_name="projects/PROJECT_ID/logs/buildkite_agent"`

- Docker Daemon logs (if Docker is installed) - log name: `docker`

  * Contains Docker daemon events and errors
  * View in Logs Explorer: `log_name="projects/PROJECT_ID/logs/docker"`

- Preemption Monitor logs - log name: `preemption_monitor`

  * Contains preemptible instance termination handling logs
  * View in Logs Explorer: `log_name="projects/PROJECT_ID/logs/preemption_monitor"`

### System logs

- System messages - log name: `syslog`

  * General system messages and events
  * View in Logs Explorer: `log_name="projects/PROJECT_ID/logs/syslog"`

- Authentication logs - log name: `auth`

  * SSH and authentication events
  * View in Logs Explorer: `log_name="projects/PROJECT_ID/logs/auth"`

### Cloud Initialization logs

- Cloud-init logs - log name: `cloud_init`

  * VM bootstrap process logs
  * View in Logs Explorer: `log_name="projects/PROJECT_ID/logs/cloud_init"`

- Cloud-init output - log name: `cloud_init_output`

  * Output from startup scripts
  * View in Logs Explorer: `log_name="projects/PROJECT_ID/logs/cloud_init_output"`

### Viewing logs in Cloud Console

1. Navigate to **Monitoring** > **Logs Explorer** in the Cloud Console
1. Use filters to view specific logs

View all logs from a specific instance:

```text
resource.type="gce_instance"
resource.labels.instance_id="INSTANCE_ID"
```

View Buildkite agent errors:

```text
resource.type="gce_instance"
log_name="projects/PROJECT_ID/logs/buildkite_agent"
severity >= ERROR
```

View startup script output:

```text
resource.type="gce_instance"
log_name="projects/PROJECT_ID/logs/cloud_init_output"
```

### Viewing logs with gcloud CLI

View recent Buildkite Agent logs:

```bash
gcloud logging read "resource.type=gce_instance AND log_name=projects/PROJECT_ID/logs/buildkite_agent" \
  --limit 50 \
  --format json \
  --project PROJECT_ID
```

View logs from a specific instance:

```bash
gcloud logging read "resource.labels.instance_id=INSTANCE_ID" \
  --limit 100 \
  --freshness 1h \
  --project PROJECT_ID
```

View ERROR-level logs only:

```bash
gcloud logging read "resource.type=gce_instance AND severity>=ERROR" \
  --limit 50 \
  --format json \
  --project PROJECT_ID
```

For more information on logging, see [LOGGING.md](https://github.com/buildkite/terraform-buildkite-elastic-ci-stack-for-gcp/blob/main/LOGGING.md).

## Accessing Elastic CI Stack for GCP instances directly

Sometimes, looking at the logs isn't enough to figure out what's going on in your instances. In these cases, it can be useful to access the shell on the instance directly.

### SSH access (if enabled)

If your Elastic CI Stack for GCP has been configured to allow SSH access (`enable_ssh_access = true`):

```bash
# SSH directly (requires external IP or Cloud NAT)
gcloud compute ssh INSTANCE_NAME --zone ZONE --project PROJECT_ID
```

### Identity-aware proxy (IAP)

If IAP is enabled (`enable_iap_access = true`), you can SSH without external IPs:

```bash
# SSH via IAP tunnel
gcloud compute ssh INSTANCE_NAME \
  --zone ZONE \
  --tunnel-through-iap \
  --project PROJECT_ID
```

Or use the **SSH** button in the Cloud Console:

1. Navigate to **Compute Engine** > **VM instances**
1. Click the **SSH** button next to the instance

### Serial console

For instances that won't boot or are inaccessible:

```bash
# View serial console output
gcloud compute instances get-serial-port-output INSTANCE_NAME \
  --zone ZONE \
  --project PROJECT_ID
```

## Managed instance group fails to boot instances

Resource shortage or configuration errors can cause this issue. Check the managed instance group's Activity log for diagnostics.

### Check instance group status

```bash
gcloud compute instance-groups managed describe INSTANCE_GROUP_NAME \
  --region REGION \
  --project PROJECT_ID
```

### Check for quota issues

```bash
gcloud compute project-info describe --project PROJECT_ID
```

## Instances are abruptly terminated

This can happen when using preemptible instances. GCP sends a notification to a preemptible instance 30 seconds prior to termination. The preemption-monitor service intercepts that notification and attempts to gracefully shut down.

### To identify if your instance was preempted

Check the Cloud Logging for the preemption monitor:

```bash
gcloud logging read "resource.type=gce_instance AND log_name=projects/PROJECT_ID/logs/preemption_monitor" \
  --limit 20 \
  --format json \
  --project PROJECT_ID
```

Look for log lines indicating termination notice:

```text
Received preemption notice for instance INSTANCE_ID
```

## Stacks over-provision agents

If you have multiple stacks, check that they listen to unique queues determined by the `buildkite_queue` variable. Each Elastic CI Stack for GCP you deploy should have a unique value for this parameter. Otherwise, each stack scales out independently to service all the jobs on the queue, but the jobs will be distributed amongst them. This will mean that your stacks are over-provisioned.

This could also happen if you have agents that are not part of an Elastic CI Stack for GCP [started with a tag](/docs/agent/v3/cli-start#tags) of the form `queue=<name of queue>`. Any agents started like this will compete with a stack for jobs, but the stack will scale out as if this competition did not exist.

## Instances fail to boot the Buildkite Agent

Check the managed instance group's activity logs and Cloud Logging for the booting instances to determine the issue. Observe where in the startup script the boot is failing. Identify what resource is failing when the instances are attempting to use it, and fix that issue.

### Check startup script logs

```bash
gcloud logging read "resource.labels.instance_id=INSTANCE_ID AND log_name=projects/PROJECT_ID/logs/cloud_init_output" \
  --limit 100 \
  --format json \
  --project PROJECT_ID
```

## Instances fail jobs

Successfully booted instances can fail jobs for numerous reasons. A frequent source of issues is their disk filling up before the hourly cleanup job fixes it or terminates them.

### Check disk space on an instance

```bash
# SSH into the instance
gcloud compute ssh INSTANCE_NAME --zone ZONE --project PROJECT_ID

# Check disk usage
df -h

# Check inode usage
df -i

# Check Docker disk usage
sudo docker system df
```

### Check Docker cleanup logs

```bash
# View regular cleanup logs
sudo journalctl -u docker-gc.service -n 50

# View emergency cleanup logs
sudo journalctl -u docker-low-disk-gc.service -n 50
```

### Perform a manual cleanup

If an instance has a full disk, you can manually trigger cleanup:

```bash
# Run regular garbage collection
sudo systemctl start docker-gc.service

# Run emergency garbage collection
sudo systemctl start docker-low-disk-gc.service

# Check disk space status
sudo /usr/local/bin/bk-check-disk-space.sh
echo $?  # 0 = healthy, 1 = low disk space
```

## Autoscaling not working

If the managed instance group isn't scaling based on queue depth, you can try the following troubleshooring steps.

### Check if autoscaling is enabled

```bash
gcloud compute instance-groups managed describe INSTANCE_GROUP_NAME \
  --region REGION \
  --project PROJECT_ID
```

### Verify if the buildkite-agent-metrics function is deployed

```bash
gcloud functions list --project PROJECT_ID | grep buildkite-agent-metrics
```

Check if the metrics are being published:

```bash
gcloud monitoring time-series list \
  --filter 'metric.type="custom.googleapis.com/buildkite/scheduled_jobs"' \
  --project PROJECT_ID
```

## Permission errors

If instances can't access resources, start with checking service account permissions:

```bash
gcloud projects get-iam-policy PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:elastic-ci-agent@*"
```

### Common permission issues

1. "Can't access Secret Manager" - enable `enable_secret_access = true`.
1. "Can't access Cloud Storage" - enable `enable_storage_access = true`.
1. "Can't pull Docker images from Artifact Registry" - grant Artifact Registry Reader role.
1. "Can't write logs" - verify that Logs Writer role is assigned.

## Getting help

If you're still stuck after trying the troubleshooting steps suggested above:

1. Check the GitHub repository - [Issues](https://github.com/buildkite/terraform-buildkite-elastic-ci-stack-for-gcp/issues).
1. Email Buildkite Support at [support@buildkite.com](mailto:support@buildkite.com) with:

   * Your stack configuration (redact sensitive values)
   * Relevant Cloud Logging logs
   * Terraform error messages
   * Instance group status and errors

## Additional information

The following GCP documentation resources can help you with the troubleshooting process:

- [Cloud Logging documentation](https://cloud.google.com/logging/docs)
- [Compute Engine troubleshooting](https://cloud.google.com/compute/docs/troubleshooting)
- [Managed instance groups documentation](https://cloud.google.com/compute/docs/instance-groups)
