require 'rubygems'
require 'bundler/setup'

require 'netaxept' # and any other gems you need
require "netaxept_credentials"

require "mechanize"

Dir.glob(File.join(File.dirname(__FILE__),"support/matchers/*_matcher.rb")) do |file|
  require file
end

Netaxept::Service.authenticate(NETAXEPT_TEST_MERCHANT_ID, NETAXEPT_TEST_TOKEN)
Netaxept::Service.environment = :test