module JsonRPC
  class Request
    attr_reader :version, :method, :params, :id

    def initialize(args)
      @version = args[:jsonrpc]
      @method = args[:method]
      @params = args[:params]
      @id = args[:id]
    end

    def notification?
      @id.nil?
    end
  end
end
