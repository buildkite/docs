require "rails_helper"

RSpec.describe LLMFullText do
  let(:nav_data) do
    [
      {
        name: "Pipelines",
        children: [
          {
            name: "Getting Started",
            path: "pipelines/getting-started"
          },
          {
            name: "Configuration",
            children: [
              {
                name: "Step types",
                path: "pipelines/configuration/step-types"
              },
              {
                name: "Environment variables",
                path: "pipelines/configuration/environment-variables"
              }
            ]
          }
        ]
      },
      {
        name: "APIs",
        children: [
          {
            name: "REST API",
            path: "apis/rest-api"
          },
          {
            name: "GraphQL Schema",
            path: "apis/graphql/schemas/query"
          }
        ]
      }
    ].map(&:deep_stringify_keys)
  end

  let(:nav) { double("Nav", data: nav_data) }
  subject(:llm_full_text) { described_class.new(nav) }

  describe ".generate" do
    it "creates a new instance with Rails default_nav and calls generate" do
      default_nav = double("DefaultNav")
      allow(Rails.application.config).to receive(:default_nav).and_return(default_nav)

      instance = double("LLMFullText")
      allow(LLMFullText).to receive(:new).with(default_nav).and_return(instance)
      allow(instance).to receive(:generate).and_return("generated content")

      expect(LLMFullText.generate).to eq("generated content")
    end
  end

  describe "#generate" do
    before do
      allow(File).to receive(:exist?).and_call_original
    end

    context "when page files exist" do
      let(:nav_data) do
        [
          {
            name: "Test Section",
            children: [
              {
                name: "Test Page",
                path: "test/my-page"
              }
            ]
          }
        ].map(&:deep_stringify_keys)
      end

      before do
        filepath = Rails.root.join("pages", "test/my_page.md")
        allow(File).to receive(:exist?).with(filepath).and_return(true)

        parsed = double("Parsed", content: "# Test Page\n\nThis is test content.")
        allow(::FrontMatterParser::Parser).to receive(:parse_file).with(filepath).and_return(parsed)
      end

      it "includes the header" do
        result = llm_full_text.generate
        expect(result).to include("# Buildkite Documentation")
        expect(result).to include("> Buildkite is a platform for running fast, secure")
      end

      it "includes the section heading" do
        result = llm_full_text.generate
        expect(result).to include("## Test Section")
      end

      it "includes the page name as a heading" do
        result = llm_full_text.generate
        expect(result).to include("### Test Page")
      end

      it "includes the page URL" do
        result = llm_full_text.generate
        expect(result).to include("URL: https://buildkite.com/docs/test/my-page")
      end

      it "includes the page content with bumped headings" do
        result = llm_full_text.generate
        expect(result).to include("This is test content.")
        expect(result).to include("#### Test Page")
        expect(result).not_to match(/^# Test Page/)
      end

      it "separates pages with horizontal rules" do
        result = llm_full_text.generate
        expect(result).to include("---")
      end
    end

    context "when page files do not exist" do
      let(:nav_data) do
        [
          {
            name: "Missing Section",
            children: [
              {
                name: "Missing Page",
                path: "missing/page"
              }
            ]
          }
        ].map(&:deep_stringify_keys)
      end

      before do
        filepath = Rails.root.join("pages", "missing/page.md")
        allow(File).to receive(:exist?).with(filepath).and_return(false)
      end

      it "skips pages that do not exist on disk" do
        result = llm_full_text.generate
        expect(result).not_to include("Missing Page")
      end
    end

    context "heading level adjustment" do
      let(:nav_data) do
        [
          {
            name: "Test Section",
            children: [
              {
                name: "Heading Page",
                path: "test/headings"
              }
            ]
          }
        ].map(&:deep_stringify_keys)
      end

      before do
        filepath = Rails.root.join("pages", "test/headings.md")
        allow(File).to receive(:exist?).with(filepath).and_return(true)

        content = [
          "# Page title",
          "## Section",
          "### Subsection",
          "#### Detail",
          "Some text with #hashtag intact"
        ].join("\n")
        parsed = double("Parsed", content: content)
        allow(::FrontMatterParser::Parser).to receive(:parse_file).with(filepath).and_return(parsed)
      end

      it "bumps page headings down by 3 levels" do
        result = llm_full_text.generate
        expect(result).to include("#### Page title")
        expect(result).to include("##### Section")
        expect(result).to include("###### Subsection")
      end

      it "caps headings at H6" do
        result = llm_full_text.generate
        expect(result).to include("###### Detail")
        expect(result).not_to include("#######")
      end

      it "does not modify non-heading hash characters" do
        result = llm_full_text.generate
        expect(result).to include("#hashtag")
      end
    end

    context "with Redcarpet inline attribute lists" do
      let(:nav_data) do
        [
          {
            name: "Test Section",
            children: [
              {
                name: "IAL Page",
                path: "test/ial"
              }
            ]
          }
        ].map(&:deep_stringify_keys)
      end

      before do
        filepath = Rails.root.join("pages", "test/ial.md")
        allow(File).to receive(:exist?).with(filepath).and_return(true)

        content = [
          "Header 1 | Header 2",
          "--- | ---",
          "Cell 1 | Cell 2",
          '{: class="responsive-table"}',
          "",
          "```yaml",
          "steps:",
          "  - command: echo hello",
          "```",
          '{: codeblock-file="pipeline.yml"}'
        ].join("\n")
        parsed = double("Parsed", content: content)
        allow(::FrontMatterParser::Parser).to receive(:parse_file).with(filepath).and_return(parsed)
      end

      it "strips Redcarpet IAL annotations" do
        result = llm_full_text.generate
        expect(result).not_to include('{: class="responsive-table"}')
        expect(result).not_to include('{: codeblock-file="pipeline.yml"}')
      end

      it "preserves the table and code block content" do
        result = llm_full_text.generate
        expect(result).to include("Header 1 | Header 2")
        expect(result).to include("Cell 1 | Cell 2")
        expect(result).to include("- command: echo hello")
      end
    end

    context "ERB helper resolution" do
      let(:nav_data) do
        [
          {
            name: "ERB Section",
            children: [
              {
                name: "ERB Page",
                path: "erb/page"
              }
            ]
          }
        ].map(&:deep_stringify_keys)
      end

      context "with image helpers" do
        before do
          filepath = Rails.root.join("pages", "erb/page.md")
          allow(File).to receive(:exist?).with(filepath).and_return(true)

          content = "Some text\n<%= image 'screenshot.png' %>\nMore text\n<%= image 'diagram.png', width: 800, height: 600 %>"
          parsed = double("Parsed", content: content)
          allow(::FrontMatterParser::Parser).to receive(:parse_file).with(filepath).and_return(parsed)
        end

        it "replaces image helpers with descriptive placeholders" do
          result = llm_full_text.generate
          expect(result).to include("[Image: screenshot.png]")
          expect(result).to include("[Image: diagram.png]")
          expect(result).not_to include("<%=")
        end
      end

      context "with URL helpers" do
        before do
          filepath = Rails.root.join("pages", "erb/page.md")
          allow(File).to receive(:exist?).with(filepath).and_return(true)

          content = 'Returns a [paginated list](<%= paginated_resource_docs_url %>) of resources.'
          parsed = double("Parsed", content: content)
          allow(::FrontMatterParser::Parser).to receive(:parse_file).with(filepath).and_return(parsed)
        end

        it "resolves paginated_resource_docs_url to the actual URL" do
          result = llm_full_text.generate
          expect(result).to include("[paginated list](/docs/apis/rest-api#pagination)")
          expect(result).not_to include("<%=")
        end
      end

      context "with url_helpers" do
        before do
          filepath = Rails.root.join("pages", "erb/page.md")
          allow(File).to receive(:exist?).with(filepath).and_return(true)

          content = '<a href="<%= url_helpers.user_access_tokens_url %>">API tokens</a>'
          parsed = double("Parsed", content: content)
          allow(::FrontMatterParser::Parser).to receive(:parse_file).with(filepath).and_return(parsed)
        end

        it "resolves url_helpers to actual URLs" do
          result = llm_full_text.generate
          expect(result).to include("[API tokens](https://buildkite.com/user/api-access-tokens)")
          expect(result).not_to include("<%=")
        end
      end

      context "with render_markdown partials" do
        before do
          filepath = Rails.root.join("pages", "erb/page.md")
          allow(File).to receive(:exist?).with(filepath).and_return(true)

          content = "Before partial\n<%= render_markdown partial: 'shared/my-partial' %>\nAfter partial"
          parsed = double("Parsed", content: content)
          allow(::FrontMatterParser::Parser).to receive(:parse_file).with(filepath).and_return(parsed)

          partial_path = Rails.root.join("pages", "shared/my_partial.md")
          partial_underscored = File.join(File.dirname(partial_path), "_my_partial.md")
          allow(File).to receive(:exist?).with(partial_path).and_return(false)
          allow(File).to receive(:exist?).with(partial_underscored).and_return(true)

          partial_parsed = double("Parsed", content: "Inlined partial content")
          allow(::FrontMatterParser::Parser).to receive(:parse_file).with(partial_underscored).and_return(partial_parsed)
        end

        it "inlines the partial content" do
          result = llm_full_text.generate
          expect(result).to include("Before partial")
          expect(result).to include("Inlined partial content")
          expect(result).to include("After partial")
          expect(result).not_to include("render_markdown")
        end
      end

      context "with render partials" do
        before do
          filepath = Rails.root.join("pages", "erb/page.md")
          allow(File).to receive(:exist?).with(filepath).and_return(true)

          content = "Before\n<%= render 'agent/cli/help/annotate' %>\nAfter"
          parsed = double("Parsed", content: content)
          allow(::FrontMatterParser::Parser).to receive(:parse_file).with(filepath).and_return(parsed)

          partial_path = Rails.root.join("pages", "agent/cli/help/annotate.md")
          partial_underscored = File.join(File.dirname(partial_path), "_annotate.md")
          allow(File).to receive(:exist?).with(partial_path).and_return(false)
          allow(File).to receive(:exist?).with(partial_underscored).and_return(true)

          partial_parsed = double("Parsed", content: "Annotate help content")
          allow(::FrontMatterParser::Parser).to receive(:parse_file).with(partial_underscored).and_return(partial_parsed)
        end

        it "inlines the partial content" do
          result = llm_full_text.generate
          expect(result).to include("Annotate help content")
          expect(result).not_to include("<%= render")
        end
      end

      context "with unresolvable ERB" do
        before do
          filepath = Rails.root.join("pages", "erb/page.md")
          allow(File).to receive(:exist?).with(filepath).and_return(true)

          content = "Text before\n<%= some_unknown_helper %>\nText after"
          parsed = double("Parsed", content: content)
          allow(::FrontMatterParser::Parser).to receive(:parse_file).with(filepath).and_return(parsed)
        end

        it "strips remaining ERB tags as a fallback" do
          result = llm_full_text.generate
          expect(result).to include("Text before")
          expect(result).to include("Text after")
          expect(result).not_to include("<%=")
          expect(result).not_to include("some_unknown_helper")
        end
      end
    end

    context "HTML to Markdown conversion" do
      let(:nav_data) do
        [
          {
            name: "Test Section",
            children: [
              {
                name: "HTML Page",
                path: "test/html"
              }
            ]
          }
        ].map(&:deep_stringify_keys)
      end

      before do
        filepath = Rails.root.join("pages", "test/html.md")
        allow(File).to receive(:exist?).with(filepath).and_return(true)
      end

      it "converts HTML links to Markdown links" do
        content = 'Visit <a href="https://buildkite.com">Buildkite</a> for details.'
        parsed = double("Parsed", content: content)
        allow(::FrontMatterParser::Parser).to receive(:parse_file).and_return(parsed)

        result = llm_full_text.generate
        expect(result).to include("[Buildkite](https://buildkite.com)")
        expect(result).not_to include("<a ")
      end

      it "converts inline formatting tags" do
        content = "<strong>bold</strong> and <em>italic</em> and <code>mono</code>"
        parsed = double("Parsed", content: content)
        allow(::FrontMatterParser::Parser).to receive(:parse_file).and_return(parsed)

        result = llm_full_text.generate
        expect(result).to include("**bold**")
        expect(result).to include("_italic_")
        expect(result).to include("`mono`")
      end

      it "converts HTML headings to Markdown headings" do
        content = '<h2>Section title</h2>'
        parsed = double("Parsed", content: content)
        allow(::FrontMatterParser::Parser).to receive(:parse_file).and_return(parsed)

        result = llm_full_text.generate
        # h2 becomes ## then gets bumped +3 to #####
        expect(result).to include("##### Section title")
        expect(result).not_to include("<h2>")
      end

      it "converts HTML tables to pipe-separated text" do
        content = "<table><tr><th>Name</th><th>Value</th></tr><tr><td>key</td><td>val</td></tr></table>"
        parsed = double("Parsed", content: content)
        allow(::FrontMatterParser::Parser).to receive(:parse_file).and_return(parsed)

        result = llm_full_text.generate
        expect(result).to include("| Name")
        expect(result).to include("| Value")
        expect(result).to include("| key")
        expect(result).not_to include("<table>")
        expect(result).not_to include("<tr>")
      end

      it "converts details/summary to plain text" do
        content = "<details><summary>More info</summary>Hidden content</details>"
        parsed = double("Parsed", content: content)
        allow(::FrontMatterParser::Parser).to receive(:parse_file).and_return(parsed)

        result = llm_full_text.generate
        expect(result).to include("**More info**")
        expect(result).to include("Hidden content")
        expect(result).not_to include("<details>")
      end

      it "decodes HTML entities" do
        content = "Use &lt;command&gt; and &amp; operator"
        parsed = double("Parsed", content: content)
        allow(::FrontMatterParser::Parser).to receive(:parse_file).and_return(parsed)

        result = llm_full_text.generate
        expect(result).to include("Use <command> and & operator")
      end

      it "strips remaining unrecognized HTML tags" do
        content = '<div class="wrapper"><span>text</span></div>'
        parsed = double("Parsed", content: content)
        allow(::FrontMatterParser::Parser).to receive(:parse_file).and_return(parsed)

        result = llm_full_text.generate
        expect(result).to include("text")
        expect(result).not_to include("<div")
        expect(result).not_to include("<span")
      end
    end

    context "with HTML comments in content" do
      let(:nav_data) do
        [
          {
            name: "Comment Section",
            children: [
              {
                name: "Comment Page",
                path: "comment/page"
              }
            ]
          }
        ].map(&:deep_stringify_keys)
      end

      before do
        filepath = Rails.root.join("pages", "comment/page.md")
        allow(File).to receive(:exist?).with(filepath).and_return(true)

        content = "Visible text\n<!-- hidden comment -->\nMore visible text"
        parsed = double("Parsed", content: content)
        allow(::FrontMatterParser::Parser).to receive(:parse_file).with(filepath).and_return(parsed)
      end

      it "strips HTML comments from content" do
        result = llm_full_text.generate
        expect(result).to include("Visible text")
        expect(result).to include("More visible text")
        expect(result).not_to include("hidden comment")
      end
    end

    context "with GraphQL schema pages" do
      it "filters out GraphQL schema documentation" do
        result = llm_full_text.generate
        expect(result).not_to include("GraphQL Schema")
        expect(result).not_to include("apis/graphql/schemas/query")
      end
    end

    context "with dividers in navigation" do
      let(:nav_data) do
        [
          {
            name: "Test Section",
            children: [
              {
                name: "Valid Page",
                path: "test/valid"
              },
              {
                type: "divider"
              },
              {
                name: "Another Page",
                path: "test/another"
              }
            ]
          }
        ].map(&:deep_stringify_keys)
      end

      before do
        valid_filepath = Rails.root.join("pages", "test/valid.md")
        another_filepath = Rails.root.join("pages", "test/another.md")

        allow(File).to receive(:exist?).with(valid_filepath).and_return(true)
        allow(File).to receive(:exist?).with(another_filepath).and_return(true)

        parsed_valid = double("Parsed", content: "Valid content")
        parsed_another = double("Parsed", content: "Another content")

        allow(::FrontMatterParser::Parser).to receive(:parse_file).with(valid_filepath).and_return(parsed_valid)
        allow(::FrontMatterParser::Parser).to receive(:parse_file).with(another_filepath).and_return(parsed_another)
      end

      it "skips dividers and includes valid pages" do
        result = llm_full_text.generate
        expect(result).to include("Valid content")
        expect(result).to include("Another content")
        expect(result).not_to include("divider")
      end
    end

    context "when a top-level section has both a path and children" do
      let(:nav_data) do
        [
          {
            name: "Pipelines",
            path: "pipelines",
            children: [
              {
                name: "Getting Started",
                path: "pipelines/getting-started"
              }
            ]
          }
        ].map(&:deep_stringify_keys)
      end

      before do
        pipelines = Rails.root.join("pages", "pipelines.md")
        getting_started = Rails.root.join("pages", "pipelines/getting_started.md")

        allow(File).to receive(:exist?).with(pipelines).and_return(true)
        allow(File).to receive(:exist?).with(getting_started).and_return(true)

        allow(::FrontMatterParser::Parser).to receive(:parse_file).with(pipelines)
          .and_return(double("Parsed", content: "Pipelines overview content"))
        allow(::FrontMatterParser::Parser).to receive(:parse_file).with(getting_started)
          .and_return(double("Parsed", content: "Getting started content"))
      end

      it "includes the section's own page" do
        result = llm_full_text.generate
        expect(result).to include("### Pipelines")
        expect(result).to include("URL: https://buildkite.com/docs/pipelines")
        expect(result).to include("Pipelines overview content")
      end

      it "also includes the section's children" do
        result = llm_full_text.generate
        expect(result).to include("### Getting Started")
        expect(result).to include("Getting started content")
      end
    end

    context "with nested navigation" do
      before do
        # Set up files for the nested nav_data fixture
        getting_started = Rails.root.join("pages", "pipelines/getting_started.md")
        step_types = Rails.root.join("pages", "pipelines/configuration/step_types.md")
        env_vars = Rails.root.join("pages", "pipelines/configuration/environment_variables.md")
        rest_api = Rails.root.join("pages", "apis/rest_api.md")

        allow(File).to receive(:exist?).with(getting_started).and_return(true)
        allow(File).to receive(:exist?).with(step_types).and_return(true)
        allow(File).to receive(:exist?).with(env_vars).and_return(true)
        allow(File).to receive(:exist?).with(rest_api).and_return(true)

        allow(::FrontMatterParser::Parser).to receive(:parse_file).with(getting_started)
          .and_return(double("Parsed", content: "Getting started content"))
        allow(::FrontMatterParser::Parser).to receive(:parse_file).with(step_types)
          .and_return(double("Parsed", content: "Step types content"))
        allow(::FrontMatterParser::Parser).to receive(:parse_file).with(env_vars)
          .and_return(double("Parsed", content: "Environment variables content"))
        allow(::FrontMatterParser::Parser).to receive(:parse_file).with(rest_api)
          .and_return(double("Parsed", content: "REST API content"))
      end

      it "flattens nested children into page entries" do
        result = llm_full_text.generate
        expect(result).to include("### Getting Started")
        expect(result).to include("### Step types")
        expect(result).to include("### Environment variables")
        expect(result).to include("### REST API")
      end

      it "includes content from all nested pages" do
        result = llm_full_text.generate
        expect(result).to include("Getting started content")
        expect(result).to include("Step types content")
        expect(result).to include("Environment variables content")
        expect(result).to include("REST API content")
      end
    end
  end
end
