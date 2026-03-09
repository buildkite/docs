# frozen_string_literal: true

require 'kramdown'

class Page::DataExtractor
  def self.extract(text, options = {})
    new.extract(text, options)
  end

  def extract(text, options = {})
    # Parse the markdown with kramdown
    doc = Kramdown::Document.new(text, input: 'GFM')
    
    page_name = nil
    page_description = ""
    sections = []
    page_attributes = []

    # Simple extraction - find first H1 for title and first paragraph for description
    lines = text.split("\n")
    
    lines.each do |line|
      if line.start_with?('# ') && page_name.nil?
        page_name = line[2..-1].strip
      elsif line.strip.length > 0 && !line.start_with?('#') && page_description.empty?
        page_description = line.strip
        break
      end
    end

    # Extract H2 sections
    lines.each do |line|
      if line.start_with?('## ')
        header = line[3..-1].strip
        sections << {
          header: header,
          id: header.downcase.gsub(/[^a-z0-9\s]/, '').gsub(/\s+/, '-'),
          toc: true
        }
      end
    end

    {
      "name" => page_name,
      "shortDescription" => page_description,
      "textContent" => page_description,
      "attributes" => page_attributes,
      "sections" => sections,
    }
  end
end
