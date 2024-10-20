Rails.application.configure do
  nav_data = YAML.load_file(File.join(Rails.root, 'data', 'nav.yml'))

  graphql_nav_item = nav_data
    .find { |item| item["name"] == "APIs" }["children"]
    .find { |item| item["name"] == "GraphQL" }

  graphql_nav_item["children"].concat(YAML.load_file(File.join(Rails.root, 'data', 'nav_graphql.yml')))

  config.default_nav = Nav.new(nav_data)
end
