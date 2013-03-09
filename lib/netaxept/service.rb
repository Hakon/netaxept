require "rest_client"
require "nokogiri"

module Netaxept
  UnknownEnvironmentError = Class.new(StandardError)
  ValidationException = Class.new(StandardError)
  AuthenticationException = Class.new(StandardError)

  RegisterResponse = Struct.new(:transaction_id)

  class Service

    ENDPOINTS = {
      test: "https://epayment-test.bbs.no",
      production: "https://epayment.bbs.no"
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
      xml_response.xpath('/Exception/Error[@xsi:type="AuthenticationException"]').each do |exception|
        raise AuthenticationException, exception.xpath("Message/text()")
      end
      xml_response.xpath('/Exception/Error[@xsi:type="ValidationException"]').each do |exception|
        raise ValidationException, exception.xpath("Message/text()")
      end

      transaction_id = xml_response.xpath("/RegisterResponse/TransactionId/text()")
      RegisterResponse.new(transaction_id)

    end

    private

    attr_reader :environment, :base_url, :credentials

  end
end