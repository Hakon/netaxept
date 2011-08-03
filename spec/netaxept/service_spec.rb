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
    use_vcr_cassette
    
    describe "a valid request" do
      
      let(:response) { service.register(20100, 12, :redirectUrl => "http://localhost:3000/order/1/return") }
      
      it "is successful" do
        response.success?.should == true
      end
      
      it "has a transaction_id" do
        response.transaction_id.should_not be_nil
      end
      
    end
    
    describe "a request without error (no money)" do

      let(:response) { service.register(0, 12, :redirectUrl => "http://localhost:3000/order/1/return") }

      it "is not a success" do
        response.success?.should == false
      end
      
      it "does not have a transaction id" do
        response.transaction_id.should be_nil
      end
      
      it "has an error message" do
        response.errors.first.message.should == "Transaction amount must be greater than zero."
      end
      
    end
    
  end
  
  describe ".sale" do
    use_vcr_cassette
    
    let(:transaction_id) { service.register(20100, 12, :redirectUrl => "http://localhost:3000/order/1/return").transaction_id }
    
    describe "a valid request" do
      
      let(:response) { service.sale(transaction_id, 20100) }
      
      it "is a success" do
        response.success?.should == true
      end
      
    end
    
  end
  
end