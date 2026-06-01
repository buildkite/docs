require 'rails_helper'

RSpec.describe Page::Renderer do
  it "renders basic markdown" do
    md = <<~MD
      # Page title
      Some description
    MD

    html = <<~HTML
      <h1>Page title</h1>

      <p>Some description</p>
    HTML

    expect(Page::Renderer.render(md).strip).to eql(html.strip)
  end

  it "adds custom syntax highlighting for curl examples" do
    md = <<~MD
      ```bash
      curl "https://api.buildkite.com/v2/organizations/{org.slug}/builds"
      ```
    MD

    doc = Nokogiri::HTML.fragment(Page::Renderer.render(md))
    pre = doc.at_css('pre.highlight.shell')

    expect(pre).not_to be_nil
    expect(pre.at_css('code').text).to eql("curl \"https://api.buildkite.com/v2/organizations/{org.slug}/builds\"\n")
    expect(pre.at_css('code .o')&.text).to eql('{org.slug}')

    # The wrapping <div class="highlight"> is the copy button's positioning context
    expect(pre.parent.name).to eql('div')
    expect(pre.parent['class']).to eql('highlight')
  end

  it "supports {: code-filename=\"file.md\"} filenames for code blocks" do
    md = <<~MD
      ```json
      { "key": "value" }
      ```
      {: codeblock-file="file.json"}
    MD

    doc = Nokogiri::HTML.fragment(Page::Renderer.render(md))
    figure = doc.at_css('figure.highlight-figure')

    expect(figure).not_to be_nil
    expect(figure.at_css('figcaption')&.text).to eql('file.json')
    expect(figure.at_css('pre.highlight.json code')&.text).to eql("{ \"key\": \"value\" }\n")

    # The wrapping <div class="highlight"> must nest inside the figure (copy button positioning context)
    expect(figure.at_css('div.highlight > pre.highlight.json')).not_to be_nil
  end

  it 'supports custom Callouts' do
    md = <<~MD
      > 🚧 Troubleshooting: `launchctl` fails with "error"
      > Ensure **strong emphasis** works
      > Second paragraph has _emphasis_
    MD

    html = <<~HTML
      <section class="callout callout--troubleshooting">
        <p class="callout__title"><a class="callout__anchor" href="#troubleshooting-launchctl-fails-with-error" id="troubleshooting-launchctl-fails-with-error"> Troubleshooting: <code>launchctl</code> fails with "error"</a></p>
        <p>Ensure <strong>strong emphasis</strong> works</p>
      <p>Second paragraph has <em>emphasis</em></p>
      </section>
    HTML

    expect(Page::Renderer.render(md).strip).to eql(html.strip)
  end

  it 'supports custom Callouts without a title' do
    md = <<~MD
      > 🚧
      > Ensure **strong emphasis** works
      > Second paragraph has _emphasis_
    MD

    html = <<~HTML
      <section class="callout callout--troubleshooting">
  
  <p>Ensure <strong>strong emphasis</strong> works</p>
