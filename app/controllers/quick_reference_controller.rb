class QuickReferenceController < ApplicationController
  before_action :add_cors_headers

  def pipelines; end

  private

  def add_cors_headers
    headers["Access-Control-Allow-Methods"] = "GET, OPTIONS"
    headers["Access-Control-Allow-Origin"] = '*'
  end
end
