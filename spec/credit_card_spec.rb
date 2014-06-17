require 'virtual_merchant/credit_card'

describe VirtualMerchant::CreditCard do
  describe "on manual" do
    it "initializes with valid number" do
      cc = VirtualMerchant::CreditCard.new(
        name_on_card: "Lee Quarella",
        number: "1234567812345670",
        expiration: "0513",
        track_2: ";5555555555555555=555555555555555?",
        security_code: "1234")
      cc.valid?.should eq true
    end
  end

  describe "on swipe" do
    it "initializes from a swipe" do
      cc = VirtualMerchant::CreditCard.new(swipe:
        "%B5555555555555555^CARDHOLDER/LEE F^5555555555555555555555555555555?;5555555555555555=555555555555555?")
      cc.valid?.should eq true
    end

  end

  describe "on encrypted" do
      it "initializes from encrypted" do
        track_1 = "474F492133496797C161C26752F61C74E094539003DFE7F70F2F51113C2CA457940157EA7D1449BED4E7CE9AEC1416D9"
        track_2 = "EB442E8F4A9357086AF17D57B6EDFB6D99749F4DD78182FD07D57A343EAC3B1B90DC3F5E26D6505D"
        swipe = {
          encrypted: true,
          track_1: track_1,
          track_2: track_2,
          device_type: "audio",
          last_four:   "1234"}
        cc = VirtualMerchant::CreditCard.new(encrypted: swipe)
        cc.encrypted_track_1.should eq(track_1)
        cc.encrypted_track_2.should eq(track_2)
        cc.last_four.should eq('1234')
      end
  end

  it "can blur the card number" do
    cc = VirtualMerchant::CreditCard.new(
      name_on_card:  "Lee Quarella",
      number:        "1234567812345670",
      expiration:    "0513",
      track_2:       ";5555555555555555=555555555555555?",
      security_code: "1234")
    cc.blurred_number.should eq("12**********5670")
    cc.number.should eq("1234567812345670")
  end

  it "sends *'s for blur of invalid card" do
    cc = VirtualMerchant::CreditCard.new(
      name_on_card:  "Lee Quarella",
      number:        "1234567812",
      expiration:    "0513",
      track_2:       ";5555555555555555=555555555555555?",
      security_code: "1234")
    cc.blurred_number.should eq("****************")
    cc.number.should eq(nil)
  end

  describe "validating" do
    it "gets errors appended when things ain't right" do
      info = {
        name_on_card:  "Lee Quarella",
        number:        "1234",
        expiration:    "0513",
        track_2:       ";5555555555555555=555555555555555?",
        security_code: "1234"}
      expect(VirtualMerchant::UserInput).to receive(:new).with(info)
        .and_return(double('input', {errors: {5000 => "no card"}}))
      VirtualMerchant::CreditCard.new(info)
    end
  end
end
