#!/usr/bin/env ruby

# Script to parse command-line options from 'buildkite-agent start --help'
# This script extracts all options and outputs them in YAML format

puts "attributes:"

# List of required options
required_options = ["token", "build-path"]

# List of options to exclude from parsing
exclude_options = ["config"]

# Get the home directory to replace with generic path
home_dir = ENV['HOME'] || Dir.home

# Run the help command and get output
help_output = `buildkite-agent start --help`

# Process each line that starts with "  --"
help_output.lines.each do |line|
  next unless line.match?(/^  --/)
  
  original_line = line.dup
  
  # Extract option name (remove leading spaces and --, get the first word)
  line_without_prefix = line.gsub(/^  --/, '')
  option_name = line_without_prefix.split(' ').first
  
  # Skip if option is in the exclude list
  next if exclude_options.include?(option_name)

  # Check if option is in the required list
  required = required_options.include?(option_name)
  
  # Extract environment variable (text in brackets, preserve $ prefixes, convert commas to newlines)
  env_var = ""
  if match = line.match(/\[([^\]]+)\]/)
    env_var = match[1].gsub(/, /, "\n      ")
  end
  
  # Extract the default value (text between "default:" and ")", preserve quotes)
  default_value = ""
  if match = line.match(/\(default:([^)]*)\)/)
    default_value = match[1].strip
    # Replace home directory path with ~ for generic documentation
    default_value = default_value.gsub(home_dir, "~")
  end

  # Extract description
  # Start with the line and remove option name and value part
  temp = line_without_prefix.gsub(/^[a-zA-Z0-9-]+( value)?[ ]*/, '')
  # Remove default value part
  temp = temp.gsub(/[ ]*\(default:[^)]*\)/, '')
  # Remove environment variable part  
  temp = temp.gsub(/[ ]*\[\$[^\]]*\][ ]*$/, '')
  
  description = temp.strip
  
  # Output YAML
  puts "  - name: \"#{option_name}\""
  puts "    env_var: |"
  puts "      #{env_var}"
  puts "    default_value: |"
  if default_value.empty?
    puts ""
  else
    puts "      #{default_value}"
  end
  puts "    required: #{required}"
  puts "    desc: |"
  puts "      #{description}"
end
