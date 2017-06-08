# frozen_string_literal: true

module JsonRPC
  class Error < StandardError
    def initialize
      super(self.class.message)
    end

    def code
      self.class.code
    end
  end

  class InvalidJSONError < Error
    def self.code
      -32_700
    end

    def self.message
      'Parse error'
    end
  end

  class InvalidRequestError < Error
    def self.code
      -32_600
    end

    def self.message
      'Invalid Request'
    end
  end

  class MethodNotFoundError < Error
    def self.code
      -32_601
    end

    def self.message
      'Method not found'
    end
  end

  class InvalidParamsError < Error
    def self.code
      -32_602
    end

    def self.message
      'Invalid params'
    end
  end

  class InternalError < Error
    def self.code
      -32_603
    end

    def self.message
      'Internal error'
    end
  end
end
