#!/usr/bin/env ruby
# frozen_string_literal: true

# Script to generate agent experiments documentation from the buildkite/agent repository
#
# This script fetches experiments.go and EXPERIMENTS.md from the agent repo and generates
# a Markdown documentation page for the Buildkite docs site.
#
# Usage:
#   ruby scripts/agent_experiments2md/agent_experiments2md.rb > pages/agent/self_hosted/configure/experiments.md
#
# Requirements:
#   - Ruby 3.0+
#   - Internet access to fetch from GitHub

require 'json'
require 'open3'

EXPERIMENTS_GO_URL = 'https://raw.githubusercontent.com/buildkite/agent/main/internal/experiments/experiments.go'
EXPERIMENTS_MD_URL = 'https://raw.githubusercontent.com/buildkite/agent/main/EXPERIMENTS.md'

# Links for promoted experiments documentation
# Format: 'Heading name' => [['link text', 'url'], ...] (1 or 2 links max)
# Use the formatted heading name as it appears in the docs (output of format_experiment_name)
PROMOTED_EXPERIMENT_LINKS = {
  'ANSI timestamps' => [
    ['ANSI timestamps and disabling them', '/docs/pipelines/configure/managing-log-output#ansi-timestamps-and-disabling-them']
  ],
  'Flock file locks' => [
    ['Flock file locks', '/docs/agent/cli/reference/lock#flock-file-locks']
  ],
  'Git mirrors' => [
    ['Git mirrors', '/docs/agent/self-hosted/configure/git-mirrors'],
    ['Setting up Git mirrors', '/docs/agent/self-hosted/configure/git-mirrors#setting-up-git-mirrors']
  ],
  'Job API' => [
    ['Internal job API', '/docs/apis/agent-api/internal-job']
  ],
  'Polyglot hooks' => [
    ['Polyglot hooks', '/docs/agent/hooks#polyglot-hooks']
  ],
  'Use zzglob' => [
    ['Glob pattern syntax', '/docs/pipelines/configure/glob-pattern-syntax']
  ]
}.freeze

def fetch_url(url)
  stdout, stderr, status = Open3.capture3('curl', '-sS', '-f', url)
  raise "Failed to fetch #{url}: #{stderr}" unless status.success?

  stdout.force_encoding('UTF-8')
end

def parse_experiments_go(content)
  available = []
  promoted = {}

  # Parse constants to get experiment string values
  constants = {}
  content.scan(/(\w+)\s*=\s*"([^"]+)"/).each do |name, value|
    constants[name] = value
  end

  # Parse Available experiments (map[string]struct{})
  # Match from "Available = map" until a line with just "}"
  if content =~ /Available\s*=\s*map\[string\]struct\{\}\{(.+?)^\s+\}/m
    available_block = $1
    available_block.scan(/^\s+(\w+):\s*\{\}/).each do |match|
      const_name = match[0]
      if constants[const_name]
        available << constants[const_name]
      end
    end
  end

  # Parse Promoted experiments - extract version from standardPromotionMsg calls
  # First, match from "Promoted = map"
  if content =~ /Promoted\s*=\s*map\[string\]string\{(.+?)^\s+\}/m
    promoted_block = $1
    # Match standardPromotionMsg(ConstName, "version")
    promoted_block.scan(/(\w+):\s*standardPromotionMsg\(\w+,\s*"([^"]+)"\)/).each do |const_name, version|
      if constants[const_name]
        promoted[constants[const_name]] = version
      end
    end
    # Also match direct string assignments (like KubernetesExec)
    promoted_block.scan(/(\w+):\s*"([^"]+)"/).each do |const_name, msg|
      if constants[const_name]
        # Extract version from message if present
        if msg =~ /v\d+\.\d+\.\d+/
          promoted[constants[const_name]] = msg[/v\d+\.\d+\.\d+/]
        else
          promoted[constants[const_name]] = 'deprecated'
        end
      end
    end
  end

  { available: available, promoted: promoted }
end

def parse_experiments_md(content)
  experiments = {}
  current_experiment = nil
  current_description = []

  content.each_line do |line|
    if line =~ /^###\s*`([^`]+)`/
      # Save previous experiment
      if current_experiment
        experiments[current_experiment] = current_description.join.strip
      end
      current_experiment = $1
      current_description = []
    elsif current_experiment
      current_description << line
    end
  end

  # Save last experiment
  if current_experiment
    experiments[current_experiment] = current_description.join.strip
  end

  experiments
end

def format_experiment_name(name)
  # Sentence case: only capitalize first word
  # Acronyms stay uppercase anywhere they appear in a word
  acronyms = %w[api pty ansi]
  words = name.split('-')

  words.map.with_index do |word, i|
    lower_word = word.downcase
    # Check if any acronym appears anywhere in the word
    matching_acronym = acronyms.find { |acr| lower_word.include?(acr) }

    if matching_acronym
      # Replace the acronym portion with uppercase, keep rest appropriate case
      lower_word.gsub(matching_acronym, matching_acronym.upcase)
    elsif i == 0
      word.capitalize
    else
      word.downcase
    end
  end.join(' ')
