class QuickReferenceController < ApplicationController
  append_view_path "app/views/pages"

  before_action :add_cors_headers

  PIPELINE_PAGES = [
    'pipelines/command_step',
    'pipelines/wait_step',
    'pipelines/block_step',
    'pipelines/input_step',
    'pipelines/trigger_step'
  ].freeze

  def pipelines
    @steps_content = PIPELINE_PAGES.map do |path|
      page = Page.new(view_context, path)

      data = page.extracted_data

      data["docsURL"] = "/docs/#{page.canonical_url}"

      data
    end

    render formats: :json
  end

  private

  def add_cors_headers
    headers["Access-Control-Allow-Methods"] = "GET, OPTIONS"
    headers["Access-Control-Allow-Origin"] = '*'
  end
end
