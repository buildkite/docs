namespace :graphql do
  desc "Fetch current Buildkite GraphQL schema"
  task :fetch_schema do
    require "graphql/client"
    require "graphql/client/http"

    if ENV["API_ACCESS_TOKEN"].blank?
      raise "API_ACCESS_TOKEN is required"
    end

    HTTP = GraphQL::Client::HTTP.new("https://graphql.buildkite.com/v1") do
      def headers(context)
        { "Authorization": "Bearer #{ENV["API_ACCESS_TOKEN"]}" }
      end
    end

    puts GraphQL::Client.load_schema(HTTP).to_definition
  end

  desc "Generate GraphQL docs and navigation from GraphQL schema"
  task :generate do
    ruby "scripts/generate_graphql_api_content.rb"
  end
end
