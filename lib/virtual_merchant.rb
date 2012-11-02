module VirtualMerchant
  require "rexml/document"
  require 'net/http'
  require 'virtual_merchant/amount'
  require 'virtual_merchant/credentials'
  require 'virtual_merchant/credit_card'
  require 'virtual_merchant/response'

  def self.charge(card, amount, creds)
    xml = self.generateXMLforVirtualMerchant(card, amount, creds, "ccsale")
    vm_response = self.sendXMLtoVirtualMerchant(xml, creds)
    response = self.generateResponse(vm_response)
    self.printResponse(response)
    response
  end

  def self.refund(card, amount, creds)
    xml = self.generateXMLforVirtualMerchant(card, amount, creds, 'cccredit')
    vm_response = self.sendXMLtoVirtualMerchant(xml, creds)
    response = self.generateResponse(vm_response)
    self.printResponse(response)
    response
  end

  def self.void(transaction_id, creds)
    xml = self.generateVoidXML(transaction_id, creds)
    vm_response = self.sendXMLtoVirtualMerchant(xml, creds)
    response = self.generateResponse(vm_response)
    self.printResponse(response)
    response
  end

  def self.generateVoidXML(transaction_id, creds)
    xml = "xmldata=<txn>
      <ssl_merchant_id>#{creds.account_id}</ssl_merchant_id>
      <ssl_user_id>#{creds.user_id}</ssl_user_id>
      <ssl_pin>#{creds.pin}</ssl_pin>
      <ssl_transaction_type>ccvoid</ssl_transaction_type>
      <ssl_txn_id>#{transaction_id}</ssl_txn_id>
      </txn>"
    return xml
  end

  def self.generateXMLforVirtualMerchant(card, amount, creds, transaction_type)
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

  def self.sendXMLtoVirtualMerchant(xml, creds)
    if creds.referer
      headers = {
        'Referer' => creds.referer
      }
    end
    if creds.demo
      uri=URI.parse('https://demo.myvirtualmerchant.com/VirtualMerchantDemo/processxml.do')
    else
      uri=URI.parse('https://www.myvirtualmerchant.com/VirtualMerchant/processxml.do')
    end

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    body = http.post(uri.request_uri, xml, headers).body
    return body
  end

  def self.generateResponse(vm_response)
    #decode XML sent back by virtualMerchant
    response = {}
    doc = REXML::Document.new(vm_response)
    REXML::XPath.each(doc, "txn") do |xml|
      if xml.elements["errorCode"]
        #Something was wrong with the transaction so an errorCode and errorMessage were sent back
        response = VirtualMerchant::Response.new(
          error: xml.elements["errorCode"].text,
          result_message: xml.elements["errorMessage"].text)
      else
        #a clean transaction has taken place
        response = VirtualMerchant::Response.new(
          result_message: xml.elements["ssl_result_message"].text,
          result: xml.elements["ssl_result"].text,
          blurred_card_number: xml.elements["ssl_card_number"].text,
          exp_date: xml.elements["ssl_exp_date"].text,
          approval_code: xml.elements["ssl_approval_code"].text,
          cvv2_response: xml.elements["ssl_cvv2_response"].text,
          transaction_id: xml.elements["ssl_txn_id"].text,
          transaction_time: xml.elements["ssl_txn_time"].text)
      end
    end
    puts "<<<<<<<<<<<<<<<<<<<<<<"
    puts response
    puts "<<<<<<<<<<<<<<<<<<<<<<"
    response
  end

  def self.printResponse(response)
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
