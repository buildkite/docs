# frozen_string_literal: true

module Matomo
  URL = ENV.fetch("MATOMO_URL", "http://analytics.buildkite.localhost").freeze
  HOST = ENV.fetch("MATOMO_HOST") { URI.parse(URL).host }.freeze
  TRACKER_URL = ENV.fetch("MATOMO_TRACKER_URL") { URI.join(URL, "matomo.php") }.freeze
  TRACKER_JS_URL = ENV.fetch("MATOMO_TRACKER_JS_URL") { URI.join(URL, "matomo.js") }.freeze
end
