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

        ## Section 1

        ### Subsection 1.1

        ### Subsection 1.2

        ## Section 2

        ### Subsection 2.1

        ### Subsection 2.2
        MD

      html = <<~HTML
        <div class="Docs__toc">
          <div class="Docs__toc__sticky">
            <p><strong>On this page:</strong></p>
            <ul class="Docs__toc__list">
              <li><a href="#section-1">Section 1</a></li>
        <li><a href="#section-2">Section 2</a></li>
            </ul>
          </div>
        </div>

        <h2 id="section-1" class="Docs__heading"><a class="Docs__heading__anchor" href="#section-1">Section 1</a></h2>

        <h3 id="section-1-subsection-1-dot-1" class="Docs__heading"><a class="Docs__heading__anchor" href="#section-1-subsection-1-dot-1">Subsection 1.1</a></h3>

        <h3 id="section-1-subsection-1-dot-2" class="Docs__heading"><a class="Docs__heading__anchor" href="#section-1-subsection-1-dot-2">Subsection 1.2</a></h3>

        <h2 id="section-2" class="Docs__heading"><a class="Docs__heading__anchor" href="#section-2">Section 2</a></h2>

        <h3 id="section-2-subsection-2-dot-1" class="Docs__heading"><a class="Docs__heading__anchor" href="#section-2-subsection-2-dot-1">Subsection 2.1</a></h3>

        <h3 id="section-2-subsection-2-dot-2" class="Docs__heading"><a class="Docs__heading__anchor" href="#section-2-subsection-2-dot-2">Subsection 2.2</a></h3>
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
          <div class="Docs__toc__sticky">
            <p><strong>On this page:</strong></p>
            <ul class="Docs__toc__list">
              <li><a href="#section">Section</a></li>
            </ul>
          </div>
        </div>
        
        <h2 id="section" class="Docs__heading"><a class="Docs__heading__anchor" href="#section">Section</a></h2>
        
        <section>
          <hgroup>
            <h1>Subsection</h1>
            <h2>Subheading</h2>
          </hgroup>
        </section>
      HTML

      expect(Page::Renderer.render(md).strip).to eql(html.strip)
    end

    it "handles custom ids" do
      md = <<~MD
        ## A Super Long Section Title
        {: id="short-id"}

        ### Subsection

        ## A Title

        ### Subsection With Custom Id
        {: id="custom-id"}
        MD

      html = <<~HTML
        <h2 id="short-id" class="Docs__heading"><a class="Docs__heading__anchor" href="#short-id">A Super Long Section Title</a></h2>



        <h3 id="short-id-subsection" class="Docs__heading"><a class="Docs__heading__anchor" href="#short-id-subsection">Subsection</a></h3>

        <h2 id="a-title" class="Docs__heading"><a class="Docs__heading__anchor" href="#a-title">A Title</a></h2>

        <h3 id="custom-id" class="Docs__heading"><a class="Docs__heading__anchor" href="#custom-id">Subsection With Custom Id</a></h3>
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

  it "supports {: code-filename=\"file.md\"} filenames for code blocks" do
    md = <<~MD
      ```json
      { "key": "value" }
      ```
      {: codeblock-file="file.json"}
    MD

    html = <<~HTML
      <figure class="highlight-figure"><figcaption>file.json</figcaption><div class="highlight"><pre class="highlight json"><code><span class="p">{</span><span class="w"> </span><span class="s2">"key"</span><span class="p">:</span><span class="w"> </span><span class="s2">"value"</span><span class="w"> </span><span class="p">}</span><span class="w">
      </span></code></pre></div></figure>
    HTML

    expect(Page::Renderer.render(md).strip).to eql(html.strip)
  end

  it "supports {: id=\"some-id\"} for manually specifying an id of the previous bit of content" do
    md = <<~MD
      ## This is a section
      {: id="some-id"}
    MD

    html = <<~HTML
      <h2 id="some-id" class="Docs__heading"><a class="Docs__heading__anchor" href="#some-id">This is a section</a></h2>
    HTML

    expect(Page::Renderer.render(md).strip).to eql(html.strip)
  end
end
