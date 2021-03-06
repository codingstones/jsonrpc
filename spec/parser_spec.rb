# frozen_string_literal: true

describe JsonRPC::Parser do
  before(:each) do
    @parser = JsonRPC::Parser.new
  end

  context 'when parsing a request' do
    before(:each) do
      request_body = to_json(method: 'subtract', params: [42, 23], id: 1)

      @request = @parser.parse(request_body)
    end

    it 'parses version' do
      expect(@request.version).to eq('2.0')
    end

    it 'parses method name' do
      expect(@request.method).to eq('subtract')
    end

    it 'parses params' do
      expect(@request.params).to eq([42, 23])
    end

    it 'parses its id' do
      expect(@request.id).to eq(1)
    end
  end

  context 'when rpc called with named parameters' do
    it 'parses to a request' do
      request_body = to_json(
        method: 'subtract',
        params: { "subtrahend": 23, "minuend": 42 },
        id: 3
      )

      request = @parser.parse(request_body)

      expect(request.params).to eq(subtrahend: 23, minuend: 42)
    end
  end

  context 'when parsing a notification' do
    it 'parses to a request' do
      request_body = to_json(method: 'update', params: [1, 2, 3, 4, 5])

      request = @parser.parse(request_body)

      expect(request).to be_notification
    end
  end

  context 'when rpc called with invalid JSON' do
    it 'raises an error' do
      request_body = '{"method": "foobar", "params": "bar", "baz]'

      expect { @parser.parse(request_body) }.to \
        raise_error(JsonRPC::InvalidJSONError)
    end
  end

  context 'when rcp called with an invalid request object' do
    context 'when checking jsonrpc field' do
      context 'and jsonrpc is different than "2.0"' do
        it 'returns an invalid request' do
          request_body = to_json(
            jsonrpc: '3.0',
            method: 'subtract',
            params: [42, 23],
            id: 1
          )

          request = @parser.parse(request_body)

          expect(request).to be_invalid
        end
      end
    end

    context 'when checking method field' do
      context 'and is not present' do
        it 'returns an invalid request' do
          request_body = to_json(params: [42, 23], id: 1)

          request = @parser.parse(request_body)

          expect(request).to be_invalid
        end
      end

      context 'and is empty' do
        it 'returns an invalid request' do
          request_body = to_json(method: nil, params: [42, 23], id: 1)

          request = @parser.parse(request_body)

          expect(request).to be_invalid
        end
      end

      context 'and is not an string' do
        it 'returns an invalid request' do
          request_body = to_json(method: 3, params: [42, 23], id: 1)

          request = @parser.parse(request_body)

          expect(request).to be_invalid
        end
      end
    end

    context 'when checking params field' do
      context 'and is not an array or hash' do
        it 'returns an invalid request' do
          request_body = to_json(method: 'dostuff', params: 'bar')

          request = @parser.parse(request_body)

          expect(request).to be_invalid
        end
      end

      context 'and is not present' do
        it 'returns an empty list as default value' do
          request_body = to_json(method: 'dostuff')

          request = @parser.parse(request_body)

          expect(request.params).to eq([])
        end

        it 'returns a valid request' do
          request_body = to_json(method: 'dostuff')

          request = @parser.parse(request_body)

          expect(request).not_to be_invalid
        end
      end
    end

    context 'when checking id field' do
      context 'and is not an string or integer' do
        it 'returns an invalid request' do
          request_body = to_json(method: 'dostuff', params: [42, 23], id: 4.5)

          request = @parser.parse(request_body)

          expect(request).to be_invalid
        end
      end

      context 'and is null' do
        it 'returns id as null' do
          request_body = to_json(method: 'dostuff', params: [42, 23], id: nil)

          request = @parser.parse(request_body)

          expect(request.id).to be_nil
        end

        it 'returns a valid request' do
          request_body = to_json(method: 'dostuff')

          request = @parser.parse(request_body)

          expect(request).not_to be_invalid
        end
      end
    end
  end

  context 'when parsing a batch' do
    it 'parses all requests in the batch' do
      request_body = %([
        {"jsonrpc": "2.0", "method": "notify_sum", "params": [1, 2], "id": 30},
        {"jsonrpc": "2.0", "method": "notify_hello", "params": [7], "id": 31}
      ])

      requests = @parser.parse(request_body)

      expect(requests.length).to eq(2)
      expect(requests[0].method).to eq('notify_sum')
      expect(requests[0].params).to eq([1, 2])
      expect(requests[0].id).to eq(30)
      expect(requests[1].method).to eq('notify_hello')
      expect(requests[1].params).to eq([7])
      expect(requests[1].id).to eq(31)
    end
  end

  def to_json(params)
    p = { jsonrpc: '2.0' }
    p.merge!(params)

    MultiJson.dump(p)
  end
end
