# frozen_string_literal: true

class Page
  HEADING_REGEX = /^[#]{2}\s(.+)$/

  class TemplateBinding
    delegate_missing_to :@view_helpers

    def initialize(renderer:, view_helpers:)
      @renderer = renderer
      @view_helpers = view_helpers
      @url_helpers = Page::BuildkiteUrl.new
    end

    def image(path, args = {})
      raise "image deprecated, use markdown ![#{args[:alt]}](#{path})"
    end

    def estimated_time(description)
      %{<p class="Docs__time-estimate">Estimated time: #{description}</p>}
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

      text = partial ? render(partial) : text
      @renderer.render(text).html_safe
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

  def title
    agentize_title(contents.match(/^\#\s(.+)/).try(:[], 1) || "")
  end

  def description
    extracted_data.fetch("shortDescription")
  end

  def markdown_body
    erb_renderer = ERB.new(contents, nil, '-')
    template_binding = TemplateBinding.new(renderer: markdown_renderer, view_helpers: @view)
    erb_renderer.result(template_binding.get_binding)
  end

  def markdown_renderer
    Page::Renderer.new(basename, @view)
  end

  def image_path
    File.join("docs", basename)
  end

  def body
    markdown_renderer.render(markdown_body)
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
