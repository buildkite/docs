# frozen_string_literal: true

class LLMTextController < ApplicationController
  def index
    content = LLMText.generate

    render plain: content, content_type: "text/plain"
  end
end
