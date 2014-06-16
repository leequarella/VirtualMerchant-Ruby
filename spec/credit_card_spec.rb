require 'virtual_merchant/credit_card'

describe VirtualMerchant::CreditCard do
  describe "on manual" do
    it "initializes with valid number" do
      cc = VirtualMerchant::CreditCard.from_manual(
        name_on_card: "Lee Quarella",
        number: "1234567812345670",
        expiration: "0513",
        track_2: ";5555555555555555=555555555555555?",
        security_code: "1234")
      cc.valid?.should eq true
    end

    it "is invalid without a number" do
      cc = VirtualMerchant::CreditCard.from_manual(
        name_on_card: "Lee Quarella",
        expiration: "0513",
        track_2: ";5555555555555555=555555555555555?",
        security_code: "1234")
      cc.valid?.should eq false
      cc.errors.has_key?(5000).should eq true
    end

    it "is invalid with invalid number" do
      cc = VirtualMerchant::CreditCard.from_manual(
        name_on_card: "Lee Quarella",
        number: "1234567890123456",
        expiration: "0513",
        track_2: ";5555555555555555=555555555555555?",
        security_code: "1234")
      cc.valid?.should eq false
      cc.errors.has_key?(5000).should eq true
    end
  end

  describe "on swipe" do
    it "initializes from a swipe" do
      cc = VirtualMerchant::CreditCard.from_swipe(
        "%B5555555555555555^CARDHOLDER/LEE F^5555555555555555555555555555555?;5555555555555555=555555555555555?")
      cc.valid?.should eq true
    end

    it "is invalid on no track 1" do
      cc = VirtualMerchant::CreditCard.from_swipe(
        ";5555555555555555=555555555555555?")
      cc.valid?.should eq false
      cc.errors.has_key?(5012).should eq true
    end

    it "is invalid on no track 2" do
      cc = VirtualMerchant::CreditCard.from_swipe(
        "%B5555555555555555^CARDHOLDER/LEE F^5555555555555555555555555555555?")
      cc.valid?.should eq false
      cc.errors.has_key?(5013).should eq true
    end

    it "is invalid on track 1 read error" do
      cc = VirtualMerchant::CreditCard.from_swipe(
        "%E?;5555555555555555=555555555555555?")
      cc.valid?.should eq false
      cc.errors.has_key?(5012).should eq true
    end

    it "is invalid on track 2 read error" do
      cc = VirtualMerchant::CreditCard.from_swipe(
        "%B5555555555555555^CARDHOLDER/LEE F^5555555555555555555555555555555?;E?")
      cc.valid?.should eq false
      cc.errors.has_key?(5013).should eq true
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
        cc = VirtualMerchant::CreditCard.from_swipe(swipe)
        cc.encrypted_track_1.should eq(track_1)
        cc.encrypted_track_2.should eq(track_2)
        cc.last_four.should eq('1234')
      end
  end

  it "can blur the card number" do
    cc = VirtualMerchant::CreditCard.from_manual(
      name_on_card: "Lee Quarella",
      number: "1234567812345670",
      expiration: "0513",
      track_2: ";5555555555555555=555555555555555?",
      security_code: "1234")
    cc.blurred_number.should eq("12**********5670")
    cc.number.should eq("1234567812345670")
  end
end
