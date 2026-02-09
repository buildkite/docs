# Pipeline signing

> 📘 Minimum version requirement
> To implement the configuration options described on this page, version 0.16.0 or later of the Agent Stack for Kubernetes controller is required.

The Buildkite Agent Stack for Kubernetes controller supports Buildkite's [signed pipelines](/docs/agent/v3/self-hosted/security/signed-pipelines) feature. A JWKS key pair is stored as Kubernetes Secrets and mounted to the `agent` and user-defined command containers.

## Generating a JWKS key pair

Using the `buildkite-agent` CLI, [generate a JWKS key pair](https://buildkite.com/docs/agent/v3/self-hosted/security/signed-pipelines#self-managed-key-creation-step-1-generate-a-key-pair):

```shell
buildkite-agent tool keygen --alg EdDSA --key-id my-jwks-key
```

This will create a pair of files in the current directory:

```
EdDSA-my-jwks-key-private.json
EdDSA-my-jwks-key-public.json
```

## Creating Kubernetes Secrets for a JWKS key pair

After using `buildkite-agent` to generate a JWKS key pair, create a Kubernetes Secret for the JWKS signing key that will be used by user-defined command containers:

```shell
kubectl create secret generic my-signing-key --from-file='key'="./EdDSA-my-jwks-key-private.json"
```

Next, create a Kubernetes Secret for the JWKS verification key that will be used by the `agent` container:

```shell
kubectl create secret generic my-verification-key --from-file='key'="./EdDSA-my-jwks-key-public.json"
```

## Updating the configuration values file

To use the Kubernetes Secrets containing your JWKS key pair, update the `agent-config` of your configuration values YAML file:

```yaml
# values.yaml
config:
  agent-config:
    signing-jwks-file: key
    signing-jwks-key-id: my-jwks-key
    signingJWKSVolume:
      name: buildkite-signing-jwks
      secret:
        secretName: my-signing-key

    verification-jwks-file: key
    verification-failure-behavior: warn # optional, default behavior is 'block'
    verificationJWKSVolume:
      name: buildkite-verification-jwks
      secret:
        secretName: my-verification-key
```

Learn more about configuring JWKS key pairs for signing/verification on the [Agent configuration](/docs/agent/v3/self-hosted/agent-stack-k8s/agent-configuration#pipeline-signing) page.
