#!/usr/bin/env ruby

require 'yaml'

def annotate!(annotation:, context:, style: "info")
  if ENV.key?("BUILDKITE")
    puts "Uploading annotation (#{annotation.size} bytes)"
    system!("buildkite-agent", "annotate", "--style", style, "--context", context, stdin_data: annotation)
  else
    puts "--- ANNOTATION [#{style},#{context}]"
    puts annotation
    puts
  end
end

def rules
  return @rules if @rules

  rules_yaml = YAML.load(File.read('link-checking-rules.yaml'))

  @rules = rules_yaml['rules'].each_with_object([]) do |r, arr|
    arr << {
      name: r['name'],
      description: r['description'],
      status_pattern: /^#{r['status_pattern']}$/,
      url_patterns: r['url_patterns'].map {|url| /^#{url}/ }
    }
  end
end

failed = {}
def result_fail(page, link)
  failed[page] ||= []

  failed[page] << link
end

passed = {}
def result_pass(page, link, decided_by)
  passed[page] ||= []

  passed[page] << link.merge({'decided_by' => decided_by})
end

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

File.open('muffet_results.json', 'w') do |f|
  f.write(muffet_output_json)
end

puts "--- Verbose JSON output from muffet"
puts muffet_output_json

puts "--- Checking results"


pages = JSON.load(muffet_output_json)

pages.each do |page|
  page['links'].each do |link|
    unless link.has?('error')
      next
    end

    rules.each do |rule|
      if rule[:status_pattern] =~ link['error']
        if rule[:url_patterns].any? {|patt| patt =~ link['url'] }
          result_pass(page, link, rule[:name])
          break
        end

        result_fail(page, link)
      end
    end
  end
end

report = ""
if failures.any?
  report = <<~MARKDOWN
    ## Muffet found broken links

    First, resolve links with statuses other than 429 or 403 (especially, 404).

  MARKDOWN

  failures.each do |page, links|
    path_and_query = page.sub(/https?:\/\/[^\/]+/,'')

    rows = links.each_with_object("") do |l, table|
      table += "| #{l['url']} | #{l['error']} |\n"
    end

    report += <<~MARKDOWN
      In #{path_and_query}:

      | Link | Status |
      #{rows}

    MARKDOWN

  end
else
  report = "## Muffet found no problems :sunglasses:\n\n"
end

if successes.any?
  report += <<~MARKDOWN
    The following requests would have failed, but we made them exempt in `.buildkite/steps/link-checking-rules.yaml`.

  MARKDOWN

  successes.each do |page, links|
    path_and_query = page.sub(/https?:\/\/[^\/]+/,'')

    rows = links.each_with_object("") do |l, table|
      table += "| #{l['url']} | #{l['error']} | #{l['decided_by']} |\n"
    end

    report += <<~MARKDOWN
      In #{path_and_query}:

      | Link | Status | Deciding rule |
      #{rows}

    MARKDOWN
  end
end

report += "The complete results (including **all** successful requests) will be uploaded in JSON format as a build artifact. If you need to figure out why links are passing checks when they shouldn't be, that is a good place to start.\n\n"

annotate!(report)
