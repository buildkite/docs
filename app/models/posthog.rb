# frozen_string_literal: true

module Posthog
  # Default to the free, hosted Posthog account which we send all dev data
  URL = ENV.fetch("POSTHOG_URL", "https://app.posthog.com").freeze
  API_KEY = ENV.fetch("POSTHOG_API_KEY") { "fPfkF4tU2OBcVBZhcshmzC7_VglTw078wuqD3tl01ic" }.freeze
end
