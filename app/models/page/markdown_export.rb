# frozen_string_literal: true

class Page::MarkdownExport
  SITE = "https://buildkite.com"
  TABLE = %r{^ {0,3}<table\b[^>]*>.*?</table>}mi
  ATTRIBUTES = /\A([ \t]*)\{:[ \t]+(class|codeblock-file)="([^"\n]*)"[ \t]*\}[ \t]*\n?\z/

  # Match link destinations and bare Buildkite docs URLs in prose.
  # Consume inline code first so examples of link syntax are left alone.
  LINK = %r{
    (?<ticks>`+)(?!`).*?(?<!`)\k<ticks>(?!`)
    |(?<prefix>\]\(\s*<?|^[ ]{0,3}\[[^\]]+\]:\s*<?|\bhref=["']|<(?=https?://))(?<url>[^\s)<>"']+)
    |(?<![^\s(])(?<bare>https?://buildkite\.com/docs(?=[/?\#\s.,;:!)]|$)[^\s)<>"']*)
  }x

  def self.format(body, path)
    code_lines = code_block_lines(body)
    if body.match?(TABLE)
      original = body
      body = original.gsub(TABLE) do |html|
        start_line = original[0...Regexp.last_match.begin(0)].count("\n") + 1
        next html if code_lines.key?(start_line)

        markdown_table(html, path)
      end
      code_lines = code_block_lines(body) if body != original
    end

    body.lines.each_with_index.filter_map do |line, index|
      case code_lines[index + 1]
      when :yaml then line.gsub(/\\:([\w+-]+)\\:/, ':\1:')
      when :code then line
      else
        attributes = line.match(ATTRIBUTES)
        if attributes
          indent, kind, value = attributes.captures
          "\n#{indent}File: `#{value}`\n" if kind == "codeblock-file"
        else
          rewrite_links(line, path)
        end
      end
    end.join
  end

  def self.code_block_lines(body)
    Commonmarker.parse(body).walk.each_with_object({}) do |node, lines|
      next unless node.type == :code_block

      position = node.source_position
      yaml = node.fenced? && %w[yaml yml].include?(node.fence_info.split.first)
      (position[:start_line]..position[:end_line]).each { |line| lines[line] = yaml ? :yaml : :code }
    end
  end

  def self.markdown_table(html, path)
    # Blank lines in a generated table can make CommonMark classify its
    # indented rows as code even though the opening tag is prose.
    html = html.lines.map { |line| rewrite_links(line, path) }.join
    fragment = Nokogiri::HTML5.fragment(html.strip)
    table = fragment.at_css("table")
    return html unless table && fragment.children.one?

    # Keep tables that a pipe table cannot represent, including anchors,
    # captions, row headers, merged cells, lists, and nested callouts.
    return html if table.matches?("[id]") || table.css("[id], [name], [colspan], [rowspan]").any?
    return html if table.css("*").any? { |node| !%w[thead tbody tr th td p a code strong b em i br].include?(node.name) }

    header, *rows = table.css("tr").map(&:element_children)
    return html unless header.present? && header.all? { |cell| cell.name == "th" }
    return html unless rows.all? { |row| row.size == header.size && row.all? { |cell| cell.name == "td" } }

    cells = [header, *rows].map do |row|
      row.map { |cell| cell.children.map { |node| markdown_cell_content(node) }.join.strip.gsub("|") { '\\|' } }
    end
    cells.insert(1, Array.new(header.size, "---"))
    "\n#{cells.map { |row| "| #{row.join(' | ')} |\n" }.join}\n"
  end

  def self.markdown_cell_content(node)
    # ERB helpers can put authored Markdown (links, inline code) in a cell.
    return node.text.gsub(/[&<>]/) { |char| CGI.escapeHTML(char) }.gsub(/\s+/, " ") if node.text?
    return "" unless node.element?

    content = node.children.map { |child| markdown_cell_content(child) }.join
    case node.name
    when "a" then node["href"] ? "[#{content}](<#{node['href']}>)" : content
    when "code"
      code = node.text.gsub(/\s+/, " ")
      ticks = "`" * (code.scan(/`+/).map(&:size).max.to_i + 1)
      code.include?("`") ? "#{ticks} #{code} #{ticks}" : "#{ticks}#{code}#{ticks}"
    when "strong", "b" then "**#{content}**"
    when "em", "i" then "_#{content}_"
    when "br" then "<br>"
    when "p" then node.next_element ? "#{content}<br>" : content
    else content
    end
  end

  def self.rewrite_links(line, path)
    line.gsub(LINK) do |match|
      prefix, url, bare = Regexp.last_match.values_at(:prefix, :url, :bare)
      if bare
        url = bare.sub(/[.,;:!?]+\z/, "")
        link_url(url, path) + bare.delete_prefix(url)
      elsif url
        prefix + link_url(url, path)
      else
        match
      end
    end
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
  private_class_method :code_block_lines, :markdown_table, :markdown_cell_content, :rewrite_links, :link_url
end
