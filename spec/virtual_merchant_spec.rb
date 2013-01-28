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

  approval_xml = File.read("spec/support/approval_response.xml")
  bad_approval_xml = File.read("spec/support/bad_approval_response.xml")
  error_xml = File.read("spec/support/error_response.xml")
  declined_void_xml = File.read("spec/support/declined_void_response.xml")
##Useful vars ################################################################

describe VirtualMerchant do
  it "Talks to Virtual Merchant" do
    response = VirtualMerchant.charge(invalid_cc, amount, invalid_creds)
    response.should be_an_instance_of VirtualMerchant::Response
    response.approved.should be_false
  end

  it "generates an error response if VM crapped out" do
    VirtualMerchant::Communication.any_instance
      .stub(:send).and_return(false)
    response = VirtualMerchant.charge(valid_cc, amount, valid_creds)
    response.should be_an_instance_of VirtualMerchant::Response
    response.approved.should be_false
  end


  describe "Charging a card" do
    context "Happy Approval" do
      it "generates an approval response" do
        VirtualMerchant::Communication.any_instance
          .stub(:send).and_return(approval_xml)
        response = VirtualMerchant.charge(valid_cc, amount, valid_creds)
        response.should be_an_instance_of VirtualMerchant::Response
        response.approved.should be_true
      end
    end
    context "Un-Happy Approval" do
      it "generates an error response" do
        VirtualMerchant::Communication.any_instance
          .stub(:send).and_return(bad_approval_xml)
        response = VirtualMerchant.charge(valid_cc, amount, valid_creds)
        response.should be_an_instance_of VirtualMerchant::Response
        response.approved.should be_false
      end
    end
    context "Straight error response" do
      it "generates an error response" do
        VirtualMerchant::Communication.any_instance
          .stub(:send).and_return(error_xml)
        response = VirtualMerchant.charge(invalid_cc, amount, valid_creds)
        response.should be_an_instance_of VirtualMerchant::Response
        response.approved.should be_false
      end
    end
  end

  describe "Refunding a card" do
    context "Happy Approval" do
      it "generates an approval response" do
        VirtualMerchant::Communication.any_instance
          .stub(:send).and_return(approval_xml)
        response = VirtualMerchant.refund(valid_cc, amount, valid_creds)
        response.should be_an_instance_of VirtualMerchant::Response
        response.approved.should be_true
      end
    end
    context "Un-Happy Approval" do
      it "generates an error response" do
        VirtualMerchant::Communication.any_instance
          .stub(:send).and_return(bad_approval_xml)
        response = VirtualMerchant.refund(valid_cc, amount, valid_creds)
        response.should be_an_instance_of VirtualMerchant::Response
        response.approved.should be_false
      end
    end
    context "Straight error response" do
      it "generates an error response" do
        VirtualMerchant::Communication.any_instance
          .stub(:send).and_return(error_xml)
        response = VirtualMerchant.refund(invalid_cc, amount, valid_creds)
        response.should be_an_instance_of VirtualMerchant::Response
        response.approved.should be_false
      end
    end
  end

  describe "Voiding a card" do
    context "successful void" do
      xit "generates an approval response" do
        response = VirtualMerchant.charge(valid_cc, amount, valid_creds)
        response = VirtualMerchant.void(response.transaction_id, valid_creds)
        response.should be_an_instance_of VirtualMerchant::Response
        response.approved.should be_true
      end
    end
    context "failed void" do
      it "generates an error response" do
        VirtualMerchant::Communication.any_instance
          .stub(:send).and_return(declined_void_xml)
        response = VirtualMerchant.void(123, valid_creds)
        response.should be_an_instance_of VirtualMerchant::Response
        response.approved.should be_false
      end
    end
  end
end