end

def generate_markdown(experiments_data, descriptions)
  available = experiments_data[:available].sort
  promoted = experiments_data[:promoted].sort_by { |name, _| name }

  output = []

  output << '<!--'
  output << ' _____           ______                _______    _ _'
  output << '(____ \         |  ___ \       _      (_______)  | (_)_'
  output << ' _   \ \ ___    | |   | | ___ | |_     _____   _ | |_| |_'
  output << '| |   | / _ \   | |   | |/ _ \|  _)   |  ___) / || | |  _)'
  output << '| |__/ / |_| |  | |   | | |_| | |__   | |____( (_| | | |__'
  output << '|_____/ \___/   |_|   |_|\___/ \___)  |_______)____|_|\___)'
  output << ''
  output << 'This file is auto-generated by scripts/agent_experiments2md/agent_experiments2md.rb.'
  output << ''
  output << 'To update this file:'
  output << ''
  output << '1. Make changes to the relevant agent files in https://github.com/buildkite/agent'
  output << '   For content not in that repo, edit it in scripts/agent_experiments2md/agent_experiments2md.rb'
  output << "2. Run './scripts/update-agent-experiments.sh' from the docs repo root"
  output << '-->'
  output << ''
  output << '# Agent experiments'
  output << ''
  output << 'Buildkite frequently introduces new experimental features to the agent. Use the [`--experiment` flag](/docs/agent/self-hosted/configure#experiment) to opt-in to them and test them out:'
  output << ''
  output << '```'
  output << 'buildkite-agent start --experiment experiment1 --experiment experiment2'
  output << '```'
  output << ''
  output << 'Or you can set them in your [agent configuration file](/docs/agent/self-hosted/configure):'
  output << ''
  output << '```'
  output << 'experiment="experiment1,experiment2"'
  output << '```'
  output << ''
  output << 'If an experiment doesn\'t exist, no error will be raised.'
  output << ''
  output << '> 🚧'
  output << '> Please note that there is a likely chance that these experiments we will be removed or changed. Therefore, using them should be at your own risk, and without the expectation that these experiments will work in future.'
  output << ''
  output << '## Available experiments'
  output << ''

  available.each do |name|
    output << "### #{format_experiment_name(name)}"
    output << ''
    if descriptions[name] && !descriptions[name].empty?
      # Clean up the description - remove Status lines, clean formatting, strip trailing spaces, and fix style issues
      desc = descriptions[name]
        .gsub(/\*\*Status:\*\*.*$/m, '')
        .gsub(/\n\n+/, "\n\n")
        .gsub(/\bvia\b/, 'using')
        .gsub(/\bdownloader\b/, 'download tool')
        .lines.map { |line| line.rstrip }.join("\n")
        .strip
      output << desc
    end
    output << ''
    output << '> 🛠'
    output << "> To use this feature, set <code>experiment=\"#{name}\"</code> in your <a href=\"/docs/agent/self-hosted/configure#experiment\">agent configuration</a>."
    output << ''
  end

  output << '## Promoted experiments'
  output << ''
  output << "The following features started as experiments before being promoted to fully supported features. Therefore, these features are now a part of the Buildkite agent's default behavior, and there's no additional configuration required to use them."
  output << ''

  promoted.each do |name, version|
    output << "### #{format_experiment_name(name)}"
    output << ''
    output << "Promoted in [#{version}](https://github.com/buildkite/agent/releases/tag/#{version})."

    # Add documentation links if defined (lookup by formatted heading name)
    heading_name = format_experiment_name(name)
    if PROMOTED_EXPERIMENT_LINKS[heading_name]
      links = PROMOTED_EXPERIMENT_LINKS[heading_name]
      case links.length
      when 1
        output << "Learn more about this feature in [#{links[0][0]}](#{links[0][1]})."
      when 2
        output << "Learn more about this feature in [#{links[0][0]}](#{links[0][1]}) and [#{links[1][0]}](#{links[1][1]})."
      end
    end

    output << ''
  end

  output.join("\n")
end

def main
  $stderr.puts 'Fetching experiments.go...'
  experiments_go = fetch_url(EXPERIMENTS_GO_URL)

  $stderr.puts 'Fetching EXPERIMENTS.md...'
  experiments_md = fetch_url(EXPERIMENTS_MD_URL)

  $stderr.puts 'Parsing experiments...'
  experiments_data = parse_experiments_go(experiments_go)
  descriptions = parse_experiments_md(experiments_md)

  $stderr.puts "Found #{experiments_data[:available].length} available experiments"
  $stderr.puts "Found #{experiments_data[:promoted].length} promoted experiments"

  puts generate_markdown(experiments_data, descriptions)
end

main
