class PagesController < ApplicationController
  append_view_path "pages"
  layout :layout_by_path

  def layout_by_path
    if request.path == "/docs"
      "homepage"
    elsif request.path.starts_with? "/docs/apis/graphql"
      "graphql"
    else
      "application"
    end
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

  def is_landing_page?
    @page && @page.is_landing_page?
  end
  helper_method :is_landing_page?

end
