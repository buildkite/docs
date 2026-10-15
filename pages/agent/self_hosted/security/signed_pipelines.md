# Signed pipelines

Signed pipelines are a security feature where pipelines are cryptographically signed when uploaded to Buildkite. Agents then verify the signature before running the job. If an agent detects a signature mismatch, it'll refuse to run the job.

Maintaining a strong security boundary is important to Buildkite and informs how we design features. It's also a key reason people choose Buildkite over other CI/CD tools. Signing pipelines improves your security posture by ensuring agents don't run jobs where a malicious actor has modified the instructions. This moves you towards zero-trust CI/CD by further isolating you from Buildkite itself being compromised. Signed pipelines can be enabled on self-hosted agents and are not available on Buildkite hosted agents.

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

Behind the scenes, signed pipelines use [JSON Web Signing (JWS)](https://datatracker.ietf.org/doc/html/rfc7797) to generate signatures. There are three options for creation of keys used with JWS, these are:

- [Self-managed key pairs](#self-managed-key-creation)
- [AWS KMS managed keys](#aws-kms-managed-key-setup)
- [GCP KMS managed keys](#gcp-kms-managed-key-setup)

## Self-managed key creation

You'll need to generate a [JSON Web Key Set (JWKS)](https://datatracker.ietf.org/doc/html/rfc7517) to sign and verify your pipelines with, then configure your agents to use those keys.

### Step 1: Generate a key pair

Luckily, the agent has you covered! A JWKS generation tool is built into the agent, which you can use to generate a key pair. To use it, you'll need to [install the agent on your machine](/docs/agent/self-hosted/install), and then run:

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

When using signed pipelines, we recommend having multiple disjoint pools of agents, each using a different [queue](/docs/agent/queues). One pool should be the _uploaders_ and have access to the private keys. Another pool should be the _runners_ and have access to the public keys. This creates a security boundary between the agents that upload and sign pipelines and the agents that run jobs and verify signatures.

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
verification-failure-behavior=warn
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
verification-failure-behavior=warn
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

## GCP KMS managed key setup

Google Cloud Key Management Service (GCP KMS) securely protects cryptographic keys. When using this service with signed pipelines, the agent never has access to the private key used to sign pipelines. Signing requests are sent to the GCP KMS API, and the agent downloads only the public key to verify signatures locally.

GCP KMS support for signed pipelines requires Buildkite agent version 3.121.0 or later.

### Step 1: Create a KMS key

GCP KMS has many options when creating keys. For pipeline signing, the key must use the following settings:

1. The key purpose must be asymmetric signing (`ASYMMETRIC_SIGN`).
1. The key algorithm must be one of the supported key algorithms listed below. The `EC_SIGN_P256_SHA256` algorithm is recommended, and is the only algorithm that works on agent versions earlier than 3.136.0.

If you're using the Google Cloud CLI, the key ring and key can be created as follows:

```bash
gcloud kms keyrings create example-keyring --location global

gcloud kms keys create example-signing-key \
  --keyring example-keyring \
  --location global \
  --purpose asymmetric-signing \
  --default-algorithm ec-sign-p256-sha256
```

Unlike AWS KMS, the agent identifies a GCP KMS key by the full resource name of a specific _key version_, in the format:

```text
projects/<project>/locations/<location>/keyRings/<key ring>/cryptoKeys/<key>/cryptoKeyVersions/<version>
```

For example, the first version of the key created above has the resource name `projects/example-project/locations/global/keyRings/example-keyring/cryptoKeys/example-signing-key/cryptoKeyVersions/1`. To list the versions of a key and their resource names, run:

```bash
gcloud kms keys versions list \
  --key example-signing-key \
  --keyring example-keyring \
  --location global
```

#### Supported key algorithms

The agent reads the algorithm from the key version and selects the matching JWS algorithm for signatures. The following GCP KMS algorithms are supported:

GCP KMS algorithm              | JWS algorithm
------------------------------ | -------------
`EC_SIGN_P256_SHA256`          | `ES256`
`EC_SIGN_P384_SHA384`          | `ES384`
`RSA_SIGN_PSS_2048_SHA256`     | `PS256`
`RSA_SIGN_PSS_3072_SHA256`     | `PS256`
`RSA_SIGN_PSS_4096_SHA256`     | `PS256`
`RSA_SIGN_PSS_4096_SHA512`     | `PS512`
`RSA_SIGN_PKCS1_2048_SHA256`   | `RS256`
`RSA_SIGN_PKCS1_3072_SHA256`   | `RS256`
`RSA_SIGN_PKCS1_4096_SHA256`   | `RS256`
`RSA_SIGN_PKCS1_4096_SHA512`   | `RS512`
{: class="two-column"}

The agent refuses to start if the key version uses any other algorithm.

> 🚧 Algorithms other than EC_SIGN_P256_SHA256 require agent version 3.136.0 or later
> Agent versions 3.121.0 to 3.135.0 always verify GCP KMS signatures as `ES256`, regardless of the key's algorithm. On these versions, jobs signed with any key other than `EC_SIGN_P256_SHA256` fail verification and are blocked by default. If any of your agents run a version earlier than 3.136.0, use an `EC_SIGN_P256_SHA256` key.

### Step 2: Configure the agents

Next, you need to configure your agents to use the KMS key version you created. On agents that upload pipelines, add the following to the agent's config file:

```ini
signing-gcp-kms-key=<key version resource name>
```

Replace `<key version resource name>` with the full resource name of the key version from the previous step. You can also set this value using the `BUILDKITE_AGENT_SIGNING_GCP_KMS_KEY` environment variable or the `--signing-gcp-kms-key` flag on `buildkite-agent start`.

This ensures that whenever those agents upload steps to Buildkite, they'll generate signatures using the private key held in GCP KMS. It also ensures that those agents verify the signatures of any steps they run, using the public key of the same key version.

The agent authenticates to GCP KMS using [Application Default Credentials](https://cloud.google.com/docs/authentication/application-default-credentials). On Compute Engine or GKE, this is usually the service account attached to the instance or workload. Elsewhere, set the `GOOGLE_APPLICATION_CREDENTIALS` environment variable to the path of a service account key file.

```ini
verification-failure-behavior=warn
```

This setting determines the Buildkite agent's response when it receives a job without a proper signature, and also specifies how strictly the agent should enforce signature verification for incoming jobs. The agent will warn about missing or invalid signatures, but will still proceed to execute the job. If not explicitly specified, the default behavior is `block`, which prevents any job without a valid signature from running, ensuring a secure pipeline environment by default.

On agents that only verify jobs, add the same `signing-gcp-kms-key` setting. These agents only need permission to read the public key, as described in [Step 4](#gcp-kms-managed-key-setup-step-4-assign-iam-permissions-to-your-agents).

### Step 3: Sign all steps

To sign steps configured in the Pipeline Settings page, you need to add static signatures to the YAML. To do this, run:

```sh
buildkite-agent tool sign \
  --graphql-token <token> \
  --signing-gcp-kms-key <key version resource name> \
  --organization-slug <org slug> \
  --pipeline-slug <pipeline slug> \
  --update
```

Replacing the following:

- `<token>` with a Buildkite GraphQL token that has the `write_pipelines` scope.
- `<key version resource name>` with the full resource name of the GCP KMS key version created earlier.
- `<org slug>` with the slug of the organization the pipeline is in.
- `<pipeline slug>` with the slug of the pipeline you want to sign.

The `buildkite-agent tool sign` and `buildkite-agent pipeline upload` commands also read the key version resource name from the `BUILDKITE_AGENT_GCP_KMS_KEY` environment variable.

### Step 4: Assign IAM permissions to your agents

There are two common roles for agents when using signed pipelines, these being those that sign and upload pipelines, and those that verify steps. To follow least privilege best practice, grant each group of agents only the IAM permissions it needs on the KMS key.

For agents which sign and verify pipelines, the following permissions are required:

- `cloudkms.cryptoKeyVersions.useToSign`
- `cloudkms.cryptoKeyVersions.viewPublicKey`

The predefined `roles/cloudkms.signerVerifier` role includes both permissions. The `roles/cloudkms.signer` role alone is not enough, because the agent fetches the public key when it starts.

For agents which only verify pipelines, the following permission is required:

- `cloudkms.cryptoKeyVersions.viewPublicKey`

The predefined `roles/cloudkms.publicKeyViewer` role includes this permission. Verification happens locally on the agent using the public key, so verifying agents don't call the GCP KMS sign or verify operations.

For example, to grant a service account permission to sign and verify using the key created earlier, run:

```bash
gcloud kms keys add-iam-policy-binding example-signing-key \
  --keyring example-keyring \
  --location global \
  --member serviceAccount:buildkite-uploader@example-project.iam.gserviceaccount.com \
  --role roles/cloudkms.signerVerifier
```

### Rotating GCP KMS keys

Because the agent is configured with a specific key version, creating a new key version in GCP KMS does not change which key the agents use. To rotate to a new key version:

1. Create a new key version in GCP KMS.
1. Update `signing-gcp-kms-key` on your signing and verifying agents to the new key version resource name, and restart them.
1. Re-sign any static steps configured in the Pipeline Settings page using the new key version, as described in [Step 3](#gcp-kms-managed-key-setup-step-3-sign-all-steps).

Each agent trusts only the public key of the key version it is configured with. Until every agent has been updated, jobs signed with one key version are rejected by agents configured with the other. To avoid failed jobs, rotate keys during a maintenance window, or temporarily set `verification-failure-behavior=warn` on verifying agents while the rollout completes.
