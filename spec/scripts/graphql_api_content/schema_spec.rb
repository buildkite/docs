require_relative '../../../scripts/graphql_api_content/schema'

RSpec.describe Schema do
  schema = Schema.new(
    <<~JSON
      {
        "data": {
          "__schema": {
            "types": [
              {
                "kind": "SCALAR",
                "name": "Boolean",
                "description": "Represents `true` or `false` values.",
                "fields": null,
                "inputFields": null,
                "interfaces": null,
                "enumValues": null,
                "possibleTypes": null
              },
              {
                "kind": "OBJECT",
                "name": "Query",
                "description": "The query root for this schema",
                "fields": [
                  {
                    "name": "agent",
                    "description": "Find an agent by its slug",
                    "args": [
                      {
                        "name": "slug",
                        "description": "The UUID for the agent, prefixed by its organization's slug i.e. `acme-inc/0bd5ea7c-89b3-4f40-8ca3-ffac805771eb`",
                        "type": {
                          "kind": "NON_NULL",
                          "name": null,
                          "ofType": {
                            "kind": "SCALAR",
                            "name": "ID",
                            "ofType": null
                          }
                        },
                        "defaultValue": null
                      }
                    ],
                    "type": {
                      "kind": "OBJECT",
                      "name": "Agent",
                      "ofType": null
                    },
                    "isDeprecated": false,
                    "deprecationReason": null
                  }
                ],
                "inputFields": null,
                "interfaces": null,
                "enumValues": null,
                "possibleTypes": null
              }
            ]
          }
        }
      }
    JSON
  )

  describe "#type_sets" do
    it "should have the right keys" do
      type_sets = schema.type_sets
      expect(type_sets.keys.sort).to eq([
        "query_types",
        "object_types",
        "scalar_types",
        "interface_types",
        "enum_types",
        "input_object_types",
        "union_types"
    ].sort)
    end
  end
end
