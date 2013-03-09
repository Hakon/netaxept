require "spec_helper"

require "netaxept/service"

module Netaxept

  describe Service do

    context "with incorrect credentials" do

      subject { Service.new("", "", :test) }

      it "fails at registering" do
        expect { subject.register({}) }.to raise_exception(AuthenticationException)
      end
    end

    subject { Service.new(NETAXEPT_TEST_MERCHANT_ID, NETAXEPT_TEST_TOKEN, :test) }

    describe "initializing the service" do

      it "raises an error if environment is unknown" do
        expect { Service.new("123", "token", :incorrect) }.to raise_exception(UnknownEnvironmentError)
      end

      it "does not raise an error if environment is known" do
        expect { Service.new("123", "token", :test) }.to_not raise_exception(UnknownEnvironmentError)
      end

    end

    describe "registering a new transaction" do
      
      it "raises a validation error when Nets encouters a validation error" do
        expect { subject.register({}) }.to raise_exception(ValidationException)
      end

      it "returns a response with a transaction id on a valid request" do
        response = subject.register({
            amount: 100,
            orderNumber: "200",
            currencyCode: "NOK",
            redirectUrl: "http://localhost:3000/"
          })
        expect(response.transaction_id).to_not be_empty
      end

    end
  end

end