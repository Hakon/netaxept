require "httparty"

module Netaxept
  class Service
    include HTTParty
    
    default_params :CurrencyCode => "NOK"
    
    module Configuration
      
      attr_accessor :merchant_id
      
      ##
      # Stores the merchant id and the token for later requests

      def authenticate(merchant_id, token)
        self.merchant_id = merchant_id
        default_params({
          :MerchantId => merchant_id,
          :token => token
          })
      end
      
      ##
      # Switches between sandbox and production environment
      
      def environment=(new_environment)
        if(new_environment == :production)
          base_uri "https://epayment.bbs.no/"
        end
        if(new_environment == :test)
          base_uri "https://epayment-test.bbs.no/"
        end
      end
      
    end
    extend Configuration
    
    environment = :production
    
    ##
    # Registers the order parameters with netaxept. Returns a Responses::RegisterResponse
    
    def register(amount, order_id, options = {})
      
      params = {}
      params[:query] = {
        :amount => amount,
        :orderNumber => order_id
        }.merge(options)
        
      Responses::RegisterResponse.new(self.class.get("/Netaxept/Register.aspx", params).parsed_response)
      
    end
    
    ##
    # Captures the whole amount instantly
    
    def sale(transaction_id, amount)
      params = {
        :query => {
          :amount => amount,
          :transactionId => transaction_id,
          :operation => "SALE"
        }
      }
      
      Responses::SaleResponse.new(self.class.get("/Netaxept/Process.aspx", params).parsed_response)
    end
    
    ##
    # Authorize the whole amount on the credit card
    
    def auth(transaction_id, amount)
      params = {
        :query => {
          :amount => amount,
          :transactionId => transaction_id,
          :operation => "AUTH"
        }
      }
      
      Responses::AuthResponse.new(self.class.get("/Netaxept/Process.aspx", params).parsed_response)
    end
    
    ##
    # The terminal url for a given transaction id
    
    def self.terminal_url(transaction_id)
      "#{Netaxept::Service.base_uri}/terminal/default.aspx?MerchantID=#{Netaxept::Service.merchant_id}&TransactionID=#{transaction_id}"
    end
    
  end
end