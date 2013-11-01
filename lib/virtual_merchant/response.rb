module VirtualMerchant
  require "rexml/document"
  class Response
    attr_accessor :result_message, :result, :blurred_card_number, :exp_date,
      :approval_code, :cvv2_response, :transaction_id, :transaction_time, :error,
      :approved, :billing_cycle, :start_payment_date, :transaction_type, :recurring_id,
      :next_payment_date, :skip_payment, :recurring_batch_count

    alias_method :approved?, :approved

    def initialize(xml_string)
      if xml_string == false
        error_response("-1", "VirtualMerchant did not respond.")
      else
        decode_xml(xml_string)
      end
    end


    private
    def decode_xml(xml_string)
      doc = REXML::Document.new(xml_string)
      REXML::XPath.each(doc, "txn") do |xml|
        if xml.elements["errorCode"]
          #Something was wrong with the transaction so an
          #errorCode and errorMessage were sent back
          error_response(
            xml.elements["errorCode"].text, xml.elements["errorMessage"].text)
        elsif (xml.elements["ssl_result"] && xml.elements["ssl_result"].text != "0")
          #something closer to an approval, but still declined
          error_response(
            xml.elements["ssl_result"].text, xml.elements["ssl_result_message"].text)
        else
          #a clean transaction has taken place
          approval(xml)
        end
      end
    end

    def error_response(code, message)
      @approved = false
      @result_message = message
      @error = code
    end

    def approval(xml)
      @approved = true
      @result_message = xml.elements["ssl_result_message"].text if xml.elements["ssl_result_message"]
      @result = xml.elements["ssl_result"].text if xml.elements["ssl_result"]
      @blurred_card_number = xml.elements["ssl_card_number"].text
      @exp_date = xml.elements["ssl_exp_date"].text
      @approval_code = xml.elements["ssl_approval_code"].text if xml.elements["ssl_approval_code"]
      @cvv2_response = xml.elements["ssl_cvv2_response"].text if xml.elements["ssl_cvv2_response"]
      @transaction_id = xml.elements["ssl_txn_id"].text if xml.elements["ssl_txn_id"]
      @transaction_time = xml.elements["ssl_txn_time"].text if xml.elements["ssl_txn_time"]
      #Recurring variables
      @billing_cycle = xml.elements["ssl_billing_cycle"].text if xml.elements["ssl_billing_cycle"]
      @start_payment_date = xml.elements["ssl_start_payment_date"].text if xml.elements["ssl_start_payment_date"]
      @transaction_type = xml.elements["ssl_transaction_type"].text if xml.elements["ssl_transaction_type"]
      @recurring_id = xml.elements["ssl_recurring_id"].text if xml.elements["ssl_recurring_id"]
      @next_payment_date = xml.elements["ssl_next_payment_date"].text if xml.elements["ssl_next_payment_date"]
      @skip_payment = xml.elements["ssl_skip_payment"].text if xml.elements["ssl_skip_payment"]
      @recurring_batch_count = xml.elements["ssl_recurring_batch_count"].text if xml.elements["ssl_recurring_batch_count"]
    end
  end
end
