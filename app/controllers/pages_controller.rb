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

    # Handle different formats
    respond_to do |format|
      format.html { render @page.template }
      format.md {
        render plain: @page.markdown_body, content_type: "text/markdown"
      }
    end
  end

  private

  def beta?
    @page && @page.beta?
  end
  helper_method :beta?

end
