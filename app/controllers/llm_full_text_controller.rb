# frozen_string_literal: true

class LLMFullTextController < ApplicationController
  def index
    if Rails.env.production?
      expires_in 1.hour, public: true
      content = Rails.cache.fetch("llm_full_text", expires_in: 1.hour) do
        LLMFullText.generate
      end
    else
      content = LLMFullText.generate
    end

    render plain: content, content_type: "text/plain"
  end
end
