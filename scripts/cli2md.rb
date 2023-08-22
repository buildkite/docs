# frozen_string_literal: true

require "cgi"

# are we in a code block?
in_code = false

# are with in the table of parameters?
in_table = false

# read from stdin or files in the args
ARGF.each_with_index do |line, line_num|
  # Replace all prime symbols with backticks. We use prime symbols instead of backticks in CLI
  # helptext because Go does not support escaping backticks in backtick delimited strings.
  # See: https://github.com/buildkite/agent/blob/main/clicommand/prime-signs.md
  line.tr!("′", "`")

  # Some agent help texts dynamically replace $HOME with the current user's home directory.
  # We need to replace it back for the docs
  line.gsub!(Dir.home, "$HOME")

  # Headings end in `:`
  if /^(\w*):/ =~ line
    puts "### #{Regexp.last_match(1)}"
  # Initial usage command
  elsif line_num == 2
    puts "`#{line.strip}`"
  # code blocks
  elsif /^\s{4}/ =~ line
    puts "```shell" unless in_code
    puts line.gsub(/^\s{4}/, "")
    in_code = true

  # first line after a code block
  elsif in_code
    in_code = false
    puts "```"
    puts line

  # Lists of parameters
  #  --config value             Path to a configuration file [$BUILDKITE_AGENT_CONFIG]
  elsif /\s{2}(-{2}[a-z0-9\- ]*)([A-Z].*)$/ =~ line
    puts %(<!-- vale off -->\n\n<table class="Docs__attribute__table">) unless in_table
    in_table = true

    command_and_value = Regexp.last_match(1).rstrip
    command = command_and_value.split[0][2..]
    value = command_and_value.split[1]
    desc = Regexp.last_match(2)

    # Extract $BUILDKITE_* env and remove from desc
    /(\$BUILDKITE[A-Z0-9_]*)/ =~ desc
    env_var = Regexp.last_match(1)
    desc.gsub!(/(\s\[\$BUILDKITE[A-Z0-9_]*\])/, "")

    # Wrap https://agent.buildkite.com/v3 in code
    desc.gsub!("https://agent.buildkite.com/v3", "<code>https://agent.buildkite.com/v3</code>")

    print %(<tr id="#{command}">)
    print %(<th><code>--#{command} #{value}</code> <a class="Docs__attribute__link" href="##{command}">#</a></th>)
    print "<td><p>#{desc}"
    print "<br /><strong>Environment variable</strong>: <code>#{env_var}</code>" unless env_var.nil? || env_var.empty?
    print "</p></td>"
    print "</tr>"
    puts
  else
    puts CGI.escapeHTML(line.lstrip)
  end
end

# last line of input was in a table
puts "</table>\n\n<!-- vale on -->\n" if in_table

# last line of input was in a code block
puts "```" if in_code
