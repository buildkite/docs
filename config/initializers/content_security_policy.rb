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
  policy.object_src :none

  # algolia requires eval
  policy.script_src :self, :unsafe_eval, Matomo::URL, Posthog::URL, "https://www.googletagmanager.com/"

  # allow AJAX queries against our search vendor
  policy.connect_src "https://#{ENV["ALGOLIA_APP_ID"]}-dsn.algolia.net", "https://#{ENV["ALGOLIA_APP_ID"]}-1.algolianet.com", "https://#{ENV["ALGOLIA_APP_ID"]}-2.algolianet.com", "https://#{ENV["ALGOLIA_APP_ID"]}-3.algolianet.com", Posthog::URL, "https://www.google-analytics.com/"

  # Specify URI for violation reports
  policy.report_uri "/_csp-violation-reports"
end

# We use nonce for inline scripts
Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }

# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
Rails.application.config.content_security_policy_report_only = true
