# frozen_string_literal: true

class Page
  module Importance
    DEFAULT_SCORE = 50
    SCORES_PATH = Rails.root.join("config", "importance-scores.json")

    def self.scores
      @scores ||= JSON.parse(File.read(SCORES_PATH))
                      .except("_comment")
                      .transform_values(&:to_i)
    end

    def self.for(canonical_url)
      scores.fetch(canonical_url, DEFAULT_SCORE)
    end

    def self.reload!
      @scores = nil
    end
  end
end
