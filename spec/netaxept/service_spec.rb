require "spec_helper"

describe Netaxept::Service do
  
  let(:service) { Netaxept::Service.new }
  
  describe ".authenticate" do
    it "sets merchant id and token as default params" do
      Netaxept::Service.should_receive(:default_params).with({
        :MerchantId => "12341234",
        :token => "abc123"
      })
      
      Netaxept::Service.authenticate("12341234", "abc123")
    end
  end
  
  describe ".environment" do
    it "sets the base_uri to https://epayment-test.bbs.no/ when set to test" do
      Netaxept::Service.should_receive(:base_uri).with "https://epayment-test.bbs.no/"
      
      Netaxept::Service.environment = :test
    end
    
    it "sets the base_uri to https://epayment.bbs.no/ when set to production" do
      Netaxept::Service.should_receive(:base_uri).with "https://epayment.bbs.no/"
      
      Netaxept::Service.environment = :production
    end
  end
  
  describe ".register" do
    
    it "calls the Register.aspx with the first argument as amount, the second as order id amd the third as custom params" do
      
      Netaxept::Service.should_receive(:get).with("/Netaxept/Register.aspx", :query => {
        :amount => 20100,
        :orderNumber => 12,
        :redirectUrl => "http://localhost:3000/order/1/return"
      })
      
      service.register(20100, 12, :redirectUrl => "http://localhost:3000/order/1/return")
      
    end
    
    it "returns an instance of Netaxept::Responses::RegisterResponse" do
      response = service.register(20100, 12, :redirectUrl => "http://localhost:3000/order/1/return")
      response.should be_a Netaxept::Responses::RegisterResponse
    end
    
  end
  
end