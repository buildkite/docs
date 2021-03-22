ARGF.each_with_index do |line, line_num|
    # Headings 
    if /^([A-z]*):/ =~ line
        puts "## #{$1}"
    # Initial usage command
    elsif line_num == 2
        puts "`#{line.strip}`"      
    # Code sections
    elsif /\s{3}\$/ =~ line
        puts " #{line}"
    # Lists of parameters
    #    --config value                         Path to a configuration file [$BUILDKITE_AGENT_CONFIG]
    elsif /\s{3}(-{2}[a-z0-9\- ]*)([A-Z].*)$/ =~ line
        command = $1.rstrip
        desc    = $2
        desc.gsub!(/(\$BUILDKITE[A-Z0-1_]*)/,"`\\1`")
        puts "* `#{command}` - #{desc}"
    elsif
        puts line.lstrip
    end
end