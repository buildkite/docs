# frozen_string_literal: true

class LLMTopicTextController < ApplicationController
  def show
    topic_slug = params[:topic]

    unless LLMTopicText.valid_topic?(topic_slug)
      render plain: "Not found", status: :not_found
      return
    end

    content = LLMTopicText.generate(topic_slug)

    render plain: content, content_type: "text/plain"
  end
end
