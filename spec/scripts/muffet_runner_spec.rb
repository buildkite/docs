require 'spec_helper'
require 'rbconfig'
require 'stringio'
require 'tmpdir'
require 'timeout'
require_relative '../../.buildkite/steps/muffet_runner'

RSpec.describe MuffetRunner do
  let(:pages) do
    [{ 'url' => 'http://app:3000/docs', 'links' => [
      { 'url' => 'https://example.com/ok', 'status' => 200 },
      { 'url' => 'https://example.com/missing', 'error' => '404' }
    ] }]
  end

  it 'preserves native JSON and accepts both successful and failed link checks' do
    Dir.mktmpdir do |dir|
      [0, 1].each do |exit_status|
        path = File.join(dir, 'results.json')
        output = StringIO.new
        json = JSON.pretty_generate(pages)
        program = "STDOUT.write(#{json.dump}); exit #{exit_status}"
        result = described_class.run([RbConfig.ruby, '-e', program], results_file: path, output: output)
        expect(result).to eq(pages)
        expect(File.read(path)).to eq(json)
        expect(output.string).to include('Muffet finished in', 'pages: 1')
      end
    end
  end

  it 'prints a heartbeat while the subprocess is still running and stops it afterward' do
    Dir.mktmpdir do |dir|
      release = File.join(dir, 'release')
      heartbeats = Queue.new
      output = Object.new
      output.define_singleton_method(:puts) do |message|
        heartbeats << message if message.start_with?('Muffet is still running:')
      end
      program = "sleep 0.01 until File.exist?(#{release.dump}); puts #{JSON.generate(pages).dump}"
      worker = Thread.new do
        described_class.run([RbConfig.ruby, '-e', program], results_file: File.join(dir, 'results.json'),
                            output: output, progress_interval: 0.02)
      end
      begin
        message = Timeout.timeout(5) { heartbeats.pop }
        expect(message).to include('elapsed', 'results appear when the crawl finishes')
        expect(worker).to be_alive
        File.write(release, '')
        expect(Timeout.timeout(5) { worker.value }).to eq(pages)
        heartbeats.pop until heartbeats.empty?
        sleep 0.06
        expect(heartbeats).to be_empty
      ensure
        File.write(release, '')
        worker.join(5)
      end
    end
  end

  it 'preserves output for debugging when the process fails' do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'results.json')
      expect do
        described_class.run([RbConfig.ruby, '-e', 'print "partial output"; exit 2'], results_file: path)
      end.to raise_error(/Muffet exited/)
      expect(File.read(path)).to eq('partial output')
    end
  end

  it 'rejects invalid or empty results rather than reporting success' do
    Dir.mktmpdir do |dir|
      ['', 'not json', '[]', '{}', 'null'].each do |json|
        path = File.join(dir, 'results.json')
        expect do
          described_class.run([RbConfig.ruby, '-e', "print #{json.dump}"], results_file: path)
        end.to raise_error(/Muffet returned (invalid JSON|no page results)/)
        expect(File.read(path)).to eq(json)
      end
    end
  end
end
