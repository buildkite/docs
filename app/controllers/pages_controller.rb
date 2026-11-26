class PagesController < ApplicationController
  append_view_path "pages"

  before_action :negotiate_page_format, only: [:index, :show]

  def index
    @nav = default_nav

    respond_to do |format|
      format.html do
        advertise_markdown("/docs")
        render :index, layout: "homepage"
      end
      format.md do
        render_markdown("/docs", render_to_string(:index, formats: [:md], layout: false))
      end
    end
  end

  def show
    @nav = default_nav
    legacy_destination = request.path_parameters[:moved_to]
    page_path = [legacy_destination, params[:path]].compact.join("/")
    @page = Page.new(view_context, page_path)

    return route_not_found unless @page.exists?

    # If there's another more correct version of the URL (for example, we changed `_`
    # to `-`), then redirect them to where they should be.
    if legacy_destination || !@page.is_canonical?
      redirect_to "/docs/#{@page.canonical_url}", status: :moved_permanently
      return # ensure we exit the method after redirecting
    end

    canonical_path = "/docs/#{@page.canonical_url}"
    respond_to do |format|
      format.html do
        advertise_markdown(canonical_path)
        render @page.template
      end
      format.md do
        render_markdown(canonical_path, @page.markdown_body)
      end
    end
  end

  private

  def advertise_markdown(path)
    @markdown_alternate_url = "#{request.base_url}#{path}.md"
    response.headers["Link"] = %(<#{@markdown_alternate_url}>; rel="alternate"; type="text/markdown")
  end

  def render_markdown(path, body)
    response.headers["Link"] = %(<#{request.base_url}#{path}>; rel="canonical")
    render plain: Page::MarkdownExport.format(body, path), content_type: "text/markdown"
  end

  def negotiate_page_format
    return if params[:format].present?

    # Setting request.format makes Rails skip its automatic Vary header.
    vary = response.headers["Vary"].to_s.split(",").map(&:strip)
    unless vary.include?("*")
      request.vary_headers.each do |header|
        vary << header unless vary.any? { |existing| existing.casecmp?(header) }
      end
      response.headers["Vary"] = vary.join(", ")
    end
    return if request.accept.blank?

    # Rails treats browser-style Accept headers containing wildcards as HTML.
    # Use the most specific range for each representation, even when its q is zero.
    ranges = request.accept.downcase.split(",").map do |entry|
      type, *parameters = entry.split(";").map(&:strip)
      quality = parameters.find { |parameter| parameter.start_with?("q=") }
      [type, quality ? quality.delete_prefix("q=").to_f : 1.0]
    end
    # Keep the Rails MIME aliases without overriding explicit ranges for either representation.
    html_type = ranges.any? { |type, _| type == "text/html" } ? "text/html" : "application/xhtml+xml"
    markdown_type = ranges.any? { |type, _| type == "text/markdown" } ? "text/markdown" : "text/plain"
    scores = { html: html_type, md: markdown_type }.filter_map do |format, exact_type|
      match = [exact_type, "text/*", "*/*"].each_with_index.lazy.filter_map do |type, specificity|
        index = ranges.index { |range, _| range == type }
        [ranges[index].last, -specificity, -index] if index
      end.first
      next unless match && match.first.positive?

      [format, match]
    end

    if scores.empty?
      head :not_acceptable
    else
      request.format = scores.max_by(&:last).first
    end
  end

  def beta?
    @page && @page.beta?
  end
  helper_method :beta?

end
