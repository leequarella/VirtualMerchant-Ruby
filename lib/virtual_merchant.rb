require "rexml/document"
require 'virtual_merchant/amount'
require 'virtual_merchant/communication'
require 'virtual_merchant/credentials'
require 'virtual_merchant/credit_card'
require 'virtual_merchant/response'
require 'virtual_merchant/logger'
require 'virtual_merchant/xml_generator'
require 'virtual_merchant/gateway'
module VirtualMerchant

  def self.charge(card, amount, creds, gateway=Gateway.new(creds))
    gateway.ccsale(card, amount)
  end

  def self.refund(card, amount, creds, gateway=Gateway.new(creds))
    gateway.cccredit(card, amount)
  end

  def self.void(transaction_id, creds, gateway=Gateway.new(creds))
    gateway.ccvoid(transaction_id)
  end

  private
  def self.process(xml, creds, amount=0)
    Gateway.new(creds).process(xml, amount=0)
    #communication = VirtualMerchant::Communication.new(
    #  {xml: xml, url: self.url(creds.demo), referer: creds.referer})
    #vm_response = communication.send
    #response = VirtualMerchant::Response.new(vm_response)
    #VirtualMerchant::Logger.new(response)
    #response
  end

end
