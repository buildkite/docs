# Hook execution differences

There is a difference in how agent hooks execute in the [Elastic CI Stack for AWS](/docs/agent/v3/self-hosted/aws/elastic-ci-stack) and the Buildkite Agent Stack for Kubernetes ([agent-stack-k8s](https://github.com/buildkite/agent-stack-k8s)). On EC2 instances, all hooks run in a single agent process. On the Agent Stack for Kubernetes, checkout and command phases run in _separate containers_. This separation significantly impacts how hooks can share state and communicate with each other.

## Separate container execution

Hooks are categorized by their lifecycle phase (see [job lifecycle hooks](/docs/agent/v3/self-hosted/hooks#job-lifecycle-hooks)). On the Agent Stack for Kubernetes, they can be categorized as `checkout`, `command` and `environment` hooks. These phases execute in separate containers.

### Checkout phase hooks

Checkout phase hooks (`pre-checkout`, `checkout`, `post-checkout`) run only in the `checkout` container. They have access to checkout-phase environment variables and can modify files in the workspace (shared with command containers). However, environment variables set during this phase cannot be directly passed to command containers.

### Command phase hooks

Command phase hooks (`pre-command`, `command`, `post-command`) run only in the user-defined `command` container(s). They do not have access to environment variables set during checkout hooks, but can access files created by checkout hooks via the shared workspace.

### Environment hook

Environment hook runs _multiple times_ per job (once per container). It executes in the checkout container first, then executes again in each command container. Each execution is isolated.

> 🚧 Critical difference from EC2
> Environment variables set during the checkout phase (`pre-checkout`, `checkout`, `post-checkout` hooks) will _not_ be available during the command phase (`pre-command`, `command`, `post-command` hooks). This is operationally different from how hooks are [sourced](/docs/agent/v3/self-hosted/hooks#hook-scopes) on EC2-based Elastic CI Stack agents.

## Migration strategies

When migrating hooks that worked on the Elastic CI Stack for AWS, consider these approaches:

### 1. Sharing environment variables between phases

On EC2, this approach works:

```bash
# .buildkite/hooks/post-checkout
export MY_CUSTOM_VAR="value"

# .buildkite/hooks/pre-command
echo $MY_CUSTOM_VAR  # ✅ Available on EC2
```

On Kubernetes it does not work as expected:

```bash
# .buildkite/hooks/post-checkout
export MY_CUSTOM_VAR="value"  # Only available in checkout container

# .buildkite/hooks/pre-command
echo $MY_CUSTOM_VAR  # ❌ Not available in command container
```

**Solution:** Use pipeline-level environment variables or shared files:

```bash
# .buildkite/hooks/post-checkout
echo "value" > /workspace/my_custom_var

# .buildkite/hooks/pre-command
MY_CUSTOM_VAR=$(cat /workspace/my_custom_var)
echo $MY_CUSTOM_VAR  # ✅ Works on Kubernetes
```

Or set the variable at pipeline level:

```yaml
steps:
  - label: "My step"
    env:
      MY_CUSTOM_VAR: "value"
    command: echo $MY_CUSTOM_VAR
```

### 2. Environment hook runs once per container

On EC2 the hook runs once per job:

```bash
# .buildkite/hooks/environment
echo "Running environment hook"  # Prints once

# Logs:
# Running environment hook
```

On Kubernetes the hook runs once per container:

```bash
# .buildkite/hooks/environment
echo "Running environment hook"  # Prints multiple times

# Logs:
# Running environment hook  # <-- checkout container
# Running environment hook  # <-- command container
```

**Solution:** Add guards for operations that should only happen once:

```bash
# .buildkite/hooks/environment
if [[ "$BUILDKITE_BOOTSTRAP_PHASES" == *"checkout"* ]]; then
  # Only run in checkout container
  echo "Running once in checkout container"
fi

if [[ "$BUILDKITE_BOOTSTRAP_PHASES" == *"command"* ]]; then
  # Only run in command container
  echo "Running hook in command container"
fi
```

### 3. Checkout skip behavior

When using `checkout: skip: true`:

On EC2 agent, hooks still run in the agent process, even when checkout is skipped.

On Kubernetes, the checkout container is not created, so:

- Checkout-related hooks do not execute at all
- Only the `environment` hook and command-related hooks run in the command container(s)

**Solution:** If your hooks depend on checkout hooks running, ensure they don't rely on this behavior when checkout is skipped, or move the logic to command-phase hooks.

### 4. Plugin permission issues with non-root users

On EC2 plugins run with consistent user permissions throughout the job lifecycle. Command hooks have access to plugin resources without permission conflicts since the agent process runs with the same user context.

On Kubernetes plugins owned by root in the Agent Stack for Kubernetes can cause permission issues when command containers run with non-root users. This results in plugin access failures when command-phase hooks attempt to execute or read plugin files.

**Solution:** Adjust file permissions on plugin files to allow non-root users to access them. Set appropriate read and execute permissions to the files at the command container (for example, `chmod 755` for directories, `chmod 644` for files, or `chmod 755` for executable scripts).

## Testing your migration

When migrating from Elastic CI Stack to Agent Stack for Kubernetes:

1. **Audit your hooks:** Review all agent hooks and repository hooks for cross-phase dependencies.
1. **Test in isolation:** Set up a test cluster with the Agent Stack for Kubernetes.
1. **Verify environment variables:** Ensure critical environment variables are set at the pipeline level, not in hooks.
1. **Check side effects:** If your `environment` hook has side effects (logging, API calls, counters), ensure they work correctly when run multiple times.
1. **Monitor build logs:** Compare build output between EC2 and Kubernetes to identify unexpected behavior.

## Additional resources

- [Agent hooks and plugins on Kubernetes](/docs/agent/v3/self-hosted/agent-stack-k8s/agent-hooks-and-plugins)
- [Agent hook execution differences](/docs/agent/v3/self-hosted/agent-stack-k8s/agent-hooks-and-plugins#agent-hook-execution-differences)
- [Buildkite Agent hooks reference](/docs/agent/v3/self-hosted/hooks)
- [Environment variables](/docs/pipelines/configure/environment-variables)
