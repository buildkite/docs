# frozen_string_literal: true

class Page::Renderers::ExternalLink

  INTERNAL_LINK_PREFIXES = [
    'buildkite.com/docs/',
    '#',
    'mailto:',
    'tel:',
  ]

  INTERNAL_DOMAINS = [
    'buildkite.com',
    'buildkitestatus.com'
  ]

  attr_accessor :node

  def initialize(node)
    @node = node
    @href = node['href']
  end

  def external_link?

    def has_internal_link_prefix?
      INTERNAL_LINK_PREFIXES.any? { |prefix| @href.include?(prefix) }
    end

    def buildkite_domain?
      host = URI.parse(@href).host

      return false if !host

      INTERNAL_DOMAINS.any? { |domain| host.include?(domain) }
    end

    return false if !@href

    true unless has_internal_link_prefix? || buildkite_domain?
  end

  def decorate_external_link_node
    unless node['class']
      node.set_attribute('class', 'external-link')
      node.set_attribute('target', '_blank')
    end
  end

  def process
    if external_link?
      decorate_external_link_node
    end

    node
  end

end
