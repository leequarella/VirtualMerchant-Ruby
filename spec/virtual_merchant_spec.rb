require 'virtual_merchant'

##Useful vars ################################################################
  valid_creds = VMCredentials.new(
    account_id: "000046",
    user_id: "000046",
    pin: "4X9PXL",
    referer: "https://thisisauri.com",
    demo: true)
  
  invalid_creds = VMCredentials.new(
    account_id: 111,
    user_id: 222,
    pin: "abc",
    referer: "https://thisisauri.com")
  
  #this is a test card used by VM.  If it appears on any real batch, that entire
  #batch will be invalid.  Use with caution.
  valid_cc = VMCreditCard.new(
    name_on_card: "Lee M Cardholder",
    number: "5000300020003003",
    expiration: "0513",
    security_code: "1234")
    
  invalid_cc = VMCreditCard.new(
    name_on_card: "Lee M Cardholder",
    number: "1234567890123456",
    expiration: "0513",
    security_code: "1234")
  
  amount = VMAmount.new(total: 10.99)
##Useful vars ################################################################

describe VirtualMerchant, "#amount" do
  it "receives a response from VM" do
    response = VirtualMerchant.charge(invalid_cc, amount, invalid_creds)
    response.should be_an_instance_of VMResponse
    response.approved.should be_false
  end

  it "refunds a card" do
    response = VirtualMerchant.refund(valid_cc, amount, valid_creds)
    response.should be_an_instance_of VMResponse
  end
end
