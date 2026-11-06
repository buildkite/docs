You can run as many parallel agent workers on the one machine as you wish with
the `spawn` configuration setting, or by passing the `--spawn` flag.

```ini
# Start 5 workers. Each one independently fetches and executes jobs.
spawn=5
```

All workers on a host share its CPU, memory, and disk space. To limit these resources, or to give each agent its own limits, see [Resource controls](/docs/agent/self-hosted/resource-controls).
