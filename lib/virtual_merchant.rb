module VirtualMerchant
  require "rexml/document"
  require 'net/http'
  require 'virtual_merchant/amount'
  require 'virtual_merchant/credentials'
  require 'virtual_merchant/credit_card'
  require 'virtual_merchant/response'
  require 'virtual_merchant/logger'
  require 'virtual_merchant/xml_generator'

  def self.charge(card, amount, creds)
    xml = VirtualMerchant::XMLGenerator.generate(card, amount, creds, "ccsale")
    vm_response = self.sendXMLtoVirtualMerchant(xml, creds)
    response = self.generateResponse(vm_response)
    VirtualMerchant::Logger.new(response)
    response
  end

  def self.refund(card, amount, creds)
    xml = VirtualMerchant::XMLGenerator.generate(card, amount, creds, 'cccredit')
    vm_response = self.sendXMLtoVirtualMerchant(xml, creds)
    response = self.generateResponse(vm_response)
    VirtualMerchant::Logger.new(response)
    response
  end

  def self.void(transaction_id, creds)
    xml = VirtualMerchant::XMLGenerator.generateVoid(transaction_id, creds)
    vm_response = self.sendXMLtoVirtualMerchant(xml, creds)
    response = self.generateResponse(vm_response)
    VirtualMerchant::Logger.new(response)
    response
  end

  private
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
        #Something was wrong with the transaction so an 
        #errorCode and errorMessage were sent back
        response = VirtualMerchant::Response.new(
          error: xml.elements["errorCode"].text,
          result_message: xml.elements["errorMessage"].text)
      elsif (xml.elements["ssl_result"] && xml.elements["ssl_result"].text != "0")
        #something closer to an approval, but still declined
        response = VirtualMerchant::Response.new(
          error: xml.elements["ssl_result_message"].text,
          result_message: xml.elements["ssl_result"].text)
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
    response
  end
end
