require "graphql/client"
require "graphql/client/http"

namespace :graphql do
  desc "Fetch current Buildkite GraphQL schema"
  task :fetch_schema do
    if ENV["API_ACCESS_TOKEN"].blank?
      raise "API_ACCESS_TOKEN is required"
    end

    HTTP = GraphQL::Client::HTTP.new("https://graphql.buildkite.com/v1") do
      def headers(context)
        { "Authorization": "Bearer #{ENV["API_ACCESS_TOKEN"]}" }
      end
    end

    puts GraphQL::Client.load_schema(HTTP).to_json
  end
end
