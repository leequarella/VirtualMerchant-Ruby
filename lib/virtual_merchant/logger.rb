module VirtualMerchant
  class Logger
    @@on = false

    def self.on!
      @@on = true
    end

    def self.off!
      @@on = false
    end

    def self.log_response(response)
      return unless @@on
      p "!!!!!!!!!!!!!!!!!!!!!!!! Credit Response !!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      if response.result
        p "result " + response.result
      elsif response.error
        p "error " + response.error
      end
      p "result_message " + response.result_message
      p "!!!!!!!!!!!!!!!!!!!!!!!! End Credit Response !!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    end
  end
end
