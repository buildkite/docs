# Agent configuration options

> 📘 Version requirement
> To be able to implement the agent configuration options described below, `v0.16.0` or newer of the controller is required.

The `agent-config` block within `values.yaml` can be used to set a subset of [the agent configuration file options](/docs/agent/v3/configuration).

```yaml
# values.yaml
config:
  agent-config:
    no-http2: false
    experiment: ["use-zzglob", "polyglot-hooks"]
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

Note that even if `no-command-eval` or `no-plugins` is enabled, the Kubernetes plugin may still be able to override everything, since it is interpreted by the stack controller and not the agent. `no-command-eval` or `no-plugins` should be used together with the [`prohibit-kubernetes-plugin`](/docs/agent/v3/agent-stack-k8s/securing-the-stack) option.

## Pipeline signing

The following sections describe optional methods for implementing pipeline signing with the Buildkite Agent Stack for Kubernetes controller.

### JWKS signing file configuration

Applies to `config/agent-config/signing-jwks-file`.

Specifies the relative/absolute path of the JWKS file containing a signing key.
When an absolute path is provided, the will be the mount path for the JWKS file.
When a relative path (or filename) is provided, this will be appended to `/buildkite/signing-jwks` to create the mount path for the JWKS file.

Default value: `key`.

```
config:
  agent-config:
    signing-jwks-key-file: key
```

### JWKS key ID configuration

Applies to the `signing-jwks-key-id` configuration parameter.

The value provided via `--key-id` during JWKS key pair generation.
If not provided and the JWKS file contains only one key, that key will be used.

```
config:
  agent-config:
    signing-jwks-key-id: my-key-id
```

### Signing JWKS volume configuration

Applies to the `config/agent-config/signing-jwks-file` configuration parameter.

Creates a Kubernetes Volume, which is mounted to the user-defined command containers at the path specified by `config/agent-config/signing-jwks-file`, containing JWKS signing key data from a Kubernetes Secret.

```
config:
  agent-config:
    signingJWKSVolume:
      name: buildkite-signing-jwks
      secret:
        secretName: my-signing-key
```

### Verification of JWKS file configuration

Specifies the relative/absolute path of the JWKS file containing a verification key. When an absolute path is provided, the will be the mount path for the JWKS file.

When a relative path (or filename) is provided, this will be appended to `/buildkite/verification-jwks` to create the mount path for the JWKS file.

Default value: `key`.

```
config:
  agent-config:
    verification-jwks-key-file: key
```

### Verification of failure behavior configuration

This setting determines the Buildkite agent's response when it receives a job without a proper signature, and also specifies how strictly the agent should enforce signature verification for incoming jobs.

Valid options are:
- `warn`: The agent will emit a warning about missing or invalid signatures but will still proceed to execute the job.
- `block`: Prevents any job without a valid signature from running, ensuring a secure pipeline environment.

Default value: `block`.

```
config:
  agent-config:
    verification-failure-behavior: warn
```

### Verification of JWKS volume configuration

Creates a Kubernetes Volume, which is mounted to the `agent` containers at the path specified by `config/agent-config/verification-jwks-file`, containing JWKS verification key data from a Kubernetes Secret.

```
config:
  agent-config:
    verificationJWKSVolume:
      name: buildkite-verification-jwks
      secret:
        secretName: my-verification-key
```
