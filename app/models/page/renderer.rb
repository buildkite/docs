# frozen_string_literal: true

class Page::Renderer
  require "rouge/plugins/redcarpet"

  CALLOUT_TYPE = {
    '📘': 'info',
    '👍': 'okay',
    '🚧': 'troubleshooting',
    '🛠': 'wip'
  }.freeze

  def self.render(text, options = {})
    new.render(text, options)
  end

  def render(text, options = {})
    html = markdown(options).render(Emoji.parse(text, sanitize: false))

    # It's like our own little HTML::Pipeline. These methods are easily
    # switchable to HTML::Pipeline steps in the future, if we so wish.
    doc = Nokogiri::HTML.fragment(html)
    doc = add_custom_ids(doc)
    doc = add_custom_classes(doc)
    doc = add_automatic_ids_to_headings(doc)
    doc = add_heading_anchor_links(doc)
    doc = add_table_of_contents(doc)
    doc = fix_curl_highlighting(doc)
    doc = add_code_filenames(doc)
    doc = add_callout(doc)
    doc = init_responsive_tables(doc)
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

  def add_automatic_ids_to_headings(doc)
    h2_ids = []
    h3s_with_manual_ids = []

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

  def add_table_of_contents(doc)
    headings = doc.search('./h2')

    # Third, we generate and replace the actual toc.
    doc.search('./p').each do |node|
      toc = '{:toc}'
      notoc = '{:notoc}'

      next unless [toc, notoc].include? node.text

      if headings.empty? or node.text == notoc
        node.replace('')
      else
        html_list_items = headings.map {|heading|
          <<~HTML.strip
            <li class="Toc__list-item"><a class="Toc__link" href="##{heading['id']}">#{heading.text.strip}</a></li>
          HTML
        }.join("").strip

        node.replace(<<~HTML.strip)
          <nav class="Toc">
            <p class="Toc__title"><strong>On this page:</strong></p>
            <ul class="Toc__list">
              #{html_list_items}
            </ul>
          </nav>
        HTML
      end
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

      next unless CALLOUT_TYPE.key? callout

      class_name = CALLOUT_TYPE[callout]
      lines = node
              .children
              .inner_html
              .split("\n")
              .reject(&:empty?)

      title = lines.first
      paras = lines[1..].map { |e| "<p>#{e}</p>" }.join

      callout_template = <<~HTML
        <section class='Docs__note Docs__#{class_name}-note'>
          <p class='note-title' id='#{title.to_url}'>#{title}</p>
          #{paras}
        </section>
      HTML

      node.replace(callout_template)
    end

    doc
  end

  def add_custom_ids(doc)
    doc.search('./p').each do |node|
      next unless node.text.starts_with?('{: id=')

      id = node.content[/id="(.*)"}/, 1]

      node.previous_element['id'] = id
      node.remove
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
