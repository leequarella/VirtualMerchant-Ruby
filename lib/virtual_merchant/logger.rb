module VirtualMerchant
  class Logger
    @@on      = false
    @@log_xml = false

    def self.on!()      @@on      = true  end
    def self.off!()     @@on      = false end
    def self.xml_on!()  @@log_xml = true  end
    def self.xml_off!() @@log_xml = false end

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

    def self.xml(msg, xml)
      return unless @@log_xml
      puts msg
      pp xml
    end

  end
end
