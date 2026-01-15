# For now, CSP is in report-only mode.
#
# This is because docsearch (a JS library provided by our algolia, our search vendor)
# uses eval(), which violates CSP unless we make the policies so generous they're not
# very useful anyway.
#
# We'd love to start enforcing CSP on the docs app, but there's been little movement on
# docsearch adapting to be more CSP friendly (see https://github.com/algolia/docsearch/pull/773).
#
# Algolia have an alternative JS library that is CSP friendly and we'd love to use it.
# Maybe that's our best path to enforcing CSP?
#
# https://www.algolia.com/doc/guides/building-search-ui/what-is-instantsearch/js/

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

Rails.application.config.content_security_policy do |policy|
  policy.default_src :self
  policy.font_src    :self, "https://www2.buildkiteassets.com/"
  policy.object_src  "https://beacon-v2.helpscout.net"
  policy.style_src   :self, :unsafe_inline, "https://beacon-v2.helpscout.net"

  policy.img_src(
    :self,
    "https://buildkiteassets.com/",
    "https://buildkite.com/",
    ENV.fetch("BADGE_DOMAIN", "https://badge.buildkite.com"),
    "https://beacon-v2.helpscout.net",
  )

  policy.script_src(
    :self,
    "https://www.googletagmanager.com/",
    "https://cdn.segment.com/",
    "https://cdn.emojicom.io/",
    "https://beacon-v2.helpscout.net",
    "https://rum.browser-intake-datadoghq.com",
    "https://www.datadoghq-browser-agent.com",
    "https://js.posthog.com/",
  )

  # Allow @vite/client to hot reload javascript changes in development
  policy.script_src *policy.script_src, :unsafe_eval, "http://#{ ViteRuby.config.host_with_port }" if Rails.env.development?

  policy.connect_src(
    "https://www.google-analytics.com",

    # allow AJAX queries against our search vendor
    "https://#{ENV['ALGOLIA_APP_ID']}-dsn.algolia.net",
    "https://#{ENV['ALGOLIA_APP_ID']}-1.algolianet.com",
    "https://#{ENV['ALGOLIA_APP_ID']}-2.algolianet.com",
    "https://#{ENV['ALGOLIA_APP_ID']}-3.algolianet.com",

    "https://cdn.segment.com/",
    "https://api.segment.io/",

    # We have Datadog Real User Monitoring enabled
    "https://rum.browser-intake-datadoghq.com",

    # For collecting feedback from customers
    "https://emojicom.io/",

    # helpscout beacon sends data to two places
    "https://beacon-v2.helpscout.net",
    "https://d3hb14vkzrxvla.cloudfront.net",

    #posthog
    "https://us.i.posthog.com",
  )

  # Allow @vite/client to hot reload changes in development
  policy.connect_src *policy.connect_src, "ws://#{ ViteRuby.config.host_with_port }" if Rails.env.development?

  # For collecting feedback from customers
  policy.frame_src(
    "https://cdn.emojicom.io/"
  )

  policy.media_src(
   "https://beacon-v2.helpscout.net"
  )

  # Specify URI for violation reports. We only include this in the header in some environments, mostly
  # so CSP in dev+test is still in play but it doesn't send useless reports to anywhere
  if ENV.key?("CSP_REPORT_URI")
    policy.report_uri ENV.fetch("CSP_REPORT_URI", nil)
  end
end

# We use nonce for inline scripts
Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }

# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
Rails.application.config.content_security_policy_report_only = true
