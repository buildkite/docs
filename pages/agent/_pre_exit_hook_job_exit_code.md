> 🚧 Pre-exit hooks can change the job exit code
> If your `pre-exit` hook can fail, be aware that its exit code will replace the command's exit code as the final job result. This can affect automatic [retry](/docs/pipelines/configure/retry) rules that match on specific exit codes. To avoid this, ensure your `pre-exit` hook exits with code `0`, or handle errors within the hook itself.
