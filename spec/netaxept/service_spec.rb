require "spec_helper"
require "netaxept/service"
require 'open-uri'

require 'uri'

shared_context 'register with an empty card' do
  let(:amount) { 100 }
  let(:register_response) { service.register(
    amount: amount,
    orderNumber: "100",
    currencyCode: "NOK",
    serviceType: "C", # We're going to register the card at once
    pan: "4925000000000087",
    expiryDate: Time.now.strftime("%m%y"),
    securityCode: "111"
  ) }
  let(:transaction_id) { register_response.transaction_id }
end

shared_context 'register with no card' do
  let(:amount) { 100 }
  let(:response) { service.register(
    amount: amount,
    orderNumber: "100",
    currencyCode: "NOK",
    redirectUrl: "http://localhost:3000/"
  ) }
end

shared_context 'register with a good card' do
  let(:amount) { 100 }
  let(:register_response) { service.register(
    amount: amount,
    orderNumber: "100",
    currencyCode: "NOK",
    serviceType: "C", # We're going to register the card at once
    pan: "4925000000000004",
    expiryDate: Time.now.strftime("%m%y"),
    securityCode: "111"
  ) }
  let(:transaction_id) { register_response.transaction_id }
end

shared_context 'register and auth with a card that fails on capture' do
  let(:amount) { 100 }
  let(:register_response) { service.register(
    amount: amount,
    orderNumber: "100",
    currencyCode: "NOK",
    serviceType: "C", # We're going to register the card at once
    pan: "4925000000000079",
    expiryDate: Time.now.strftime("%m%y"),
    securityCode: "111"
  ) }
  let(:transaction_id) { register_response.transaction_id }
end

module Netaxept

  describe Service do
    let(:service) { Service.new(merchant_id, token, environment) }
    let(:merchant_id) { NETAXEPT_TEST_MERCHANT_ID }
    let(:token) { NETAXEPT_TEST_TOKEN }
    let(:environment) { :test }

    context "with incorrect credentials" do
      let(:merchant_id) { '' }
      let(:token) { '' }

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

    describe '.new' do
      context "when the environment is unknown" do
        let(:environment) { :incorrect }

        it "raises an error" do
          expect { service }.to raise_exception(UnknownEnvironmentError)
        end
      end

      context "when environment is known" do
        let(:environment) { :test }

        it "does not raise an error" do
          expect { service }.to_not raise_exception(UnknownEnvironmentError)
        end
      end
    end

    describe '#register' do
      subject { service.register(params) }

      context "when invalid params given" do
        let(:params) { {} }

        it "raises a validation error" do
          expect { subject }.to raise_exception(ValidationException)
        end
      end

      context "when valid params given" do
        include_context 'register with no card'

        it "returns a response with a transaction id as a string" do
          expect(response.transaction_id).to be_a(String)
          expect(response.transaction_id).to_not be_empty
        end

        it "returns a response with an url to the terminal" do
          expect(response.terminal_url).to be_a_valid_uri
          expect(open(response.terminal_url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE)).to_not include("Internal error")
        end
      end
    end

    describe '#sale' do
      subject { service.sale(transaction_id, amount) }

      context "when registered with a good card" do
        include_context 'register with a good card'

        it "returns on a successful sale" do
          expect { subject }.to_not raise_exception
        end

        context "and invalid transaction id given" do
          let(:transaction_id) { 'BLA BLA BLA' }

          it "raises an exception" do
            expect { subject }.to raise_exception(GenericError)
          end
        end
      end

      context "when registered with an empty card" do
        include_context 'register with an empty card'

        it "raises an exception on a sale with the correct amount" do
          expect { subject }.to raise_exception(BBSException)
        end
      end
    end

    describe '#auth' do
      subject { service.auth(transaction_id) }

      context "when registered with a good card" do
        include_context 'register with a good card'

        it "returns on a successful auth" do
          expect { subject }.to_not raise_exception
        end
      end

      context "when registered with an empty card" do
        include_context 'register with an empty card'

        it "raises an exception on an auth with the correct amount" do
          expect { subject }.to raise_exception(BBSException)
        end
      end
    end

    describe '#capture' do
      subject { service.capture(transaction_id, amount) }

      before do
        service.auth(transaction_id)
      end

      context "when registered with a good card" do
        include_context 'register with a good card'

        it "returns with correct amount" do
          expect { subject }.to_not raise_exception
        end
      end

      context "when registered with a card that fails on capture" do
        include_context 'register and auth with a card that fails on capture'

        it "raises a BBSException when trying to capture the correct amount" do
          expect { subject }.to raise_exception(BBSException)
        end
      end
    end

    describe '#credit' do
      include_context 'register with a good card'

      subject { service.credit(transaction_id, amount) }

      before do
        service.sale(transaction_id, amount)
      end

      it "returns with no error" do
        expect { subject }.to_not raise_exception
      end
    end
  end
end
