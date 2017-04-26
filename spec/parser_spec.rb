describe JsonRPC::Parser do

  before(:each) do
    @parser = JsonRPC::Parser.new
  end

  context "when parsing a request" do
    before(:each) do
      request_body = '{"jsonrpc": "2.0", "method": "subtract", "params": [42, 23], "id": 1}'

      @request = @parser.parse(request_body)
    end

    it "parses version" do
      expect(@request.version).to eq(2.0)
    end

    it "parses method name" do
      expect(@request.method).to eq('subtract')
    end

    it "parses params" do
      expect(@request.params).to eq([42, 23])
    end

    it "parses its id" do
      expect(@request.id).to eq(1)
    end
  end

  context "when rpc called with named parameters" do
    it "parses to a request" do
      request_body = '{"jsonrpc": "2.0", "method": "subtract", "params": {"subtrahend": 23, "minuend": 42}, "id": 3}'

      request = @parser.parse(request_body)

      expect(request.params).to eq({"subtrahend": 23, "minuend": 42})
    end
  end

  context "when parsing a notification" do
    it "parses to a request" do
      request_body = '{"jsonrpc": "2.0", "method": "update", "params": [1,2,3,4,5]}'

      request = @parser.parse(request_body)

      expect(request).to be_notification
    end
  end

  context "when rpc called with invalid JSON" do
    it "raises an error" do
      request_body = '{"jsonrpc": "2.0", "method": "foobar, "params": "bar", "baz]'

      expect { @parser.parse(request_body) }.to raise_error(JsonRPC::InvalidJSONError)
    end
  end

  context "when rcp called with an invalid request object" do
    it "raises an error" do
      request_body = '{"jsonrpc": "2.0", "method": 1, "params": "bar"}'

      expect { @parser.parse(request_body) }.to raise_error(JsonRPC::InvalidRequestError)
    end
  end
end
