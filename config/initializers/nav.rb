Rails.application.configure do
  config.default_nav = Nav.new(
    YAML.load_file(File.join(Rails.root, 'data', 'nav.yml'))
  )
  config.graphql_nav = Nav.new(
    YAML.load_file(File.join(Rails.root, 'data', 'nav_graphql.yml'))
  )
end
