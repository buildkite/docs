# frozen_string_literal: true

class Page::Renderer
  # Similar to the built-in TableOfContentsFilter, 
  class TableOfContentsFilter < HTML::Pipeline::Filter
    def call
      # First, we find all the top-level h2s. We check the parent to make sure
      # we're excluding any that might be nested inside a <section> for example.
      headings = doc.search('h2').select {|node|
        node.parent.name == '#document-fragment'
      }

      # Second, we make them all linkable and give them the right classes.
      headings.each do |node|
        node['class'] = 'Docs__heading'
        node['id'] = node.text.to_url
        node.add_child(%{
          <a href="##{node['id']}" aria-hidden="true" class="Docs__heading__anchor"></a>
        })
      end

      # Third, we generate and replace the actual toc.
      doc.search('p').each do |node|
        next unless node.to_html == '<p>{:toc}</p>'

        if headings.empty?
          node.replace('')
        else
          node.replace(%{
            <div class="Docs__toc">
              <p>On this page:</p>
              <ul>
                #{headings.map {|heading|
                  %{<li><a href="##{heading['id']}">#{heading.text}</a></li>}
                }.join("\n")}
              </ul>
            </div>
          })
        end
      end
      
      doc
    end
  end

  # Inspired by: https://github.com/jch/html-pipeline/blob/6d223dc2f7e7f307d3bda8902e225c0d5ea0b2e8/lib/html/pipeline/emoji_filter.rb
  #
  # Except this one works with our built-in Buildkite emojis.
  class EmojiFilter < HTML::Pipeline::Filter
    IGNORED_ANCESTOR_TAGS = %w(pre code tt).freeze

    def call
      doc.search('.//text()').each do |node|
        content = node.to_html
        next unless content.include?(':')
        next if has_ancestor?(node, IGNORED_ANCESTOR_TAGS)
        html = Emoji.parse(content, sanitize: false) # Docs don't need sanitizing
        next if html == content
        node.replace(html)
      end
      doc
    end
  end

  HTML_PIPELINE = HTML::Pipeline.new [
    HTML::Pipeline::MarkdownFilter,
    HTML::Pipeline::SyntaxHighlightFilter,
    TableOfContentsFilter,
    EmojiFilter
  ], unsafe: true

  def self.render(text, options = {})
    new.render(text, options)
  end

  def render(text, options = {})
    HTML_PIPELINE.call(text, options)[:output].to_s
  end
end
