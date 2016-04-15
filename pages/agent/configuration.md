# Buildkite Agent Configuration

Every agent installer comes with a configuration file. You can find the location of your configuration file in your platform’s installation documentation.

<%= toc %>

## Configuration Settings

* `token` - The agent token from your organization’s Agents page
* `name` - The name of the agent - Default: `"%hostname-%n"`
* `priority` - The priority of the agent (higher priorities are assigned work first, null is assigned last) - Default: `null`
* `meta-data` - Meta data for the agent - Default: `"queue=default"`
* `meta-data-ec2-tags` - Populate the meta data from the current instances EC2 Tags - Default: `false`
* `build-path` - Path to where the builds will run from - Default: (depends on platform)
* `hooks-path` - Directory where the global hook scripts are found - Default: (depends on platform)
* `no-pty` - Do not run jobs within a pseudo terminal - Default: `false`
* `no-automatic-ssh-fingerprint-verification` - Do not automatically verify SSH fingerprints for first-time checkouts - Default: `false`
* `no-command-eval` - Do not allow this agent to run arbitrary console commands - Default: `false`
* `debug` - Enable debug mode - Default: `false`
* `no-color` - Do not show colors in logging - Default: `false`

## Example Configuration File

```
token="24db61df8338027652b24aadf82dd483b016eef98fcd332815"
name="my-app-%n"
meta-data="ci=true,docker=true"
debug=true
```