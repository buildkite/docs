# Removes trailing slashes from URLs, making sure we don't serve up two
# different URLs with the same content, and confuse spiders as to which is the
# canonical URL.
class TrailingSlashMiddlware
  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)

    if req.path_info != "/" && req.path_info.end_with?("/")
      req.path_info = req.path_info.delete_suffix("/")
      [
        301,
        { "Location" => req.url, "Content-Type" => "text/plain" },
        ["Moved permanently to #{req.url}"]
      ]
    else
      @app.call(env)
    end
  end
end

Rails.application.config.middleware.use TrailingSlashMiddlware
