# Private storage link

Buildkite Package Registries lets you store packages, container images, and modules in **your own** cloud-storage bucket instead of Buildkite-hosted storage. This capability is called a _Private Storage Link_ (PSL).

A PSL gives you:

- Ownership and custody of the binary data.
- Reduced latency when the bucket is close to your workloads.
- Full control over bucket-level security and lifecycle policies.
- The same Buildkite API and UI experience — only the bytes move.

Buildkite currently supports two storage providers:

| Provider | Documentation |
| -------- | ------------- |
| Amazon Web Services – **S3** | [Set up an S3 Private Storage Link →](./s3) |
| Google Cloud – **Cloud Storage (GCS)** | [Set up a GCS Private Storage Link →](./gcs) |

> More providers will be added over time. Follow the links above to configure the provider that matches your infrastructure.

---

Need a quick visual overview? The high-level flow is identical for every provider:

1. Provide bucket details.  
1. Authorize Buildkite to access the bucket.  
1. Run a diagnostic to confirm Buildkite can _PUT_ and _GET_ objects.  
1. Activate the link.

<%# Placeholder graphic – PSL high-level flow %>
<%= image "psl-generic-flow.png", alt: "Four-step Private Storage Link flow" %>
