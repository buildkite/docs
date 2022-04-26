class PagesController < ApplicationController
  append_view_path "pages"

  def index
    render layout: "homepage"
  end

  def show
    @page = Page.new(view_context, params[:path])

    # If the page doesn't exist, throw a 404
    raise ActionController::RoutingError.new("The documentation page `#{@page.basename}` does not exist") unless @page.exists?

    # For the homepage, render with a custom layout that doesn't include the sidebar etc

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
end
