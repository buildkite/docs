# Deploying to AWS Lambda

This tutorial demonstrates deploying Lambda functions to [AWS Lambda](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html) using Buildkite Pipelines and the [AWS Lambda Deploy plugin](https://buildkite.com/resources/plugins/buildkite-plugins/aws-lambda-deploy-buildkite-plugin/). The plugin provides alias management, health checks, and automatic rollback capabilities for reliable Lambda deployments.

## Before starting

Before deploying to AWS Lambda from Buildkite Pipelines, ensure the following requirements are met:

- An AWS account with appropriate [Lambda permissions](https://docs.aws.amazon.com/lambda/latest/dg/lambda-intro-execution-role.html) (further explained in [Required AWS IAM permissions](#required-aws-iam-permissions))
- [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed on Buildkite Agents
- [`jq` command-line tool](https://jqlang.org/) available
- A Lambda function already created in AWS (or permission to create one)

### Required AWS IAM permissions

Buildkite Agents need the following Lambda permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "lambda:GetFunction",
        "lambda:UpdateFunctionCode",
        "lambda:UpdateFunctionConfiguration",
        "lambda:PublishVersion",
        "lambda:GetAlias",
        "lambda:UpdateAlias",
        "lambda:CreateAlias",
        "lambda:DeleteFunction",
        "lambda:InvokeFunction"
      ],
      "Resource": "arn\:aws\:lambda:*:*:function:my-function*"
    }
  ]
}
```

For S3-based deployments, additional S3 permissions are required:

```json
{
  "Effect": "Allow",
  "Action": ["s3:GetObject", "s3:GetObjectVersion"],
  "Resource": "arn\:aws\:s3:::deployment-bucket/*"
}
```

## Deploying zip-based Lambda functions

The most common Lambda deployment pattern uses ZIP files containing the function's code. The following example demonstrates a pipeline that builds and deploys a Python Lambda function:

```yaml
steps:
  - label: ":package: Build function"
    key: "build"
    commands:
      - echo "Building Lambda function..."
      - zip -r function.zip src/
    artifact_paths:
      - "function.zip"

  - label: ":rocket: Deploy to Lambda"
    depends_on: "build"
    commands:
      - buildkite-agent artifact download "function.zip" .
    plugins:
      - aws-lambda-deploy#v1.0.0:
          function-name: "my-function"
          alias: "production"
          mode: "deploy"
          zip-file: "function.zip"
          region: "us-east-1"
          runtime: "python3.13"
          handler: "lambda_function.lambda_handler"
          timeout: 30
          memory-size: 128
          description: "Deployed from build ${BUILDKITE_BUILD_NUMBER}"
          environment:
            LOG_LEVEL: "INFO"
            STAGE: "production"
          auto-rollback: true
          health-check-enabled: true
          health-check-timeout: 60
          health-check-payload: '{"test": true}'
```

## Deploying container-based Lambda functions

For larger functions or functions requiring custom runtimes, Lambda supports container images. The following example deploys a containerized Lambda function from Amazon Elastic Container Registry (ECR):

```yaml
steps:
  - label: ":rocket: Deploy Lambda container"
    plugins:
      - aws-lambda-deploy#v1.0.0:
          function-name: "my-container-function"
          alias: "production"
          mode: "deploy"
          package-type: "Image"
          image-uri: "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-function:${BUILDKITE_BUILD_NUMBER}"
          region: "us-east-1"
          timeout: 300
          memory-size: 512
          description: "Container deployment from build ${BUILDKITE_BUILD_NUMBER}"
          environment:
            STAGE: "production"
            VERSION: "${BUILDKITE_BUILD_NUMBER}"
          auto-rollback: true
          health-check-enabled: true
          health-check-payload: '{"length": 5, "width": 10}'
          health-check-timeout: 120
```

## S3-based deployments

For larger deployment packages or shared packages, Lambda functions can be deployed from S3:

```yaml
steps:
  - label: ":rocket: Deploy from S3"
    plugins:
      - aws-lambda-deploy#v1.0.0:
          function-name: "my-function"
          alias: "production"
          mode: "deploy"
          s3-bucket: "my-deployment-bucket"
          s3-key: "functions/my-function-${BUILDKITE_BUILD_NUMBER}.zip"
          region: "us-east-1"
          runtime: "python3.13"
          handler: "lambda_function.lambda_handler"
          auto-rollback: true
          health-check-enabled: true
```

## Manual approval and rollback

For production [deployments](/docs/pipelines/deployments), you can use [block steps](/docs/pipelines/configure/step-types/block-step) and manual rollback:

```yaml
steps:
  - label: ":rocket: Deploy to production"
    plugins:
      - aws-lambda-deploy#v1.0.0:
          function-name: "my-function"
          alias: "production"
          mode: "deploy"
          zip-file: "function.zip"
          region: "us-east-1"
          runtime: "python3.13"
          handler: "lambda_function.lambda_handler"
          timeout: 30
          memory-size: 128
          description: "Deployment from build ${BUILDKITE_BUILD_NUMBER}"

  - block: ":thinking_face: Review deployment"
    prompt: "Check if the deployment is working correctly"

  - label: ":leftwards_arrow_with_hook: Manual rollback"
    plugins:
      - aws-lambda-deploy#v1.0.0:
          function-name: "my-function"
          alias: "production"
          mode: "rollback"
          region: "us-east-1"
```

## Health checks

The plugin supports comprehensive health checks to validate deployments:

```yaml
- label: ":rocket: Deploy with health checks"
  plugins:
    - aws-lambda-deploy#v1.0.0:
        function-name: "my-api-function"
        alias: "production"
        mode: "deploy"
        zip-file: "function.zip"
        region: "us-east-1"
        # Health check configuration
        health-check-enabled: true
        health-check-timeout: 120
        health-check-payload: |
          {
            "httpMethod": "GET",
            "path": "/health",
            "headers": {
              "User-Agent": "Buildkite-HealthCheck"
            }
          }
        health-check-expected-status: 200
        auto-rollback: true
```

Health checks run after the deployment completes and will trigger automatic rollback if they fail (when `auto-rollback` is enabled).

## Build metadata and tracking

The [AWS Lambda Deploy plugin](https://buildkite.com/resources/plugins/buildkite-plugins/aws-lambda-deploy-buildkite-plugin/) automatically tracks deployment state using Buildkite build's metadata. This enables:

- **Cross-step state sharing**: multiple steps can access deployment information.
- **Rollback coordination**: rollback steps can access previous version information.
- **Deployment history**: track which versions were deployed when.

Metadata keys are namespaced by function name:

- `deployment:aws_lambda:my-function:current_version`
- `deployment:aws_lambda:my-function:previous_version`
- `deployment:aws_lambda:my-function:result`

For complete configuration options, see the [AWS Lambda Deploy plugin documentation](https://github.com/buildkite-plugins/aws-lambda-deploy-buildkite-plugin/).
