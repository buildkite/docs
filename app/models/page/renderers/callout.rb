# frozen_string_literal: true

class Page::Renderers::Callout
  require "rouge/plugins/redcarpet"

  CALLOUT_TYPE = {
    '📘': 'info',
    '🚧': 'troubleshooting',
    '🛠': 'wip'
  }.freeze

  attr_accessor :node, :callout

  def initialize(node, callout)
    @node = node
    @callout = callout
  end

  def process
    node.replace(template)
  end

  private

  def class_name
    CALLOUT_TYPE[callout]
  end

  def lines
    @lines ||= node.children.inner_html.split("\n").reject(&:empty?)
  end

  def title
    # Removing emoji from first line
    lines.first[1..-1]
  end

  def paragraphs
    lines[1..].map { |e| "<p>#{e}</p>" }.join
  end

  def template
    @template = <<~HTML
      <section class='callout callout--#{class_name}'>
        #{title_template}
        #{paragraphs}
      </section>
    HTML
  end

  def title_template
    if title.empty?
      ""
    else
      "<p class='callout__title'>#{formatted_title}</p>"
    end
  end

  def url
    title.to_url
  end

  def formatted_title
    if url.present?
      anchor
    else
      title
    end
  end

  def anchor
    "<a class='callout__anchor' href='##{url}' id='#{url}'>#{title}</a>"
  end
end
