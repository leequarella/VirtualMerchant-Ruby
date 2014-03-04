module VirtualMerchant
  class Logger
    def initialize(response = {})
      p "!!!!!!!!!!!!!!!!!!!!!!!! Credit Response !!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      if response.result
        p "result " + response.result
      elsif response.error
        p "error " + response.error
      end
      p "result_message " + response.result_message
      p "!!!!!!!!!!!!!!!!!!!!!!!! End Credit Response !!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      p 'wat'
    end
  end
end
