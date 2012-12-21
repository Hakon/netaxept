RSpec::Matchers.define :be_successful do

  match do |response|
    response.success?
  end
  
  failure_message_for_should do |response|
    errors = response.errors.map(&:message).join(", ")
    "#{response} should be successful, got error(s): #{errors}"
  end
  
  failure_message_for_should_not do |response|
    "#{response} should not be successful"
  end
  
end

RSpec::Matchers.define :fail do
  chain :with_message do |message|
    @message = message
  end

  match do |response|
    @failure = !response.success?
    
    if(@message)
      @failure && response.errors.map(&:message).include?(@message)
    else
      @failure
    end
    
  end
  
  failure_message_for_should do |response|
    errors = response.errors.map(&:message).join(", ")
    if(@message)
      "#{response} should have error message: #{@message}"
    else
      "#{response} should not be successful"
    end
  end
  
  failure_message_for_should_not do |response|
    "#{response} should be successful"
  end
  
end