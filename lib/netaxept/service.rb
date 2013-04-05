require "rest_client"
require "nokogiri"

module Netaxept
  UnknownEnvironmentError = Class.new(StandardError)
  ValidationException = Class.new(StandardError)
  AuthenticationException = Class.new(StandardError)
  BBSException = Class.new(StandardError)
  MerchantTranslationException = Class.new(StandardError)
  UniqueTransactionIdException = Class.new(StandardError)
  SecurityException = Class.new(StandardError)
  QueryException = Class.new(StandardError)
  GenericError = Class.new(StandardError)
  NotSupportedException = Class.new(StandardError)

  RegisterResponse = Struct.new(:transaction_id, :terminal_url)

  class Service

    ENDPOINTS = {
      test: "https://epayment-test.bbs.no",
      production: "https://epayment.bbs.no"
    }

    EXCEPTIONS = {
      "AuthenticationException" => AuthenticationException,
      "BBSException" => BBSException,
      "MerchantTranslationException" => MerchantTranslationException,
      "UniqueTransactionIdException" => UniqueTransactionIdException,
      "GenericError" => GenericError,
      "ValidationException" => ValidationException,
      "SecurityException" => SecurityException,
      "QueryException" => QueryException,
      "NotSupportedException" => NotSupportedException
    }

    def initialize(merchant_id, token, environment)
      @base_url = ENDPOINTS[environment] or raise UnknownEnvironmentError
      @environment = environment
      @credentials = {
        merchantId: merchant_id,
        token: token
      }
    end

    def register(params)
      http_response = RestClient.get("#{base_url}/Netaxept/Register.aspx", params: params.merge(credentials))

      xml_response = Nokogiri::XML(http_response.to_s)
      xml_response.xpath('/Exception/Error').each do |exception|
        raise EXCEPTIONS[exception.xpath("@xsi:type").to_s], exception.xpath("Message").text
      end

      transaction_id = xml_response.xpath("/RegisterResponse/TransactionId").text
      RegisterResponse.new(transaction_id, base_url + "/Terminal/default.aspx?merchantId=#{credentials[:merchantId]}&transactionId=#{transaction_id}")

    end

    def sale(transaction_id, amount)
      process(transactionId: transaction_id, amount: amount, operation: "SALE")
    end

    def auth(transaction_id)
      process(transactionId: transaction_id, operation: "AUTH")
    end

    def capture(transaction_id, amount)
      process(transactionId: transaction_id, amount: amount, operation: "CAPTURE")
    end

    private

    def process(params)

      http_response = RestClient.get("#{base_url}/Netaxept/Process.aspx", params: params.merge(credentials))
      xml_response = Nokogiri::XML(http_response.to_s)
      xml_response.xpath('/Exception/Error').each do |exception|
        raise EXCEPTIONS[exception.xpath("@xsi:type").to_s], exception.xpath("Message").text
      end

      nil
    end

    attr_reader :environment, :base_url, :credentials

  end
end