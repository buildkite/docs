require 'json'

scripts_dir = File.dirname(__FILE__)
schemas_dir = "#{scripts_dir}/../pages/apis/graphql/schemas"
schema_json = File.read("#{scripts_dir}/../data/graphql_data_schema.json")
data_hash = JSON.parse(schema_json)
all_types = data_hash["data"]["__schema"]["types"]

type_sets = {
  "object_types" => [],
  "scalar_types" => [],
  "interface_types" => [],
  "enum_types" => [],
  "input_object_types" => [],
  "union_types" => []
}

all_types.each do |type|
  key = "#{type["kind"].downcase}_types"
  type_sets[key].push type
end

type_sets.each_value do |set|
  set.each do |type|
    name = type["name"]
    description = type["description"]

    if name && name.length() > 0
      File.write(
        "#{schemas_dir}/#{name}.md.erb",
        <<~MARKDOWN
          # #{name}

          #{description}
        MARKDOWN
      )
    end
  end
end
