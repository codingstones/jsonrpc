require 'multi_json'

module JsonRPC
  class Parser
    def parse(request_body)
      parsed = MultiJson.load(request_body, symbolize_keys: true)

      unless is_array_or_hash?(parsed[:params])
        raise InvalidRequestError
      end

      Request.new(parsed)
    rescue MultiJson::ParseError
      raise InvalidJSONError
    end

    private

    def is_array_or_hash?(params)
      params.kind_of? (Array) or params.kind_of? (Hash)
    end
  end
end
