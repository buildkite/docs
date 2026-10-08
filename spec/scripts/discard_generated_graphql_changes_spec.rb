require "fileutils"
require "open3"
require "tmpdir"

RSpec.describe "discard-generated-graphql-changes.sh" do
  let(:script) { File.expand_path("../../.buildkite/scripts/discard-generated-graphql-changes.sh", __dir__) }

  def run_command(*command, chdir:)
    stdout, stderr, status = Open3.capture3(*command, chdir: chdir)
    raise "Command failed: #{command.join(' ')}\n#{stdout}\n#{stderr}" unless status.success?

    stdout
  end

  def write_file(path, content)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
  end

  around do |example|
    Dir.mktmpdir do |repo|
      @repo = repo
      run_command("git", "init", "--quiet", chdir: repo)
      run_command("git", "config", "user.email", "docs-bot@example.com", chdir: repo)
      run_command("git", "config", "user.name", "Docs Bot", chdir: repo)

      write_file("#{repo}/data/graphql/schema.graphql", "original schema\n")
      write_file("#{repo}/data/nav_graphql.yml", "original navigation\n")
      write_file("#{repo}/pages/apis/graphql/schemas/object/example.md", "original reference\n")
      write_file("#{repo}/pages/apis/graphql/cookbooks/example.md", "original cookbook\n")
      write_file("#{repo}/pages/pipelines/example.md", "original pipeline docs\n")

      run_command("git", "add", ".", chdir: repo)
      run_command("git", "commit", "--quiet", "-m", "Initial commit", chdir: repo)

      example.run
    end
  end

  def run_script(marker: nil)
    command = marker ? ["env", "DISCARDED_GENERATED_GRAPHQL_MARKER=#{marker}", script, "HEAD"] : [script, "HEAD"]
    run_command(*command, chdir: @repo)
  end

  def status
    run_command("git", "status", "--porcelain", "--untracked-files=all", chdir: @repo)
  end

  it "discards generated GraphQL modifications, deletions, and additions" do
    write_file("#{@repo}/data/graphql/schema.graphql", "changed schema\n")
    write_file("#{@repo}/data/nav_graphql.yml", "changed navigation\n")
    FileUtils.rm("#{@repo}/pages/apis/graphql/schemas/object/example.md")
    write_file("#{@repo}/pages/apis/graphql/schemas/object/new_type.md", "new reference\n")

    marker = File.join(Dir.tmpdir, "discarded-generated-graphql-#{Process.pid}")
    FileUtils.rm_f(marker)
    expect(run_script(marker: marker)).to include("Discarding changes to generated GraphQL reference files")
    expect(status).to eq("")
    expect(File.read("#{@repo}/data/graphql/schema.graphql")).to eq("original schema\n")
    expect(File).not_to exist("#{@repo}/pages/apis/graphql/schemas/object/new_type.md")
    expect(File).to exist(marker)
  ensure
    FileUtils.rm_f(marker) if marker
  end

  it "preserves manually maintained GraphQL documentation" do
    write_file("#{@repo}/data/graphql/schema.graphql", "changed schema\n")
    write_file("#{@repo}/pages/apis/graphql/cookbooks/example.md", "changed cookbook\n")

    run_script

    expect(status).to eq(" M pages/apis/graphql/cookbooks/example.md\n")
  end

  it "preserves non-GraphQL documentation" do
    write_file("#{@repo}/pages/pipelines/example.md", "changed pipeline docs\n")

    expect(run_script).to eq("")
    expect(status).to eq(" M pages/pipelines/example.md\n")
  end
end
