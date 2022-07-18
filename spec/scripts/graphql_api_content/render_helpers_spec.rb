require_relative '../../../scripts/graphql_api_content/render_helpers'
include RenderHelpers

RSpec.describe RenderHelpers do
  describe "#render_of_type" do
    context "when of_type is not nested" do
      it "renders a link" do
        of_type = {
          "kind" => "OBJECT",
          "name" => "Agent",
          "ofType" => nil
        }
        expect(render_of_type(of_type)).to eq(
          <<~HTML
            <a href="/docs/apis/graphql/schemas/agent" class="pill pill--object pill--normal-case pill--medium" title="Go to OBJECT Agent"><code>Agent</code></a>
          HTML
        )
      end
    end

    context "when of_type is a nested hash" do
      it "renders a link from the deepest hash" do
        of_type = {
          "kind" => "NON_NULL",
          "name" => nil,
          "ofType" => {
            "kind" => "SCALAR",
            "name" => "ID",
            "ofType" => nil
          }
        }
        expect(render_of_type(of_type)).to eq(
          <<~HTML
            <a href="/docs/apis/graphql/schemas/id" class="pill pill--scalar pill--normal-case pill--medium" title="Go to SCALAR ID"><code>ID</code></a>
          HTML
        )
      end
    end

    context "when of_type['name'] is not available" do
      it "renders the of_type['kind'] instead" do
        of_type = {
          "kind" => "NON_NULL",
          "name" => nil,
          "ofType" => nil
        }
        expect(render_of_type(of_type)).to eq("NON_NULL")
      end
    end
  end

  describe "#render_fields" do
    context "when there are no valid values in the fields" do
      context "when it's not an array" do
        it "doesn't render anything" do
          fields = nil
          expect(render_fields(fields)).to eq(nil)
        end
      end

      context "when it's empty" do
        it "doesn't render anything" do
          fields = []
          expect(render_fields(fields)).to eq(nil)
        end
      end
    end

    context "when there are valid values in the fields" do
      it "renders all the fields correctly" do
        fields = [
          {
            "name" => "agent",
            "description" => "Find an agent by its slug",
            "args" => [
              {
                "name" => "slug",
                "description" => "The UUID for the agent, prefixed by its organization's slug i.e. `acme-inc/0bd5ea7c-89b3-4f40-8ca3-ffac805771eb`",
                "type" => {
                  "kind" => "SCALAR",
                  "name" => "ID",
                  "ofType" => nil
                },
                "defaultValue" => "Default"
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
            "description" => nil,
            "args" => [
              {
                "name" => "slug",
                "description" => "The UUID for the agent token, prefixed by its organization's slug i.e. `acme-inc/0bd5ea7c-89b3-4f40-8ca3-ffac805771eb`",
                "type" => {
                  "kind" => "SCALAR",
                  "name" => "ID",
                  "ofType" => nil
                },
                "defaultValue" => "test default"
              }
            ],
            "type" => {
              "kind" => "OBJECT",
              "name" => "AgentToken",
              "ofType" => nil
            },
            "isDeprecated" => true,
            "deprecationReason" => "Deprecated because of reasons"
          }
        ]
        fields_string = render_fields(fields).gsub(/^[\s\t]*|[\s\t]*\n/, '')

        expect(fields_string).to eq(
          <<~HTML.gsub(/^[\s\t]*|[\s\t]*\n/, '')
            <table class="responsive-table responsive-table--single-column-rows">
              <thead>
                <th>
                  <h2>Fields</h2>
                </th>
              </thead>
              <tbody>
                <tr>
                  <td>
                    <h3 class="is-small has-pills"><code>agent</code><a href="/docs/apis/graphql/schemas/agent" class="pill pill--object pill--normal-case pill--medium" title="Go to OBJECT Agent"><code>Agent</code></a></h3>
                    <p>Find an agent by its slug</p>
                    <details>
                      <summary>Arguments</summary>
                      <table class="responsive-table responsive-table--single-column-rows">
                        <tbody>
                            <tr>
                              <td>
                                <h4 class="is-small has-pills no-margin"><code>slug</code>
                                  <a href="/docs/apis/graphql/schemas/id" class="pill pill--scalar pill--normal-case pill--medium" title="Go to SCALAR ID">
                                    <code>ID</code>
                                  </a>
                                </h4>
                                <p class="no-margin">The UUID for the agent, prefixed by its organization's slug i.e. `acme-inc/0bd5ea7c-89b3-4f40-8ca3-ffac805771eb`</p>
                                <p class="no-margin">Default value: <code>Default</code></p>
                              </td>
                            </tr>
                        </tbody>
                      </table>
                    </details>
                  </td>
                </tr>
                <tr>
                  <td>
                    <h3 class="is-small has-pills"><code>agentToken</code><a href="/docs/apis/graphql/schemas/agenttoken" class="pill pill--object pill--normal-case pill--medium" title="Go to OBJECT AgentToken"><code>AgentToken</code></a><span class="pill pill--deprecated"><code>deprecated</code></span></h3>
                    <p><em>Deprecated: Deprecated because of reasons</em></p>
                    <details>
                      <summary>Arguments</summary>
                      <table class="responsive-table responsive-table--single-column-rows">
                        <tbody>
                          <tr>
                            <td>
                              <h4 class="is-small has-pills no-margin">
                                <code>slug</code>
                                <a href="/docs/apis/graphql/schemas/id" class="pill pill--scalar pill--normal-case pill--medium" title="Go to SCALAR ID">
                                  <code>ID</code>
                                </a>
                              </h4>
                              <p class="no-margin">The UUID for the agent token, prefixed by its organization's slug i.e. `acme-inc/0bd5ea7c-89b3-4f40-8ca3-ffac805771eb`</p>
                              <p class="no-margin">Default value: <code>test default</code></p>
                            </td>
                          </tr>
                        </tbody>
                      </table>
                    </details>
                  </td>
                </tr>
              </tbody>
          </table>
          HTML
        )
      end
    end
  end

  describe "#render_field_args" do
    context "when there are no valid values in the arguments" do
      context "when it's not an array" do
        it "doesn't render anything" do
          args = nil
          expect(render_field_args(args)).to eq(nil)
        end
      end

      context "when it's empty" do
        it "doesn't render anything" do
          args = nil
          expect(render_field_args(args)).to eq(nil)
        end
      end

      context "when there are valid values in the arguments" do
        it "renders all the arguments correctly" do
          args = [
            {
              "name" => "slug",
              "description" => "The slug for the sso provider, prefixed by its organization's slug i.e. `acme-inc/0bd5ea7c-89b3-4f40-8ca3-ffac805771eb`",
              "type" => {
                "kind" => "SCALAR",
                "name" => "ID",
                "ofType" => nil
              },
              "defaultValue" => nil
            },
            {
              "name" => "uuid",
              "description" => "The UUID of the sso provider",
              "type" => {
                "kind" => "SCALAR",
                "name" => "ID",
                "ofType" => nil
              },
              "defaultValue" => nil
            }
          ]

          args_string = render_field_args(args).gsub(/^[\s\t]*|[\s\t]*\n/, '')

          expect(args_string).to eq(
            <<~HTML.gsub(/^[\s\t]*|[\s\t]*\n/, '')
              <details>
                <summary>Arguments</summary>
                <table class="responsive-table responsive-table--single-column-rows">
                  <tbody>
                    <tr>
                      <td>
                        <h4 class="is-small has-pills no-margin">
                          <code>slug</code>
                          <a href="/docs/apis/graphql/schemas/id" class="pill pill--scalar pill--normal-case pill--medium" title="Go to SCALAR ID"><code>ID</code></a><span class="pill pill--required pill--normal-case"><code>required</code></span></h4><p class="no-margin">The slug for the sso provider, prefixed by its organization's slug i.e. `acme-inc/0bd5ea7c-89b3-4f40-8ca3-ffac805771eb`</p></td></tr><tr><td><h4 class="is-small has-pills no-margin"><code>uuid</code><a href="/docs/apis/graphql/schemas/id" class="pill pill--scalar pill--normal-case pill--medium" title="Go to SCALAR ID">
                            <code>ID</code>
                          </a>
                          <span class="pill pill--required pill--normal-case">
                            <code>required</code>
                          </span>
                        </h4>
                        <p class="no-margin">The UUID of the sso provider</p>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </details>
            HTML
          )
        end
      end
    end
  end

  describe "#render_possible_types" do
    context "when there are no valid values in possible_types" do
      context "when it's not an array" do
        it "doesn't render anything" do
          possible_types = nil
          expect(render_possible_types(possible_types)).to eq(nil)
        end
      end

      context "when it's empty" do
        it "doesn't render anything" do
          possible_types = []
          expect(render_possible_types(possible_types)).to eq(nil)
        end
      end
    end
    
    context "when there are valid values in possible_types" do
      it "renders possible_types correctly" do
        possible_types = [
          {
            "kind" => "OBJECT",
            "name" => "APIAccessToken",
            "ofType" => nil
          },
          {
            "kind" => "OBJECT",
            "name" => "APIAccessTokenCode",
            "ofType" => nil
          }
        ]

        possible_types_string = render_possible_types(possible_types).gsub(/^[\s\t]*|[\s\t]*\n/, '')

        expect(possible_types_string).to eq(
          <<~HTML.gsub(/^[\s\t]*|[\s\t]*\n/, '')
            <h2>Possible Types</h2>
            <a href="/docs/apis/graphql/schemas/apiaccesstoken" class="pill pill--object pill--normal-case pill--large" title="Go to OBJECT APIAccessToken">
              <code>APIAccessToken</code>
            </a>
            <a href="/docs/apis/graphql/schemas/apiaccesstokencode" class="pill pill--object pill--normal-case pill--large" title="Go to OBJECT APIAccessTokenCode">
              <code>APIAccessTokenCode</code>
            </a>
          HTML
        )
      end
    end
  end

  describe "#render_input_fields" do
    context "when there are no valid values in input_fields" do
      context "when it's not an array" do
        it "doesn't render anything" do
        input_fields = nil
          expect(render_input_fields(input_fields)).to eq(nil)
        end
      end

      context "when it's empty" do
        it "doesn't render anything" do
        input_fields = []
          expect(render_input_fields(input_fields)).to eq(nil)
        end
      end
    end
    
    context "when there are valid values in input_fields" do
      it "renders input_fields correctly" do
        input_fields = [
          {
            "name" => "twoFactorEnabled",
            "description" => nil,
            "type" => {
              "kind" => "SCALAR",
              "name" => "Boolean",
              "ofType" => nil
            },
            "defaultValue" => nil
          },
          {
            "name" => "passwordProtected",
            "description" => "Test description",
            "type" => {
              "kind" => "SCALAR",
              "name" => "Boolean",
              "ofType" => nil
            },
            "defaultValue" => "Test default"
          }
        ]

        input_fields_string = render_input_fields(input_fields).gsub(/^[\s\t]*|[\s\t]*\n/, '')

        expect(input_fields_string).to eq(
          <<~HTML.gsub(/^[\s\t]*|[\s\t]*\n/, '')
            <table class="responsive-table responsive-table--single-column-rows">
              <thead>
                <th>
                  <h2>Input Fields</h2>
                </th>
              </thead>
              <tbody>
                <tr>
                  <td>
                    <p>
                      <strong><code>twoFactorEnabled</code></strong>
                      <a href="/docs/apis/graphql/schemas/boolean" class="pill pill--scalar pill--normal-case pill--medium" title="Go to SCALAR Boolean">
                        <code>Boolean</code>
                      </a>
                      <span class="pill pill--required pill--normal-case pill--medium">required</span>
                    </p>
                  </td>
                </tr>
                <tr>
                  <td>
                    <p>
                      <strong><code>passwordProtected</code></strong>
                      <a href="/docs/apis/graphql/schemas/boolean" class="pill pill--scalar pill--normal-case pill--medium" title="Go to SCALAR Boolean">
                        <code>Boolean</code>
                      </a>
                    </p>
                    <p>Test description</p>
                    <p>Default value: Test default</p>
                  </td>
                </tr>
              </tbody>
            </table>
          HTML
        )
      end
    end
  end

  describe "#render_interfaces" do
    context "when there are no valid values in interfaces" do
      context "when it's not an array" do
        it "doesn't render anything" do
        interfaces = nil
          expect(render_interfaces(interfaces)).to eq(nil)
        end
      end

      context "when it's empty" do
        it "doesn't render anything" do
        interfaces = []
          expect(render_interfaces(interfaces)).to eq(nil)
        end
      end
    end
    
    context "when there are valid values in interfaces" do
      it "renders interfaces correctly" do
        interfaces = [
          {
            "kind" => "INTERFACE",
            "name" => "Authorization",
            "ofType" => nil
          },
          {
            "kind" => "INTERFACE",
            "name" => "Node",
            "ofType" => nil
          }
        ]

        interfaces_string = render_interfaces(interfaces).gsub(/^[\s\t]*|[\s\t]*\n/, '')

        expect(interfaces_string).to eq(
          <<~HTML.gsub(/^[\s\t]*|[\s\t]*\n/, '')
            <h2>Interfaces</h2>
            <a href="/docs/apis/graphql/schemas/authorization" class="pill pill--interface pill--normal-case pill--large" title="Go to INTERFACE Authorization">
              <code>Authorization</code>
            </a>
            <a href="/docs/apis/graphql/schemas/node" class="pill pill--interface pill--normal-case pill--large" title="Go to INTERFACE Node">
              <code>Node</code>
            </a>
          HTML
        )
      end
    end
  end

  describe "#render_enum_values" do
    context "when there are no valid values in enum_values" do
      context "when it's not an array" do
        it "doesn't render anything" do
        enum_values = nil
          expect(render_enum_values(enum_values)).to eq(nil)
        end
      end

      context "when it's empty" do
        it "doesn't render anything" do
        enum_values = []
          expect(render_enum_values(enum_values)).to eq(nil)
        end
      end
    end
    
    context "when there are valid values in enum_values" do
      it "renders enum_values correctly" do
        enum_values = [
          {
            "name" => "SKIPPED",
            "description" => "The build was skipped",
            "isDeprecated" => false,
            "deprecationReason" => nil
          },
          {
            "name" => "CREATING",
            "description" => nil,
            "isDeprecated" => true,
            "deprecationReason" => "Deprecated because of reasons"
          }
        ]

        enum_values_string = render_enum_values(enum_values).gsub(/^[\s\t]*|[\s\t]*\n/, '')

        expect(enum_values_string).to eq(
          <<~HTML.gsub(/^[\s\t]*|[\s\t]*\n/, '')
            <table class="responsive-table responsive-table--single-column-rows">
              <thead>
                <th>
                  <h2>ENUM Values</h2>
                </th>
              </thead>
              <tbody>
                <tr>
                  <td>
                    <p>
                      <strong><code>SKIPPED</code></strong>
                    </p>
                    <p>The build was skipped</p>
                  </td>
                </tr>
                <tr>
                  <td>
                    <p>
                      <strong><code>CREATING</code></strong>
                      <span class="pill pill--deprecated">deprecated</span>
                    </p>
                    <p>Deprecated: Deprecated because of reasons</p>
                  </td>
                </tr>
              </tbody>
            </table>
          HTML
        )
      end
    end
  end

  describe "#render_pill" do
    context "when I don't set a size" do
      it "renders correctly with the default size" do
        pill_string = render_pill("Object").gsub(/^[\s\t]*|[\s\t]*\n/, '')
        expect(pill_string).to eq(
          <<~HTML.gsub(/^[\s\t]*|[\s\t]*\n/, '')
            <span class="pill pill--object pill--normal-case pill--medium">
              <code>Object</code>
            </span>
          HTML
        )
      end
    end

    context "when I set it to small" do
      it "renders correctly with the right size" do
        pill_string = render_pill("Object", "small").gsub(/^[\s\t]*|[\s\t]*\n/, '')
        expect(pill_string).to eq(
          <<~HTML.gsub(/^[\s\t]*|[\s\t]*\n/, '')
            <span class="pill pill--object pill--normal-case pill--small">
              <code>Object</code>
            </span>
          HTML
        )
      end
    end
  end

  describe "#render_page" do
    it "renders correctly" do
      schema_type_data = {
        "kind" => "OBJECT",
        "name" => "JobTypeTrigger",
        "description" => "A type of job that triggers another build on a pipeline",
        "fields" => [
          {
            "name" => "build",
            "description" => "The build that this job is a part of",
            "args" => [],
            "type" => {
              "kind" => "OBJECT",
              "name" => "Build",
              "ofType" => nil
            },
            "isDeprecated" => false,
            "deprecationReason" => nil
          },
          {
            "name" => "id",
            "description" => nil,
            "args" => [
              {
                "name" => "first",
                "description" => "Returns the first _n_ elements from the list.",
                "type" => {
                  "kind" => "SCALAR",
                  "name" => "Int",
                  "ofType" => nil
                },
                "defaultValue" => nil
              },
              {
                "name" => "after",
                "description" => "Returns the elements in the list that come after the specified cursor.",
                "type" => {
                  "kind" => "SCALAR",
                  "name" => "String",
                  "ofType" => nil
                },
                "defaultValue" => nil
              }
            ],
            "type" => {
              "kind" => "NON_NULL",
              "name" => nil,
              "ofType" => {
                "kind" => "SCALAR",
                "name" => "ID",
                "ofType" => nil
              }
            },
            "isDeprecated" => false,
            "deprecationReason" => nil
          }
        ],
        "inputFields" => nil,
        "interfaces" => [
          {
            "kind" => "INTERFACE",
            "name" => "Node",
            "ofType" => nil
          }
        ],
        "enumValues" => nil,
        "possibleTypes" => nil
      }

      page_string = render_page(schema_type_data).gsub(/^[\s\t]*|[\s\t]*\n/, '')

      expect(page_string).to eq(
        <<~HTML.gsub(/^[\s\t]*|[\s\t]*\n/, '')
          <h1 class="has-pills"><code>JobTypeTrigger</code><span class="pill pill--object pill--normal-case pill--large"><code>OBJECT</code></span></h1>
          A type of job that triggers another build on a pipeline{:notoc}
          <table class="responsive-table responsive-table--single-column-rows">
            <thead>
              <th>
                <h2>Fields</h2>
              </th>
            </thead>
            <tbody>
              <tr>
                <td>
                    <h3 class="is-small has-pills"><code>build</code><a href="/docs/apis/graphql/schemas/build" class="pill pill--object pill--normal-case pill--medium" title="Go to OBJECT Build"><code>Build</code></a></h3>
                    <p>The build that this job is a part of</p>
                </td>
              </tr>
              <tr>
                <td>
                    <h3 class="is-small has-pills"><code>id</code><a href="/docs/apis/graphql/schemas/id" class="pill pill--scalar pill--normal-case pill--medium" title="Go to SCALAR ID"><code>ID</code></a></h3>
                    <details>
                      <summary>Arguments</summary>
                      <table class="responsive-table responsive-table--single-column-rows">
                          <tbody>
                            <tr>
                                <td>
                                  <h4 class="is-small has-pills no-margin"><code>first</code><a href="/docs/apis/graphql/schemas/int" class="pill pill--scalar pill--normal-case pill--medium" title="Go to SCALAR Int"><code>Int</code></a><span class="pill pill--required pill--normal-case"><code>required</code></span></h4>
                                  <p class="no-margin">Returns the first _n_ elements from the list.</p>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                  <h4 class="is-small has-pills no-margin"><code>after</code><a href="/docs/apis/graphql/schemas/string" class="pill pill--scalar pill--normal-case pill--medium" title="Go to SCALAR String"><code>String</code></a><span class="pill pill--required pill--normal-case"><code>required</code></span></h4>
                                  <p class="no-margin">Returns the elements in the list that come after the specified cursor.</p>
                                </td>
                            </tr>
                          </tbody>
                      </table>
                    </details>
                </td>
              </tr>
            </tbody>
          </table>
          <h2>Interfaces</h2>
          <a href="/docs/apis/graphql/schemas/node" class="pill pill--interface pill--normal-case pill--large" title="Go to INTERFACE Node"><code>Node</code></a>
        HTML
      )
    end
  end
end
