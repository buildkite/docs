# SonarScanner CLI integration tutorial

The [SonarScanner CLI](https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/) integration enables static code analysis of your projects using SonarQube or SonarCloud directly within your Buildkite pipelines.

SonarScanner analyzes your code for bugs, vulnerabilities, and code smells across 25+ programming languages. This integration is designed for self-hosted SonarQube instances, with optional support for SonarCloud as an alternative.

This page is a tutorial that covers both self-hosted SonarQube instances and SonarCloud integration.

## Prerequisites

Before configuring SonarScanner in your Buildkite pipeline, ensure you have:

1. **SonarQube account** or **SonarCloud account**
1. **Authentication token** that is:
   - Generated from your SonarQube/SonarCloud account settings
   - Stored securely using [Buildkite secrets management](/docs/pipelines/security/secrets/managing)
1. **Java Runtime Environment (JRE) 11 or higher**
   - Required by SonarScanner CLI to run
   - Needs to be installed for the [pre-installed binary implementation approach](/docs/pipelines/integrations/security-and-compliance/sonar#implementation-approaches-pre-installed-binary-approach)
   - Comes pre-installed in most Buildkite Agent environments
   - Not required for [Docker image-based implementation approach](/docs/pipelines/integrations/security-and-compliance/sonar#implementation-approaches-docker-image-approach) (Java is included in the container)
1. **Secrets management solutions** - this tutorial demonstrates [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/) with the [AWS Secrets Manager Buildkite Plugin](https://buildkite.com/resources/plugins/seek-oss/aws-sm-buildkite-plugin/).

## Configuration strategy

SonarScanner supports two configuration methods:

- **Environment variables**: Recommended for runtime settings and sensitive authentication data (tokens, URLs).
- **Properties files**: Recommended for project-specific settings.

> 📘 Configuration precedence
> Environment variables take precedence over the settings in the properties file. This design allows you to keep project configuration in version control while securely managing authentication through Buildkite's secrets management.

## Environment variables

Use environment variables in your pipeline for authentication and server configuration:

| Environment Variable | Description |
| --- | --- |
| `SONAR_TOKEN` | **Required.** Authentication token for your SonarQube/SonarCloud server<br>*SonarQube example:* `sqp_1234567890abcdef1234567890abcdef12345678`<br>*SonarCloud example:* `a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0`<br>**Security:** Store using [secrets management](/docs/pipelines/security/secrets/managing) |
| `SONAR_HOST_URL` | **Required.** URL of your SonarQube server<br>*Example:* `https://sonarqube.mycompany.com` or `https://sonar.internal.mycompany.com` |

## Properties file configuration

Create a `sonar-project.properties` file in your repository root to define project-specific settings:

```properties
# SonarQube configuration
sonar.host.url=https://sonarqube.mycompany.com
sonar.projectKey=sample-project
sonar.projectName=Multi-Language Sample Project
sonar.projectVersion=1.0
# Source configuration
sonar.sources=src,lib,scripts
sonar.sourceEncoding=UTF-8
# Working directory (adjust based on execution environment; default is root)
sonar.working.directory=./.scannerwork
# Exclusions
sonar.exclusions=**/.git/**,**/.buildkite/**,**/node_modules/**,**/target/**,**/*.jar,**/*.class
# Language-specific settings (optional)
sonar.javascript.lcov.reportPaths=coverage/lcov.info
sonar.python.coverage.reportPaths=coverage.xml
sonar.java.binaries=target/classes
```

### Understanding key properties

- **sonar.sources**: comma-separated list of directories containing source code, relative to project root.
- **sonar.working.directory**: directory where SonarScanner stores temporary analysis files. Execution user must have `write` permissions to this directory.
- **sonar.exclusions**: files and directories to exclude from analysis using Ant-style patterns (`**` = any subdirectories, `*` = any characters).
- **sonar.tests**: directories containing test files, separate from the main source analysis.

## Implementation approaches

Choose between two deployment approaches based on your infrastructure preferences and agent setup:

- [Pre-installed binary](/docs/pipelines/integrations/security-and-compliance/sonar#implementation-approaches-pre-installed-binary-approach) - install SonarScanner directly on your Buildkite agents for faster execution and reduced container overhead.
- [Docker image](/docs/pipelines/integrations/security-and-compliance/sonar#implementation-approaches-docker-image-approach) - use the official SonarScanner Docker image for consistent environments and simplified agent setup.

### Pre-installed binary approach

This approach uses the SonarScanner CLI binary installed directly on your Buildkite Agents. Below is an example for [Buildkite Elastic CI Stack for AWS](/docs/agent/v3/aws/elastic-ci-stack).

#### Update launch template userdata

Add the following installation script to your Auto Scaling Group's launch template userdata:

```bash
#!/bin/bash -v

# Download and install SonarScanner CLI
echo "Installing SonarScanner CLI..."
cd /opt
sudo wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip
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

#### Deploy launch template updates

Update your existing launch template with the new userdata script, create a new version, and configure your Auto Scaling Group to use the updated template. This ensures new agent instances will have SonarScanner pre-installed.

#### Pipeline configuration

Configure your pipeline configuration file to be able to run the `sonar-scanner`.

```yaml
steps:
  - label: "📊 SonarQube Analysis"
    command: |
      # Wait for sonar-scanner availability
      echo "⏳ Ensuring sonar-scanner is ready..."
      timeout 30 bash -c 'while [[ ! -x "/opt/sonar-scanner/bin/sonar-scanner" ]]; do sleep 5; done' || {
        echo "❌ Error: SonarScanner binary not ready after 30 seconds"
        echo "Check that SonarScanner is properly installed on your agents"
        exit 1
      }

      # Run SonarScanner analysis
      /opt/sonar-scanner/bin/sonar-scanner
    env:
      SONAR_HOST_URL: "https://sonarqube.mycompany.com"
      SONAR_PROJECT_CONFIG: "./sonar-project.properties"
    plugins:
      - seek-oss/aws-sm#v2.3.3:
          env:
            SONAR_TOKEN: path/to/your/sonar-token
```

### Docker image approach

This approach uses the official SonarScanner Docker image, eliminating the need for agent setup. This tutorial uses the [Docker Buildkite plugin](https://buildkite.com/resources/plugins/buildkite-plugins/docker-buildkite-plugin/).

```yaml
steps:
  - label: "📊 SonarQube Analysis"
    command: |
      # Run SonarScanner analysis in Docker container
      sonar-scanner
    env:
      SONAR_HOST_URL: "https://sonarqube.mycompany.com"
      SONAR_PROJECT_CONFIG: "./sonar-project.properties"
    plugins:
      - seek-oss/aws-sm#v2.3.3:
          env:
            SONAR_TOKEN: path/to/your/sonar-token
      - docker#v5.13.0:
          image: "sonarsource/sonar-scanner-cli:latest"
          environment:
            - "SONAR_TOKEN"
          propagate-environment: true
```

#### Configure your working directory

Adjust your `sonar-project.properties` working directory in Docker, for example:

```conf
# For Docker execution
sonar.working.directory=/usr/src/.scannerwork # Container runs as root
# For native binary execution (e.g., Elastic CI Stack for AWS)
sonar.working.directory=/tmp/.scannerwork # Runs as buildkite-agent user
```

## Complete templated multi-language example

This example demonstrates a complete SonarScanner setup for analyzing a typical multi-language project using the [pre-installed binary approach](/docs/pipelines/integrations/security-and-compliance/sonar#implementation-approaches-pre-installed-binary-approach). You can adapt this configuration for your own projects by modifying the properties file.

#### Pipeline configuration

```yaml
steps:
  - label: "📥 Setup"
    command: |
      echo "🏗️  Multi-Language SonarScanner Analysis"
      echo "🎯 Analyzing 20+ language samples..."
  - label: "🔍 SonarCloud Analysis"
    command: |
      # Wait for sonar-scanner availability (Elastic CI Stack for AWS)
      echo "⏳ Ensuring sonar-scanner is ready..."
      timeout 30 bash -c 'while [[ ! -x "/opt/sonar-scanner/bin/sonar-scanner" ]]; do sleep 5; done' || {
        echo "❌ Error: SonarScanner binary not ready after 30 seconds"
        echo "Check that SonarScanner is properly installed on your agents"
        exit 1
      }

      # Run analysis using properties file configuration
      /opt/sonar-scanner/bin/sonar-scanner
      echo "✅ Analysis completed successfully"
    plugins:
      - seek-oss/aws-sm#v2.3.3:
          env:
            SONAR_TOKEN: my-org/sonar-token
    # If using Docker
    #   - docker#v5.13.0:
    #       image: "sonarsource/sonar-scanner-cli:latest"
    #       environment:
    #         - "SONAR_TOKEN"
    #       propagate-environment: true
```

### Properties file configuration

```conf
# SonarQube configuration
sonar.host.url=https://sonarqube.mycompany.com
sonar.projectKey=sample-project
sonar.projectName=Multi-Language Sample Project
sonar.projectVersion=1.0
# Comprehensive source analysis - scan all example projects
sonar.sources=examples/
sonar.sourceEncoding=UTF-8
# Working directory (Elastic CI Stack for AWS)
sonar.working.directory=/tmp/.scannerwork
# Working directory (Docker execution)
# sonar.working.directory=/usr/src/.scannerwork
# Exclusions for clean analysis
sonar.exclusions=**/.git/**,**/.buildkite/**,**/.scannerwork/**,**/images/**,**/target/**,**/build/**,**/gradle/**,**/node_modules/**,**/*.jar,**/*.class,**/vendor/**,**/__pycache__/**,**/*.pyc,**/dist/**,**/.terraform/**
```

## Troubleshooting

This section covers some common issues and proposed mitigations for the SonarScanner integration for Buildkite.

### Installation and path issues

**SonarScanner binary not found (pre-installed binary approach)**

```bash
# Check if binary exists
ls -la /opt/sonar-scanner/bin/sonar-scanner

# Verify permissions
sudo chmod +x /opt/sonar-scanner/bin/sonar-scanner

# Check PATH configuration
echo $PATH | grep sonar-scanner

# Test direct execution
/opt/sonar-scanner/bin/sonar-scanner --version
```

### Authentication problems

**Token authentication failures**

- Verify that the SonarQube/SonarCloud token is correctly stored in your secrets manager.
- Check token permissions in SonarQube/SonarCloud (the token needs "Execute Analysis" permission).
- Ensure token hasn't expired (check the expiration date in SonarQube/SonarCloud).
- Test token's validity manually: `curl -u YOUR_TOKEN: https://your-sonarqube-url/api/authentication/validate`.

### Analysis timeout or performance issues

**Analysis timeout or memory issues**

```conf
# Increase memory allocation for large projects
sonar.javascript.node.maxspace=8192

# Exclude large or unnecessary files and file types using `sonar.exclusions`
sonar.exclusions=**/*.min.js,**/vendor/**,**/third-party/**,**/*.pdf,**/*.jpg,**/*.png
```

**Large project optimization**

```conf
# Exclude test files from duplication analysis
sonar.cpd.exclusions=**/test/**,**/tests/**

# Skip binary files
sonar.exclusions=**/*.jar,**/*.zip

# Limit analysis scope
sonar.sources=src/main
sonar.tests=src/test
```

### Docker permission issues

- Check Docker image version compatibility.
- Verify working directory permissions:

```bash
docker exec -it <container_name> ls -ld /path/to/workdir
```

## Using SonarCloud instead of SonarQube

While this tutorial describes the implementation of self-hosted SonarQube, you can also use [SonarCloud](https://docs.sonarcloud.io/) (the hosted SaaS version) by making a few changes.

### Environment variables changes

- `SONAR_HOST_URL`: Optional (defaults to `https://sonarcloud.io`)
- `SONAR_TOKEN`: Required (also saved in your choice of Buildkite secrets management service)

### Properties file changes

```conf
# SonarCloud configuration

# Optional (defaults to https://sonarcloud.io)
sonar.host.url=https://sonarcloud.io
# Required
sonar.projectKey=my-org_sample-project
# Required
sonar.organization=my-org
```

### Token generation changes

Generate your SonarCloud token from **My Account > Security > Generate Tokens** in your SonarCloud dashboard.

## Additional resources

- [SonarQube documentation](https://docs.sonarqube.org/latest/)
- [SonarCloud documentation](https://docs.sonarcloud.io/)
- [SonarScanner CLI reference](https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/)
- [Buildkite Secrets Management](/docs/pipelines/security/secrets/managing) documentation page.
