require 'virtual_merchant'

##Useful vars ################################################################
  valid_creds = VirtualMerchant::Credentials.new(
    account_id: "000309",
    user_id: "000309",
    pin: "ZNXBPG",
    referer: "https://thisisauri.com",
    demo: true)
  
  invalid_creds = VirtualMerchant::Credentials.new(
    account_id: 111,
    user_id: 222,
    pin: "abc",
    referer: "https://thisisauri.com")
  
  #this is a test card used by VM.  If it appears on any real batch, that entire
  #batch will be invalid.  Use with caution.
  valid_cc = VirtualMerchant::CreditCard.new(
    name_on_card: "Lee M Cardholder",
    number: "5000300020003003",
    expiration: "0513",
    security_code: "1234")
    
  invalid_cc = VirtualMerchant::CreditCard.new(
    name_on_card: "Lee M Cardholder",
    number: "1234567890123456",
    expiration: "0513",
    security_code: "1234")
  
  amount = VirtualMerchant::Amount.new(total: 0.01)
##Useful vars ################################################################

describe VirtualMerchant, "#amount" do
  it "Talks to Virtual Merchant" do
    response = VirtualMerchant.charge(invalid_cc, amount, invalid_creds)
    response.should be_an_instance_of VirtualMerchant::Response
    response.approved.should be_false
  end

  describe "Charging a card" do
    context "Happy Approval" do
      it "generates an approval response" do
        approval_xml = File.read("spec/support/approval_response.xml")
        VirtualMerchant.stub!(:sendXMLtoVirtualMerchant).and_return(approval_xml)
        response = VirtualMerchant.charge(valid_cc, amount, valid_creds)
        response.should be_an_instance_of VirtualMerchant::Response
        response.approved.should be_true
      end
    end
    context "Un-Happy Approval" do
      it "generates an error response" do
        approval_xml = File.read("spec/support/bad_approval_response.xml")
        VirtualMerchant.stub!(:sendXMLtoVirtualMerchant).and_return(approval_xml)
        response = VirtualMerchant.charge(valid_cc, amount, valid_creds)
        response.should be_an_instance_of VirtualMerchant::Response
        response.approved.should be_false
      end
    end
    context "Straight error response" do
      it "generates an error response" do
        error_xml = File.read("spec/support/error_response.xml")
        VirtualMerchant.stub!(:sendXMLtoVirtualMerchant).and_return(error_xml)
        response = VirtualMerchant.charge(invalid_cc, amount, valid_creds)
        response.should be_an_instance_of VirtualMerchant::Response
        response.approved.should be_false
      end
    end
  end

  it "refunds a card" do
    response = VirtualMerchant.refund(valid_cc, amount, valid_creds)
    response.should be_an_instance_of VirtualMerchant::Response
  end

  it "voids a transaction" do
    response = VirtualMerchant.charge(invalid_cc, amount, invalid_creds)
    response = VirtualMerchant.void(response.transaction_id, valid_creds)
    response.should be_an_instance_of VirtualMerchant::Response
  end
end
