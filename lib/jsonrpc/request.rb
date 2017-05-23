# frozen_string_literal: true

module JsonRPC
  class Request
    attr_reader :version, :method, :params, :id

    def initialize(args)
      @version = args[:jsonrpc]
      @method = args[:method]
      @params = args[:params] || []
      @id = args[:id]
      @invalid = args[:invalid] || false
    end

    def notification?
      @id.nil?
    end

    def invalid?
      @invalid == true
    end
  end
end
