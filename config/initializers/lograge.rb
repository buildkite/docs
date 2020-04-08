Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.custom_options = lambda do |event|
    {
      ip: event.payload[:remote_ip],
      request_id: event.payload[:request_id],
      user_agent: event.payload[:user_agent],
    }
  end
end
