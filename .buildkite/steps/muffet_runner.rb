require 'json'
require 'open3'

module MuffetRunner
  def self.run(command, results_file:, output: $stdout, progress_interval: 15)
    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    progress = Thread.new do
      loop do
        sleep progress_interval
        elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started
        output.puts "Muffet is still running: #{elapsed.round}s elapsed (results appear when the crawl finishes)"
      end
    end

    json, status = Open3.capture2(*command)
    File.write(results_file, json)
    raise "Muffet exited with #{status}" unless [0, 1].include?(status.exitstatus)

    begin
      pages = JSON.parse(json)
    rescue JSON::ParserError
      raise "Muffet returned invalid JSON; see #{results_file}"
    end
    raise 'Muffet returned no page results' unless pages.is_a?(Array) && !pages.empty?

    elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started
    output.puts "Muffet finished in #{elapsed.round(1)}s; pages: #{pages.size}"
    pages
  ensure
    progress&.kill
    progress&.join
  end
end
