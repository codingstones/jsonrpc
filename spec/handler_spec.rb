# frozen_string_literal: true

describe JsonRPC::Handler do
  let(:request_body) { 'irrelevant request body' }
  let(:an_id) { 1 }

  before(:each) do
    @parser = instance_spy(JsonRPC::Parser)
    @handler = JsonRPC::Handler.new(@parser)
    @dispatcher = spy('dispatch')
  end

  it 'executes and return a jsonrcp response' do
    a_request = create_request
    allow(@parser).to receive(:parse).and_return(a_request)

    response = @handler.handle(request_body) do |request|
      request.params[0] - request.params[1]
    end

    expect(response).to include(result: 19)
    expect(response).to include(id: a_request.id)
  end

  context 'when parser raises an error' do
    it 'returns an error response' do
      allow(@parser).to receive(:parse).and_raise(JsonRPC::InvalidJSONError)

      response = @handler.handle(request_body)

      expect(response).to include(error: be_an_invalid_json_error)
    end
  end

  context 'when handler raises a method not found error' do
    it 'returns an error response' do
      allow(@parser).to receive(:parse).and_return(create_request)

      response = @handler.handle(request_body) do
        raise JsonRPC::MethodNotFoundError
      end

      expect(response).to include(error: be_a_method_not_found_error)
    end
  end

  context 'when handler raises an invalid params error' do
    it 'returns an error response' do
      allow(@parser).to receive(:parse).and_return(create_request)

      response = @handler.handle(request_body) do
        raise JsonRPC::InvalidParamsError
      end

      expect(response).to include(error: be_an_invalid_params_error)
    end
  end

  context 'when receiving an invalid request' do
    before(:each) do
      allow(@parser).to receive(:parse).and_return(
        create_request(invalid: true)
      )

      @response = @handler.handle(request_body) do |request|
        @dispatcher.dispatch(request.method, request.params)
      end
    end

    it 'does not execute yield block' do
      expect(@dispatcher).not_to have_received(:dispatch)
    end

    it 'returns an error request' do
      expect(@response).to include(error: be_an_invalid_request_error)
    end
  end

  context 'when receiving a batch request' do
    it 'executes yield block for every request' do
      allow(@parser).to receive(:parse).and_return([
        create_request(method: 'subtract', params: [42, 23], id: 1),
        create_request(method: 'add', params: [1, 3], id: 2)
      ])

      @handler.handle(request_body) do |request|
        @dispatcher.dispatch(request.method, request.params)
      end

      expect(@dispatcher).to have_received(:dispatch).twice
      expect(@dispatcher).to have_received(:dispatch).with('subtract', [42, 23])
      expect(@dispatcher).to have_received(:dispatch).with('add', [1, 3])
    end

    context 'and contains a notification' do
      it 'does not return any notification response in batch responses' do
        allow(@parser).to receive(:parse).and_return([
          create_request(method: 'subtract', params: [42, 23], id: an_id),
          create_request(method: 'add', params: [1, 3], id: nil)
        ])

        response = @handler.handle(request_body) { nil }

        expect(response.length).to eq(1)
        expect(response[0]).to have_id(an_id)
      end
    end
  end

  context 'when receiving a notification' do
    before(:each) do
      allow(@parser).to receive(:parse).and_return(create_request(id: nil))

      @response = @handler.handle(request_body) do |request|
        @dispatcher.dispatch(request.method, request.params)
      end
    end

    it 'executes yield block with parameters' do
      expect(@dispatcher).to have_received(:dispatch).with('subtract', [42, 23])
    end

    it 'does not return anything' do
      expect(@response).to be_nil
    end
  end

  context 'when batch contains execution errors' do
    it 'returns responses for each error' do
      other_id = 'other irrelevant id'

      allow(@parser).to receive(:parse).and_return([
        create_request(method: 'subtract', params: [42, 23], id: an_id),
        create_request(method: 'add', params: [1, 3], id: other_id)
      ])

      response = @handler.handle(request_body) do |request|
        raise JsonRPC::MethodNotFoundError if request.method == 'subtract'
        raise JsonRPC::InvalidParamsError if request.method == 'add'
      end

      expect(response.length).to eq(2)
      expect(response[0]).to include(error: be_a_method_not_found_error)
      expect(response[1]).to include(error: be_an_invalid_params_error)
    end
  end

  def create_request(**params)
    p = { jsonrpc: '2.0', method: 'subtract', params: [42, 23], id: an_id }
    p.merge!(params)

    JsonRPC::Request.new(p)
  end
end
