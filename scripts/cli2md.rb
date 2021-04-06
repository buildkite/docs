incode = false
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
        command = $1.rstrip
        desc    = $2
        # Wrap $BUILDKITE_* env vars in code
        desc.gsub!(/(\$BUILDKITE[A-Z0-9_]*)/,"`\\1`")
        # Wrap https://agent.buildkite.com/v3 in code
        desc.gsub!('https://agent.buildkite.com/v3',"`https://agent.buildkite.com/v3`")
        puts "* `#{command}` - #{desc}"
    else
        puts line.lstrip
    end
end
