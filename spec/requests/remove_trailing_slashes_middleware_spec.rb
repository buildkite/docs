require 'rails_helper'

RSpec.describe "Remove trailing slashes middleware" do
  it "should 301 redirect to non-slash" do
    get "/docs/agent/"

    expect(response.status).to eql(301)
    expect(response.body).to eql("Moved permanently to http://www.example.com/docs/agent")
    expect(response.headers["Location"]).to eql("http://www.example.com/docs/agent")
  end

  it "should preserve params" do
    get "/docs/agent/?moo=cow"

    expect(response.status).to eql(301)
    expect(response.body).to eql("Moved permanently to http://www.example.com/docs/agent?moo=cow")
    expect(response.headers["Location"]).to eql("http://www.example.com/docs/agent?moo=cow")
  end

  it "should not redirect non-slash paths" do
    get "/docs/agent"

    expect(response.status).to eql(200)
  end
end
