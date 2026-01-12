# Signed pipelines

Signed pipelines are a security feature where pipelines are cryptographically signed when uploaded to Buildkite. Agents then verify the signature before running the job. If an agent detects a signature mismatch, it'll refuse to run the job.

Maintaining a strong security boundary is important to Buildkite and informs how we design features. It's also a key reason people choose Buildkite over other CI/CD tools. Signing pipelines improves your security posture by ensuring agents don't run jobs where a malicious actor has modified the instructions. This moves you towards zero-trust CI/CD by further isolating you from Buildkite itself being compromised.

The signature guarantees the origin of jobs by asserting:

- The jobs were uploaded from a trusted source.
- The jobs haven't been modified after upload.

These signatures mean that if a threat actor could modify a job in flight, the agent would refuse to run it due to mismatched signatures.

<details>
  <summary>🤔 I think I've seen this before...</summary>
  <p>This work is inspired by the <a href="https://github.com/buildkite/buildkite-signed-pipeline"><code>buildkite-signed-pipeline</code></a> tool, which you could add to your agent instances. It had a similar idea—signing steps before they're uploaded to Buildkite, then verifying them when they're run. However, it had some limitations, including:</p>
  <ul>
    <li>It had to be installed on every agent instance, leading to more configuration.</li>
    <li>It only supported symmetric signatures (using HMAC-SHA256), meaning that every verifier could also sign uploads.</li>
    <li>It couldn't sign <a href="/docs/pipelines/configure/workflows/build-matrix">matrix steps</a>.</li>
  </ul>
  <p>This newer version of pipeline signing is built right into the agent and addresses all of these limitations. Being built into the agent, it's also easier to configure and use.</p>
  <p>Many thanks to <a href="https://www.seek.com.au/">SEEK</a>, who we collaborated with on the older version of the tool, and whose prior art has been instrumental in the development of this newer version.</p>
</details>

## Pipeline signatures

Pipeline signatures establish that important aspects of steps haven't been changed since they were uploaded.

The following fields are included in the signature for each step:

- **Commands.**
- **Environment variables defined in the pipeline YAML.** Environment variables set by the agent, hooks, or the user's shell are _not_ signed, and can override the environment a step's command is started with.
- **Plugins and plugin configuration.**
- **Matrix configuration.** The matrix configuration is signed as a whole rather than each individual matrix job. This means the signature is the same for each job in the matrix. When signatures are verified for matrix jobs, the agent double-checks that the job it received is a valid construction of the matrix and that the signature matches the matrix configuration.
- **The repository the commands are running in.** This prevents you from copying a signed step from one repository to another.

> 📘 Compatibility with pipeline templates
> [Pipeline templates](/docs/pipelines/governance/templates) are designed to be used across multiple pipelines and therefore, repositories. Due to the inclusion of repositories in step signatures, signed steps cannot be used with pipeline templates.

## Enabling signed pipelines on your agents

You'll need to configure your agents and update pipeline definitions to enable signed pipelines.

