module Netaxept
  module Responses
    
    class Response
      
      #attr_reader :errors
      
      def initialize(node)
        # super()
        # @errors = []
        # if(node.xpath("//Exception").first)
        #   errors << Netaxept::ErrorMessage.new(node.xpath("//Error"))
        # elsif(node.xpath("//BBSException").first)
        #   errors << Netaxept::ErrorMessage.new(node)
        # end
      end
      
    end
    
  end
end