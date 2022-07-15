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

def render_of_type(of_type, size = "medium")
  if of_type["ofType"]
    render_of_type(of_type["ofType"])
  else
    if of_type["name"]
      <<~HTML
        <a
          href="/docs/apis/graphql/schemas/#{of_type['name'].downcase}"
          class="pill pill--#{of_type['kind'].downcase} pill--normal-case pill--#{size}"
          title="Go to #{of_type['kind']} #{of_type['name']}"><code>#{of_type["name"]}</code></a>
      HTML
    else
      of_type["kind"]
    end
  end
end

def render_fields(fields)
  if fields.is_a?(Array) && !fields.empty?
    <<~HTML
      <table class="responsive-table">
        <thead>
          <th>
            <h2>Fields</h2>
          </th>
        </thead>
        <tbody>
          #{
            fields.map {
              |field|
              <<~HTML
                <tr>
                  <td>
                    <h3 class="is-small has-pills">
                      <code>#{field["name"]}</code>
                      #{render_of_type(field["type"])}
                      #{field["isDeprecated"] ? '<span class="pill pill--deprecated"><code>deprecated</code></span>' : ""}
                    </h3>
                    #{field["deprecationReason"] && "<p><em>Deprecated: #{field["deprecationReason"]}</em></p>"}
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
      <details>
        <summary>Arguments</summary>
        <table class="responsive-table">
          <tbody>
            #{
              args.map {
                |arg|
                <<~HTML
                  <tr>
                    <td>
                      <h4 class="is-small has-pills no-margin">
                        <code>#{arg["name"]}</code>
                        #{render_of_type(arg["type"])}
                        #{!arg["defaultValue"] && '<span class="pill pill--required pill--normal-case"><code>required</code></span>'}
                      </h4>
                      #{arg["description"] && "<p class=\"no-margin\">#{arg["description"]}</p>"}
                      #{arg["defaultValue"] && "<p class=\"no-margin\">Default value: <code>#{arg["defaultValue"]}</code></p>"}
                    </td>
                  </tr>
                HTML
              }.join('')
            }
          </tbody>
        </table>
      </details>
    HTML
  end
end

def render_possible_types(possible_types)
  if possible_types.is_a?(Array) && !possible_types.empty?
    <<~HTML
      <h2>Possible types</h2>
      #{possible_types.map { |possible_type| render_of_type(possible_type, "large") }.join('')}
    HTML
  end
end

def render_input_fields(input_fields)
  if input_fields.is_a?(Array) && !input_fields.empty?
    <<~HTML
      <h2>Input fields</h2>
      #{
        input_fields.map {
          |input_field|
          <<~HTML
            <h3>
              <code>#{input_field["name"]}</code>
              #{render_of_type(input_field["type"])}
              #{!input_field["defaultValue"] && "<span>Required</span>"}
            </h3>
            #{input_field["description"] && "<p>#{input_field["description"]}</p>"}
            #{input_field["defaultValue"] && "<p>Default value: <code>#{input_field["defaultValue"]}</code></p>"}
          HTML
        }.join('')
      }
    HTML
  end
end

def render_interfaces(interfaces)
  if interfaces.is_a?(Array) && !interfaces.empty?
    <<~HTML
      <h2>Interfaces</h2>
      #{
        interfaces.map {
          |interface|
          render_of_type(interface, "large")
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
              #{enum_value["isDeprecated"] && "<span class=\"pill pill--deprecated\">deprecated</span>"}
            </h3>
            #{enum_value["description"] && "<p>#{enum_value["description"]}</p>"}
            #{enum_value["deprecationReason"] && "<p>Deprecated: #{enum_value["deprecationReason"]}</p>"}
          HTML
        }.join("")
      }
    HTML
  end
end

def render_pill(name, size = "medium")
  if name
    <<~HTML
      <span class="pill pill--#{name.downcase} pill--normal-case pill--#{size}"><code>#{name}</code></span>
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
        "#{schemas_dir}/#{name.downcase}.md.erb",
        <<~HTML
          <h1 class="has-pills">
            <code>#{name}</code>
            #{render_pill(type["kind"], "large")}
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
# [x] graphql layout uses nav_graphql.yml
# [ ] refactor all the things
# [ ] stylingz!
# [ ] pipeline configuration
# [ ] update notification message
