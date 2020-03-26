class ApplicationController < ActionController::Base
  helper_method :probably_authenticated?

  def route_not_found
    render file: Rails.root.join("public","404.html"), layout: false, status: 404
  end

  private

  # When you login to Buildkite, we set this cookie as an indicator for other
  # services that the user *may* be logged in.
  def probably_authenticated?
    request.cookie_jar[:bk_logged_in] == "true"
  end
end
