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

  def self.authorize(card, amount, creds, gateway=Gateway.new(creds))
    gateway.ccauth(card, amount)
  end

  def self.complete(amount, creds, transaction_id, gateway=Gateway.new(creds))
    gateway.cccomplete(amount, transaction_id)
  end

  def self.delete(creds, transaction_id, gateway=Gateway.new(creds))
    gateway.ccdelete(transaction_id)
  end

  def self.add_recurring(card, amount, creds, gateway=Gateway.new(creds))
    gateway.ccaddrecurring(card, amount)
  end

  def self.refund(card, amount, creds, gateway=Gateway.new(creds))
    gateway.cccredit(card, amount)
  end

  def self.void(transaction_id, creds, gateway=Gateway.new(creds))
    gateway.ccvoid(transaction_id)
  end
end
