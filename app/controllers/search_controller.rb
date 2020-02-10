class SearchController < ApplicationController

  skip_before_action :verify_authenticity_token, :only => [:show]

  def show
    @data = []

    @query = params[:search_query]

    @data = Search.new.find_word(@query)

    respond_to do |format|
      format.html
    end

  end
end
