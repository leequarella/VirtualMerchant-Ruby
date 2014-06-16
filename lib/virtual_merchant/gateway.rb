class Gateway
  attr_reader :creds

  def initialize(creds)
    @creds = creds
  end

  def ccsale(card, amount, custom_fields)
    if card.valid?
      xml = VirtualMerchant::XMLGenerator.generate(card, amount, creds, custom_fields, "ccsale")
      process(xml, amount)
    else
      gen_cc_errors(card)
    end
  end

  def ccauth(card, amount, custom_fields)
    if card.valid?
      xml = VirtualMerchant::XMLGenerator.generate(card, amount, creds, custom_fields, "ccauthonly")
      process(xml, amount)
    else
      gen_cc_errors(card)
    end
  end

  def cccomplete(amount, transaction_id)
    xml = VirtualMerchant::XMLGenerator.modify(creds, "cccomplete",
                                               transaction_id, amount)
    process(xml, amount)
  end

  def ccdelete(transaction_id)
    xml = VirtualMerchant::XMLGenerator.modify(creds, "ccdelete", transaction_id)
    process(xml)
  end

  def ccaddrecurring(card, amount, custom_fields)
    if card.valid?
      xml = VirtualMerchant::XMLGenerator.generate(card, amount, creds, custom_fields, "ccaddrecurring")
      process(xml, amount)
    else
      gen_cc_errors(card)
    end
  end

  def cccredit(card, amount, custom_fields)
    if card.valid?
      xml = VirtualMerchant::XMLGenerator.generate(card, amount, creds, custom_fields, 'cccredit')
      process(xml, amount)
    else
      gen_cc_errors(card)
    end
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
    VirtualMerchant::Logger.log_response(response)
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

  def gen_cc_errors(card)
    card.errors.each do |code, msg|
      xml = VirtualMerchant::XMLGenerator.error(code, msg)
      response = VirtualMerchant::Response.new(xml)
      VirtualMerchant::Logger.log_response(response)
      response
    end
  end
end
