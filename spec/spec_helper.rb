require 'rubygems'
require 'bundler/setup'

require 'netaxept' # and any other gems you need
require "netaxept_credentials"

RSpec.configure do |config|
  Netaxept::Service.authenticate(NETAXEPT_TEST_MERCHANT_ID, NETAXEPT_TEST_TOKEN)
  Netaxept::Service.environment = :test
end