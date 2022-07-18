require_relative '../../../scripts/graphql_api_content/nav_data'
include NavData

RSpec.describe NavData do
  type_sets = {
    "query_types" => [
      {
        "name" => "schema1"
      },
      {
        "name" => "schema2"
      }
    ],
    "object_types" => [
      {
        "name" => "schema3"
      },
      {
        "name" => "schema4"
      }
    ],
    "scalar_types" => [
      {
        "name" => "schema5"
      },
      {
        "name" => "schema6"
      }
    ],
    "interface_types" => [
      {
        "name" => "schema7"
      },
      {
        "name" => "schema8"
      }
    ],
    "enum_types" => [
      {
        "name" => "schema9"
      },
      {
        "name" => "schema10"
      }
    ],
    "input_object_types" => [
      {
        "name" => "schema11"
      },
      {
        "name" => "schema12"
      }
    ],
    "union_types" => [
      {
        "name" => "schema13"
      },
      {
        "name" => "schema14"
      }
    ]
  }

  describe "#convert_to_nav_items" do
    it "converts to an array of nav_item hashes" do
      expect(convert_to_nav_items(type_sets["object_types"])).to eq([
        {
          "name" => "schema3",
          "path" => "apis/graphql/schemas/schema3"
        },
        {
          "name" => "schema4",
          "path" => "apis/graphql/schemas/schema4"
        }
      ])
    end
  end

  describe "#generate_graphql_nav_data" do
    it "generates nav data correctly" do
      docs_nav_data = [
        [
          {
            "name" => "Pipelines",
            "path" => "tutorials/getting-started",
            "icon" => "pipeline.svg"
          },
          { 
            "name" => "Test Analytics",
            "path" => "test-analytics",
            "icon" => "test-analytics.svg",
            "pill" => "new"
          },
          {
            "name" => "APIs",
            "path" => "apis/graphql-api",
            "icon" => "api.svg"
          }
        ]
      ]

      expect(generate_graphql_nav_data(docs_nav_data, type_sets)).to eq([
        [
          {
            "name" => "Pipelines",
            "path" => "tutorials/getting-started",
            "icon" => "pipeline.svg"
          },
          {
            "name" => "Test Analytics", "path" => "test-analytics", "icon" => "test-analytics.svg", "pill" => "new"
          },
          {
            "name" => "APIs",
            "path" => "apis/graphql-api",
            "icon" => "api.svg",
            "children" => [
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
                "children" => [
                  {
                    "name" => "schema1",
                    "path" => "apis/graphql/schemas/schema1"
                  },
                  {
                    "name" => "schema2",
                    "path" => "apis/graphql/schemas/schema2"
                  }
                ]
              },
              {
                "name" => "Objects",
                "children" => [
                  {
                    "name" => "schema3",
                    "path" => "apis/graphql/schemas/schema3"
                  },
                  {
                    "name" => "schema4",
                    "path" => "apis/graphql/schemas/schema4"
                  }
                ]
              },
              {
                "name" => "Scalars",
                "children" => [
                  {
                    "name" => "schema5",
                    "path" => "apis/graphql/schemas/schema5"
                  }, {
                    "name" => "schema6",
                    "path" => "apis/graphql/schemas/schema6"
                  }
                ]
              },
              {
                "name" => "Interfaces",
                "children" => [{
                  "name" => "schema7",
                  "path" => "apis/graphql/schemas/schema7"
                }, {
                  "name" => "schema8",
                  "path" => "apis/graphql/schemas/schema8"
                }]
              },
              {
                "name" => "ENUMs",
                "children" => [
                  {
                    "name" => "schema9",
                    "path" => "apis/graphql/schemas/schema9"
                  },
                  {
                    "name" => "schema10",
                    "path" => "apis/graphql/schemas/schema10"
                  }
                ]
              },
              {
                "name" => "Input objects",
                "children" => [
                  {
                    "name" => "schema11",
                    "path" => "apis/graphql/schemas/schema11"
                  },
                  {
                    "name" => "schema12",
                    "path" => "apis/graphql/schemas/schema12"
                  }
                ]
              },
              {
                "name" => "Unions",
                "children" => [
                  {
                    "name" => "schema13",
                    "path" => "apis/graphql/schemas/schema13"
                  },
                  {
                    "name" => "schema14",
                    "path" => "apis/graphql/schemas/schema14"
                  }
                ]
              }
            ]
          }
        ]
      ])
    end
  end
end
