# frozen_string_literal: true

class LLMFullTextController < ApplicationController
  def index
    request.format = :md
    bundle = LLMFullText.new(default_nav, view_context)
    content = if Rails.env.production?
      expires_in 1.hour, public: true
      Rails.cache.fetch("llm_full_text", expires_in: 1.hour) { bundle.generate }
    else
      bundle.generate
    end

    render plain: content, content_type: "text/plain"
  end
end
