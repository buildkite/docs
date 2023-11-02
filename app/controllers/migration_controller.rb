class MigrationController < ApplicationController
  skip_forgery_protection

  def show
    @nav = default_nav

    render template: "migrate", layout: "homepage"
  end

  def migrate
    # Some request path rewriting for the compat server to slot in.
    request.env["REQUEST_PATH"] = "/"
    request.env["REQUEST_URI"] = "/"
    request.env["PATH_INFO"] = "/"

    res = BK::Compat::Server.new.call(request.env)

    render body: res[2].string, status: res[0], content_type: res[1]["content-type"]
  end
end
