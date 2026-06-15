#!/usr/bin/env ruby

require 'yaml'
require 'json'

require 'open3'

# This check is split into two modes, each run as a separate Buildkite step:
#
#   internal — only checks Buildkite Docs links (those served by our own app,
#              i.e. the `/docs/...` pages and `#fragment` anchors within them).
#   external — only checks links pointing to other sites.
#
# Both modes share this script and the exemption rules; they differ only in
# which links they crawl/report and which annotation/exit code they produce.
MODE = ENV.fetch('LINK_CHECK_MODE', 'internal')
unless %w[internal external].include?(MODE)
  abort "LINK_CHECK_MODE must be 'internal' or 'external' (got #{MODE.inspect})"
end

# Internal docs links resolve to absolute URLs on the local app server, e.g.
# `/docs/foo` becomes `http://app:3000/docs/foo` and a `#bar` anchor becomes
# `http://app:3000/docs/<current-page>#bar`.
SITE_PREFIX = 'http://app:3000/'

def internal_link?(url)
  url.start_with?(SITE_PREFIX)
end

# Whether a link belongs to the bucket this run is responsible for.
def in_scope?(url)
  MODE == 'internal' ? internal_link?(url) : !internal_link?(url)
end

RESULTS_FILE = "muffet_results_#{MODE}.json"

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

until system('wget --spider -S http://app:3000/docs/agent/hooks')
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
  '--buffer-size=16384',
  '--format=json',
  # Capture successes as well as failures
  '--verbose',
]

# In internal mode, restrict crawling/checking to the local app server so we
# never make requests to external sites. Muffet still follows every internal
# page (they all match this pattern), so docs link discovery stays complete.
# In external mode we crawl everything, then filter the results down to
# external links below.
muffet_cmd << "--include='^http://app:3000'" if MODE == 'internal'

muffet_output_json=`#{muffet_cmd.join(' ')}`

File.write(RESULTS_FILE, muffet_output_json)

puts "--- Checking results"


pages = JSON.load(muffet_output_json)

pages.each do |page|
  page['links'].each do |link|
    unless link.has_key?('error')
      next
    end

    # Only consider links that belong to this run's bucket (internal vs external).
    next unless in_scope?(link['url'])

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

link_kind = MODE == 'internal' ? 'Buildkite Docs' : 'external'

report = ""
if @failed.any?
  report = <<~MARKDOWN
    ## Muffet found potentially broken #{link_kind} links

    Resolve _genuine broken links_ with either a **404** or **id #fragment not found** status first.

    Ignore links with a **timeout** / **timed out** / **503** status (since these are usually only temporarily broken), as well as _working links_ that return a **403** or **id #fragment not found** status, or an unusual status with a lengthy description.

    Configure any _consistently working_ **403** or **id #fragment not found** status links as exceptions in the relevant section of the `link-checking-rules.yaml` file, which moves them to the **Non-breaking failures** section below.

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

else
  report = "## Muffet found no #{link_kind} link problems :sunglasses:\n\n"
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

report += "The complete results (including **all** successful requests) will be uploaded in JSON format as the `#{RESULTS_FILE}` build artifact. If you need to figure out why links are passing checks when they shouldn't be, that is a good place to start.\n\n"

annotate!(annotation: report, context: "muffet-#{MODE}")

puts report.size
puts "Report #{report.size < 1024**2 ? 'will' : 'will not'} fit in an annotation."

if @failed.any?
  exit(1)
else
  exit(0)
end
