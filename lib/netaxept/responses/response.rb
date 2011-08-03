module Netaxept
  module Responses
    
    class Response
      
      attr_reader :errors
      
      def initialize(node)
        super()
        @errors = []
        if(node["Exception"])
          errors << Netaxept::ErrorMessage.new(node["Exception"]["Error"])
        elsif(node["BBSException"])
          errors << Netaxept::ErrorMessage.new(node)
        end
      end
      
      def success?
        self.errors.empty?
      end
      
    end
    
  end
end