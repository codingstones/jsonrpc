module JsonRPC
  class Handler
    def initialize(parser)
      @parser = parser
    end

    def handle(raw_request)
      request = @parser.parse(raw_request)

      if request.invalid?
        Response.new(request_id: request&.id, error: InvalidRequestError.new).to_json
      else
        result = yield request

        Response.new(request_id: request.id, result: result).to_json
      end
    rescue JsonRPC::Error => error
      Response.new(request_id: request&.id, error: error).to_json
    end
  end
end
