# frozen_string_literal: true

class Page
  HEADING_REGEX = /^[#]{2}\s(.+)$/

  class TemplateBinding
    delegate_missing_to :@view_helpers

    def initialize(view_helpers: nil, image_path: '')
      @view_helpers = view_helpers
      @image_path = image_path
      @url_helpers = Page::BuildkiteUrl.new
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

      content_tag :div, @view_helpers.image_tag(image_url(name), args), :class => "image-container"
    end

    def image_url(name)
      stripped_image_path = @image_path.sub(/\Adocs\//, "")
      @view_helpers.image_path(File.join(stripped_image_path, name))
    end

    def paginated_resource_docs_url
      @url_helpers.docs_path + '/rest-api#pagination'
    end

    def url_helpers
      @url_helpers
    end

    def get_binding
      binding
    end

    def render(partial)
      PagesController.render(partial: partial, formats: [:md])
    end

    def render_markdown(partial: nil, text: nil)
      if partial.blank? && text.blank?
        raise ArgumentError, "partial or nil not specified"
      end

      text = if partial
                 render(partial)
               else
                text
               end

      Page::Renderer.render(text).html_safe
    end
  end

  def initialize(view, name)
    @view = view
    @name = name
  end

  def is_landing_page?
    LandingPages.all.include? @name
  end

  def beta?
    BetaPages.all.include? @name
  end

  def exists?
    filename.present?
  end

  def title
    agentize_title(contents.match(/^\#\s(.+)/).try(:[], 1) || "")
  end

  def description
    extracted_data.fetch("shortDescription")
  end

  def markdown_body
    erb_renderer = ERB.new(contents, nil, '-')
    template_binding = TemplateBinding.new(view_helpers: @view,
                                           image_path: File.join("docs", basename))

    erb_renderer.result(template_binding.get_binding)
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
    @name.to_s.gsub(/[^0-9a-zA-Z\-\_\/]/, '').underscore
  end

  private

  def contents
    @contents ||= begin
                    File.read(filename) if exists?
                  rescue => e
                    raise e
                  end
  end

  def filename
    @filename ||= begin
                    directory = Rails.root.join("pages")

                    potential_files = [ "#{basename}.md", "#{basename}.md.erb" ].map { |n| directory.join(n) }
                    potential_files.find { |file| File.exist?(file) }
                  end
  end

  def agentize_title(title)
    if basename =~ /^agent\/v(.+?)\/?/ and basename.exclude?('elastic_ci')
      "#{title} v#{$1}"
    else
      title
    end
  end
end
