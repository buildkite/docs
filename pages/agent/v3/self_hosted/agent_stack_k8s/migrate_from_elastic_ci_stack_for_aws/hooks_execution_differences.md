# Hook execution differences

The primary migration consideration when migrating from the [Elastic CI Stack for AWS](/docs/agent/v3/self-hosted/aws/elastic-ci-stack) to the Buildkite Agent Stack for Kubernetes ([agent-stack-k8s](https://github.com/buildkite/agent-stack-k8s)), is how agent hooks behave differently in the Kubernetes controller compared to EC2 instances. There is a different execution process unique to the Agent Stack for Kubernetes since the checkout and command phases run in **separate containers**.

### Separate container execution

**Checkout phase hooks** (`pre-checkout`, `checkout`, `post-checkout`):
- Run only in the `checkout` container
- Have access to checkout-phase environment variables
- Can modify files in the workspace (shared with command containers)
- Cannot directly pass environment variables to command containers

**Command phase hooks** (`pre-command`, `command`, `post-command`):
- Run only in the user-defined `command` container(s)
- Do not have access to environment variables set during checkout hooks
- Can access files created by checkout hooks (via shared workspace)

**Environment hook**:
- Runs **multiple times** per job (once per container)
- Executes in the checkout container first
- Executes again in each command container
- Each execution is isolated

> ⚠️ Critical difference from EC2
> Environment variables set during the checkout phase (`pre-checkout`, `checkout`, `post-checkout` hooks) will **not** be available during the command phase (`pre-command`, `command`, `post-command` hooks). This is operationally different from how hooks are [sourced](/docs/agent/v3/hooks#hook-scopes) on EC2-based Elastic CI Stack agents.

### Migration strategies

When migrating hooks that worked on the Elastic CI Stack for AWS, consider these approaches:

#### 1. Sharing environment variables between phases

**On EC2 (works):**
```bash
# .buildkite/hooks/post-checkout
export MY_CUSTOM_VAR="value"

# .buildkite/hooks/pre-command
echo $MY_CUSTOM_VAR  # ✅ Available on EC2
```

**On Kubernetes (does not work as expected):**
```bash
# .buildkite/hooks/post-checkout
export MY_CUSTOM_VAR="value"  # Only available in checkout container

# .buildkite/hooks/pre-command
echo $MY_CUSTOM_VAR  # ❌ Not available in command container
```

**Solution:** Use pipeline-level environment variables or shared files
```bash
# .buildkite/hooks/post-checkout
echo "value" > /workspace/my_custom_var

# .buildkite/hooks/pre-command
MY_CUSTOM_VAR=$(cat /workspace/my_custom_var)
echo $MY_CUSTOM_VAR  # ✅ Works on Kubernetes
```

Or set at pipeline level:
```yaml
steps:
  - label: "My step"
    env:
      MY_CUSTOM_VAR: "value"
    command: echo $MY_CUSTOM_VAR
```

#### 2. Environment hook runs once per container

**On EC2 (runs once per job):**
```bash
# .buildkite/hooks/environment
echo "Running environment hook"  # Prints once

# Logs:
# Running environment hook
```

**On Kubernetes (runs once per container):**
```bash
# .buildkite/hooks/environment
echo "Running environment hook"  # Prints multiple times

# Logs:
# Running environment hook  # <-- checkout container
# Running environment hook  # <-- command container
```

**Solution:** Add guards for operations that should only happen once
```bash
# .buildkite/hooks/environment
if [ "$BUILDKITE_PLUGIN_NAME" = "checkout" ] || [ -z "$BUILDKITE_PLUGIN_NAME" ]; then
  # Only run in checkout container
  echo "Running once in checkout container"
fi
```

#### 3. Checkout skip behavior

When using `checkout: skip: true`:

**On EC2:** Agent hooks still run in the agent process, even when checkout is skipped.

**On Kubernetes:** The checkout container is not created, so:
- Checkout-related hooks do not execute at all
- Only the `environment` hook and command-related hooks run in the command container(s)

**Solution:** If your hooks depend on checkout hooks running, ensure they don't rely on this behavior when checkout is skipped, or move the logic to command-phase hooks.

#### 4. Plugin permission issues with non-root users

**On EC2 (works):**
Plugins run with consistent user permissions throughout the job lifecycle. Command hooks have access to plugin resources without permission conflicts since the agent process runs with the same user context.

**On Kubernetes (permission issues):**
Plugins owned by root in agent-stack-k8s can cause permission issues when command containers run with non-root users. This results in plugin access failures when command-phase hooks attempt to execute or read plugin files.

**Solution:** Adjust file permissions on plugin files to allow non-root users to access them. Set appropriate read and execute permissions to the files at the command container  (e.g., `chmod 755` for directories, `chmod 644` for files, or `chmod 755` for executable scripts).

## Testing your migration

When migrating from Elastic CI Stack to Agent Stack for Kubernetes:

1. **Audit your hooks:** Review all agent hooks and repository hooks for cross-phase dependencies
2. **Test in isolation:** Set up a test cluster with the Agent Stack for Kubernetes
3. **Verify environment variables:** Ensure critical environment variables are set at the pipeline level, not in hooks
4. **Check side effects:** If your `environment` hook has side effects (logging, API calls, counters), ensure they work correctly when run multiple times
5. **Monitor build logs:** Compare build output between EC2 and Kubernetes to identify unexpected behavior

## Additional resources

- [Agent hooks and plugins on Kubernetes](/docs/agent/v3/agent-stack-k8s/agent-hooks-and-plugins)
- [Agent hook execution differences](/docs/agent/v3/agent-stack-k8s/agent-hooks-and-plugins#agent-hook-execution-differences)
- [Buildkite Agent hooks reference](/docs/agent/v3/hooks)
- [Environment variables](/docs/pipelines/configure/environment-variables)
