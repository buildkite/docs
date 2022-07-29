require "commonmarker"

module ApiParityTableHelper
  def api_parity_tables
    data = api_parity_data
    feature_parity_data = data["feature_parity"]
    missing_features_data = data["missing_features"]

    <<~HTML
      <table class="comparison-table">
        <thead>
          <th width="34%">Task</th>
          <th width="33%">REST</th>
          <th width="33%">:graphql: GraphQL</th>
        </thead>
        #{rowgroups(feature_parity_data)}
      </table>
      #{render_missing_features(missing_features_data)}
    HTML
  end

  private

  def rowgroups(data)
    html = ""

    data.each do |key, value|
      rest_data = value["rest"]
      graphql_data = value["graphql"]

      html << <<~HTML
        <tbody>
          #{rows(key, value["style"], rest_data, graphql_data)}
        </tbody>
      HTML
    end

    html
  end

  def rows(table_header, table_header_style, rest_data, graphql_data)
    html = <<~HTML
      <tr class="comparison-table__tbody-header">
        <th width="33%">
          <span class="pill pill--#{table_header_style}">#{table_header}</span>
        </th>
        <td aria-hidden></td>
        <td aria-hidden></td>
      </tr>
    HTML

    if rest_data
      rest_data.each do |element|
        rows = <<~HTML
          <tr>
            <th>
              #{CommonMarker.render_html(element)}
            </th>
            <td>
              :white_check_mark: <span class="OffScreen">Only available in REST</span>
            </td>
            <td>
              <span class="OffScreen">Not available in GraphQL</span>
            </td>
          </tr>
        HTML

        html << rows
      end
    end

    if graphql_data
      graphql_data.each do |element|
        rows = <<~HTML
          <tr>
            <th>
              #{CommonMarker.render_html(element)}
            </th>
            <td>
              <span class="OffScreen">Not available in REST</span>
            </td>
            <td>
              :white_check_mark: <span class="OffScreen">Only available in GraphQL</span>
            </td>
          </tr>
        HTML

        html << rows
      end
    end

    html
  end

  def render_missing_features(data)
    unless data.empty?
      html = ""

      html << <<~HTML
        <h2>Known missing API features<h2>
        <p>These are known requested features that are currently missing from both REST and GraphQL APIs:</p>
        <ul>
      HTML

      data.each do |key, value|
        html << <<~HTML
          <li>
            <span class="pill pill--#{value["style"]}">#{key}</span>
            #{value["description"]}
          </li>
        HTML
      end

      html << "</ul>"
    end
  end
end