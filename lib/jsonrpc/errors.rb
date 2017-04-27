module JsonRPC
  class Error < StandardError
    attr_reader :code

    def initialize(code, message)
      @code = code
      super(message)
    end
  end

  class InvalidJSONError < Error
    def initialize
      super(-32700, "Parse error")
    end
  end

  class InvalidRequestError < Error
    def initialize
      super(-32600, "Invalid Request")
    end
  end

  class MethodNotFoundError < Error
    def initialize
      super(-32601, "Method not found")
    end
  end

  class InvalidParamsError < Error
    def initialize
      super(-32602, "Invalid params")
    end
  end

  class InternalError < Error
    def initialize
      super(-32603, "Internal error")
    end
  end
end
