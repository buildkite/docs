# frozen_string_literal: true

class Page
  HEADING_REGEX = /^\#{2}\s(.+)$/

  class << self
    # Find all markdown pages in the pages directory (ignoring partials).
    def all
      Dir.glob("#{Rails.root}/pages/**/*.md")
         .select { |path| !path.to_s.include?('/_') }
         .map do |path|
        Struct.new(:path, :updated_at).new(
          path
            .sub("#{Rails.root}/pages/", '/docs/')
            .sub(/\.md$/, '')
            .gsub('_', '-'),
          File.mtime(path)
        )
      end
    end
  end

  class TemplateBinding
    delegate_missing_to :@view_helpers

    def initialize(view_helpers: nil, image_path: '')
      @view_helpers = view_helpers
      @image_path = image_path
      @url_helpers = Page::BuildkiteUrl.new
    end

    def estimated_time(description)
      %(<p class="Docs__time-estimate">Estimated time: #{description}</p>)
    end

    def image(name, args = {})
      align = args.delete(:align)&.to_s

      # Support the same :size that the standard Rails helper supports
      if size = args.delete(:size)
        width, height = size.split('x').map(&:to_i)
        args[:width] = width
        args[:height] = height
      end

      if args.include?(:width) && args.include?(:height)
        args[:max_width] = args[:width]
        args[:align] = align if align

        responsive_image_tag(image_path(name),
                             args[:width],
                             args[:height],
                             args.except(:width, :height))
      else
        if align == 'center'
          # Add centering styles for non-responsive images
          args[:style] = merge_styles(args[:style], 'display:block; margin-inline: auto;')
        end
        @view_helpers.image_tag(image_path(name), args)
      end
    end

    def image_path(name)
      stripped_image_path = @image_path.sub(%r{\Adocs/}, '')
      @view_helpers.vite_asset_path(File.join('images', stripped_image_path, name))
    end

    def paginated_resource_docs_url
      @url_helpers.docs_path + '/rest-api#pagination'
    end

    attr_reader :url_helpers

    def get_binding
      binding
    end

    def merge_styles(*styles)
      styles.compact.join(' ').strip.presence
    end

    def render(partial)
      PagesController.render(partial: partial, formats: %i[md html])
    end

    def render_markdown(partial: nil, text: nil)
      raise ArgumentError, 'partial or nil not specified' if partial.blank? && text.blank?

      text = if partial
               render(partial)
             else
               text
             end

      Page::Renderer.render(text).html_safe
    end

    def responsive_image_tag(image, width, height, image_tag_options = {}, &block)
      align_center = image_tag_options.delete(:align)&.to_s == 'center'
      max_width = image_tag_options.delete(:max_width)

      img_class = image_tag_options.delete(:class).try(:split, ' ') || []
      img_class << 'responsive-image-container'

      container_style = align_center && !max_width ? 'margin-inline: auto;' : nil
      container = content_tag :div, image_tag(image, image_tag_options), class: img_class, style: container_style

      if max_width
        outer_style = "max-width: #{max_width}px"
        outer_style << '; margin-inline: auto' if align_center
        content_tag :div, container, style: outer_style
      else
        container
      end
    end
  end

  def initialize(view, name)
    @view = view
    @name = name
  end

  def landing_page?
    LandingPages.all.include? @name
  end

  def beta?
    BetaPages.all.include? @name
  end

  def exists?
    filename.present?
  end

  def sections
    extracted_data.fetch('sections')
  end

  def markdown_body
    erb_renderer = ERB.new(file.content, trim_mode: '-')
    template_binding = TemplateBinding.new(view_helpers: @view,
                                           image_path: File.join('docs', basename))

    result = erb_renderer.result(template_binding.get_binding)

    # Remove HTML comments from the markdown output
    # This ensures they don't appear in .md format responses or copy functionality
    filter_html_comments(result)
  end

  def body
    Page::Renderer.render(markdown_body)
  end

  def extracted_data
    Page::DataExtractor.extract(markdown_body)
  end

  def canonical_url
    basename.tr('_', '-')
  end

  def is_canonical?
    @name == canonical_url
  end

  def basename
    @name.to_s.gsub(%r{[^0-9a-zA-Z\-_/]}, '').underscore
  end

  # Page title, either from front matter or extracted from the markdown
  def title
    front_matter.fetch(:title, extracted_data.fetch('name'))
  end

  # Page description, either from front matter or extracted from the markdown
  def description
    front_matter.fetch(:description, extracted_data.fetch('shortDescription'))
  end

  # Should page render a table of contents?
  def toc?
    front_matter.fetch(:toc)
  end

  # Should pageinclude H3s in the table of contents?
  def toc_include_h3?
    front_matter.fetch(:toc_include_h3)
  end

  def template
    front_matter.fetch(:template, 'show')
  end

  # Returns focus keywords to guide content writers with an overview of the page content
  # Note: it's not for meta keywords, which is a deprecated SEO practice
  def keywords
    # Gracefully falls back to the page's path if no keywords are specified to help reduce technical writer workload
    front_matter.fetch(:keywords, keywords_from_path)
  end

  private

  def front_matter
    @front_matter ||= begin
      defaults = {
        # Default to rendering table of contents
        "toc": true,
        # Default to H3s being included in the table of contents
        "toc_include_h3": true
      }
      if file.front_matter
        defaults.merge(file.front_matter.symbolize_keys)
      else
        defaults
      end
    end
  end

  def file
    @_file ||= ::FrontMatterParser::Parser.parse_file(filename)
  rescue StandardError
    raise "Error parsing #{filename}"
  end

  def filename
    @filename ||= begin
      directory = Rails.root.join('pages')

      potential_files = ["#{basename}.md"].map { |n| directory.join(n) }
      potential_files.find { |file| File.exist?(file) }
    end
  end

  def keywords_from_path
    @view.request.path.split('/').reject(&:empty?).map { |segment| segment.gsub('-', ' ') }.join(', ')
  end

  def filter_html_comments(text)
    # Remove HTML comments using a regex that handles:
    # - Single line comments: <!-- comment -->
    # - Multi-line comments that span multiple lines
    # - Comments with various content including newlines and special characters
    result = text.gsub(/<!--.*?-->/m, '')

    # Clean up any resulting blank lines (but preserve intentional spacing)
    result.gsub(/\n\s*\n\s*\n/, "\n\n")
  end
end
