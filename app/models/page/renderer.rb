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
    doc = add_custom_classes(doc)
    doc = add_automatic_ids_to_headings(doc)
    doc = add_heading_anchor_links(doc)
    doc = fix_curl_highlighting(doc)
    doc = fix_yaml_highlighting(doc)
    doc = add_code_filenames(doc)
    doc = add_callout(doc)
    doc = decorate_external_links(doc)
    doc = init_responsive_tables(doc)
    doc = wrap_sections(doc)
    doc.to_html.html_safe
  end

  private

  def markdown(options)
    Redcarpet::Markdown.new(HTMLWithSyntaxHighlighting.new(options), autolink: true,
                                                                     space_after_headers: true,
                                                                     fenced_code_blocks: true,
                                                                     tables: true,
                                                                     no_intra_emphasis: true)
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
      %{<code>#{EscapeUtils.escape_html(code)}</code>}
    end
  end

  def wrap_sections(doc)
    headers = doc.css('h2,h3')
    headers.each do |header|
      next_element = header.next_element
      header.wrap("<section id=\"#{header['id']}\"></section>")

      while !next_element.nil? && !next_element.name.match?(/h2|h3/)  do
        current_element = next_element
        next_element = next_element.next_element

        header.parent.add_child(current_element)
      end
    end

    doc
  end

  def add_automatic_ids_to_headings(doc)
    h2_ids = []
    h3s_with_manual_ids = []

    # h2 headers
    doc.search('./h2').each do |h2|
      if (id = h2['id']).blank?
        id = h2['id'] = h2.text.to_url
      end
      h2_ids << id
    end

    h3s_with_manual_ids = doc.search('h3[id]')

    h2_ids.each do |h2_id|
      # This matches all following h3s each time, but future h3s get overridden
      # each time so it works out to the be value of the previous one.
      doc.css("\##{h2_id} ~ h3").each do |h3|
        next if h3s_with_manual_ids.include?(h3)
        h3['id'] = h2_id + "-" + h3.text.to_url
      end
    end

    doc
  end

  def add_heading_anchor_links(doc)
    headings = doc.search('./h2', './h3')

    # Second, we make them all linkable and give them the right classes.
    headings.each do |node|
      node['class'] = 'Docs__heading'
      link = "<a class='Docs__heading__anchor' href='##{node['id']}'></a>"

      node.children.wrap(link)
    end

    doc
  end

  def fix_curl_highlighting(doc)
    doc.search('.//code').each do |node|
      next unless node.text.starts_with?('curl ')

      node.replace(node.to_html.gsub(/\{.*?\}/mi) {|uri_template|
        %(<span class="o">) + uri_template + %(</span>)
      })
    end

    doc
  end

  def fix_yaml_highlighting(doc)
    # Find code blocks that contain YAML content
    doc.search('.//pre[contains(@class, "highlight")]').each do |pre|
      code_block = pre.at('code')
      next unless code_block

      # Check if this looks like YAML content (contains common YAML patterns)
      text_content = code_block.text
      next unless text_content.match?(/^\s*(steps:|plugins:|commands:|label:)/m)

      # Remove error styling from colons that follow Buildkite plugin patterns
      # Pattern: <span class="s">plugin-name#version</span><span class="err">:</span>
      code_block.inner_html = code_block.inner_html.gsub(
        /(<span class="s">[^<]*#[^<]*<\/span>)<span class="err">:<\/span>/i,
        '\1<span class="pi">:</span>'
      )

      # Remove error styling from standalone colons in YAML context
      # Only if they're likely valid YAML colons (not actual errors)
      code_block.inner_html = code_block.inner_html.gsub(
        /<span class="err">:<\/span>/
      ) do |match|
        # Replace with normal punctuation indicator styling
        '<span class="pi">:</span>'
      end
    end

    doc
  end

  def add_code_filenames(doc)
    doc.search('./p').each do |node|
      next unless node.text.starts_with?('{: codeblock-file=')

      filename = node.content[/codeblock-file="(.*)"}/, 1]
      figure = "<figure class='highlight-figure'><figcaption>#{filename}</figcaption></figure>"

      node.previous_element.wrap(figure)
      node.remove
    end

    doc
  end

  def add_callout(doc)
    doc.search('./blockquote').each do |node|
      callout = node.children.compact_blank.join.chr.to_sym

      next unless Page::Renderers::Callout::CALLOUT_TYPE.key? callout

      Page::Renderers::Callout.new(node, callout).process
    end

    doc
  end

  def add_custom_classes(doc)
    doc.search('./p').each do |node|
      next unless node.text.starts_with?('{: class=')

      css_class = node.content[/class="(.*)"}/, 1]

      node.previous_element['class'] = css_class
      node.remove
    end

    doc
  end

  def decorate_external_links(doc)
    doc.css('a').each do |node|
      Page::Renderers::ExternalLink.new(node).process
    end

    doc
  end

  def init_responsive_tables(doc)
    doc.css('table.responsive-table:not(.responsive-table--single-column-rows)').each do |table|
      thead_ths = table.css('thead th')

      unless thead_ths.empty?
        table.search('./tbody/tr').each do |tr|
          tr.search('./td').each_with_index do |td, i|
            faux_th = "<th aria-hidden class=\"responsive-table__faux-th\">#{thead_ths[i].children}</th>"

            td.add_previous_sibling(faux_th)
          end
        end
      end
    end

    doc
  end
end
