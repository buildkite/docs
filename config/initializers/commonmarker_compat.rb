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

module Commonmarker
  class Node
    # 0.23 exposed `next`, 2.x renamed it to `next_sibling`
    alias_method :next, :next_sibling unless method_defined?(:next)

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
      if respond_to?(:to_plaintext_internal)
        to_plaintext_internal()
      else
        # naive fallback: CommonMark → strip most formatting tokens
        to_commonmark()
          .gsub(/[`*_~>\[\]\(\)#\!\-]/, "")
          .strip
      end
    end
  end
end
