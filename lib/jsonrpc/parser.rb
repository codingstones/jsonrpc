require 'json'

module JsonRPC
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
      parsed = JSON::parse(request_body, symbolize_names: true)

      Request.new(parsed)
    end
  end
end
