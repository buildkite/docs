class PagesController < ApplicationController
  append_view_path "app/views/pages"

  def show
    @page = Page.new(view_context, params[:path])

    # If the page doesn't exist, throw a 404
    raise ActionController::RoutingError.new("That documentation page does not exist") unless @page.exists?

    # If there's another more correct version of the URL (i.e. we changed `_`
    # to `-`), then redirect them to where they should be.
    unless @page.is_canonical?
      redirect_to "/docs/#{@page.canonical_url}", status: :moved_permanently
    end

    # Otherwise, render the page (the default)
  end
end
