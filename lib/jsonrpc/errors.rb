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
end
