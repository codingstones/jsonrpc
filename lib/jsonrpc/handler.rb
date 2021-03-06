# frozen_string_literal: true

module JsonRPC
  class Handler
    def initialize(parser)
      @parser = parser
    end

    def handle(raw_request, &block)
      request = @parser.parse(raw_request)

      if batch_request?(request)
        request.map { |current| handle_request(current, block) }.compact
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
      raise InvalidRequestError if request.invalid?

      result = block.call(request)

      unless request.notification?
        Response.new(request_id: request.id, result: result).to_json
      end
    rescue JsonRPC::Error => error
      Response.new(request_id: request&.id, error: error).to_json
    end
  end
end
