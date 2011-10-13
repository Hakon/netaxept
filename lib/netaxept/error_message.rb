module Netaxept
  class ErrorMessage
    attr_accessor :message, :code, :source, :text
    def initialize(node)
      if(node)
        @message = node["Message"]
        @code = node["Code"]
        @source = node["ResponseSource"]
        @text = node["ResponseText"]
      end
    end
  end
end