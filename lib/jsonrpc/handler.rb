module JsonRPC
  class Handler
    def initialize(parser)
      @parser = parser
    end

    def handle(raw_request, &block)
      request = @parser.parse(raw_request)

      if batch_request?(request)
        request.map { |current| handle_request(current, block) }
      else
        handle_request(request, block)
      end
    rescue JsonRPC::Error => error
      Response.new(request_id: request&.id, error: error).to_json
    end

    private

    def batch_request?(request)
      request.is_a?(Array)
    end

    def handle_request(request, block)
      if request.invalid?
        Response.new(request_id: request&.id, error: InvalidRequestError.new).to_json
      else
        result = block.call(request)

        Response.new(request_id: request.id, result: result).to_json unless request.notification?
      end
    end
  end
end
