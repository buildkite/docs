if ENV["BUGSNAG_API_KEY"].present?
  Bugsnag.configure do |config|
    config.api_key = ENV["BUGSNAG_API_KEY"]

    # Ignore exceptions handled as a client error by ActionDispatch::ShowExceptions
    config.add_on_error(-> (event) {
      name = event.original_error.class.name
      if ActionDispatch::ExceptionWrapper.status_code_for_exception(name) < 500
        return false # discard
      end
    })
  end
end
