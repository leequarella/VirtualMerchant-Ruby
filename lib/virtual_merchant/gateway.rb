require "pp"
class Gateway
  attr_reader :creds

  def initialize(creds)
    @creds = creds
  end

  def ccsale(card, amount)
    xml = VirtualMerchant::XMLGenerator.generate(card, amount, creds, "ccsale")
    process(xml, amount)
  end
  
  def cccredit(card, amount)
    xml = VirtualMerchant::XMLGenerator.generate(card, amount, creds, 'cccredit')
    process(xml, amount)
  end

  def ccvoid(transaction_id)
    xml = VirtualMerchant::XMLGenerator.generateVoid(transaction_id, creds)
    process(xml)
  end

  def process(xml, amount=0)
    communication = VirtualMerchant::Communication.new(
      {xml: xml, url: url(creds.demo), referer: creds.referer})
    vm_response = communication.send
    response = VirtualMerchant::Response.new(vm_response)
    VirtualMerchant::Logger.new(response)
    response
  end

  private
  def url(demo)
    if demo
      'https://demo.myvirtualmerchant.com/VirtualMerchantDemo/processxml.do'
    else
      'https://www.myvirtualmerchant.com/VirtualMerchant/processxml.do'
    end
  end
end
