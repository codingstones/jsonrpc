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

      expect(response).to include(error: be_an_invalid_json_error)
    end
  end

  context "when receiving an invalid request" do
    before(:each) do
      allow(@parser).to receive(:parse).and_return(JsonRPC::Request.new(invalid: true))
      @dispatcher = spy("dispatch")

      @response = @handler.handle(request_body) do |request|
        @dispatcher.dispatch(request.method, request.params)
      end
    end

    it "does not execute yield block" do
      expect(@dispatcher).not_to have_received(:dispatch)
    end

    it "returns an error request" do
      expect(@response).to include(error: be_an_invalid_request_error)
    end
  end

  context "when receiving a batch request" do
    it "executes yield block for every request" do
      allow(@parser).to receive(:parse).and_return([
        JsonRPC::Request.new(jsonrpc: "2.0", method: "subtract", params: [42, 23], id: 1),
        JsonRPC::Request.new(jsonrpc: "2.0", method: "add", params: [1, 3], id: 2)
      ])
      @dispatcher = spy("dispatch")

      @response = @handler.handle(request_body) do |request|
        @dispatcher.dispatch(request.method, request.params)
      end

      expect(@dispatcher).to have_received(:dispatch).twice
      expect(@dispatcher).to have_received(:dispatch).with("subtract", [42, 23])
      expect(@dispatcher).to have_received(:dispatch).with("add", [1, 3])
    end
  end
end
