module Netaxept
  module Responses
    
    class RegisterResponse < Response
      
      #attr_reader :transaction_id
      
      def initialize(node)
        #@transaction_id = node.xpath("//TransactionId").inner_text
      end
      
    end # RegisterResponse
    
  end # Responses
end # Netaxept