# frozen_string_literal: true

class Page::DataExtractor
  def self.extract(text, options = {})
    new.extract(text, options)
  end

  def extract(text, options = {})
    markdown_ast = markdown_doc(text)

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
        # Add any paragraphs or code blocks we hit before we find
        # other information to the description, ignoring any TOC entries
        unless page_description_found || node.to_plaintext == "{:toc}\n"
          page_description.append_child(node)
        end

        if node.type == :code_block
          # TODO: support turning codeblock-file directives into figure/figcaption elements
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
                textContent: "<span>#{row.last_element_child.inner_html.strip}</span>"
              })
            end
          end
        end
      end

      # End searches for the initial description once we hit a non-paragraph item
      # TODO: Allow for code examples in description?
      #       - TODO: check about emoji
      if page_description_found == false &&
        (node.type == :header && node.header_level > 1) ||
        node.type == :code_block ||
        !([:header, :paragraph, :code_block, :html].include?(node.type))
        page_description_found = true
      end
    end

    return {
      "name" => page_name,
      "icon" => "TK: add icon attribute somewhere",
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
