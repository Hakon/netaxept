require 'rubygems'
require 'bundler/setup'

require 'vcr'
require "fakeweb"

require 'netaxept' # and any other gems you need
require "netaxept_credentials"

VCR.config do |c|
  c.cassette_library_dir     = 'spec/cassettes'
  c.stub_with                :fakeweb
  c.default_cassette_options = { :record => :new_episodes }
end

RSpec.configure do |config|
  
  config.extend VCR::RSpec::Macros
  
end

Netaxept::Service.authenticate(NETAXEPT_TEST_MERCHANT_ID, NETAXEPT_TEST_TOKEN)
Netaxept::Service.environment = :test