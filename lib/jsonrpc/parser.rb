require 'multi_json'
require 'dry-validation'

module JsonRPC
  class Parser
    def parse(request_body)
      parsed = MultiJson.load(request_body, symbolize_keys: true)

      validation = RequestSchema.call(parsed)
      if validation.failure?
        raise InvalidRequestError
      end

      Request.new(validation.to_h)
    rescue MultiJson::ParseError
      raise InvalidJSONError
    end
  end

  private

  RequestSchema = Dry::Validation.Schema do
    required(:jsonrpc).filled(:str?, eql?: "2.0")
    required(:method).filled(:str?)
    optional(:params) { type?(Array) | type?(Hash) }
    optional(:id) { none? | type?(String) | type?(Integer) }
  end
end
