class PagesController < ApplicationController
  def show
    # @page = params[:page]

    # @docs_presenter = DocumentationPresenter.new(request)
    @page = Page.new(view_context, params[:path])

    unless @page.exists?
      raise ActionController::RoutingError.new("That documentation page does not exist")
    end

    view_context.provide(:page_title, @page.title)

    render html: @page.body, layout: true


    # unless @docs_page_presenter.is_canonical?
    #   redirect_to @docs_presenter.url_for(@docs_page_presenter.canonical_url), status: :moved_permanently
    # end
  end
end
