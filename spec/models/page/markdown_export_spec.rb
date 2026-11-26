require "rails_helper"

RSpec.describe Page::MarkdownExport do
  it "converts irregular HTML rows without losing cells, links, or the adjacent callout" do
    body = <<~MARKDOWN
      <table>
        <tr><th>Name<th>Value

          <tr><td>First<td><code>a|b</code>
          <tr><td>Second<td><a class="test" href="/docs/agent"><strong>Read &amp; run</strong></a>
      </table>
      {: class="responsive-table"}

      > 🚧 Warning
      > Keep this marker.
    MARKDOWN

    markdown = described_class.format(body, "/docs/example")
    html = Nokogiri::HTML5.fragment(Commonmarker.to_html(markdown, options: { extension: { table: true } }))

    expect(html.css("table tr").map { |row| row.element_children.map(&:text) }).to eq([
      ["Name", "Value"], ["First", "a|b"], ["Second", "Read & run"]
    ])
    expect(html.at_css("td a")["href"]).to eq("https://buildkite.com/docs/agent.md")
    expect(markdown).to include("> 🚧 Warning\n> Keep this marker.")
    expect(markdown).not_to include("responsive-table")
  end

  it "keeps complex table semantics and does not convert a table in example code" do
    body = <<~MARKDOWN
      <table>
        <caption>Grouped values</caption>
        <tr><td colspan="2"><blockquote>⚠ Preserve this note.</blockquote></td></tr>
      </table>

      ```html
      <table><tr><th>Example</th></tr><tr><td>Literal</td></tr></table>
      {: class="example"}
      ```
      {: codeblock-file="example.html"}
    MARKDOWN

    markdown = described_class.format(body, "/docs/example")

    expect(markdown).to include(
      "<caption>Grouped values</caption>",
      '<td colspan="2"><blockquote>⚠ Preserve this note.</blockquote></td>',
      "<table><tr><th>Example</th></tr><tr><td>Literal</td></tr></table>\n{: class=\"example\"}",
      "File: `example.html`"
    )
    expect(markdown).not_to include("codeblock-file")
  end
end
