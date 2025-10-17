# Agent configuration options

> 📘 Minimum version requirement
> To implement the agent configuration options described on this page, version 0.16.0 or later of the Agent Stack for Kubernetes controller is required.

The `agent-config` block within `values.yaml` can be used to set a subset of the [Buildkite Agent configuration](/docs/agent/v3/configuration) options.

```yaml
# values.yaml
config:
  agent-config:
    no-http2: false
    experiment: ["use-zzglob"]
    shell: "/bin/bash"
    no-color: false
    strict-single-hooks: true
    no-multipart-artifact-upload: false
    trace-context-encoding: json
    disable-warnings-for: ["submodules-disabled"]
    no-pty: false
    no-command-eval: true
    no-local-hooks: true
    no-plugins: true
    plugin-validation: false
```

> 📘
> If `no-command-eval` or `no-plugins` are set to `true`, the Kubernetes plugin may still be able to override everything, since it is interpreted by the Agent Stack for Kubernetes controller and not the Buildkite Agent itself.
> To avoid being overridden, the `no-command-eval` or `no-plugins` options should be used together with the [`prohibit-kubernetes-plugin`](/docs/agent/v3/agent-stack-k8s/securing-the-stack) option.

## Pipeline signing

The following sections describe optional methods for implementing pipeline signing with the Buildkite Agent Stack for Kubernetes controller.

### JWKS file configuration containing a signing key

This option applies to the `config.agent-config.verification-jwks-file` file.

Specifies the relative/absolute path of the JWKS file containing a signing key. When an absolute path is provided, this will be the mount path for the JWKS file.

When a relative path (or filename) is provided, this will be appended to `/buildkite/signing-jwks` to create the mount path for the JWKS file.

Default value: `key`.

```
config:
  agent-config:
    signing-jwks-file: key
```

### JWKS signing key ID configuration

This option applies to the `signing-jwks-key-id` configuration parameter.

The value that was provided for `--key-id` during JWKS key pair generation. If you don't specify a `signing-jwks-key-id` in your configuration and your JWKS file contains only one key, then this JWKS file's key will be used.

```
config:
  agent-config:
    signing-jwks-key-id: my-key-id
```

### Volume configuration containing a JWKS signing key

This option applies to the `config/agent-config/signing-jwks-file` configuration parameter.

Creates a Kubernetes volume, which is mounted to the user-defined command containers at the path specified by `config/agent-config/signing-jwks-file`, containing the JWKS signing key data from a Kubernetes Secret.

```
config:
  agent-config:
    signingJWKSVolume:
      name: buildkite-signing-jwks
      secret:
        secretName: my-signing-key
```

### JWKS file configuration containing a verification key

This option applies to the `config/agent-config/verification-jwks-file` configuration parameter.

Specifies the relative/absolute path of the JWKS file containing a verification key. When an absolute path is provided, this will be the mount path for the JWKS file.

When a relative path (or filename) is provided, this will be appended to `/buildkite/verification-jwks` to create the mount path for the JWKS file.

Default value: `key`.

```
config:
  agent-config:
    verification-jwks-file: key
```

### Verification of failure behavior configuration

This option applies to the `config/agent-config/verification-failure-behavior` configuration parameter.

This setting determines the Buildkite Agent's response when it receives a job without a proper signature, and also specifies how strictly the agent should enforce signature verification for incoming jobs.

Valid options are:

- `warn`: The agent will emit a warning about missing or invalid signatures but will still proceed to execute the job.
- `block`: Prevents any job without a valid signature from running, ensuring a secure pipeline environment.

Default value: `block`.

```
config:
  agent-config:
    verification-failure-behavior: warn
```

### Volume configuration containing a JWKS verification key

This option applies to the `config/agent-config/verificationJWKSVolume` configuration parameter.

Creates a Kubernetes Volume, which is mounted to the `agent` containers at the path specified by `config/agent-config/verification-jwks-file`, containing the JWKS verification key data from a Kubernetes Secret.

```
config:
  agent-config:
    verificationJWKSVolume:
      name: buildkite-verification-jwks
      secret:
        secretName: my-verification-key
```
