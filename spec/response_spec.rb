describe JsonRPC::Response do
  let(:an_id) { 'irrelevant id' }
  let(:a_result) { 'irrelevant result' }

  context "when serializing to json" do
    before(:each) do
      response = JsonRPC::Response.new(request_id: an_id, result: a_result)

      @serialized = response.as_json
    end

    it "contains a jsonrpc field" do
      expect(@serialized).to include(jsonrpc: "2.0")
    end

    it "contains an id field" do
      expect(@serialized).to include(id: an_id)
    end

    it "contains a result field" do
      expect(@serialized).to include(result: a_result)
    end

    it "does not contain an error field" do
      expect(@serialized).not_to have_key(:error)
    end

    context "when execution has an error" do
      before(:each) do
        @error = JsonRPC::InvalidRequestError.new
        response = JsonRPC::Response.new(request_id: an_id, result: a_result, error: @error)

        @serialized = response.as_json
      end

      it "contains an error field" do
        expect(@serialized).to include(error: {code: @error.code, message: @error.message })
      end

      it "does not contain a result field" do
        expect(@serialized).not_to have_key(:result)
      end
    end
  end
end
