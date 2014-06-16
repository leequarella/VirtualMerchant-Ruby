module VirtualMerchant
  class XMLGenerator
    def self.generateVoid(transaction_id, creds)
      xml = "xmldata=<txn>
        <ssl_transaction_type>ccvoid</ssl_transaction_type>
        <ssl_merchant_id>#{creds.account_id}</ssl_merchant_id>
        <ssl_user_id>#{creds.user_id}</ssl_user_id>
        <ssl_pin>#{creds.pin}</ssl_pin>
        <ssl_txn_id>#{transaction_id}</ssl_txn_id>
        </txn>"
      VirtualMerchant::Logger.xml('VOID OUTPUT', xml)
      return xml
    end

    def self.generate(card, amount, creds, custom_fields, transaction_type)
      xml = "xmldata=<txn>"
        xml += credentials(creds)
        xml += basic(card, transaction_type, amount)
        xml += for_recurring(amount) if transaction_type == 'ccaddrecurring'
        if card.encrypted?
          xml += for_encrypted(card, creds)
        else
          xml += for_clear_text(card)
        end
        custom_fields.each do |key,value|
          xml += "<#{key}>#{value}</#{key}>"
        end
      xml += "</txn>"
      VirtualMerchant::Logger.xml('NORMAL OUTPUT', xml)
      xml
    end

    def self.modify(creds, transaction_type, transaction_id, amount=0)
      xml =    "xmldata=<txn>"
        xml +=  credentials(creds)
        xml += "<ssl_transaction_type>#{transaction_type}</ssl_transaction_type>
                <ssl_txn_id>#{transaction_id}</ssl_txn_id>"
      if transaction_type == 'cccomplete'
        xml += "<ssl_amount>#{amount.total}</ssl_amount>"
      end
      xml +=   "</txn>"
      VirtualMerchant::Logger.xml('MODIFY TRANSACTION OUTPUT', xml)
      xml
    end

    private
    def self.credentials(creds)
      "<ssl_merchant_id>#{creds.account_id}</ssl_merchant_id>
       <ssl_user_id>#{creds.user_id}</ssl_user_id>
       <ssl_pin>#{creds.pin}</ssl_pin>"
    end

    def self.basic(card, transaction_type, amount)
       "<ssl_transaction_type>#{transaction_type}</ssl_transaction_type>
       <ssl_amount>#{amount.total}</ssl_amount>
       <ssl_salestax>#{amount.tax}</ssl_salestax>
       <ssl_customer_code>#{card.last_four}</ssl_customer_code>
       <ssl_card_present>Y</ssl_card_present>
       <ssl_partial_auth_indicator>0</ssl_partial_auth_indicator>"
    end

    def self.for_clear_text(card)
      if card.swiped?
        "<ssl_track_data>#{card.track2}</ssl_track_data>"
      else
        manual(card)
      end
    end

    def self.for_recurring(amount)
      "<ssl_next_payment_date>#{amount.next_payment_date}</ssl_next_payment_date>
       <ssl_billing_cycle>#{amount.billing_cycle}</ssl_billing_cycle>
       <ssl_end_of_month>#{amount.end_of_month}</ssl_end_of_month>"
    end

    def self.for_encrypted(card, creds)
       "<ssl_vm_mobile_source>#{creds.source}</ssl_vm_mobile_source>
       <ssl_vendor_id>#{creds.vendor_id}</ssl_vendor_id>
       <ssl_ksn>#{creds.ksn}</ssl_ksn>
       <ssl_encrypted_track1_data>#{card.encrypted_track_1}</ssl_encrypted_track1_data>
       <ssl_encrypted_track2_data>#{card.encrypted_track_2}</ssl_encrypted_track2_data>
       <ssl_vm_encrypted_device>#{creds.device_type}</ssl_vm_encrypted_device>"
    end

    def self.manual(card)
      xml = "<ssl_card_number>#{card.number.to_s}</ssl_card_number>
             <ssl_exp_date>#{card.expiration}</ssl_exp_date>"
      if !card.security_code || card.security_code == ""
        xml += "<ssl_cvv2cvc2_indicator>0</ssl_cvv2cvc2_indicator>"
      else
        xml += "<ssl_cvv2cvc2_indicator>1</ssl_cvv2cvc2_indicator>
                <ssl_cvv2cvc2>#{card.security_code}</ssl_cvv2cvc2>"
      end
      xml
    end

    def self.error(code, message)
      xml =  "<txn>
              <errorCode>#{code}</errorCode>
              <errorMessage>#{message}</errorMessage>
              </txn>"
      xml
    end
  end
end
