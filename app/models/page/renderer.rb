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
    doc = add_custom_ids(doc)
    doc = add_custom_classes(doc)
    doc = add_automatic_ids_to_headings(doc)
    doc = add_heading_anchor_links(doc)
    doc = add_table_of_contents(doc)
    doc = fix_curl_highlighting(doc)
    doc = add_code_filenames(doc)
    doc = add_callout(doc)
    doc = init_responsive_tables(doc)
    doc = add_copy_to_clipboard_button(doc)

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

  def add_copy_to_clipboard_button(doc)
    doc.css("div.highlight").map do |node|
      node.set_attribute("tabindex", 0)

      # Render clipboard icon from https://www.figma.com/file/zJ2OfBZPY0bYGkv0TZ2FNR/Heroicons?node-id=2%3A943&t=igXNWnw6MjFltc3X-4
      node.add_child('<button class="Button Button--small Button--default highlight__button" data-copy-to-clipboard-btn aria-label="Copy to clipboard" title="Copy to clipboard"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M8.25 7.5V6.10822C8.25 4.97324 9.09499 4.01015 10.2261 3.91627C10.5994 3.88529 10.9739 3.85858 11.3495 3.83619M15.75 18H18C19.2426 18 20.25 16.9926 20.25 15.75V6.10822C20.25 4.97324 19.405 4.01015 18.2739 3.91627C17.9006 3.88529 17.5261 3.85858 17.1505 3.83619M15.75 18.75V16.875C15.75 15.011 14.239 13.5 12.375 13.5H10.875C10.2537 13.5 9.75 12.9963 9.75 12.375V10.875C9.75 9.01104 8.23896 7.5 6.375 7.5H5.25M17.1505 3.83619C16.8672 2.91757 16.0116 2.25 15 2.25H13.5C12.4884 2.25 11.6328 2.91757 11.3495 3.83619M17.1505 3.83619C17.2152 4.04602 17.25 4.26894 17.25 4.5V5.25H11.25V4.5C11.25 4.26894 11.2848 4.04602 11.3495 3.83619M6.75 7.5H4.875C4.25368 7.5 3.75 8.00368 3.75 8.625V20.625C3.75 21.2463 4.25368 21.75 4.875 21.75H14.625C15.2463 21.75 15.75 21.2463 15.75 20.625V16.5C15.75 11.5294 11.7206 7.5 6.75 7.5Z" stroke="#0F172A" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg></button>')
    end

    doc
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

      next unless Page::Renderers::Callout::CALLOUT_TYPE.key? callout

      Page::Renderers::Callout.new(node, callout).process
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
