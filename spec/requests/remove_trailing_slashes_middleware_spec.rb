require 'rails_helper'

RSpec.describe "Remove trailing slashes middleware" do
  it "should 301 redirect to non-slash" do
    get "/docs/agent/v3/"

    expect(response.status).to eql(301)
    expect(response.body).to eql("Moved permanently to http://www.example.com/docs/agent/v3")
    expect(response.headers["Location"]).to eql("http://www.example.com/docs/agent/v3")
  end

  it "should preserve params" do
    get "/docs/agent/v3/?moo=cow"

    expect(response.status).to eql(301)
    expect(response.body).to eql("Moved permanently to http://www.example.com/docs/agent/v3?moo=cow")
    expect(response.headers["Location"]).to eql("http://www.example.com/docs/agent/v3?moo=cow")
  end

  it "should not redirect non-slash paths" do
    get "/docs/agent/v3"

    expect(response.status).to eql(200)
  end
end
