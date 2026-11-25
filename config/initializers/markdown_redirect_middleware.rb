# Preserve the explicit Markdown format across redirects between docs pages,
# including both routing aliases and controller-level canonicalization.
class MarkdownRedirectMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)
    if status.in?([301, 302, 307, 308]) && env["PATH_INFO"].match?(%r{\A/docs(?:/.*)?\.md\z}) && headers["location"]
      request = ActionDispatch::Request.new(env)
      location = URI.parse(headers["location"])
      if (location.host.nil? || headers["location"].start_with?("#{request.base_url}/")) &&
          location.path&.match?(%r{\A/docs(?:/[\w-]+)*\z})
        location.path += ".md"
        headers["location"] = location.to_s
      end
    end
    [status, headers, body]
  end
end

Rails.application.config.middleware.use MarkdownRedirectMiddleware
