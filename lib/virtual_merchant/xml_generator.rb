module VirtualMerchant
  class XMLGenerator
    def self.generateVoid(transaction_id, creds)
      xml = "xmldata=<txn>
        <ssl_merchant_id>#{creds.account_id}</ssl_merchant_id>
        <ssl_user_id>#{creds.user_id}</ssl_user_id>
        <ssl_pin>#{creds.pin}</ssl_pin>
        <ssl_transaction_type>ccvoid</ssl_transaction_type>
        <ssl_txn_id>#{transaction_id}</ssl_txn_id>
        </txn>"
      return xml
    end
  
    def self.generate(card, amount, creds, transaction_type)
      xml = "xmldata=<txn>
        <ssl_merchant_id>" + creds.account_id + "</ssl_merchant_id>
        <ssl_user_id>" + creds.user_id + "</ssl_user_id>
        <ssl_pin>" + creds.pin + "</ssl_pin>
        <ssl_transaction_type>" + transaction_type + "</ssl_transaction_type>
        <ssl_amount>" + amount.total + "</ssl_amount>
        <ssl_salestax>" + amount.tax + "</ssl_salestax>
        <ssl_customer_code>" + card.last_four + "</ssl_customer_code>
        <ssl_card_present>Y</ssl_card_present>
        <ssl_partial_auth_indicator>0</ssl_partial_auth_indicator>"
      if card.track2
        xml += "<ssl_track_data>" + card.track2 + " </ssl_track_data>"
      else
        #Manual Entry
        xml += "<ssl_card_number>" + card.number.to_s + "</ssl_card_number>
          <ssl_exp_date>" + card.expiration + "</ssl_exp_date>"
      end
  
      if !card.security_code || card.security_code == ""
        xml += "<ssl_cvv2cvc2_indicator>0</ssl_cvv2cvc2_indicator>"
      else
        xml += "<ssl_cvv2cvc2_indicator>1</ssl_cvv2cvc2_indicator>
            <ssl_cvv2cvc2>" + card.security_code + "</ssl_cvv2cvc2>"
      end
  
      xml += "</txn>"
      return xml
    end
  end
end
