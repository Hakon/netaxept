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
      
      def terminal_url
        "#{Netaxept::Service.base_uri}/terminal/default.aspx?MerchantID=#{Netaxept::Service.merchant_id}&TransactionID=#{self.transaction_id}"
      end
      
    end # RegisterResponse
    
  end # Responses
end # Netaxept