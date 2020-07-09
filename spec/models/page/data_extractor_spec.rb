require 'rails_helper'

RSpec.describe Page::DataExtractor do
  describe "page title and description fields" do
    it "extracts data from basic markdown" do
      md = <<~MD
        # Page title

        Some description
      MD

      expect(Page::DataExtractor.extract(md)).to eql({
        "attributes" => [],
        "name" => "Page title",
        "shortDescription" => "Some description",
        "textContent" => "Some description"
      })
    end

    it "Takes the first page title only" do
      md = <<~MD
        # Page title

        # Another page title? Weird!

        Some description
      MD

      expect(Page::DataExtractor.extract(md)).to eql({
        "attributes" => [],
        "name" => "Page title",
        "shortDescription" => "Some description",
        "textContent" => "Some description"
      })
    end

    it "ignores table-of-contents directives, stops at secondary headings" do
      md = <<~MD
        # Page title

        {:toc}

        Some description

        And some more description here

        ## Here's a second heading

        More text goes here!

        ## Here's another!

        Yet more text goes in this section
      MD

      expect(Page::DataExtractor.extract(md)).to eql({
        "attributes" => [],
        "name" => "Page title",
        "shortDescription" => "Some description",
        "textContent" => <<~MD.strip
          Some description

          And some more description here
        MD
      })
    end

    it "ignores raw HTML tags in the description" do
      md = <<~MD
        # Page title

        {:toc}

        Some description

        <img src="https://placekitten.com/320/240" />

        More text goes here
      MD

      expect(Page::DataExtractor.extract(md)).to eql({
        "attributes" => [],
        "name" => "Page title",
        "shortDescription" => "Some description",
        "textContent" => <<~MD.strip
          Some description

          More text goes here
        MD
      })
    end

    it "supports {: code-filename=\"file.md\"} filenames for code blocks" do
      md = <<~MD
        ```json
        { "key": "value" }
        ```
        {: codeblock-file="file.json"}
      MD

      expect(Page::DataExtractor.extract(md)).to eql({
        "attributes" => [],
        "name" => nil,
        "shortDescription" => "",
        "textContent" => <<~MD.strip
          <figure class="highlight-figure"><figcaption>file.json</figcaption>

          ``` json
          { "key": "value" }
          ```

          </figure>
        MD
      })
    end
  end
end
