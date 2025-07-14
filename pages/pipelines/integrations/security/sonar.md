# SonarScanner CLI Tutorial

The [SonarScanner CLI](https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/) integration allows you to perform static code analysis of your projects using your [SonarQube](https://docs.sonarsource.com/sonarqube-server/latest/) server directly within your Buildkite pipelines.

## Overview

SonarScanner analyzes your code for bugs, vulnerabilities, and code smells across 25+ programming languages. This integration is designed for self-hosted SonarQube instances, with optional support for SonarCloud as an alternative.

## Prerequisites

Before configuring SonarScanner in your Buildkite pipeline, ensure you have:

1. SonarQube account
2. Authentication token 
    - Generated from your SonarQube account settings
    - Stored securely using your choice of [Buildkite secrets management](https://buildkite.com/docs/pipelines/security/secrets/managing) service. This tutorial uses  [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/) and the [AWS Secrets Manager Buildkite Plugin](https://buildkite.com/resources/plugins/seek-oss/aws-sm-buildkite-plugin/)

# Configuration Approaches

SonarScanner can be configured using **environment variables** or a **properties file**. The recommended approach is to use environment variables for sensitive authentication and properties files for project-specific settings.

## Environment Variables

Use environment variables in your pipeline for authentication and server configuration:

| Environment Variable | Description |
| --- | --- |
| `SONAR_TOKEN` | **Required.** Authentication token for your SonarQube server<br>*Example:* `squ_a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0`<br>**Security:** Store using [secrets management](https://www.notion.so/docs/pipelines/security/secrets/managing) |
| `SONAR_HOST_URL` | **Required.** URL of your SonarQube server<br>*Example:* `https://sonarqube.mycompany.com` or `https://sonar.internal.company.com` |

## Properties File Configuration

Create a `sonar-project.properties` file in your repository root for project-specific configuration:

```
# SonarQube configuration
sonar.host.url=https://sonarqube.mycompany.com
sonar.projectKey=sample-project
sonar.projectName=Multi-Language Sample Project
sonar.projectVersion=1.0

# Source configuration
sonar.sources=src,lib,scripts
sonar.sourceEncoding=UTF-8

# Working directory (adjust based on execution environment but default is root)
sonar.working.directory="./.scannerwork"

# Exclusions
sonar.exclusions=**/.git/**,**/.buildkite/**,**/node_modules/**,**/target/**,**/*.jar,**/*.class

# Language-specific settings (optional)
sonar.javascript.lcov.reportPaths=coverage/lcov.info
sonar.python.coverage.reportPaths=coverage.xml
sonar.java.binaries=target/classes
```

> 📘 Configuration Precedence
> 
> 
> Environment variables take precedence over properties file settings. This design allows you to keep project configuration in version control while securely managing authentication through Buildkite's secrets management.
> 

# Implementation Approaches

## Approach 1: Pre-installed Binary

This approach uses the sonar-scanner CLI binary installed directly on your Buildkite agents. Below is an example for [Buildkite Elastic CI Stack for AWS](https://buildkite.com/docs/agent/v3/aws/elastic-ci-stack).

### **Step 1: Update Launch Template Userdata**

Add the following installation script to your Auto Scaling Group's launch template userdata:

```bash
#!/bin/bash -v

# Download and install SonarScanner CLI
echo "Installing SonarScanner CLI..."
cd /opt
sudo wget <https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip>
sudo unzip sonar-scanner-cli-5.0.1.3006-linux.zip
sudo ln -s sonar-scanner-5.0.1.3006-linux sonar-scanner

# Set proper permissions for buildkite-agent user
sudo chown -R root:root /opt/sonar-scanner-5.0.1.3006-linux
sudo chmod +x /opt/sonar-scanner/bin/sonar-scanner

# Add to system PATH
sudo tee /etc/profile.d/sonar-scanner.sh << 'EOF'
export PATH="/opt/sonar-scanner/bin:$PATH"
EOF
sudo chmod +x /etc/profile.d/sonar-scanner.sh

# Add to buildkite-agent user profile
sudo -u buildkite-agent tee -a /var/lib/buildkite-agent/.bashrc << 'EOF'
export PATH="/opt/sonar-scanner/bin:$PATH"
EOF

echo "SonarScanner installation completed"
```

### **Step 2: Deploy Launch Template Updates**

Update your existing launch template with the new userdata script, create a new version, and configure your Auto Scaling Group to use the updated template. This ensures new agent instances will have SonarScanner pre-installed.

### **Step 3: Pipeline Configuration**

```
steps:
  - label: " 📊 SonarQube Analysis"
    command: |
      # Wait for sonar-scanner availability
      echo "⏳ Ensuring sonar-scanner is ready..."
      timeout 30 bash -c 'while [[ ! -x "/opt/sonar-scanner/bin/sonar-scanner" ]]; do sleep 5; done'

      # Run SonarScanner analysis
      /opt/sonar-scanner/bin/sonar-scanner
    env:
      SONAR_HOST_URL: "<https://sonarqube.mycompany.com>"
      SONAR_PROJECT_CONFIG: "./config/sonar-project.properties"
    plugins:
      - seek-oss/aws-sm#v2.3.3:
          env:
            SONAR_TOKEN: path/to/your/sonar-token
```

## Approach 2: Docker Image

This approach uses the official SonarScanner Docker image, eliminating the need for agent setup. This tutorial uses the [Docker Buildkite Plugin](https://buildkite.com/resources/plugins/buildkite-plugins/docker-buildkite-plugin/).

```
steps:
  - label: " 📊 SonarQube Analysis"
    env:
      SONAR_HOST_URL: "<https://sonarqube.mycompany.com>"
      SONAR_PROJECT_CONFIG: "./config/sonar-project.properties"
    plugins:
      - seek-oss/aws-sm#v2.3.3:
          env:
            SONAR_TOKEN: path/to/your/sonar-token
      - docker#v5.11.0:
          image: "sonarsource/sonar-scanner-cli:latest"
          environment:
            - "SONAR_TOKEN"
          propagate-environment: true
```

## Working Directory Configuration

When using a properties file option, adjust your working directory, for example:

```
# For Docker execution 
sonar.working.directory=/usr/src/.scannerwork # Container runs as root

# For native binary execution (e.g., Elastic CI stack) 
sonar.working.directory=/tmp/.scannerwork # Runs as buildkite-agent user
```

# Templated Multi-Language Sample Project

This complete example demonstrates SonarScanner analysis against the [sample projects](https://github.com/SonarSource/sonar-scanning-examples/tree/master/sonar-scanner/src) using the **properties file approach**.

### Pipeline Configuration

```
steps:
  - label: "📥 Setup"
    command: |
      echo "🏗️  Multi-Language SonarScanner Analysis"
      echo "🎯 Analyzing 20+ language samples..."

  - label: "🔍 SonarCloud Analysis"
    command: |
      # Wait for sonar-scanner availability (Elastic CI Stack)
      echo "⏳ Ensuring sonar-scanner is ready..."
      timeout 30 bash -c 'while [[ ! -x "/opt/sonar-scanner/bin/sonar-scanner" ]]; do sleep 5; done'

      # Run analysis using properties file configuration
      /opt/sonar-scanner/bin/sonar-scanner

      echo "✅ Analysis completed successfully"
    plugins:
      - seek-oss/aws-sm#v2.3.3:
          env:
            SONAR_TOKEN: my-org/sonar-token

    # If using Docker
    #   - docker#v5.11.0:
    #       image: "sonarsource/sonar-scanner-cli:latest"
    #       environment:
    #         - "SONAR_TOKEN"
    #       propagate-environment: true
```

### Properties File Configuration

```
# SonarQube configuration
sonar.host.url=https://sonarqube.mycompany.com
sonar.projectKey=sample-project
sonar.projectName=Multi-Language Sample Project
sonar.projectVersion=1.0

# Comprehensive source analysis - scan all example projects
sonar.sources=examples/
sonar.sourceEncoding=UTF-8

# Working directory (Elastic CI Stack)
sonar.working.directory=/tmp/.scannerwork
# Working directory (Docker execution)
# sonar.working.directory=/usr/src/.scannerwork

# Exclusions for clean analysis
sonar.exclusions=**/.git/**,**/.buildkite/**,**/.scannerwork/**,**/images/**,**/target/**,**/build/**,**/gradle/**,**/node_modules/**,**/*.jar,**/*.class,**/vendor/**,**/__pycache__/**,**/*.pyc,**/dist/**,**/.terraform/**
```

# Troubleshooting

## Common Issues

**SonarScanner binary not found (Elastic CI stack agent)**

- Verify installation: `ls -la /opt/sonar-scanner/bin/sonar-scanner`
- Check permissions: `chmod +x /opt/sonar-scanner/bin/sonar-scanner`
- Verify PATH: `echo $PATH | grep sonar-scanner`

**Authentication failures**

- Verify token is correctly stored in secrets manager
- Check token permissions in SonarQube/SonarCloud
- Ensure token hasn't expired

**Analysis timeout or performance issues**

- Increase timeout for large projects
- Exclude unnecessary files using `sonar.exclusions`

**Docker permission issues**

- Verify working directory permissions
- Check Docker image version compatibility

# SonarCloud Alternative

While this documentation focuses on self-hosted SonarQube, you can also use [SonarCloud](https://docs.sonarcloud.io/) (the hosted SaaS version) by making these simple adjustments:

### **Environment Variables:**

- `SONAR_HOST_URL`: Optional (defaults to `https://sonarcloud.io`)
- `SONAR_TOKEN`: Required (also saved in your choice of Buildkite secrets management service)

### **Properties File Changes:**

```
# SonarCloud configuration
sonar.host.url=https://sonarcloud.io # Optional (defaults to <https://sonarcloud.io>)
sonar.projectKey=my-org_sample-project
sonar.organization=my-org  # Required
```