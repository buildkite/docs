# frozen_string_literal: true

require "cgi"

STATE_INITIAL = :inital
STATE_CODE = :code
STATE_TABLE = :table

state = STATE_INITIAL

# read from stdin or files in the args
ARGF.each_with_index do |line, line_num|
  # Replace all prime symbols with backticks. We use prime symbols instead of backticks in CLI
  # helptext because the cli framework we use, urfave/cli, has special handling for backticks.
  #
  # See: https://github.com/buildkite/agent/blob/main/clicommand/prime-signs.md
  line.tr!("′", "`")

  # Some agent help texts dynamically replace $HOME with the current user's home directory.
  # We need to replace it back for the docs
  line.gsub!(Dir.home, "$HOME")

  # Initial usage command
  if line_num == 2
    puts "`#{line.strip}`"
    next
  end

  case line
  # Headings end in `:`
  when /^(\w*):$/
    puts "### #{Regexp.last_match(1)}"
    state = STATE_INITIAL
    next
  # code blocks
  when /^\s{4}/
    puts "```shell" unless state == STATE_CODE
    puts line.gsub(/^\s{4}/, "")
    state = STATE_CODE
    next
  # Lists of parameters
  #  --config value             Path to a configuration file [$BUILDKITE_AGENT_CONFIG]
  when /\s{2}(-{2}[a-z0-9\- ]*)([A-Z].*)$/
    puts %(<!-- vale off -->\n\n<table class="Docs__attribute__table">) unless state == STATE_TABLE

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
    print "\n"
    state = STATE_TABLE
    next
  end

  case state
  # first line after a table
  when STATE_TABLE
    puts "</table>\n\n<!-- vale on -->\n"
    puts line
    state = STATE_INITIAL
    next
  # first line after a code block
  when STATE_CODE
    puts "```"
    puts line
    state = STATE_INITIAL
    next
  when STATE_INITIAL
    puts CGI.escapeHTML(line.lstrip)
    next
  else
    warn "Unknown state #{state} on line #{line_num}: #{line}"
  end
end

# handle when the last line was in a code block or table
case state
when STATE_TABLE
  puts "</table>\n\n<!-- vale on -->\n"
when STATE_CODE
  puts "```"
end