<p>Second paragraph has <em>emphasis</em></p>
</section>
    HTML

    expect(Page::Renderer.render(md).strip).to eql(html.strip)
  end

  describe "#decorate_external_links" do
    it "adds `.external-link` class and `_blank` target to external links" do
      md = <<~MD
        [Google](https://www.google.com)
      MD

      html = <<~HTML
        <p><a href="https://www.google.com" class="external-link" target="_blank">Google</a></p>
      HTML

      expect(Page::Renderer.render(md).strip).to eql(html.strip)
    end

    context "non-external links" do
      it "does not affect /docs/ links" do
        md = <<~MD
          [Test Engine](/docs/test-engine)
        MD
  
        html = <<~HTML
          <p><a href="/docs/test-engine">Test Engine</a></p>
        HTML

        expect(Page::Renderer.render(md).strip).to eql(html.strip)
      end

      it "does not affect links to Buildkite domains" do
        md = <<~MD
          [Test Engine](https://buildkite.com/test-engine)

          [GraphQL Explorer](https://graphql.buildkite.com/explorer)

          [Buildkite status](https://www.buildkitestatus.com)
        MD

        html = <<~HTML
          <p><a href="https://buildkite.com/test-engine">Test Engine</a></p>

          <p><a href="https://graphql.buildkite.com/explorer">GraphQL Explorer</a></p>

          <p><a href="https://www.buildkitestatus.com">Buildkite status</a></p>
        HTML

        expect(Page::Renderer.render(md).strip).to eql(html.strip)
      end

      it "does not affect internal fragments" do
        md = <<~MD
          [Back to top](#top)
        MD
  
        html = <<~HTML
          <p><a href="#top">Back to top</a></p>
        HTML

        expect(Page::Renderer.render(md).strip).to eql(html.strip)
      end

      it "does not affect mailto:" do
        md = <<~MD
          [Email us](mailto:test@example.com)
        MD
  
        html = <<~HTML
          <p><a href="mailto:test@example.com">Email us</a></p>
        HTML

        expect(Page::Renderer.render(md).strip).to eql(html.strip)
      end

      it "does not affect tel:" do
        md = <<~MD
          [Call us](tel:131313)
        MD
  
        html = <<~HTML
          <p><a href="tel:131313">Call us</a></p>
        HTML

        expect(Page::Renderer.render(md).strip).to eql(html.strip)
      end
    end


    it "does not affect links with existing css classes" do
      md = <<~MD
        <p><a href="https://www.github.com/buildkite/docs" class="Docs__example-repo" target="_blank">Docs repo</a></p>
      MD

      html = <<~HTML
        <p><a href="https://www.github.com/buildkite/docs" class="Docs__example-repo" target="_blank">Docs repo</a></p>
      HTML

      expect(Page::Renderer.render(md).strip).to eql(html.strip)
    end
  end

  describe "Responsive table" do
    it "prepends faux th to each table cell" do
      md = <<~MD
        | Name   | Price    |
        | ------ | -------- |
        | Apple  | $4.00/kg |
        | Orange | $5.00/kg |
        {: class="responsive-table"}
      MD

      html_in_md = <<~HTML
        <table class="responsive-table">
        <thead>
        <tr>
        <th>Name</th>
        <th>Price</th>
        </tr>
        </thead>
        <tbody>
        <tr>
        <td>Apple</td>
        <td>$4.00/kg</td>
        </tr>
        <tr>
        <td>Orange</td>
        <td>$5.00/kg</td>
        </tr>
        </tbody>
        </table>
      HTML

      html = <<~HTML
        <table class="responsive-table">
        <thead>
        <tr>
        <th>Name</th>
        <th>Price</th>
        </tr>
        </thead>
        <tbody>
        <tr>
        <th aria-hidden class="responsive-table__faux-th">Name</th>
        <td>Apple</td>
        <th aria-hidden class="responsive-table__faux-th">Price</th>
        <td>$4.00/kg</td>
        </tr>
        <tr>
        <th aria-hidden class="responsive-table__faux-th">Name</th>
        <td>Orange</td>
        <th aria-hidden class="responsive-table__faux-th">Price</th>
        <td>$5.00/kg</td>
        </tr>
        </tbody>
        </table>
      HTML

      expect(Page::Renderer.render(md).strip).to eql(html.strip)
      expect(Page::Renderer.render(html_in_md).strip).to eql(html.strip)
    end

    it "does't affect tables without the .responsive-table CSS class" do
      md = <<~MD
        | Name   | Price    |
        | ------ | -------- |
        | Apple  | $4.00/kg |
        | Orange | $5.00/kg |
      MD

      html = <<~HTML
        <table>
        <thead>
        <tr>
        <th>Name</th>
        <th>Price</th>
        </tr>
        </thead>
        <tbody>
        <tr>
        <td>Apple</td>
        <td>$4.00/kg</td>
        </tr>
        <tr>
        <td>Orange</td>
        <td>$5.00/kg</td>
        </tr>
        </tbody>
        </table>
      HTML

      expect(Page::Renderer.render(md).strip).to eql(html.strip)
    end
  end
end
