import React from "react";

import Section from "./section";
import Link from "./link";

class Navigation extends React.Component {
  render() {
    return (
      <nav className="Docs__nav">
        <Section title="Guides" path="/docs/guides">
          <Link href="getting-started">Getting Started</Link>
          <Link href="branch-configuration">Branch Configuration</Link>
          <Link href="artifacts">Using Build Artifacts</Link>
          <Link href="build-meta-data">Using Build Meta-data</Link>
          <Link href="writing-build-scripts">Writing Build Scripts</Link>
          <Link href="managing-log-output">Managing Log Output</Link>
          <Link href="environment-variables">Environment Variables</Link>
          <Link href="uploading-pipelines">Uploading Pipelines</Link>
          <Link href="parallelizing-builds">Parallelizing Builds</Link>
          <Link href="docker-containerized-builds">Docker-Based Builds</Link>
          <Link href="images-in-build-output">Images in Build Output</Link>
          <Link href="managing-emails">Managing Emails</Link>
          <Link href="skipping-a-build">Skipping a Build</Link>
          <Link href="github-repo-access">GitHub Repo Access</Link>
          <Link href="github-enterprise">GitHub Enterprise</Link>
          <Link href="gitlab">GitLab</Link>
          <Link href="deploying-to-heroku">Deploying to Heroku</Link>
          <Link href="build-status-badges">Build Status Badges</Link>
          <Link href="cc-menu">CCMenu &amp; CCTray</Link>
        </Section>

        <Section title="Agent" path="/docs/agent">
          <Link href="/">Overview</Link>
          <Link href="installation">Installation</Link>
          <Link indent={true} href="ubuntu">Ubuntu</Link>
          <Link indent={true} href="debian">Debian</Link>
          <Link indent={true} href="redhat">Red Hat/CentOS</Link>
          <Link indent={true} href="freebsd">FreeBSD</Link>
          <Link indent={true} href="osx">Mac OS X</Link>
          <Link indent={true} href="windows">Windows</Link>
          <Link indent={true} href="linux">Linux</Link>
          <Link indent={true} href="docker">Docker</Link>
          <Link href="configuration">Configuration</Link>
          <Link href="ssh-keys">SSH Keys</Link>
          <Link href="hooks">Hooks</Link>
          <Link href="queues">Queues</Link>
          <Link href="prioritization">Prioritization</Link>
          <Link href="agent-meta-data">Agent Meta-data</Link>
          <Link href="build-meta-data">Build Meta-data</Link>
          <Link href="build-artifacts">Build Artifacts</Link>
          <Link href="build-pipelines">Build Pipelines</Link>
          <Link href="securing">Securing</Link>
          <Link href="upgrading-to-v2">Upgrading to v2</Link>
        </Section>

        <Section title="Webhooks" path="/docs/webhooks">
          <Link href="/">Overview</Link>
          <Link href="integrations">Integrations</Link>
          <Link href="agent-events">Agent Events</Link>
          <Link href="build-events">Build Events</Link>
          <Link href="job-events">Job Events</Link>
          <Link href="ping-events">Ping Events</Link>
        </Section>

        <Section title="API" path="/docs/api">
          <Link href="/">Overview</Link>
          <Link href="organizations">Organizations</Link>
          <Link href="pipelines">Pipelines</Link>
          <Link href="builds">Builds</Link>
          <Link href="jobs">Jobs</Link>
          <Link href="agents">Agents</Link>
          <Link href="artifacts">Artifacts</Link>
          <Link href="emojis">Emojis</Link>
        </Section>
      </nav>
    )
  }
}

export default Navigation;
