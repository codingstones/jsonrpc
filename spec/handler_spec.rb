describe JsonRPC::Handler do
  let(:request_body) { 'irrelevant request body' }

  before(:each) do
    @parser = instance_spy(JsonRPC::Parser)
    @handler = JsonRPC::Handler.new(@parser)
  end

  it "executes and return a jsonrcp response" do
    allow(@parser).to receive(:parse).and_return(JsonRPC::Request.new(jsonrpc: "2.0", method: "subtract", params: [42, 23], id: 1))

    response = @handler.handle(request_body) do |request|
      request.params[0] - request.params[1]
    end

    expect(response).to include(result: 19)
    expect(response).to include(id: 1)
  end

  context "when parser raises an error" do
    it "returns an error request" do
      allow(@parser).to receive(:parse).and_raise(JsonRPC::InvalidJSONError)

      response = @handler.handle(request_body) { |request| nil }

      expect(response).to include(:error)
    end
  end
end
