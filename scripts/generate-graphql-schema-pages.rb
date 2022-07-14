require 'json'
require 'yaml'

scripts_dir = File.dirname(__FILE__)
schemas_dir = "#{scripts_dir}/../pages/apis/graphql/schemas"
schema_json = File.read("#{scripts_dir}/../data/graphql_data_schema.json")
data_hash = JSON.parse(schema_json)
all_types = data_hash["data"]["__schema"]["types"]

type_sets = {
  "query_types" => nil,
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

query_types = type_sets["object_types"].find { |object_type| object_type["name"] == "Query" }
type_sets["query_types"] = query_types && query_types["fields"]

def render_of_type(of_type)
  if of_type["ofType"]
    render_of_type(of_type["ofType"])
  else
    if of_type["name"]
      "<a href=\"/docs/apis/graphql/schemas/#{of_type["name"].downcase}\" title=\"#{of_type["kind"]} #{of_type["name"]}\">"\
      "  #{of_type["name"]}"\
      "</a>"
    else
      of_type["kind"]
    end
  end
end

def render_fields(fields)
  if fields.is_a?(Array) && !fields.empty?
    <<~HTML
      <h2>Fields</h2>
      <table class="responsive-table">
        <tbody>
          #{
            fields.map {
              |field|
              <<~HTML
                <tr>
                  <td>
                    <h3>
                      <code>#{field["name"]}</code>
                      #{render_of_type(field["type"])}
                      #{field["isDeprecated"] ? '<span class="pill pill--deprecated">Deprecated</span>' : ""}
                    </h3>
                    #{field["deprecationReason"] && "<p>Deprecated: #{field["deprecationReason"]}</p>"}
                    #{field["description"] && "<p>#{field["description"]}</p>"}
                    #{render_field_args(field["args"])}
                  </td>
                </tr>
              HTML
            }.join('')
          }
        </tbody>
      </table>
    HTML
  end
end

def render_field_args(args)
  if args.is_a?(Array) && !args.empty?
    <<~HTML
      <h4>Arguments</h4>
      #{
        args.map {
          |arg|
          <<~HTML
            <h5>
              <code>#{arg["name"]}</code>
              #{render_of_type(arg["type"])}
              #{!arg["defaultValue"] && "<span>Required</span>"}
            </h5>
            #{arg["description"] && "<p>#{arg["description"]}</p>"}
            #{arg["defaultValue"] && "<p>Default value: #{arg["defaultValue"]}</p>"}
          HTML
        }.join('')
      }
    HTML
  end
end

def render_possible_types(possible_types)
  if possible_types.is_a?(Array) && !possible_types.empty?
    <<~HTML
      <h3>Possible types</h3>
      #{possible_types.map { |possible_type| render_of_type(possible_type) }.join(', ')}
    HTML
  end
end

def render_input_fields(input_fields)
  if input_fields.is_a?(Array) && !input_fields.empty?
    <<~HTML
      <h3>Input fields</h3>
      #{
        input_fields.map {
          |input_field|
          <<~HTML
            <h4>
              <code>#{input_field["name"]}</code>
              #{render_of_type(input_field["type"])}
              #{!input_field["defaultValue"] && "<span>Required</span>"}
            </h4>
            #{input_field["description"] && "<p>#{input_field["description"]}</p>"}
            #{input_field["defaultValue"] && "<p>Default value: #{input_field["defaultValue"]}</p>"}
          HTML
        }.join('')
      }
    HTML
  end
end

def render_interfaces(interfaces)
  if interfaces.is_a?(Array) && !interfaces.empty?
    <<~HTML
      <h3>Interfaces</h3>
      #{
        interfaces.map {
          |interface|
          render_of_type(interface)
        }.join('')
      }
    HTML
  end
end

def render_enum_values(enum_values)
  if enum_values.is_a?(Array) && !enum_values.empty?
    <<~HTML
      <h2>ENUM Values</h2>
      #{
        enum_values.map {
          |enum_value|
          <<~HTML
            <h3>
              #{enum_value["name"]}
              #{enum_value["isDeprecated"] && "<span class=\"pill pill--deprecated\">Deprecated</span>"}
            </h3>
            #{enum_value["description"] && "<p>#{enum_value["description"]}</p>"}
            #{enum_value["deprecationReason"] && "<p>Deprecated: #{enum_value["deprecationReason"]}</p>"}
          HTML
        }.join("")
      }
    HTML
  end
end

type_sets.each_value do |set|
  set.each do |type|
    name = type["name"]
    fields = render_fields(type["fields"])
    input_fields = render_input_fields(type["inputFields"])
    possible_types = render_possible_types(type["possibleTypes"])
    interfaces = render_interfaces(type["interfaces"])
    enum_values = render_enum_values(type["enumValues"])

    if name && name.length() > 0
      File.write(
        "#{schemas_dir}/#{name}.md.erb",
        <<~HTML
          <h1>
            <code>#{name}</code>
            <small>#{type["kind"]}</small>
          </h1>
          
          #{type["description"]}
          
          {:notoc}

          #{fields}
          
          #{input_fields}
          
          #{interfaces}
          
          #{possible_types}

          #{enum_values}
        HTML
      )
    end
  end
end

nav_data = YAML.load_file("#{scripts_dir}/../data/nav.yml")
nav_data[0].map { |nav_item| nav_item.delete('children') }

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

nav_data[0][2]["children"] = [
  {
    "name" => "All APIs",
    "path" => "apis",
    "icon" => "arrow-left.svg"
  },
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

File.write("#{scripts_dir}/../data/nav_graphql.yml", nav_data.to_yaml)

# Convert type_sets hash to nav YML

# [x] get nav YAML
# [x] only get the top level navs
# [x] generate nav_graphql.yml, populate
  # guideline pages
  # query pages
  # objects
  # scalar
  # interface_types
  # enum_types
  # input_object_types
  # union_types
# [ ] graphql layout uses nav_graphql.yml
# [ ] refactor
# [ ] stylingz!
