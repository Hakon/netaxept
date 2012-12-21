require "spec_helper"

describe Netaxept::Service do
  
  let(:service) { Netaxept::Service.new }
  
  describe ".authenticate" do
    it "sets merchant id and token as default params" do
      Netaxept::Service.should_receive(:default_params).with({
        :MerchantId => NETAXEPT_TEST_MERCHANT_ID,
        :token => NETAXEPT_TEST_TOKEN
      })
      
      Netaxept::Service.authenticate(NETAXEPT_TEST_MERCHANT_ID, NETAXEPT_TEST_TOKEN)
    end
  end
  
  describe ".environment" do
    it "sets the base_uri to https://epayment.bbs.no/ when set to production" do
      Netaxept::Service.should_receive(:base_uri).with "https://epayment.bbs.no/"
      
      Netaxept::Service.environment = :production
    end
    
    it "sets the base_uri to https://epayment-test.bbs.no/ when set to test" do
      Netaxept::Service.should_receive(:base_uri).with "https://epayment-test.bbs.no/"
      
      Netaxept::Service.environment = :test
    end
  end
  
  describe ".terminal_url" do
    
    it "returns the terminal url if you pass a transaction id" do
      Netaxept::Service.should_receive(:merchant_id).and_return("123133")
      Netaxept::Service.terminal_url("deadbeef00").should == "https://epayment-test.bbs.no/terminal/default.aspx?MerchantID=123133&TransactionID=deadbeef00"
    end
    
    it "has a production terminal url if the environment is production" do
      Netaxept::Service.environment = :production
        Netaxept::Service.should_receive(:merchant_id).and_return("123133")
        Netaxept::Service.terminal_url("deadbeef00").should == "https://epayment.bbs.no/terminal/default.aspx?MerchantID=123133&TransactionID=deadbeef00"
      Netaxept::Service.environment = :test
    end
    
  end
  
  describe ".register" do
    
    describe "a valid request" do
      
      let(:response) { service.register(20100, 12, :redirectUrl => "http://localhost:3000/order/1/return") }
      
      it "is successful" do
        response.should be_successful
      end
      
      it "has a transaction_id" do
        response.transaction_id.should_not be_nil
      end
      
    end
    
    describe "a request without error (no money)" do

      let(:response) { service.register(0, 12, :redirectUrl => "http://localhost:3000/order/1/return") }

      it "is not a success" do
        response.should fail.with_message("Transaction amount must be greater than zero.")
      end
      
      it "does not have a transaction id" do
        response.transaction_id.should be_nil
      end
      
    end
    
  end
  
  context "with a transaction id" do
    
    let(:transaction_id) { service.register(20100, 12, :redirectUrl => "http://localhost:3000/order/1/return").transaction_id }

    before do 

      # Register some card data with the transaction.
      url = Netaxept::Service.terminal_url(transaction_id)
      mechanic = Mechanize.new
      mechanic.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      mechanic.get(url) do |page|
        form = page.form_with(:name => "form1")
        cc_form = form.click_button(form.button_with(:value => /^Neste/)).form_with(:name => "form1") do |form|
          
          form["ctl10$cardNo"] = "4925000000000004"
          form.field_with(:id => "month").options.last.tick
          form.field_with(:id => "year").options.last.tick
          form["ctl10$securityCode"] = "111"

        end
        mechanic.redirect_ok = false
        cc_form.click_button(cc_form.button_with(:id => "okButton"))
      end

    end
    
    describe "a valid sale request" do

      it "is a success" do
        response = service.sale(transaction_id, 20100)
        response.should be_successful
      end
      
    end

    describe "a valid auth request" do
      
      it "is a success" do
        response = service.auth(transaction_id, 20100)
        response.should be_successful
      end
      
    end
  
    describe "a valid capture request" do
      
      it "is a success" do
        service.auth(transaction_id, 20100)
        response = service.capture(transaction_id, 20100)
        response.should be_successful
      end
      
    end
  
    describe "a valid credit request" do

      it "is a success" do
        service.sale(transaction_id, 20100)

        service.credit(transaction_id, 20100).should be_successful
      end
    end

    describe "a valid annul request" do

      it "is a success" do
        service.auth(transaction_id, 20100)
        service.annul(transaction_id).should be_successful
      end
    end

    
  end
end