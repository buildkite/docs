module NavData
  def convert_to_nav_items(type_set)
    nav_items = []
    
    type_set.each do |set|
      nav_items.push({
        "name" => set["name"],
        "path" => "apis/graphql/schemas/#{set['name'].downcase}"
      })
    end
  
    nav_items
  end

  def generate_graphql_nav_data(docs_nav_data, type_sets)
    graphql_nav_data = docs_nav_data
    graphql_nav_data[0].map { |nav_item| nav_item.delete('children') }
    graphql_nav_data[0][2]["children"] = [
      {
        "name" => "All APIs",
        "path" => "apis",
        "icon" => "arrow-left.svg"
      },
      {
        "is_divider" => true
      },
      {
        "name" => "GraphQL API",
        "children" => [
          {
            "name" => "Overview",
            "path" => "apis/graphql-api"
          },
          {
            "name" => "Console and CLI tutorial",
            "path" => "apis/graphql/graphql-tutorial"
          },
          {
            "name" => "Cookbook",
            "path" => "apis/graphql/graphql-cookbook"
          }
        ]
      },
      {
        "name" => "Queries",
        "children" => convert_to_nav_items(type_sets["query_types"])
      },
      {
        "name" => "Objects",
        "children" => convert_to_nav_items(type_sets["object_types"])
      },
      {
        "name" => "Scalars",
        "children" => convert_to_nav_items(type_sets["scalar_types"])
      },
      {
        "name" => "Interfaces",
        "children" => convert_to_nav_items(type_sets["interface_types"])
      },
      {
        "name" => "ENUMs",
        "children" => convert_to_nav_items(type_sets["enum_types"])
      },
      {
        "name" => "Input objects",
        "children" => convert_to_nav_items(type_sets["input_object_types"])
      },
      {
        "name" => "Unions",
        "children" => convert_to_nav_items(type_sets["union_types"])
      }
    ]

    graphql_nav_data
  end
end
