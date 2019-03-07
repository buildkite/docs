class PagesController < ApplicationController
  def show
    @page = Page.new(view_context, params[:path])

    # If the page doesn't exist, throw a 404
    raise ActionController::RoutingError.new("That documentation page does not exist") unless @page.exists?

    # If the URL we landed on is the *correct* version of the URL, render the
    # content.
    #
    # If there's another more correct version of the URL (i.e. we changed `_`
    # to `-`), then redirect them to where they should be.
    if @page.is_canonical?
      @page_title = @page.title
      render html: @page.body, layout: true
    else
      redirect_to "/docs/#{@page.canonical_url}", status: :moved_permanently
    end
  end
end