Behind the scenes, signed pipelines use [JSON Web Signing (JWS)](https://datatracker.ietf.org/doc/html/rfc7797) to generate signatures. There are two options for creation of keys used with JWS, these are:

- Self managed key pairs
- AWS KMS managed keys

## Self-managed key creation

You'll need to generate a [JSON Web Key Set (JWKS)](https://datatracker.ietf.org/doc/html/rfc7517) to sign and verify your pipelines with, then configure your agents to use those keys.

### Step 1: Generate a key pair

Luckily, the agent has you covered! A JWKS generation tool is built into the agent, which you can use to generate a key pair. To use it, you'll need to [install the agent on your machine](/docs/agent/v3/self-hosted/install), and then run:

```bash
buildkite-agent tool keygen --alg <algorithm> --key-id <key-id>
```

Replacing the following:

- `<algorithm>` with the signing algorithm you want to use.
- `<key-id>` with the key ID you want to use.

Note that both the algorithm and key ID are optional - if `alg` isn't provided, the agent will default to `EdDSA`. If `key-id` isn't provided, the agent will generate a random one for you.

For example, to generate an [EdDSA](https://en.wikipedia.org/wiki/EdDSA) key pair with a key ID of `my-key-id`, you'd run:

```bash
buildkite-agent tool keygen --alg EdDSA --key-id my-key-id
```

The agent generates a JWKS key pair in your current directory: one private and one public. You can then use these keys to sign and verify your pipelines.

Note that the value of `--alg` must be a valid [JSON Web Signing Algorithm](https://datatracker.ietf.org/doc/html/rfc7518#section-3), and that the agent does not support all JWA signing algorithms. At the time of writing, the agent supports:

- `EdDSA` (the default)
- `PS512`
- `ES512`

For an up-to-date list of supported algorithms, run:

```sh
buildkite-agent tool keygen --help
```

Also note that the `PS512` and `ES512` algorithms are nondeterministic, which means that they will generate different signatures each time they are used. This feature can be desirable for dynamically generated pipelines, but may make it difficult to detect drift when the signed result is persisted—for example, when using the [Terraform provider](https://registry.terraform.io/providers/buildkite/buildkite/latest/docs/data-sources/signed_pipeline_steps).

<details>
  <summary>Why doesn't the agent support RSASSA-PKCS1 v1.5 signatures?</summary>
  <p>In short, RSASSA-PKCS1 v1.5 signatures are less secure than the newer RSA-PSS signatures. While RSASSA-PKCS1 v1.5 signatures are still relatively secure, we want to encourage our users to use the most secure algorithms possible, so when using RSA keys, we only support RSA-PSS signatures. We also recommend looking into ECDSA and EdDSA signatures, which are more secure than RSA signatures.</p>
</details>

#### Algorithm options

When using signed pipelines, we recommend having multiple disjoint pools of agents, each using a different [queue](/docs/agent/v3/targeting/queues). One pool should be the _uploaders_ and have access to the private keys. Another pool should be the _runners_ and have access to the public keys. This creates a security boundary between the agents that upload and sign pipelines and the agents that run jobs and verify signatures.

Regarding your specific algorithm choice, any of the supported signing algorithms are fine and will be secure. If you're not sure which one to use, `EdDSA` is proven to be secure, has a modern design, wasn't designed by a Nation State Actor, and produces nice short signatures. It's also the default when running `buildkite-agent tool keygen`.

### Step 2: Configure the agents

Next, you need to configure your agents to use the keys you generated. On agents that upload pipelines, add the following to the agent's config file:

```ini
signing-jwks-file=<path to private key set>
signing-jwks-key-id=<the key id you generated earlier>
verification-jwks-file=<path to public key set>
```

This ensures that whenever those agents upload steps to Buildkite, they'll generate signatures using the private key you generated earlier. It also ensures that those agents verify the signatures of any steps they run, using the public key.

```ini
verification-failure-behavior=<warn>
```

This setting determines the Buildkite agent's response when it receives a job without a proper signature, and also specifies how strictly the agent should enforce signature verification for incoming jobs. The agent will warn about missing or invalid signatures, but will still proceed to execute the job. If not explicitly specified, the default behavior is `block`, which prevents any job without a valid signature from running, ensuring a secure pipeline environment by default.

On instances that verify jobs, add:

```ini
verification-jwks-file=<path to verification keys>
```

### Step 3: Sign all steps

So far, you've configured agents to sign and verify any steps they upload and run. However, you also define steps in a pipeline's settings through the Buildkite dashboard. For example, teams commonly use a single step in the Pipeline Settings to upload a pipeline definition from [a YAML file in the repository](/docs/pipelines/configure/defining-steps#step-defaults-pipeline-dot-yml-file). These steps should also be signed.

> 🚧 Non-YAML steps
> You must use YAML to sign steps configured in the Pipeline Settings page. If you don't use YAML, you'll need to [migrate to YAML steps](/docs/pipelines/tutorials/pipeline-upgrade) before continuing.

To sign steps configured in the Pipeline Settings page, you need to add static signatures to the YAML. To do this, run:

```sh
buildkite-agent tool sign \
  --graphql-token <token> \
  --jwks-file <path to signing jwks> \
  --jwks-key-id <signing key id> \
  --organization-slug <org slug> \
  --pipeline-slug <pipeline slug> \
  --update
```

Replacing the following:

- `<token>` with a Buildkite GraphQL token that has the `write_pipelines` scope.
- `<path to signing jwks>` with the path to the private key set you generated earlier.
- `<signing key id>` with the key ID from earlier.
- `<org slug>` with the slug of the organization the pipeline is in.
- `<pipeline slug>` with the slug of the pipeline you want to sign.

This will download the pipeline definition using the Buildkite GraphQL API, sign all steps, and upload the signed pipeline definition back to Buildkite.

### Rotating signing keys

Regularly rotating signing and verification keys is good security practice, as it reduces the impact of a compromised key. Because signed pipelines use JWKS as their key format, rotating keys is easy.

To rotate your keys:

1. [Generate a new key pair](#self-managed-key-creation-step-1-generate-a-key-pair).
1. Add the new keys to your existing key sets. Be careful not to mix public and private keys.
1. Update the `signing-key-id` on your signing agents to use the new key ID.

The verifying agents will automatically use the public key with the matching key ID, if it's present.

## AWS KMS managed key setup

AWS Key Management Service (AWS KMS) is a web service that securely protects cryptographic keys, when using this service with signed pipelines the agent never has access to the private key used to sign pipelines, with calls going with the KMS API.

### Step 1: Create a KMS key

AWS KMS has a myriad of options when creating keys, for pipeline signing we require that you use some specific settings.

1. The key type must be Asymmetric and have a usage type of `SIGN_VERIFY`.
2. The key spec must be `ECC_NIST_P256`.

If your using the AWS CLI the key can be created as follows:

```bash
aws kms create-key --key-spec ECC_NIST_P256 --key-usage SIGN_VERIFY
```

Once created you can retrieve the key identifier, this will be a UUID, for example `1234abcd-12ab-34cd-56ef-1234567890ab`.

Optionally you can create a key alias, or friendly name for the key as follows:

```bash
aws kms create-alias \
  --alias-name alias/example-alias \
  --target-key-id 1234abcd-12ab-34cd-56ef-1234567890ab
```

### Step 2: Configure the agents

Next, you need to configure your agents to use the KMS key you created. On agents that upload pipelines, add the following to the agent's config file:

```ini
signing-aws-kms-key=<key id or alias>
```

This ensures that whenever those agents upload steps to Buildkite, they'll generate signatures using the private key you generated earlier. It also ensures that those agents verify the signatures of any steps they run, using the public key.

```ini
verification-failure-behavior=<warn>
```

This setting determines the Buildkite agent's response when it receives a job without a proper signature, and also specifies how strictly the agent should enforce signature verification for incoming jobs. The agent will warn about missing or invalid signatures, but will still proceed to execute the job. If not explicitly specified, the default behavior is `block`, which prevents any job without a valid signature from running, ensuring a secure pipeline environment by default.

### Step 3: Sign all steps

To sign steps configured in the Pipeline Settings page, you need to add static signatures to the YAML. To do this, run:

```sh
buildkite-agent tool sign \
  --graphql-token <token> \
  --signing-aws-kms-key <key id or alias> \
  --organization-slug <org slug> \
  --pipeline-slug <pipeline slug> \
  --update
```

Replacing the following:

- `<token>` with a Buildkite GraphQL token that has the `write_pipelines` scope.
- `<path to signing jwks>` with the path to the private key set you generated earlier.
- `<key id or alias>` with the AWS KMS key ID or alias created earlier.
- `<org slug>` with the slug of the organization the pipeline is in.
- `<pipeline slug>` with the slug of the pipeline you want to sign.

### Step 4: Assign IAM permissions to your agents

There are two common roles for agents when using signed pipelines, these being those that sign and upload pipelines, and those that verify steps. To follow least privilege best practice you should access to the KMS key using IAM to specific actions as seen below.

For agents which will sign and verify pipelines the following IAM Actions are required.

- kms:Sign
- kms:Verify
- kms:GetPublicKey

For agents which only verify pipelines the following IAM Actions are required.

- kms:Verify
- kms:GetPublicKey
