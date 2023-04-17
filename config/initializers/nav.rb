Rails.application.configure do
  config.base_nav = YAML.load_file(File.join(Rails.root, 'data', "nav.yml"))
  config.graphql_nav = YAML.load_file(File.join(Rails.root, 'data', "nav_graphql.yml"))
end
