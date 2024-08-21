module NavData
  def convert_to_nav_items(type_set, sub_dir = nil)
    nav_items = []

    type_set.each do |schema_type_data|
      sub_dir = sub_dir || schema_type_data["kind"].to_s.downcase

      nav_items.push({
        "name" => schema_type_data["name"],
        "path" => "apis/graphql/schemas/#{sub_dir.gsub('_', '-')}/#{schema_type_data['name'].downcase.gsub('_', '-')}"
      })
    end

    nav_items.sort_by { |nav_item| nav_item["name"] }
  end

  def generate_graphql_nav_data(type_sets)
    [
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
        "children" => [
          {
            "name" => "Overview",
            "path" => "apis/graphql/graphql-cookbook"
          },
          {
            "name" => "Agents",
            "path" => "apis/graphql/cookbooks/agents"
          },
          {
            "name" => "Artifacts",
            "path" => "apis/graphql/cookbooks/artifacts"
          },
          {
            "name" => "Builds",
            "path" => "apis/graphql/cookbooks/builds"
          },
          {
            "name" => "Clusters",
            "path" => "apis/graphql/cookbooks/clusters"
          },
          {
            "name" => "Jobs",
            "path" => "apis/graphql/cookbooks/jobs"
          },
          {
            "name" => "Packages",
            "path" => "apis/graphql/cookbooks/packages"
          },
          {
            "name" => "Pipelines",
            "path" => "apis/graphql/cookbooks/pipelines"
          },
          {
            "name" => "Pipeline templates",
            "path" => "apis/graphql/cookbooks/pipeline-templates"
          },
          {
            "name" => "Organizations",
            "path" => "apis/graphql/cookbooks/organizations"
          },
          {
            "name" => "Teams",
            "path" => "apis/graphql/cookbooks/teams"
          }
        ]
      },
      {
        "name" => "Limits",
        "path" => "apis/graphql/graphql-resource-limits"
      },
      {
        "name" => "Queries",
        "children" => convert_to_nav_items(type_sets["query_types"], "query")
      },
      {
        "name" => "Mutations",
        "children" => convert_to_nav_items(type_sets["mutation_types"], "mutation")
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
  end
end
