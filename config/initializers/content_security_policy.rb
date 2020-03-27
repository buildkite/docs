# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

Rails.application.config.content_security_policy do |policy|
  policy.default_src :self
  policy.font_src    :self, 'https://www2.buildkiteassets.com/'
  policy.img_src     :self, 'https://buildkiteassets.com/', 'https://buildkite.com/', Matomo::URL, :data, :https, :http
  policy.object_src  :none
  policy.script_src  :self, Matomo::URL
  policy.script_src  :self, :unsafe_inline, :strict_dynamic, :report_sample, :https, :http

  # Allow unsafe_eval in development. Mostly because we do the same in the buildktie app, but also
  # because it's required to load the algolia docsearch JS
  if Rails.env.development?
    #policy.script_src :self, :unsafe_eval, Matomo::URL, :unsafe_inline, :strict_dynamic, :report_sample, :https, :http
    policy.script_src :unsafe_eval, :unsafe_inline, :strict_dynamic, :report_sample, :https, :http
  end
  policy.connect_src 'https://*.algolia.net', 'https://*.algolianet.com'

  # Specify URI for violation reports
  # policy.report_uri "/csp-violation-report-endpoint"
end

# We use nonce for inline scripts
Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }

# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
# Rails.application.config.content_security_policy_report_only = true
