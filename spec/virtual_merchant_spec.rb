require 'spec_helper'
require 'virtual_merchant'

##Useful vars ################################################################
  valid_creds = VirtualMerchant::Credentials.new(
    account_id: "002602",
    user_id:    "002602",
    pin:        "1YURP7",
    referer:    "https://thisisauri.com",
    demo:       true)

  invalid_creds = VirtualMerchant::Credentials.new(
    account_id: 111,
    user_id:    222,
    pin:        "abc",
    referer:    "https://thisisauri.com")

  #this is a test card used by VM.  If it appears on any real batch, that entire
  #batch will be invalid.  Use with caution.
  valid_cc = VirtualMerchant::CreditCard.new(
    name_on_card:  "Lee M Cardholder",
    number:        "5000300020003003",
    expiration:    "0515",
    security_code: "1234")

  invalid_cc = VirtualMerchant::CreditCard.new(
    name_on_card:  "Lee M Cardholder",
    number:        "1234567890123456",
    expiration:    "0513",
    security_code: "1234")

  #serial  = "2F9CFB042D001600"
  #track_1 = "474F492133496797C161C26752F61C74E094539003DFE7F70F2F51113C2CA457940157EA7D1449BED4E7CE9AEC1416D9"
  #track_2 = "EB442E8F4A9357086AF17D57B6EDFB6D99749F4DD78182FD07D57A343EAC3B1B90DC3F5E26D6505D"
  #encrypted_cc = VirtualMerchant::CreditCard.from_swipe({
  #  encrypted: true,
  #  serial:  serial,
  #  track_1: track_1,
  #  track_2: track_2,
  #  device_type: "audio",
  #  last_four:   "1234"})

  amount            = VirtualMerchant::Amount.new(total: 0.01)

  approval_xml      = File.read("spec/support/approval_response.xml")
  bad_approval_xml  = File.read("spec/support/bad_approval_response.xml")
  error_xml         = File.read("spec/support/error_response.xml")
  declined_void_xml = File.read("spec/support/declined_void_response.xml")
##Useful vars ################################################################

describe VirtualMerchant, vcr: true do
  it "Talks to Virtual Merchant" do
    response = VirtualMerchant.charge(invalid_cc, amount, invalid_creds)
    response.should_not be_approved
  end

  context "no connection to VM", vcr: false do
    it "generates an error response" do
      stub_request(:any, "demo.myvirtualmerchant.com")
        .to_raise(StandardError)
      response = VirtualMerchant.charge(valid_cc, amount, valid_creds)
      response.should_not be_approved
    end
  end

  describe "Charging a card" do
    context "Manual entry" do
      context "Happy Approval" do
        it "generates an approval response" do
          response = VirtualMerchant.charge(valid_cc, amount, valid_creds)
          response.should be_approved
        end
      end
      context "Un-Happy Approval", vcr: false do
        it "generates an error response" do
          stub_request(:any, "demo.myvirtualmerchant.com")
            .with(body: bad_approval_xml)
          response = VirtualMerchant.charge(valid_cc, amount, valid_creds)
          response.should_not be_approved
        end
      end
      context "Straight error response" do
        it "generates an error response" do
          response = VirtualMerchant.charge(invalid_cc, amount, valid_creds)
          response.should be_an_instance_of VirtualMerchant::Response
          response.should_not be_approved
        end
      end
    end

    context "encrypted swipe" do
    end
  end

  describe "Refunding a card" do
    context "Happy Approval" do
      it "generates an approval response" do
        response = VirtualMerchant.refund(valid_cc, amount, valid_creds)
        response.should be_approved
      end
    end
    context "Un-Happy Approval", vcr: false do
      it "generates an error response" do
        stub_request(:any, "demo.myvirtualmerchant.com")
          .with(body: bad_approval_xml)
        response = VirtualMerchant.refund(valid_cc, amount, valid_creds)
        response.should_not be_approved
      end
    end
    context "Straight error response" do
      it "generates an error response" do
        response = VirtualMerchant.refund(invalid_cc, amount, valid_creds)
        response.should_not be_approved
      end
    end
  end

  describe "Voiding a card" do
    context "successful void" do
      it "generates an approval response" do
        response = VirtualMerchant.charge(valid_cc, amount, valid_creds)
        response = VirtualMerchant.void(response.transaction_id, valid_creds)
        response.should be_approved
      end
    end
    context "failed void" do
      it "generates an error response" do
        response = VirtualMerchant.void(123, valid_creds)
        response.should_not be_approved
      end
    end
  end
end
