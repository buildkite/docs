require "rails_helper"

RSpec.describe RejectUnsafeMethodOverrideMiddleware do
  subject(:middleware) do
    described_class.new(Rack::MethodOverride.new(->(env) { [200, { "content-type" => "text/plain" }, [env[Rack::REQUEST_METHOD]]] }))
  end

  def multipart_env(method:, field: "_method", media_type: "multipart/form-data")
    body = "--boundary\r\nContent-Disposition: form-data; name=\"#{field}\"\r\nContent-Type: text/plain; charset=ISO-8859-1\r\n\r\n#{method}\r\n--boundary--\r\n".b
    Rack::MockRequest.env_for("/", method: "POST", input: body, "CONTENT_TYPE" => "#{media_type}; boundary=boundary")
  end

  it "rejects a non-ASCII method through the application stack" do
    post "/docs/agent", params: { _method: "ΐ" }

    expect(response.status).to eql(400)
  end

  %w[multipart/form-data multipart/related multipart/mixed].each do |media_type|
    it "rejects a non-ASCII #{media_type} method before Rack processes it" do
      guard = described_class.new(->(*) { raise "unsafe request reached the application" })
      status, _, _ = guard.call(multipart_env(method: "ΐ", media_type: media_type))

      expect(status).to eq(400)
    end
  end

  it "rejects a non-ASCII URL-encoded method before Rack processes it" do
    guard = described_class.new(->(*) { raise "unsafe request reached the application" })
    env = Rack::MockRequest.env_for("/", method: "POST", input: "_method=%CE%90", "CONTENT_TYPE" => "application/x-www-form-urlencoded")

    status, _, _ = guard.call(env)

    expect(status).to eq(400)
  end

  it "rejects a non-ASCII method override header before Rack processes it" do
    guard = described_class.new(->(*) { raise "unsafe request reached the application" })
    env = Rack::MockRequest.env_for("/", method: "POST", "HTTP_X_HTTP_METHOD_OVERRIDE" => "ΐ")

    status, _, _ = guard.call(env)

    expect(status).to eq(400)
  end

  it "rejects a single-byte non-ASCII method" do
    guard = described_class.new(->(*) { raise "unsafe request reached the application" })
    status, _, _ = guard.call(multipart_env(method: "\xDF".b))

    expect(status).to eq(400)
  end

  it "removes temporary files created while parsing a rejected multipart request" do
    guard = described_class.new(->(*) { raise "unsafe request reached the application" })
    env = multipart_env(method: "ΐ")
    file_part = "--boundary\r\nContent-Disposition: form-data; name=\"upload\"; filename=\"dummy.txt\"\r\nContent-Type: text/plain\r\n\r\ncontents\r\n--boundary--\r\n"
    env[Rack::RACK_INPUT] = StringIO.new(env[Rack::RACK_INPUT].string.sub("--boundary--\r\n", file_part))
    env["CONTENT_LENGTH"] = env[Rack::RACK_INPUT].size.to_s

    status, _, _ = guard.call(env)

    expect(status).to eq(400)
    expect(env.fetch(Rack::RACK_TEMPFILES)).to contain_exactly(have_attributes(closed?: true, path: nil))
  end

  it "keeps ordinary multipart method overrides working" do
    status, _, body = middleware.call(multipart_env(method: "DELETE"))

    expect([status, body]).to eq([200, ["DELETE"]])
  end

  it "does not reject the same byte in a different field" do
    status, _, body = middleware.call(multipart_env(method: "\xDF".b, field: "description"))

    expect([status, body]).to eq([200, ["POST"]])
  end

  it "keeps URL-encoded method overrides working" do
    env = Rack::MockRequest.env_for("/", method: "POST", input: "_method=PATCH", "CONTENT_TYPE" => "application/x-www-form-urlencoded")

    status, _, body = middleware.call(env)

    expect([status, body]).to eq([200, ["PATCH"]])
  end

  it "keeps ASCII method override headers working" do
    env = Rack::MockRequest.env_for("/", method: "POST", "HTTP_X_HTTP_METHOD_OVERRIDE" => "DELETE")

    status, _, body = middleware.call(env)

    expect([status, body]).to eq([200, ["DELETE"]])
  end
end
