require 'commonmarker'

module RenderHelpers

  @@vale_off_pages = [
    "__DirectiveLocation"
  ]

  def render_html(markdown)
    markdown ? CommonMarker.render_html(markdown) : nil
  end

  def render_of_type(type, is_list = false, is_non_nullable = false, size = "medium")
    if type["ofType"]
      is_list = is_list || type["kind"] == "LIST"
      is_non_nullable = is_non_nullable || type["kind"] == "NON_NULL"
      render_of_type(type["ofType"], is_list, is_non_nullable, size)
    else
      name = type["name"]
      kind = type["kind"]

      formatted_type = name
      formatted_type += "!" if is_non_nullable
      formatted_type = "[#{formatted_type}]" if is_list

      <<~HTML
        <a href="/docs/apis/graphql/schemas/#{kind.downcase}/#{name.downcase}" class="pill pill--#{kind.downcase} pill--normal-case pill--#{size}" title="Go to #{kind} #{name}">
          <code>#{formatted_type}</code>
        </a>
      HTML
    end
  end

  def render_table(schema_type_data)
    if table_data = schema_type_data["fields"] || schema_type_data["args"] || nil
      table_heading = schema_type_data["fields"] ? "Fields" : "Arguments"
      if table_data.is_a?(Array) && !table_data.empty?
        <<~HTML
          <table class="responsive-table responsive-table--single-column-rows">
            <thead>
              <th>
                <h2 data-algolia-exclude>#{table_heading}</h2>
              </th>
            </thead>
            <tbody>
              #{
                table_data.map {
                  |row_data|
                  <<~HTML.gsub(/^[\s\t]*|[\s\t]*\n/, '')
                    <tr>
                      <td>
                        <h3 class="is-small has-pills">
                          <code>#{row_data["name"]}</code>
                          #{render_of_type(row_data["type"])}
                          #{row_data["isDeprecated"] ? '<span class="pill pill--deprecated"><code>deprecated</code></span>' : ""}
                        </h3>
                        #{row_data["deprecationReason"] ? "<p><em>Deprecated: #{row_data["deprecationReason"]}</em></p>" : nil}
                        #{row_data["description"] ? "#{render_html(row_data["description"].gsub("\n", " "))}" : nil}
                        #{render_field_args(row_data["args"])}
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
  end

  def render_field_args(args)
    if args.is_a?(Array) && !args.empty?
      <<~HTML.gsub(/^[\s\t]*|[\s\t]*\n/, '')
        <div>
          <details>
            <summary>Arguments</summary>
            <table class="responsive-table responsive-table--single-column-rows">
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
                          </h4>
                          #{arg["description"] && "#{render_html(arg["description"].gsub("\n", " "))}"}
                          #{arg["defaultValue"] && "<p class=\"no-margin\">Default value: <code>#{arg["defaultValue"]}</code></p>"}
                        </td>
                      </tr>
                    HTML
                  }.join('')
                }
              </tbody>
            </table>
          </details>
        </div>
      HTML
    end
  end

  def render_possible_types(possible_types)
    if possible_types.is_a?(Array) && !possible_types.empty?
      <<~HTML
        <h2 data-algolia-exclude>Possible types</h2>
        <div>#{possible_types.map { |possible_type| render_of_type(possible_type, false, false, "large") }.join('')}</div>
      HTML
    end
  end

  def render_input_fields(input_fields)
    if input_fields.is_a?(Array) && !input_fields.empty?
      <<~HTML
        <table class="responsive-table responsive-table--single-column-rows">
          <thead>
            <th>
              <h2 data-algolia-exclude>Input Fields</h2>
            </th>
          </thead>
          <tbody>
            #{
              input_fields.map {
                |input_field|
                <<~HTML.gsub(/^[\s\t]*|[\s\t]*\n/, '')
                  <tr>
                    <td>
                      <p>
                        <strong><code>#{input_field["name"]}</code></strong>
                        #{render_of_type(input_field["type"])}
                      </p>
                      #{input_field["description"] ? "#{render_html(input_field["description"].gsub("\n", " "))}" : nil}
                      #{input_field["defaultValue"] ? "<p>Default value: #{input_field["defaultValue"]}</p>" : nil}
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

  def render_interfaces(interfaces)
    if interfaces.is_a?(Array) && !interfaces.empty?
      <<~HTML
        <h2 data-algolia-exclude>Interfaces</h2>
        <div>
          #{
            interfaces.map {
              |interface|
              render_of_type(interface, false, false, "large")
            }.join('')
          }
        </div>
      HTML
    end
  end

  def render_enum_values(enum_values)
    if enum_values.is_a?(Array) && !enum_values.empty?
      <<~HTML
        <table class="responsive-table responsive-table--single-column-rows">
          <thead>
            <th>
              <h2 data-algolia-exclude>ENUM Values</h2>
            </th>
          </thead>
          <tbody>
            #{
              enum_values.map {
                |enum_value|
                <<~HTML.gsub(/^[\s\t]*|[\s\t]*\n/, '')
                  <tr>
                    <td>
                      <p>
                        <strong><code>#{enum_value["name"]}</code></strong>
                        #{enum_value["isDeprecated"] ? "<span class=\"pill pill--deprecated\">deprecated</span>" : nil}
                      </p>
                      #{enum_value["description"] ? "#{render_html(enum_value["description"].gsub("\n", " "))}" : nil}
                      #{enum_value["deprecationReason"] ? "<p>Deprecated: #{enum_value["deprecationReason"]}</p>" : nil}
                    </td>
                  </tr>
                HTML
              }.join("")
            }
          </tbody>
        </table>
      HTML
    end
  end

  def render_pill(schema_type_data, size = "medium")
    if kind = schema_type_data["kind"]
      <<~HTML.gsub(/^[\s\t]*|[\s\t]*\n/, '')
        <span class="pill pill--#{kind.downcase} pill--normal-case pill--#{size.downcase}">
          <code>#{kind}</code>
        </span>
      HTML
    elsif type = schema_type_data["type"]
      render_of_type(type, false, false, "large")
    else
      ""
    end
  end

  def render_page(schema_type_data, namespace)
    name = schema_type_data["name"]
    table = render_table(schema_type_data)
    input_fields = render_input_fields(schema_type_data["inputFields"])
    possible_types = render_possible_types(schema_type_data["possibleTypes"])
    interfaces = render_interfaces(schema_type_data["interfaces"])
    enum_values = render_enum_values(schema_type_data["enumValues"])
    valeOff = @@vale_off_pages.any? { |page_name| page_name == name }
    description = schema_type_data["description"].gsub("\n", " ").strip if !schema_type_data["description"].nil?

    page_content = <<~HTML.strip
      ---
      #  _____   ____    _   _  ____ _______   ______ _____ _____ _______
      #  |  __ \ / __ \  | \ | |/ __ \__   __| |  ____|  __ \_   _|__   __|
      #  | |  | | |  | | |  \| | |  | | | |    | |__  | |  | || |    | |
      #  | |  | | |  | | | . ` | |  | | | |    |  __| | |  | || |    | |
      #  | |__| | |__| | | |\  | |__| | | |    | |____| |__| || |_   | |
      #  |_____/ \____/  |_| \_|\____/  |_|    |______|_____/_____|  |_|
      #  This file is auto-generated by script/generate_graphql_api_content.sh,
      #  please build the schema.graphql by running `rails graphql:update_reference_schema`
      #  with https://github.com/buildkite/buildkite/,
      #  replace the content in data/schema.graphql
      #  and run the generation script `./scripts/generate-graphql-api-content.sh`.

      title: #{name} – #{namespace} – GraphQL API
      toc: false
      ---
      <!-- vale off -->
      <h1 class="has-pills">
        #{name}
        <span data-algolia-exclude>#{render_pill(schema_type_data, "large")}</span>
      </h1>
      <!-- vale on -->
      #{valeOff ? "<!-- vale off -->" : nil}

      #{description}

      #{table}

      #{input_fields}

      #{interfaces}

      #{possible_types}

      #{enum_values}
      #{valeOff ? "<!-- vale on -->" : nil}
    HTML

    page_content + "\n"
  end
end
