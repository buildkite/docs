# The docs are served from https://buildkite.com/docs, the same browser origin as the
# Buildkite app, so any script that runs here can make authenticated requests to the app.
# This policy is enforced to limit which scripts can run. It does not stop a script that
# runs from sending data out.
#
# Before allowing a new script host, prefer bundling the vendor's JavaScript with Vite, as
# the docs do for PostHog.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

# Vite builds ALGOLIA_APP_ID from .env.production and .env.development into the search
# JavaScript. Production sets a different ALGOLIA_APP_ID at runtime, so don't read it from ENV.
algolia_app_id = "3K1WZ230FA"

Rails.application.config.content_security_policy do |policy|
  policy.default_src :self
  policy.base_uri    :self
  policy.form_action :self
  policy.object_src  :none

  policy.font_src(
    :self,
    "https://www2.buildkiteassets.com/",
    "https://buildkite.com/_site/assets/fonts/",

    # Plain chat
    "https://chat.cdn-plain.com",
  )

  policy.style_src(
    :self,
    :unsafe_inline,

    # Plain chat
    "https://fonts.googleapis.com",
  )

  policy.img_src(
    :self,
    :data,
    "https://buildkiteassets.com/",
    "https://buildkite.com/",
    ENV.fetch("BADGE_DOMAIN", "https://badge.buildkite.com"),

    # Plain chat: workspace logo, attachment files, AI agent avatar, and Gravatar (agent profile pictures)
    "https://static-assets.plain.com",
    "https://prod-uk-services-workspac-workspacefilespublicbuck-vs4gjqpqjkh6.s3.amazonaws.com",
    "https://prod-uk-services-attachm-attachmentsbucket28b3ccf-uwfssb4vt2us.s3.eu-west-2.amazonaws.com",
    "https://i0.wp.com",

    # Add to Cursor buttons
    "https://cursor.com/deeplink/",
  )

  policy.script_src(
    :self,
    "https://www.datadoghq-browser-agent.com",
    "https://static.reo.dev",
    "https://chat.cdn-plain.com",
  )

  # Allow @vite/client to hot reload javascript changes in development
  policy.script_src *policy.script_src, :unsafe_eval, "http://#{ ViteRuby.config.host_with_port }" if Rails.env.development?

  policy.connect_src(
    # Turbo visits and the copy page Markdown fetch
    :self,

    # allow AJAX queries against our search vendor
    "https://#{algolia_app_id}-dsn.algolia.net",
    "https://#{algolia_app_id}-1.algolianet.com",
    "https://#{algolia_app_id}-2.algolianet.com",
    "https://#{algolia_app_id}-3.algolianet.com",

    # We have Datadog Real User Monitoring enabled
    "https://rum.browser-intake-datadoghq.com",

    # PostHog: events, and remote configuration from the assets host
    "https://us.i.posthog.com",
    "https://us-assets.i.posthog.com",

    # Reo.dev product analytics
    "https://api.reo.dev",

    # Plain chat: message API and attachment uploads
    "https://chat.uk.plain.com",
    "https://prod-uk-services-attachm-attachmentsuploadbucket2-1l2e4906o2asm.s3.eu-west-2.amazonaws.com",
  )

  # Allow @vite/client to hot reload changes in development
  policy.connect_src *policy.connect_src, "ws://#{ ViteRuby.config.host_with_port }" if Rails.env.development?

  policy.frame_src(
    # Plugins directory and emoji browser embeds
    "https://buildkite.com/resources/plugins/",
    "https://emoji.buildkite.com",
  )

  # Specify URI for violation reports. We only include this in the header in some environments, mostly
  # so CSP in dev+test is still in play but it doesn't send useless reports to anywhere
  if ENV.key?("CSP_REPORT_URI")
    policy.report_uri ENV.fetch("CSP_REPORT_URI", nil)
  end
end

# We use nonce for inline scripts. Styles don't get a nonce, because a nonce in style-src
# makes browsers ignore 'unsafe-inline', which blocks the style attributes in docs pages.
Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }
Rails.application.config.content_security_policy_nonce_directives = %w(script-src)
