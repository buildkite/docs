# frozen_string_literal: true

# Heroku likes the version here; we like only updating one place
ruby File.read(".ruby-version").strip

source "https://rubygems.org"

# Choo choo 🚝 (only include the Rails gems we need)
gem "actionpack", "~> 8.0.1"
gem "actionview", "~> 8.0.1"
gem "activesupport", "~> 8.0.1"
gem "railties", "~> 8.0.1"

# Use Puma as the app server
gem "puma"

# Helps with running the server locally
gem "foreman"

# For converting strings to URL friendly versions
gem "stringex"

# Rendering markdown
gem "redcarpet"

# Parsing markdown
gem "commonmarker"

# Syntax highlighting code
gem "rouge", "3.30.0"

# For escaping code snippets in markdown
gem "escape_utils"

# One rails log line per request, instead of enraging quantity
gem "lograge"

# Error reporting
gem "bugsnag"

# Parse "front matter" from markdown files
gem 'front_matter_parser'

gem 'matrix'

# Asset compilation
gem 'vite_rails'

# No page reloads
gem 'turbo-rails'

# Sitemap
gem 'sitemap_generator'

group :development, :test do
  # Call "byebug" anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "dotenv-rails"
end

group :development do
  # Access an interactive console on exception pages or by calling `console` anywhere in the code.
  gem "web-console"
  gem "pry"
  gem 'graphql-client'
end

group :test do
  # Who doesn't love tests!?
  gem "rspec-rails"

  # We want junit output so we can annotate the build
  gem "rspec_junit_formatter"

  # Browser testing stuff
  gem "capybara"

  gem "buildkite-test_collector"
end
