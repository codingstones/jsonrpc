require 'multi_json'

module JsonRPC
  class InvalidJSONError < StandardError
    attr_reader :code

    def initialize
      @code = -32700
      super("Parse error")
    end
  end

  class InvalidRequestError < StandardError
    attr_reader :code

    def initialize
      @code = -32600
      super("Invalid Request")
    end

  end

  class Request
    attr_reader :version, :method, :params, :id

    def initialize(args)
      @version = args[:jsonrpc].to_f
      @method = args[:method]
      @params = args[:params]
      @id = args[:id]
    end

    def notification?
      @id.nil?
    end
  end

  class Parser
    def parse(request_body)
      begin
        parsed = MultiJson.load(request_body, symbolize_keys: true)

        unless is_array_or_hash?(parsed[:params])
          raise InvalidRequestError
        end

        Request.new(parsed)
      rescue MultiJson::ParseError
        raise InvalidJSONError
      end
    end

    private

    def is_array_or_hash?(params)
      params.kind_of? (Array) or params.kind_of? (Hash)
    end
  end
end
