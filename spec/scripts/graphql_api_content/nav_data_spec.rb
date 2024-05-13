require 'rails_helper'
require_relative '../../../scripts/graphql_api_content/nav_data'
include NavData

RSpec.describe NavData do
  let(:nav) {
    [
        {
          "name" => "Pipelines",
          "path" => "pipelines"
        },
        {
          "name" => "Test Analytics",
          "path" => "test-analytics",
        },
        {
          "name" => "APIs",
          "path" => "apis",
          "children" => [
            {
              "name" => "GraphQL",
              "children" => []
            },
          ]
        },
        {
          "name" => "Integrations",
          "path" => "integrations",
        },
      ]
   }

  type_sets = {
    "query_types" => [
      {
        "name" => "agent",
        "description" => "Find an agent by its slug",
        "args" => [
          {
            "name" => "slug",
            "description" => "The UUID for the agent, prefixed by its organization's slug i.e. `acme-inc/0bd5ea7c-89b3-4f40-8ca3-ffac805771eb`",
            "type" => {
              "kind" => "NON_NULL",
              "name" => nil,
              "ofType" => {
                "kind" => "SCALAR",
                "name" => "ID",
                "ofType" => nil
              }
            },
            "defaultValue" => nil
          }
        ],
        "type" => {
          "kind" => "OBJECT",
          "name" => "Agent",
          "ofType" => nil
        },
        "isDeprecated" => false,
        "deprecationReason" => nil
      },
      {
        "name" => "agentToken",
        "description" => "Find an agent token by its slug",
        "args" => [
          {
            "name" => "slug",
            "description" => "The UUID for the agent token, prefixed by its organization's slug i.e. `acme-inc/0bd5ea7c-89b3-4f40-8ca3-ffac805771eb`",
            "type" => {
              "kind" => "NON_NULL",
              "name" => nil,
              "ofType" => {
                "kind" => "SCALAR",
                "name" => "ID",
                "ofType" => nil
              }
            },
            "defaultValue" => nil
          }
        ],
        "type" => {
          "kind" => "OBJECT",
          "name" => "AgentToken",
          "ofType" => nil
        },
        "isDeprecated" => false,
        "deprecationReason" => nil
      }
    ],
    "mutation_types" => [
      {
        "name" => "agentStop",
        "description" => "Instruct an agent to stop accepting new build jobs and shut itself down.",
        "args" => [
          {
            "name" => "input",
            "description" => nil,
            "type" => {
              "kind" => "NON_NULL",
              "name" => nil,
              "ofType" => {
                "kind" => "INPUT_OBJECT",
                "name" => "AgentStopInput",
                "ofType" => nil
              }
            },
            "defaultValue" => nil
          }
        ],
        "type" => {
          "kind" => "OBJECT",
          "name" => "AgentStopPayload",
          "ofType" => nil
        },
        "isDeprecated" => false,
        "deprecationReason" => nil
      },
      {
        "name" => "agentTokenCreate",
        "description" => "Create a new agent registration token.",
        "args" => [
          {
            "name" => "input",
            "description" => nil,
            "type" => {
              "kind" => "NON_NULL",
              "name" => nil,
              "ofType" => {
                "kind" => "INPUT_OBJECT",
                "name" => "AgentTokenCreateInput",
                "ofType" => nil
              }
            },
            "defaultValue" => nil
          }
        ],
        "type" => {
          "kind" => "OBJECT",
          "name" => "AgentTokenCreatePayload",
          "ofType" => nil
        },
        "isDeprecated" => false,
        "deprecationReason" => nil
      }
    ],
    "object_types" => [
      {
        "kind" => "OBJECT",
        "name" => "Avatar",
        "description" => "An avatar belonging to a user",
        "fields" => [],
        "inputFields" => nil,
        "interfaces" => [],
        "enumValues" => nil,
        "possibleTypes" => nil
      },
      {
        "kind" => "OBJECT",
        "name" => "PullRequest",
        "description" => "A pull request on a provider",
        "fields" => [],
        "inputFields" => nil,
        "interfaces" => [],
        "enumValues" => nil,
        "possibleTypes" => nil
      }
    ],
    "scalar_types" => [
      {
        "kind" => "SCALAR",
        "name" => "Boolean",
        "description" => "Represents `true` or `false` values.",
        "fields" => nil,
        "inputFields" => nil,
        "interfaces" => nil,
        "enumValues" => nil,
        "possibleTypes" => nil
      },
      {
        "kind" => "SCALAR",
        "name" => "String",
        "description" => "Represents textual data as UTF-8 character sequences. This type is most often used by GraphQL to represent free-form human-readable text.",
        "fields" => nil,
        "inputFields" => nil,
        "interfaces" => nil,
        "enumValues" => nil,
        "possibleTypes" => nil
      }
    ],
    "interface_types" => [
      {
        "kind" => "INTERFACE",
        "name" => "Node",
        "description" => "An object with an ID.",
        "inputFields" => nil,
        "interfaces" => nil,
        "enumValues" => nil
      },
      {
        "kind" => "INTERFACE",
        "name" => "Connection",
        "description" => nil,
        "fields" => [],
        "inputFields" => nil,
        "interfaces" => nil,
        "enumValues" => nil,
        "possibleTypes" => []
      }
    ],
    "enum_types" => [
      {
        "kind" => "ENUM",
        "name" => "BuildBlockedStates",
        "description" => "All the possible blocked states a build can be in",
        "fields" => nil,
        "inputFields" => nil,
        "interfaces" => nil,
        "enumValues" => [],
        "possibleTypes" => nil
      },
      {
        "kind" => "ENUM",
        "name" => "PipelineVisibility",
        "description" => "The visibility of the pipeline",
        "fields" => nil,
        "inputFields" => nil,
        "interfaces" => nil,
        "enumValues" => [],
        "possibleTypes" => nil
      }
    ],
    "input_object_types" => [
      {
        "kind" => "INPUT_OBJECT",
        "name" => "JobConcurrencySearch",
        "description" => "Searching for concurrency groups on jobs",
        "fields" => nil,
        "inputFields" => [],
        "interfaces" => nil,
        "enumValues" => nil,
        "possibleTypes" => nil
      },
      {
        "kind" => "INPUT_OBJECT",
        "name" => "JobStepSearch",
        "description" => "Searching for jobs based on step information",
        "fields" => nil,
        "inputFields" => [],
        "interfaces" => nil,
        "enumValues" => nil,
        "possibleTypes" => nil
      }
    ],
    "union_types" => [
      {
        "kind" => "UNION",
        "name" => "BuildCreator",
        "description" => "Either a `User` or an `UnregisteredUser` type",
        "fields" => nil,
        "inputFields" => nil,
        "interfaces" => nil,
        "enumValues" => nil,
        "possibleTypes" => []
      },
      {
        "kind" => "UNION",
        "name" => "Job",
        "description" => "Kinds of jobs that can exist on a build",
        "fields" => nil,
        "inputFields" => nil,
        "interfaces" => nil,
        "enumValues" => nil,
        "possibleTypes" => []
      }
    ]
  }

  describe "#convert_to_nav_items" do
    it "converts to an array of nav_item hashes" do
      expect(convert_to_nav_items(type_sets["object_types"])).to eq([
        {
          "name" => "Avatar",
          "path" => "apis/graphql/schemas/object/avatar"
        },
        {
          "name" => "PullRequest",
          "path" => "apis/graphql/schemas/object/pullrequest"
        }
      ])
    end
  end

  describe "#generate_graphql_nav_data" do
    it "generates nav data correctly" do
      expect(generate_graphql_nav_data(type_sets)).to eq(
       [
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
            "children" => [
              {
                "name" => "Overview",
                "path" => "apis/graphql/graphql-cookbook"
              },
              {
                "name" => "Agents",
                "path" => "apis/graphql/cookbooks/agents"
              },
              {
                "name" => "Artifacts",
                "path" => "apis/graphql/cookbooks/artifacts"
              },
              {
                "name" => "Builds",
                "path" => "apis/graphql/cookbooks/builds"
              },
              {
                "name" => "Clusters",
                "path" => "apis/graphql/cookbooks/clusters"
              },
              {
                "name" => "Jobs",
                "path" => "apis/graphql/cookbooks/jobs"
              },
              {
                "name" => "Pipelines",
                "path" => "apis/graphql/cookbooks/pipelines"
              },
              {
                "name" => "Pipeline templates",
                "path" => "apis/graphql/cookbooks/pipeline-templates"
              },
              {
                "name" => "Organizations",
                "path" => "apis/graphql/cookbooks/organizations"
              },
              {
                "name" => "Teams",
                "path" => "apis/graphql/cookbooks/teams"
              }
            ]
          },
          {
            "name" => "Limits",
            "path" => "apis/graphql/graphql-resource-limits"
          },
          {
            "name" => "Queries",
            "children" => [
              {
                "name" => "agent",
                "path" => "apis/graphql/schemas/query/agent"
              },
              {
                "name" => "agentToken",
                "path" => "apis/graphql/schemas/query/agenttoken"
              }
            ]
          },
          {
            "name" => "Mutations",
            "children" => [
              {
                "name" => "agentStop",
                "path" => "apis/graphql/schemas/mutation/agentstop"
              },
              {
                "name" => "agentTokenCreate",
                "path" => "apis/graphql/schemas/mutation/agenttokencreate"
              }
            ]
          },
          {
            "name" => "Objects",
            "children" => [
              {
                "name" => "Avatar",
                "path" => "apis/graphql/schemas/object/avatar"
              },
              {
                "name" => "PullRequest",
                "path" => "apis/graphql/schemas/object/pullrequest"
              }
            ]
          },
          {
            "name" => "Scalars",
            "children" => [
              {
                "name" => "Boolean",
                "path" => "apis/graphql/schemas/scalar/boolean"
              },
              {
                "name" => "String",
                "path" => "apis/graphql/schemas/scalar/string"
              }
            ]
          },
          {
            "name" => "Interfaces",
            "children" => [
              {
                "name" => "Connection",
                "path" => "apis/graphql/schemas/interface/connection"
              },
              {
                "name" => "Node",
                "path" => "apis/graphql/schemas/interface/node"
              }
            ]
          },
          {
            "name" => "ENUMs",
            "children" => [
              {
                "name" => "BuildBlockedStates",
                "path" => "apis/graphql/schemas/enum/buildblockedstates"
              },
              {
                "name" => "PipelineVisibility",
                "path" => "apis/graphql/schemas/enum/pipelinevisibility"
              }
            ]
          },
          {
            "name" => "Input objects",
            "children" => [
              {
                "name" => "JobConcurrencySearch",
                "path" => "apis/graphql/schemas/input-object/jobconcurrencysearch"
              },
              {
                "name" => "JobStepSearch",
                "path" => "apis/graphql/schemas/input-object/jobstepsearch"
              }
            ]
          },
          {
            "name" => "Unions",
            "children" => [
              {
                "name" => "BuildCreator",
                "path" => "apis/graphql/schemas/union/buildcreator"
              },
              {
                "name" => "Job",
                "path" => "apis/graphql/schemas/union/job"
              }
            ]
          }
        ]
      )
    end
  end
end
