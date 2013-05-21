require "spec_helper"
require "netaxept/service"
require 'open-uri'

require 'uri'

module Netaxept

  describe Service do
    context "with incorrect credentials" do
      let(:service) { Service.new("", "", :test) }

      describe '#register' do
        it "raises an auth error" do
          expect { service.register({}) }.to raise_exception(AuthenticationException)
        end
      end

      describe '#sale' do
        it "raises an auth error" do
          expect { service.sale('txn-1', 10) }.to raise_exception(AuthenticationException)
        end
      end

      describe '#auth' do
        it "raises an auth error" do
          expect { service.auth('txn-2') }.to raise_exception(AuthenticationException)
        end
      end

      describe '#capture' do
        it "raises an auth error" do
          expect { service.capture('txn-3', 10) }.to raise_exception(AuthenticationException)
        end
      end

      describe '#credit' do
        it "raises an auth error" do
          expect { service.credit('txn-4', 10) }.to raise_exception(AuthenticationException)
        end
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

      it "returns a response with a transaction id as a string on a valid request" do
        response = subject.register({
            amount: 100,
            orderNumber: "200",
            currencyCode: "NOK",
            redirectUrl: "http://localhost:3000/"
          })
        expect(response.transaction_id).to be_a(String)
        expect(response.transaction_id).to_not be_empty
      end

      it "returns a response with an url to the terminal with the transaction id" do
        response = subject.register({
            amount: 100,
            orderNumber: "200",
            currencyCode: "NOK",
            redirectUrl: "http://localhost:3000/"
          })

        expect(response.terminal_url).to be_a_valid_uri
        expect(open(response.terminal_url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)).to_not include("Internal error")
      end

    end


    context "with a card with insufficient funds" do

      before do
        response = subject.register({
            amount: 100,
            orderNumber: "100",
            currencyCode: "NOK",

            serviceType: "C", # We're going to register the card at once
            pan: "4925000000000087",
            expiryDate: Time.now.strftime("%m%y"),
            securityCode: "111"
          })
        @transaction_id = response.transaction_id
      end

      it "raises an exception on a sale with the correct amount" do
        expect { subject.sale(@transaction_id, 100) }.to raise_exception(BBSException)
      end

      it "raises an exception on an auth with the correct amount" do
        expect { subject.auth(@transaction_id) }.to raise_exception(BBSException)
      end

    end

    context "with a valid card supplied at the terminal" do

      before do
        response = subject.register({
            amount: 100,
            orderNumber: "100",
            currencyCode: "NOK",
            redirectUrl: "http://localhost:3000",

            serviceType: "C", # We're going to register the card at once
            pan: "4925000000000004",
            expiryDate: Time.now.strftime("%m%y"),
            securityCode: "111"
          })
        @transaction_id = response.transaction_id
      end

      it "raises an exception on a sale with an unknown transaction id" do
        expect { subject.sale("BLA BLA BLA", 100) }.to raise_exception(GenericError)
      end

      it "returns on a successful sale" do
        expect { subject.sale(@transaction_id, 100) }.to_not raise_exception
      end

      it "returns on a successful auth" do
        expect { subject.auth(@transaction_id) }.to_not raise_exception
      end

      it "returns on a capture with correct amount" do
        subject.auth(@transaction_id)
        expect { subject.capture(@transaction_id, 100) }.to_not raise_exception
      end

    end

    context "with a card with authorized amount but fails on capture" do
      before do
        response = subject.register({
            amount: 100,
            orderNumber: "100",
            currencyCode: "NOK",

            serviceType: "C", # We're going to register the card at once
            pan: "4925000000000079",
            expiryDate: Time.now.strftime("%m%y"),
            securityCode: "111"
          })
        @transaction_id = response.transaction_id
        subject.auth(@transaction_id)
      end

      it "raises a BBSException when trying to capture the correct amount" do
        expect { subject.capture(@transaction_id, 100) }.to raise_exception(BBSException)
      end
    end

  end
end
