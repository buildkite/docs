# Collecting tests with OpenTelemetry

Buildkite Test Engine can ingest test results and instrumentation using [OpenTelemetry](https://opentelemetry.io/).

Currently only Ruby RSpec is supported, using the [Ruby collector's OpenTelemetry integration](/docs/pipelines/configure/tests/test-collection/ruby-collectors#collecting-rspec-tests-with-opentelemetry).
Other frameworks are under active development, and it is possible to implement OpenTelemetry test ingestion without using a Buildkite Collector, see below.

## Writing your own OpenTelemetry ingestion

Test Engine ingests test results as [Traces](https://opentelemetry.io/docs/concepts/signals/traces/).
Two types of span can be sent.

- Test spans - These represent an overview of the test execution. A test span is mandatory for a test to be ingested, and is usually the root span of the trace. There should be one test span per test execution.
- Child spans - Any other instrumentation may be attached to the test span as part of the trace hierarchy. Child spans are optional.

To send test results to Test Engine via OpenTelemetry, you must emit one test span per test execution, as the root span of the trace.
You may optionally attach child spans for operations you wish to instrument to see where each test spends its time.

Test Engine creates the test result from the test span.
You cannot send a separate JSON or JUnit XML upload for the same execution.
If you are using OpenTelemetry for instrumentation, you must use OpenTelemetry for result upload.

### Test span structure

In your test runner's hooks, start a new root span for each execution and end it after the test and its cleanup finish. Each execution must have its own trace, with no parent span. Create instrumented child spans while that root span is active so they share its trace ID.

Set these attributes on each root span

Attribute | Description
--------- | -----------
`buildkite.execution.via` | Set to `otlp` to create a test execution from this span.
`buildkite.run_key` | The identifier for the test run. Use the same value as the `Buildkite-Tests-Run-Key` request header.
`buildkite.test.name` | A nonempty, stable test name.
`test.case.result.status` | Set to `pass`, `fail`, `skipped`, or `pending`. The span's OpenTelemetry status alone does not determine the test result.
{: class="two-column"}

The root span must have valid start and end timestamps. Its duration becomes the test execution duration. Spans without a name, a run key, or a recognized result do not create test executions.

Use `buildkite.test.scope` to group tests, and keep the combination of scope and name stable between runs. Add `code.file.path` and `code.line.number` for source locations. For failures, set the span status to error and record `exception` events with `exception.message` and `exception.stacktrace` to include failure details.

For [CI metadata](/docs/pipelines/configure/tests/test-collection/ci-environments), set resource attributes such as `cicd.pipeline.run.id`, `cicd.pipeline.run.url.full`, `vcs.ref.head.name`, and `vcs.ref.head.revision`. On Buildkite Pipelines, populate these from `BUILDKITE_BUILD_ID`, `BUILDKITE_BUILD_URL`, `BUILDKITE_BRANCH`, and `BUILDKITE_COMMIT`, respectively. Set `buildkite.job_id` on each root span from `BUILDKITE_JOB_ID` to associate executions with their job. Add custom execution tags as `buildkite.tag.<key>` span attributes.

### Example implementation

The following example uses the Python OpenTelemetry SDK to submit a passing test. For another language, use its OpenTelemetry SDK with the same endpoint, headers, and span attributes.

1. [Create a test suite](/docs/pipelines/getting-started#add-a-test-suite-create-a-test-suite) and obtain its suite API token. Store the token [securely](/docs/pipelines/security/secrets/managing) as the `BUILDKITE_ANALYTICS_TOKEN` environment variable. Use a suite API token, not a user API access token.

1. Install the SDK and HTTP/protobuf exporter:

    ```bash
    python -m pip install \
      opentelemetry-sdk \
      opentelemetry-exporter-otlp-proto-http
    ```

1. Save the following as `otel_test.py`:

    ```python
    import os
    import uuid

    from opentelemetry.exporter.otlp.proto.http.trace_exporter import (
        OTLPSpanExporter,
    )
    from opentelemetry.sdk.trace import TracerProvider
    from opentelemetry.sdk.trace.export import BatchSpanProcessor
    from opentelemetry.trace import Status, StatusCode

    # Share this key across all executions and parallel jobs in a run.
    run_key = os.getenv("BUILDKITE_BUILD_ID") or str(uuid.uuid4())
    token = os.environ["BUILDKITE_ANALYTICS_TOKEN"]

    provider = TracerProvider()
    provider.add_span_processor(BatchSpanProcessor(OTLPSpanExporter(
        endpoint="https://tests-otlp.buildkite.com/v1/traces",
        headers={
            "Authorization": f'Token token="{token}"',
            "Buildkite-Tests-Run-Key": run_key,
        },
    )))
    tracer = provider.get_tracer("example-test-collector")

    try:
        with tracer.start_as_current_span("test.execution", attributes={
            "buildkite.execution.via": "otlp",
            "buildkite.run_key": run_key,
            "buildkite.test.scope": "Arithmetic",
            "buildkite.test.name": "adds two numbers",
        }) as span:
            try:
                assert 2 + 3 == 5
            except Exception as error:
                span.set_attribute("test.case.result.status", "fail")
                span.set_status(Status(StatusCode.ERROR, str(error)))
                raise
            else:
                span.set_attribute("test.case.result.status", "pass")
    finally:
        # Export buffered results even if the test fails.
        provider.shutdown()
    ```

1. Run the example with the token available in its environment:

    ```bash
    python otel_test.py
    ```

1. Open your suite in Buildkite Test Engine and find the new run. Use the suite's [**Uploads** page](/docs/pipelines/configure/tests/test-suites/upload-health) to investigate rejected or failed uploads.

### Transport and authentication

Send traces to `https://tests-otlp.buildkite.com/v1/traces` using OTLP over HTTP with protobuf encoding (`Content-Type: application/x-protobuf`). The endpoint does not accept OTLP/JSON or gRPC. Uncompressed and gzip-compressed requests are supported. Request bodies must not exceed 900 KiB; reduce the exporter batch size if you receive HTTP 413 responses.

Every request must include:

- `Authorization: Token token="YOUR_SUITE_API_TOKEN"`
- `Buildkite-Tests-Run-Key: YOUR_RUN_KEY`

Run keys must contain between one and 255 printable ASCII characters, with no spaces. Use one key for all requests belonging to the same run, including child spans and parallel jobs, and a different key for each new run.

You can also authenticate with an [agent OIDC token](/docs/pipelines/configure/tests/test-collection/oidc) whose suite policy grants the `write_uploads` scope. Use the OIDC token in place of the suite API token in the authorization header.

An HTTP 200 response confirms receipt, not that every span created a test execution. If results are missing, check the root span attributes and the suite's **Uploads** page. Do not upload the same executions through both OTLP and another upload method, as this creates duplicate results.
