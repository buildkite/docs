module NavData
  def convert_to_nav_items(type_set)
    nav_items = []
    
    type_set.each do |schema_type_data|
      nav_items.push({
        "name" => schema_type_data["name"],
        "path" => "apis/graphql/schemas/#{schema_type_data['name'].downcase}"
      })
    end
  
    nav_items.sort_by { |nav_item| nav_item["name"] }
  end

  def generate_graphql_nav_data(docs_nav_data, type_sets)
    graphql_nav_data = docs_nav_data
    graphql_nav_data[0].map { |nav_item| nav_item.delete('children') }
    graphql_nav_data[0][2]["children"] = [
      {
        "name" => "All APIs",
        "path" => "apis",
        "type" => "back"
      },
      {
        "type" => "divider"
      },
      {
        "name" => "GraphQL API",
        "path" => "apis/graphql-api"
      },
      {
        "name" => "Console and CLI tutorial",
        "path" => "apis/graphql/graphql-tutorial"
      },
      {
        "name" => "Schema Browser",
        "start_expanded" => true,
        "children" => [
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
      },
      {
        "name" => "Cookbook",
        "path" => "apis/graphql/graphql-cookbook"
      }
    ]

    graphql_nav_data
  end
end
