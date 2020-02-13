class SearchController < ApplicationController

  skip_before_action :verify_authenticity_token, :only => [:show]

  def index
    @data = []

    @query = params[:query]

    @data = Search.find_word(@query)

    respond_to do |format|
      format.html
    end

  end
end
