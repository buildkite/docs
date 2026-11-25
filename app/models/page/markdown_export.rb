# frozen_string_literal: true

class Page::MarkdownExport
  SITE = "https://buildkite.com"

  # Match destinations in inline links, reference definitions, and HTML links.
  # Consume inline code first so examples of link syntax are left alone.
  LINK = /(?<ticks>`+)(?!`).*?(?<!`)\k<ticks>(?!`)|(?<prefix>\]\(\s*<?|^ {0,3}\[[^\]]+\]:\s*<?|\bhref=["']|<(?=https?:\/\/))(?<url>[^\s)<>"']+)/

  def self.format(body, path)
    code_lines = {}
    Commonmarker.parse(body).walk.each do |node|
      next unless node.type == :code_block

      lines = node.source_position
      yaml = node.fenced? && %w[yaml yml].include?(node.fence_info.split.first)
      (lines[:start_line]..lines[:end_line]).each { |line| code_lines[line] = yaml }
    end

    body.lines.each_with_index.map do |line, index|
      case code_lines[index + 1]
      when true
        line.gsub(/\\:([\w+-]+)\\:/, ':\1:')
      when false
        line
      else
        line.gsub(LINK) do |match|
          prefix, url = Regexp.last_match.values_at(:prefix, :url)
          url ? prefix + link_url(url, path) : match
        end
      end
    end.join
  end

  def self.link_url(url, path)
    uri = URI.join("#{SITE}#{path}", url)
    return url unless uri.host == "buildkite.com" && %w[http https].include?(uri.scheme)

    # Generated SDK references are published separately and only have HTML versions.
    return uri.to_s if uri.path == "/docs/sdk" || uri.path.start_with?("/docs/sdk/")

    if uri.path.match?(%r{\A/docs(?:/[\w-]+)*/?(?:\.html|\.md)?\z})
      uri.scheme = "https"
      uri.path = uri.path.delete_suffix("/").delete_suffix(".html").delete_suffix(".md") + ".md"
    end
    uri.to_s
  rescue URI::InvalidURIError
    url
  end
  private_class_method :link_url
end
