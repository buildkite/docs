require 'cgi'

incode = false

first_param = false

ARGF.each_with_index do |line, line_num|
    # Headings
    if /^(\w*):/ =~ line
        puts "## #{$1}"
    # Initial usage command
    elsif line_num == 2
        puts "`#{line.strip}`"
    # Code sections
    elsif /\s{3}\$/ =~ line
        # Break code lines that end in \
        if line [-2] == "\\"
            incode=true
        end
        puts " #{line}"
    # If previous line ends in \ indent to code block
    elsif incode == true
        incode = false
        puts "   #{line}"
    # Lists of parameters
    #    --config value                         Path to a configuration file [$BUILDKITE_AGENT_CONFIG]
    elsif /\s{3}(-{2}[a-z0-9\- ]*)([A-Z].*)$/ =~ line
        if(first_param==false)
            puts "<!-- vale off -->\n\n<table class=\"Docs__attribute__table\">"
            first_param = true
        end
        command_and_value = $1.rstrip
        command = command_and_value.split[0][2..-1]
        value = command_and_value.split[1]
        desc    = $2

        # Extract $BUILDKITE_* env and remove from desc
        /(\$BUILDKITE[A-Z0-9_]*)/ =~ desc
        env_var = $1
        desc.gsub!(/(\s\[\$BUILDKITE[A-Z0-9_]*\])/,"")


        # Wrap https://agent.buildkite.com/v3 in code
        desc.gsub!('https://agent.buildkite.com/v3',"<code>https://agent.buildkite.com/v3</code>")
        puts "<tr id=\"#{command}\"><th><code>--#{command} #{value}</code> <a class=\"Docs__attribute__link\" href=\"##{command}\">#</a></th><td><p>#{desc}<br /><strong>Environment variable</strong>: <code>#{env_var}</code></p></td></tr>"
    else
        if(first_param==true)
            puts "</table>\n\n<!-- vale on -->\n"
            first_param = false
            next
        end
        puts CGI::escapeHTML(line.lstrip)
    end
end
