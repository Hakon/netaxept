require 'rubygems'
require 'bundler/setup'
require "netaxept_credentials"

Dir.glob(File.join(File.dirname(__FILE__),"support/matchers/*_matcher.rb")) do |file|
  require file
end