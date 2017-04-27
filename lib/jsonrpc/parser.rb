require 'multi_json'
require 'dry-validation'

module JsonRPC
  class Parser
    def parse(request_body)
      parsed = MultiJson.load(request_body, symbolize_keys: true)

      if parsed.is_a? (Array)
        parsed.map do |current|
          parse_object(current)
        end
      else
        parse_object(parsed)
      end
    rescue MultiJson::ParseError
      raise InvalidJSONError
    end

    private

    def parse_object(item)
      validation = RequestSchema.call(item)
      if validation.failure?
        raise InvalidRequestError
      end

      Request.new(validation.to_h)
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
