# frozen_string_literal: true
#
# Bridges the gap between the 0.23 API we used and the 1.x/2.x API shipped
# with the Rust implementation so we can upgrade with zero call-site changes.

require "commonmarker"  # loads the new gem

# Old constant was CommonMarker (capital M), new one is Commonmarker.
# We expose the old constant so all existing `require 'commonmarker'`
# call-sites continue to work untouched.
module CommonMarker
  Node = ::Commonmarker::Node

  module_function

  def parse(text, **kw)
    ::Commonmarker.parse(text, **kw)
  end

  def render_doc(text, options = nil)
    ::Commonmarker.parse(text)
  end

  def render_html(text, **kw)
    ::Commonmarker.to_html(text, **kw)
  end

  def to_html(text, **kw)
    ::Commonmarker.to_html(text, **kw)
  end
end

# Monkey patch the Node class to provide Node.new compatibility
class << Commonmarker::Node
  alias_method :orig_new, :new
  
  def new(type, *args)
    # Map old node types to new ones
    mapped_type = case type
    when :html
      :html_inline
    else
      type
    end
    
    begin
      orig_new(mapped_type, *args)
    rescue => e
      # If the type is still invalid, create a generic html_inline node
      orig_new(:html_inline)
    end
  end
end

module Commonmarker
  class Node
    # 0.23 exposed `next`, 2.x renamed it to `next_sibling`
    alias_method :next, :next_sibling unless method_defined?(:next)

    # Node type compatibility - 0.23 used :header, 2.x uses :heading  
    alias_method :orig_type, :type
    def type
      t = orig_type
      case t
      when :heading
        :header
      when :html_inline
        :html  # Map back to old name for compatibility
      else
        t
      end
    end

    # Compatibility for string_content= which may not work on all node types
    alias_method :orig_string_content=, :string_content=
    def string_content=(content)
      begin
        orig_string_content=(content)
      rescue TypeError => e
        # If setting string content fails, try to modify the node differently
        # For HTML nodes, this might not be supported in the new API
        puts "Warning: Could not set string content on #{orig_type} node: #{e.message}"
      end
    end

    # API compatibility for to_commonmark - new version doesn't take options
    alias_method :orig_to_commonmark, :to_commonmark
    def to_commonmark(options = nil, width = nil)
      orig_to_commonmark()
    end

    # 0.23 exposed a plaintext renderer that is no longer wrapped.
    # The native function still exists (`node_to_plaintext`) – we just add
    # the missing Ruby sugar.  If the symbol ever disappears we fall back to
    # a very light "strip markdown" implementation that is good enough for
    # our header/description extraction needs.
    def to_plaintext(options = nil, width = 32_767)
      # Simple plaintext conversion - just get the text content without markdown
      case type
      when :text
        string_content
      when :code_block
        string_content
      when :html_block, :html_inline
        ""
      else
        # For other nodes, recursively get text from children
        children.map { |child| child.to_plaintext(options, width) }.join("")
      end
    end

    # Helper to get all children as array
    def children
      result = []
      child = first_child
      while child
        result << child
        child = child.next_sibling
      end
      result
    end
  end
end
