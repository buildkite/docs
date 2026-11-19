# Rejects non-ASCII method overrides before Rack::MethodOverride runs String
# case conversion on them.
class RejectUnsafeMethodOverrideMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    if env[Rack::REQUEST_METHOD] == "POST"
      request = Rack::Request.new(env)
      method = begin
        request.POST["_method"] if request.form_data? || request.parseable_data?
      rescue Rack::Utils::InvalidParameterError, Rack::Utils::ParameterTypeError, Rack::QueryParser::ParamsTooDeepError, EOFError
        nil
      end
      method ||= env[Rack::MethodOverride::HTTP_METHOD_OVERRIDE_HEADER]

      if method && !method.to_s.ascii_only?
        env[Rack::RACK_TEMPFILES]&.each(&:close!)
        return [400, { "content-type" => "text/plain" }, ["Invalid method override"]]
      end
    end

    @app.call(env)
  end
end

Rails.application.config.middleware.insert_before Rack::MethodOverride, RejectUnsafeMethodOverrideMiddleware
