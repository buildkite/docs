class PagesController < ApplicationController
  append_view_path "pages"

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

    # Otherwise, render the page (the default)
    render @page.template
  end

  private

  def beta?
    @page && @page.beta?
  end
  helper_method :beta?

  # Renders keywords to the page for content writers to inspect and use as a guide
  # Gracefully falls back to the page's path if no keywords are specified
  # to help reduce content workload
  def content_keywords
    @page.keywords || request.path.split("/").reject(&:empty?).map { |segment| segment.gsub("-", " ") }.join(", ")
  end
  helper_method :content_keywords

end
