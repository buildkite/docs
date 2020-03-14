# frozen_string_literal: true

class Page
  HEADING_REGEX = /^[#]{2}\s(.+)$/

  class TemplateBinding
    # include ResponsiveImageContainerHelper
    # include EmojiHelper
    # include WebhookDescriptionsHelper

    def initialize(headings: [], view_helpers: nil, image_path: '')
      @headings = headings
      @view_helpers = view_helpers
      @image_path = image_path
      @url_helpers = Page::BuildkiteUrl.new
    end

    def toc
      if @headings.length > 1
        lis = @headings.map do |name|
          anchor = name.to_url

          %{<li><a href="##{anchor}">#{name}</a></li>}
        end

        return %{<div class="Docs__toc"><p>On this page:</p><ul>#{lis.join("")}</ul></div>}
      end

      ""
    end

    def estimated_time(description)
      %{<p class="Docs__time-estimate">Estimated time: #{description}</p>}
    end

    def image(name, args={})
      # Support the same :size that the standard Rails helper supports
      if size = args.delete(:size)
        width, height = size.split('x').map(&:to_i)
        args[:width] = width
        args[:height] = height
      end

      if args.include?(:width) && args.include?(:height)
        args[:max_width] = args[:width]

        responsive_image_tag(image_url(name),
                             args[:width],
                             args[:height],
                             args.except(:width, :height))
      else
        @view_helpers.image_tag(image_url(name), args)
      end
    end

    def image_tag(*args)
      @view_helpers.image_tag(*args)
    end

    def image_url(name)
      stripped_image_path = @image_path.sub(/\Adocs\//, "")
      @view_helpers.image_path(File.join(stripped_image_path, name))
    end

    def paginated_resource_docs_url
      @url_helpers.docs_path + '/rest-api#pagination'
    end

    def content_tag(*args)
      @view_helpers.content_tag(*args)
    end

    def url_helpers
      @url_helpers
    end

    def t(s)
      I18n.translate(s)
    end

    def get_binding
      binding
    end

    def render(*args)
      av = ActionView::Base.new
      av.view_paths = ActionController::Base.view_paths
      av.view_paths << Rails.root.join("app/views/pages").to_s
      av.render(*args)
    end

    def render_markdown(markdown_path, *args)
      Page::Renderer.render(render(markdown_path + '.md', *args)).html_safe
    end

    def responsive_image_tag(image, width, height, image_tag_options={}, &block)
      styles = [ "padding-bottom: #{height.to_f / width.to_f * 100}%" ]

      max_width = image_tag_options.delete(:max_width)
      container = content_tag :div, image_tag(image, image_tag_options), class: "responsive-image-container", style: styles.join("; ")

      if max_width
        content_tag :div, container, style: "max-width: #{max_width}px"
      else
        container
      end
    end
  end

  def initialize(view, name)
    @view = view
    @name = name
  end

  def exists?
    filename.present?
  end

  def title
    agentize_title(contents.match(/^\#\s(.+)/).try(:[], 1) || "")
  end

  def body
    # Look for markdown headings and prepare the TOC
    in_code_block = false
    headings = []
    c = contents.split("\n").map do |line|
      # Keep track of whether or not we're in a code block, so we can ignore
      # any headings inside it
      if line.starts_with?("```")
        in_code_block = !in_code_block
      end

      if !in_code_block && line =~ HEADING_REGEX
        text = $1.gsub(/^\#+/, '').chomp
        anchor = text.to_url
        headings << text

        %{<h2 class="Docs__heading" id="#{anchor}">#{text}<a href="##{anchor}" aria-hidden="true" class="Docs__heading__anchor"></a></h2>}
      else
        line
      end
    end.join("\n")

    renderer = ERB.new(c)
    binding = TemplateBinding.new(headings: headings,
                                  view_helpers: @view,
                                  image_path: File.join("docs", basename))

    post_erb = renderer.result(binding.get_binding)

    # Add the TOC data and links to headings
    post_erb.gsub!(HEADING_REGEX) do |heading|
      text = heading.gsub(/^\#+/, '').chomp
      anchor = text.to_url

      %{<h2 class="Docs__heading" id="#{anchor}">#{text}<a href="##{anchor}" aria-hidden="true" class="Docs__heading__anchor"></a></h2>}
    end

    html = Page::Renderer.render(post_erb)

    # Syntax highlight curl URL templates
    html.gsub!(%r{<code>curl.*?</code>}mi) do |curl|
      curl.gsub(/\{.*?\}/mi) do |uri_template|
        %(<span class="o">) + uri_template + %(</span>)
      end
    end

    html.html_safe
  end

  def open_source_url
    "https://github.com/buildkite/docs/tree/master/pages/#{basename}.md.erb"
  end

  def canonical_url
    basename.tr('_', '-')
  end

  def is_canonical?
    @name == canonical_url
  end

  private

  def contents
    @contents ||= begin
                    File.read(filename) if exists?
                  rescue => e
                    raise e
                  end
  end

  def basename
    @name.to_s.gsub(/[^0-9a-zA-Z\-\_\/]/, '').underscore
  end

  def filename
    @filename ||= begin
                    directory = Rails.root.join("app/views/pages")

                    potential_files = [ "#{basename}.md", "#{basename}.md.erb" ].map { |n| directory.join(n) }
                    potential_files.find { |file| File.exist?(file) }
                  end
  end

  def agentize_title(title)
    if basename =~ /^agent\/v(.+?)\/?/
      "#{title} (v#{$1})"
    else
      title
    end
  end
end
