class PagesController < ApplicationController
  append_view_path "pages"
  layout :layout_by_path

  def index
    @nav = default_nav

    render :index, layout: "homepage"
  end

  def show
    @nav = default_nav
    @page = Page.new(view_context, params[:path])

    # If the page doesn't exist, throw a 404
    raise ActionController::RoutingError.new("The documentation page `#{@page.basename}` does not exist") unless @page.exists?

    # If there's another more correct version of the URL (for example, we changed `_`
    # to `-`), then redirect them to where they should be.
    unless @page.is_canonical?
      redirect_to "/docs/#{@page.canonical_url}", status: :moved_permanently
    end

    # Otherwise, render the page (the default)
  end

  private

  def beta?
    @page && @page.beta?
  end
  helper_method :beta?

  def landing_page?
    @page && @page.landing_page?
  end

  def layout_by_path
    if landing_page?
      "landing_page"
    else
      "application"
    end
  end
end
