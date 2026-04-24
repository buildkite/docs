class PagesController < ApplicationController
  append_view_path "pages"

  before_action :negotiate_markdown_from_accept_header, only: :show

  def index
    @nav = default_nav

    render :index, layout: "homepage"
  end

  def show
    @nav = default_nav
    @page = Page.new(view_context, params[:path])

    # If the page doesn't exist, throw a 404
    unless @page.exists?
      raise ActionController::RoutingError.new("The documentation page `#{@page.basename}` does not exist")
      return # ensure we exit the method after raising the error
    end

    # If there's another more correct version of the URL (for example, we changed `_`
    # to `-`), then redirect them to where they should be.
    unless @page.is_canonical?
      redirect_to "/docs/#{@page.canonical_url}", status: :moved_permanently
      return # ensure we exit the method after redirecting
    end

    # Handle different formats
    respond_to do |format|
      format.html {
        markdown_url = "#{request.base_url}/docs/#{@page.canonical_url}.md"
        response.headers["Link"] = %(<#{markdown_url}>; rel="alternate"; type="text/markdown")
        @markdown_alternate_url = markdown_url
        render @page.template
      }
      format.md {
        canonical_url = "#{request.base_url}/docs/#{@page.canonical_url}"
        response.headers["Link"] = %(<#{canonical_url}>; rel="canonical")
        render plain: @page.markdown_body_with_table_conversion, content_type: "text/markdown"
      }
    end
  end

  private

  # Rails' respond_to prefers the first declared format when Accept includes */*,
  # which most AI fetchers send (e.g. Claude Code: "text/markdown, text/html, */*").
  # Explicitly route to markdown when the client lists text/markdown as acceptable.
  def negotiate_markdown_from_accept_header
    return if params[:format].present?

    accepted = request.accept.to_s.split(",").map { |type| type.split(";").first.to_s.strip }
    request.format = :md if accepted.include?("text/markdown")
  end

  def beta?
    @page && @page.beta?
  end
  helper_method :beta?

end
