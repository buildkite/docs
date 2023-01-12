require "graphql/client"
require "graphql/client/http"

namespace :graphql do
  OUTPUT_SCHEMA_PATH = "data/graphql_data_schema.json"

  desc "Dump current Buildkite GraphQL schema"
  task :dump_schema do
    HTTP = GraphQL::Client::HTTP.new("https://graphql.buildkite.com/v1") do
      def headers(context)
        { "Authorization": "Bearer #{ENV["API_ACCESS_TOKEN"]}" }
      end
    end

    schema = GraphQL::Client.load_schema(HTTP)

    path = Rails.root.join(OUTPUT_SCHEMA_PATH).to_s
    File.write(path, schema.to_json + "\n")
  end
end
