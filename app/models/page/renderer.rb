# frozen_string_literal: true

class Page::Renderer
  require "rouge/plugins/redcarpet"

  def self.render(text, options = {})
    new.render(text, options)
  end

  def render(text, options = {})
    html = markdown(options).render(Emoji.parse(text, sanitize: false))

    # It's like our own little HTML::Pipeline. These methods are easily
    # switchable to HTML::Pipeline steps in the future, if we so wish.
    doc = Nokogiri::HTML.fragment(html)
    doc = add_table_of_contents(doc)
    doc = fix_curl_highlighting(doc)
    doc.to_html.html_safe
  end

  private

  def markdown(options)
    Redcarpet::Markdown.new(HTMLWithSyntaxHighlighting.new(options), autolink: true,
                                                                     space_after_headers: true,
                                                                     fenced_code_blocks: true)
  end

  class HTMLWithSyntaxHighlighting < Redcarpet::Render::HTML
    include Rouge::Plugins::Redcarpet

    def initialize(options = {})
      @options = options
      super()
    end

    def image(link, title, alt)
      url = Camo::UrlBuilder.build(link) unless link.nil?

      %{<img src="#{EscapeUtils.escape_html(url || '')}" alt="#{EscapeUtils.escape_html(alt || '')}" class="#{@options[:img_classes]}"/>}
    end

    def codespan(code)
      %{<code class="dark-gray border border-gray rounded" style="padding: .1em .25em; font-size: 85%">#{EscapeUtils.escape_html(code)}</code>}
    end
  end

  def add_table_of_contents(doc)
    # First, we find all the top-level h2s
    headings = doc.search('./h2')

    # Second, we make them all linkable and give them the right classes.
    headings.each do |node|
      node['class'] = 'Docs__heading'
      node['id'] = node.text.to_url
      node.add_child(<<~HTML)
        <a href="##{node['id']}" aria-hidden="true" class="Docs__heading__anchor"></a>
      HTML
    end

    # Third, we generate and replace the actual toc.
    doc.search('./p').each do |node|
      next unless node.to_html == '<p>{:toc}</p>'

      if headings.empty?
        node.replace('')
      else
        node.replace(<<~HTML.strip)
          <div class="Docs__toc">
            <p>On this page:</p>
            <ul>
              #{headings.map {|heading|
                %{<li><a href="##{heading['id']}">#{heading.text.strip}</a></li>}
              }.join("")}
            </ul>
          </div>
        HTML
      end
    end
    
    doc
  end

  def fix_curl_highlighting(doc)
    doc.search('code').each do |node|
      next unless node.text.starts_with?('curl ')
    
      node.replace(node.to_html.gsub(/\{.*?\}/mi) {|uri_template|
        %(<span class="o">) + uri_template + %(</span>)
      })
    end

    doc
  end
end
