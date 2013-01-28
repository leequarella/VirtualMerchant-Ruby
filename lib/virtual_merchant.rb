module VirtualMerchant
  require "rexml/document"
  require 'virtual_merchant/amount'
  require 'virtual_merchant/communication'
  require 'virtual_merchant/credentials'
  require 'virtual_merchant/credit_card'
  require 'virtual_merchant/response'
  require 'virtual_merchant/logger'
  require 'virtual_merchant/xml_generator'

  def self.charge(card, amount, creds)
    xml = VirtualMerchant::XMLGenerator.generate(card, amount, creds, "ccsale")
    self.process(xml, creds, amount)
  end

  def self.refund(card, amount, creds)
    xml = VirtualMerchant::XMLGenerator.generate(card, amount, creds, 'cccredit')
    self.process(xml, creds, amount)
  end

  def self.void(transaction_id, creds)
    xml = VirtualMerchant::XMLGenerator.generateVoid(transaction_id, creds)
    self.process(xml, creds)
  end

  private
  def self.process(xml, creds, amount=0)
    communication = VirtualMerchant::Communication.new(
      {xml: xml, url: self.url(creds.demo), referer: creds.referer})
    vm_response = communication.send
    response = self.generateResponse(vm_response)
    VirtualMerchant::Logger.new(response)
    response
  end

  def self.url(demo)
    if demo
      'https://demo.myvirtualmerchant.com/VirtualMerchantDemo/processxml.do'
    else
      'https://www.myvirtualmerchant.com/VirtualMerchant/processxml.do'
    end
  end

  def self.generateResponse(vm_response)
    #decode XML sent back by virtualMerchant
    if vm_response == false
      response =  
       self.error_response("-1", "VirtualMerchant didn't respond.")
      return response
    end

    response = {}
    doc = REXML::Document.new(vm_response)
    REXML::XPath.each(doc, "txn") do |xml|
      if xml.elements["errorCode"] 
        #Something was wrong with the transaction so an 
        #errorCode and errorMessage were sent back
        response = 
          self.error_response(xml.elements["errorCode"].text, xml.elements["errorMessage"].text)
      elsif (xml.elements["ssl_result"] && xml.elements["ssl_result"].text != "0")
        #something closer to an approval, but still declined
        response = 
          self.error_response(xml.elements["ssl_result_message"].text, xml.elements["ssl_result"].text)
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

  def self.error_response(code, message)
    response = VirtualMerchant::Response.new(
      error: code,
      result_message: message)
  end
end
