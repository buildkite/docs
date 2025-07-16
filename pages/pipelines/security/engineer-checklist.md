# Security Engineer Checklist

This checklist provides security engineers with essential tasks and considerations for maintaining security best practices in Buildkite environments.

## Agent Security

### Agent Configuration
- [ ] Review [agent expiry dates](/docs/agent/v3/tokens) and ensure rotation policies are in place
- [ ] Verify agents are running with minimal required privileges
- [ ] Confirm [agent security configuration](/docs/agent/v3/securing) follows organizational standards
- [ ] Validate agent tokens are properly scoped and rotated regularly
- [ ] Review agent queue configurations and access controls

### Agent Environment
- [ ] Ensure agents run in secure, isolated environments
- [ ] Verify agent software is kept up-to-date with latest security patches
- [ ] Confirm agent hosts have proper network security controls
- [ ] Review agent logging and monitoring configurations

## Token Security

### Token Management
- [ ] Audit all active API tokens and their permissions
- [ ] Implement token rotation policies and procedures
- [ ] Review token scoping to ensure minimal necessary permissions
- [ ] Validate token storage and distribution mechanisms
- [ ] Monitor token usage patterns for anomalies

### Access Controls
- [ ] Review user access permissions and roles
- [ ] Validate team permissions align with organizational requirements
- [ ] Ensure proper separation of duties for sensitive operations
- [ ] Confirm pipeline permissions are appropriately scoped

## Security Scans and Testing

### Automated Security Testing
- [ ] Implement security scanning in CI/CD pipelines
- [ ] Configure dependency vulnerability scanning
- [ ] Set up static application security testing (SAST)
- [ ] Enable dynamic application security testing (DAST) where applicable
- [ ] Review and tune security scan configurations for accuracy

### Manual Security Reviews
- [ ] Conduct regular security code reviews
- [ ] Perform pipeline security assessments
- [ ] Review third-party integrations and plugins
- [ ] Assess secrets management practices
- [ ] Validate security incident response procedures

## Cluster and Rules Security

### Cluster Configuration
- [ ] Review cluster security configurations
- [ ] Validate cluster access controls and permissions
- [ ] Ensure cluster isolation and network security
- [ ] Confirm cluster monitoring and logging

### Pipeline Rules
- [ ] Review and validate pipeline rules for security compliance
- [ ] Ensure rules are properly scoped and enforced
- [ ] Monitor rule violations and exceptions
- [ ] Maintain documentation of rule rationale and updates

## Secrets Management

### Secret Configuration
- [ ] Review [secrets management practices](/docs/pipelines/security/secrets/managing)
- [ ] Validate [Buildkite secrets](/docs/pipelines/security/secrets/buildkite-secrets) configuration
- [ ] Assess [risk considerations](/docs/pipelines/security/secrets/risk-considerations) for current setup
- [ ] Ensure secrets are not exposed in logs or artifacts
- [ ] Verify proper secret rotation procedures

### Secret Access
- [ ] Review who has access to secrets and secret management systems
- [ ] Validate secret scoping and access controls
- [ ] Monitor secret usage and access patterns
- [ ] Ensure proper secret backup and recovery procedures

## Infrastructure Security

### Environment Security
- [ ] Review build environment security configurations
- [ ] Validate network security controls and segmentation
- [ ] Ensure proper logging and monitoring coverage
- [ ] Confirm backup and disaster recovery procedures

### Compliance and Auditing
- [ ] Conduct regular security audits and assessments
- [ ] Ensure compliance with organizational security policies
- [ ] Maintain security documentation and procedures
- [ ] Review and update security incident response plans

## OIDC and Authentication

### OIDC Configuration
- [ ] Review [OIDC setup](/docs/pipelines/security/oidc) and configuration
- [ ] Validate [OIDC with AWS](/docs/pipelines/security/oidc/aws) integration if applicable
- [ ] Ensure proper token validation and audience configuration
- [ ] Monitor OIDC token usage and authentication flows

### Authentication Security
- [ ] Review multi-factor authentication requirements
- [ ] Validate single sign-on (SSO) configuration
- [ ] Ensure proper session management and timeout policies
- [ ] Monitor authentication logs for anomalies

## Monitoring and Incident Response

### Security Monitoring
- [ ] Implement security event monitoring and alerting
- [ ] Review security logs regularly for suspicious activity
- [ ] Maintain security metrics and reporting
- [ ] Ensure proper log retention and analysis capabilities

### Incident Response
- [ ] Test incident response procedures regularly
- [ ] Maintain up-to-date contact information for security team
- [ ] Ensure proper escalation procedures are documented
- [ ] Review and update incident response playbooks

## Documentation and Training

### Security Documentation
- [ ] Maintain current security procedures and policies
- [ ] Document security configurations and rationale
- [ ] Ensure security knowledge is properly documented and shared
- [ ] Regular review and update of security documentation

### Team Training
- [ ] Provide security awareness training to development teams
- [ ] Ensure security best practices are communicated and followed
- [ ] Conduct regular security training and updates
- [ ] Maintain security contact information and escalation procedures

---

> **Note**: This checklist should be reviewed and updated regularly to ensure it remains current with evolving security threats and organizational requirements. Consider customizing this checklist based on your specific environment and security requirements.