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
    lines.first
  end

  def paragraphs
    lines[1..].map { |e| "<p>#{e}</p>" }.join
  end

  def template
    @template = <<~HTML
      <section class='callout callout--#{class_name}' id='#{title.to_url}'>
        <p class='callout__title'>
          <a class='callout__anchor' href='##{title.to_url}'>#{title}</a>
        </p>
        #{paragraphs}
      </section>
    HTML
  end
end
