class QuickReferenceController < ApplicationController
  append_view_path "app/views/pages"

  before_action :add_cors_headers

  PIPELINE_PAGES = [
    'pipelines/configure/step-types/command_step',
    'pipelines/configure/step-types/wait_step',
    'pipelines/configure/step-types/block_step',
    'pipelines/configure/step-types/input_step',
    'pipelines/configure/step-types/trigger_step',
    'pipelines/configure/step-types/group_step'
  ].freeze

  NOTIFICATION_PAGES = [
    'pipelines/configure/notifications'
  ].freeze

  def pipelines
    @steps_content = parse_pages(PIPELINE_PAGES)
    @notifications_content = parse_pages(NOTIFICATION_PAGES)

    render formats: :json
  end

  private

  def parse_pages(pages)
    pages.map do |path|
      page = Page.new(view_context, path)

      data = page.extracted_data

      data["docsURL"] = "/docs/#{page.canonical_url}"

      data
    end
  end

  def add_cors_headers
    headers["Access-Control-Allow-Methods"] = "GET, OPTIONS"
    headers["Access-Control-Allow-Origin"] = '*'
  end
end
