require 'json'

class Schema
  def initialize(schema_json)
    schema_hash = JSON.parse(schema_json)
    schema_data = schema_hash["data"]["__schema"]
    
    @all_schema_types = schema_data["types"]
    @query_type_name = schema_data["queryType"]["name"]
    @mutation_type_name = schema_data["mutationType"]["name"]
    @type_sets_default = {
      "query_types" => [],
      "mutation_types" => [],
      "object_types" => [],
      "scalar_types" => [],
      "interface_types" => [],
      "enum_types" => [],
      "input_object_types" => [],
      "union_types" => []
    }
  end

  def type_sets
    type_sets = @type_sets_default
    query_object_type = nil

    @all_schema_types.each do |type|
      key = "#{type["kind"].downcase}_types"
      type_sets[key].push type
    end

    query_object_type = type_sets["object_types"].find { |object_type| object_type["name"] == @query_type_name }
    type_sets["query_types"] = query_object_type && query_object_type["fields"]

    mutation_object_type = type_sets["object_types"].find { |object_type| object_type["name"] == @mutation_type_name }
    type_sets["mutation_types"] = mutation_object_type && mutation_object_type["fields"]

    type_sets
  end
end
