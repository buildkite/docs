#!/usr/bin/env ruby

require 'yaml'
require 'json'

require 'open3'

def annotate!(annotation:, context:, style: "info")
  annotated = false
  if ENV["BUILDKITE"] == 'true'
    puts "Uploading annotation (#{annotation.size} bytes)"
    Open3.popen3(%Q[buildkite-agent annotate --style "#{style}" --context "#{context}"]) do |stdin, _, _, wait_thr|
      stdin.puts(annotation)
      stdin.close

      annotated = (wait_thr.value.exitstatus == 0)
    end
  end

  unless annotated
    puts "--- ANNOTATION [#{style},#{context}]"
    puts annotation
    puts
  end
end

def rules
  return @rules if @rules

  rules_yaml = YAML.load(File.read('link-checking-rules.yaml'))

  @rules = rules_yaml['link_checking_exemptions'].each_with_object([]) do |r, arr|
    arr << {
      name: r['name'],
      description: r['description'],
      status_pattern: /^#{r['status_pattern']}$/,
      url_patterns: r['url_patterns'].map {|url| /^#{url}/ }
    }
  end
end

@failed = {}
def result_fail(page, link)
  @failed[page] ||= []

  @failed[page] << link
end

@passed = {}
def result_pass(page, link, decided_by)
  @passed[page] ||= []

  @passed[page] << link.merge({'decided_by' => decided_by})
end

puts "--- Waiting for app to start"

until system('wget --spider -S http://app:3000/docs/agent/v3/hooks')
  puts "💎🛤️🦥 Rails is still starting"
  sleep 0.5
end
puts "💎🛤️🚆 Rails has started running"

puts "--- Running muffet"

muffet_cmd = [
  '/muffet',
  'http://app:3000/docs',
  '--header="User-Agent: Muffet/$(/muffet --version)"',
  '--max-connections=10',
  '--timeout=15',
  '--buffer-size=8192',
  '--format=json',
  # Capture successes as well as failures
  '--verbose',
  ].join(' ')

muffet_output_json=`#{muffet_cmd}`

File.write('muffet_results.json', muffet_output_json)

puts "--- Checking results"


pages = JSON.load(muffet_output_json)

pages.each do |page|
  page['links'].each do |link|
    unless link.has_key?('error')
      next
    end

    # There is an error. Do we have an exempting rule for it?
    exemptors = rules.select do |rule|
      rule[:status_pattern].match?(link['error']) &&
        rule[:url_patterns].any? {|patt| patt.match?(link['url']) }
    end

    if exemptors.any?
      result_pass(page['url'], link, exemptors)
    else
      result_fail(page['url'], link)
    end

  end
end

report = ""
if @failed.any?
  report = <<~MARKDOWN
    ## Muffet found broken links

    Resolve genuine broken links with either a **404** or **id #fragment not found** status first.
    
    Ignore links with a **timeout** status (since these are usually only temporarily broken), as well as working links that return a **403** or **id #fragment not found** status.

  MARKDOWN

  @failed.each do |page, links|
    path_and_query = page.sub(/https?:\/\/[^\/]+/,'')

    rows = links.reduce("") do |table, l|
      table += "| #{l['url']} | #{l['error']} |\n"
    end

    report += <<~MARKDOWN
      ### In \`#{path_and_query}\`:

      | Link | Status |
      |------|--------|
      #{rows}

    MARKDOWN

  end

  report += <<~MARKDOWN

  Configure any consistently working **403** or **id #fragment not found** status links as exceptions in the relevant section of the `link-checking-rules.yaml` file, which moves them to the **Non-breaking failures** section below.

  MARKDOWN

else
  report = "## Muffet found no problems :sunglasses:\n\n"
end

if @passed.any?
  report += <<~MARKDOWN

    ## Non-breaking failures

    The following requests would have failed, but we made them exempt in `.buildkite/steps/link-checking-rules.yaml`.

    <details><summary>Exempt links</summary>

  MARKDOWN

  @passed.each do |page, links|
    path_and_query = page.sub(/https?:\/\/[^\/]+/,'')

    rows = links.reduce("") do |table, l|
      table += "| #{l['url']} | #{l['error']} | #{l['decided_by'].map {|r| r[:name] }.join(', ')} |\n"
    end

    report += <<~MARKDOWN
      ### In \`#{path_and_query}\`:

      | Link | Status | Deciding rule(s) |
      |------|--------|------------------|
      #{rows}

    MARKDOWN
  end

  report += "</details>\n\n"
end

report += "The complete results (including **all** successful requests) will be uploaded in JSON format as a build artifact. If you need to figure out why links are passing checks when they shouldn't be, that is a good place to start.\n\n"

annotate!(annotation: report, context: 'muffet')

puts report.size
puts "Report #{report.size < 1024**2 ? 'will' : 'will not'} fit in an annotation."

if @failed.any?
  exit(1)
else
  exit(0)
end
