module JsonRPC
  class Response
    def initialize(args)
      @request_id = args[:request_id]
      @result = args[:result]
      @error = args[:error]
    end

    def as_json
      response = {
        :jsonrpc => "2.0",
        :id => @request_id,
      }

      if @error.nil?
        response[:result] = @result
      else
        response[:error] =  {
          code: @error.code,
          message: @error.message
        }
      end

      response
    end
  end
end
