Rails.application.config.generators do |generate|
  generate.helper false
  generate.request_specs false
  generate.routing_specs false
  generate.stylesheets false
  generate.system_tests = nil
  generate.test_framework :rspec
  generate.view_specs false
end

