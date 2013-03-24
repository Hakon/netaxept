require 'uri'

RSpec::Matchers.define :be_a_valid_uri do

  match do |string|
    string =~ URI::regexp
  end
  
  failure_message_for_should do |string|
    "#{string} should be a valid URI, but isn't."
  end
  
  failure_message_for_should_not do |string|
    "#{string} should not be a valid URI, but is."
  end
  
end
