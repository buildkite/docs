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

  describe "TOC generation" do
    it "adds TOC and heading links" do
      md = <<~MD
        {:toc}

        ## Section
      MD

      html = <<~HTML
        <div class="Docs__toc">
          <p>On this page:</p>
          <ul>
            <li><a href="#section">Section</a></li>
          </ul>
        </div>

        <h2 class="Docs__heading" id="section">Section<a href="#section" aria-hidden="true" class="Docs__heading__anchor"></a>
        </h2>
      HTML

      expect(Page::Renderer.render(md).strip).to eql(html.strip)
    end

    it "ignores nested h2s" do
      md = <<~MD
        {:toc}

        ## Section

        <section>
          <hgroup>
            <h1>Subsection</h1>
            <h2>Subheading</h2>
          </hgroup>
        </section>
      MD

      html = <<~HTML
        <div class="Docs__toc">
          <p>On this page:</p>
          <ul>
            <li><a href="#section">Section</a></li>
          </ul>
        </div>
        
        <h2 class="Docs__heading" id="section">Section<a href="#section" aria-hidden="true" class="Docs__heading__anchor"></a>
        </h2>
        
        <section>
          <hgroup>
            <h1>Subsection</h1>
            <h2>Subheading</h2>
          </hgroup>
        </section>
      HTML

      expect(Page::Renderer.render(md).strip).to eql(html.strip)
    end

    it "renders nothing if there's no sections" do
      md = <<~MD
        {:toc}

        Just some words
      MD

      html = <<~HTML
        <p>Just some words</p>
      HTML

      expect(Page::Renderer.render(md).strip).to eql(html.strip)
    end
  end

  it "adds custom syntax highlighting for curl examples" do
    md = <<~MD
      ```bash
      curl "https://api.buildkite.com/v2/organizations/{org.slug}/builds"
      ```
    MD

    html = <<~HTML
      <div class="highlight"><pre class="highlight shell"><code>curl <span class="s2">"https://api.buildkite.com/v2/organizations/<span class="o">{org.slug}</span>/builds"</span>
      </code></pre></div>
    HTML

    expect(Page::Renderer.render(md).strip).to eql(html.strip)
  end
end
