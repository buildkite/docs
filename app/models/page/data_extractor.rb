# frozen_string_literal: true

class Page::DataExtractor
  def self.extract(text, options = {})
    new.extract(text, options)
  end

  def extract(text, options = {})
    # Hack to unescape any emoji references in this: emoji is unsupported
    markdown_ast = markdown_doc(Emoji::Parser.parse([], text, sanitize: false))

    page_name = nil
    # Create an empty markdown document so we can append markdown nodes to it later
    page_description = markdown_doc('')
    page_description_found = false
    page_attributes = []

    markdown_ast.each do |node|
      case node.type
      when :header
        if node.header_level == 1 && page_name.nil?
          page_name = node.to_plaintext(:DEFAULT, 32_767).strip
        end
      when :paragraph, :code_block
        unless page_description_found
          wrap_figure = false

          # Look ahead for code block file names
          if node.type == :code_block && node.next&.type == :paragraph
            node_text = node.next&.to_plaintext

            # If it's a codeblock filename, extract the name
            if node_text.starts_with?('{: codeblock-file=')
              wrap_figure = node_text[/codeblock-file="(.*)"}/, 1]
            end
          end

          # Add the starting HTML fragment for the figure/figcaption pair
          if wrap_figure
            figure_start = CommonMarker::Node.new(:html)
            figure_start.string_content = "<figure class=\"highlight-figure\"><figcaption>#{wrap_figure}</figcaption>"
            page_description.append_child(figure_start)
          end

          # Add any paragraphs or code blocks we hit before we find
          # other information to the description, ignoring any TOC entries
          unless node.to_plaintext == "{:toc}\n"
            page_description.append_child(node)
          end

          # Add the ending HTML fragment for the figure/figcaption pair
          if wrap_figure
            figure_end = CommonMarker::Node.new(:html)
            figure_end.string_content = "</figure>"
            page_description.append_child(figure_end)
          end
        end
      when :html
        parsed_html = Nokogiri::HTML.fragment(node.to_html(:UNSAFE).strip)
        if parsed_html.children.length == 1
          element = parsed_html.first_element_child
          if element.name == "table" && element.attributes.include?("data-attributes")
            table_attributes_required = element.attributes.include?("data-attributes-required")

            element.css('tr').each do |row|
              page_attributes.push({
                name: row.first_element_child.inner_text,
                isRequired: table_attributes_required,
                textContent: "<div>#{row.last_element_child.inner_html.strip}</div>"
              })
            end
          end
        end
      end

      # Stop pulling elements out for the description after we hit either;
      # - a second-level header,
      # - a code block
      # - anything which is not a header, paragraph, code block or html fragment
      if page_description_found == false &&
        (node.type == :header && node.header_level > 1) ||
        node.type == :code_block ||
        !([:header, :paragraph, :code_block, :html].include?(node.type))
        page_description_found = true
      end
    end

    return {
      "name" => page_name,
      "shortDescription" => page_description.first_child.to_plaintext(:DEFAULT, 32_767).strip,
      "textContent" => page_description.to_commonmark(:DEFAULT, 32_767).strip,
      "attributes" => page_attributes
    }
  end

  private

  def markdown_doc(text)
    CommonMarker.render_doc(text, :UNSAFE)
  end
end
