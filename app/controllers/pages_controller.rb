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
    @page = Page.new(view_context, params[:path])

    # If the page doesn't exist, walk up the URL looking for the nearest ancestor
    # page that does exist and redirect there (302). If no ancestor page exists,
    # fall through to a 404 so callers get a clear signal.
    unless @page.exists?
      segments = params[:path].to_s.split("/")
      parent_path = loop do
        segments.pop
        break nil if segments.empty?
        candidate = Page.new(view_context, segments.join("/"))
        break "/docs/#{segments.join("/")}" if candidate.exists?
      end

      if parent_path
        redirect_to parent_path, status: :found
      else
        raise ActionController::RoutingError.new("The documentation page `#{@page.basename}` does not exist")
      end
      return
    end

    # If there's another more correct version of the URL (for example, we changed `_`
    # to `-`), then redirect them to where they should be.
    unless @page.is_canonical?
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
        render_markdown(canonical_path, @page.markdown_body_with_table_conversion)
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
    return if params[:format].present? || request.accept.blank?

    # Rails treats browser-style Accept headers containing wildcards as HTML.
    # Use the most specific range for each representation, even when its q is zero.
    ranges = request.accept.downcase.split(",").map do |entry|
      type, *parameters = entry.split(";").map(&:strip)
      quality = parameters.find { |parameter| parameter.start_with?("q=") }
      [type, quality ? quality.delete_prefix("q=").to_f : 1.0]
    end
    # Keep the existing text/plain alias, but never let it override an explicit Markdown range.
    markdown_type = ranges.any? { |type, _| type == "text/markdown" } ? "text/markdown" : "text/plain"
    scores = { html: "text/html", md: markdown_type }.filter_map do |format, exact_type|
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
