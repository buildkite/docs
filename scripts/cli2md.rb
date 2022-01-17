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
            puts "<table>"
            first_param = true
        end
        command = $1.rstrip
        desc    = $2

        # Extract $BUILDKITE_* env and remove from desc
        /(\$BUILDKITE[A-Z0-9_]*)/ =~ desc
        env_var = $1
        desc.gsub!(/(\s\[\$BUILDKITE[A-Z0-9_]*\])/,"")


        # Wrap https://agent.buildkite.com/v3 in code
        desc.gsub!('https://agent.buildkite.com/v3',"<code>https://agent.buildkite.com/v3</code>")
        puts "<tr><td><code>#{command}</code></td><td><p>#{desc}</p><br /><b>ENV:</b> <code>#{env_var}</code></td>"
    else
        if(first_param==true)
            puts "</table>"
            first_param = false
            next
        end
        puts CGI::escapeHTML(line.lstrip)
    end
end
