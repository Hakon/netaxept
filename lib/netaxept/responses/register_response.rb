module Netaxept
  module Responses
    
    class RegisterResponse < Response
      
      attr_reader :transaction_id
      
      def initialize(node)
        super(node)
        if(success?)
          @transaction_id = node["RegisterResponse"]["TransactionId"]
        end
      end
      
    end # RegisterResponse
    
  end # Responses
end # Netaxept