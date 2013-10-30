require 'virtual_merchant/credit_card'

describe VirtualMerchant::CreditCard do
  it "initializes" do
    cc = VirtualMerchant::CreditCard.from_manual(
      name_on_card: "Lee Quarella",
      number: "1234567890123456",
      expiration: "0513",
      track_2: ";5555555555555555=555555555555555?",
      security_code: "1234")
    cc.name_on_card.should eq("Lee Quarella")
    cc.number.should eq("1234567890123456")
    cc.expiration.should eq("0513")
    cc.security_code.should eq("1234")
    cc.track2.should eq(";5555555555555555=555555555555555?")
  end

  it "initializes from a swipe" do
    cc = VirtualMerchant::CreditCard.from_swipe(
      "%B5555555555555555^CARDHOLDER/LEE F^5555555555555555555555555555555?;5555555555555555=555555555555555?")
    cc.name_on_card.should eq("LEE F CARDHOLDER")
    cc.number.should eq("5555555555555555")
    cc.expiration.should eq("5555")
    cc.track2.should eq(";5555555555555555=555555555555555?")
  end

  it "initializes from encrypted" do
      ksn  = "2F9CFB042D001600"
      track_1 = "474F492133496797C161C26752F61C74E094539003DFE7F70F2F51113C2CA457940157EA7D1449BED4E7CE9AEC1416D9"
      track_2 = "EB442E8F4A9357086AF17D57B6EDFB6D99749F4DD78182FD07D57A343EAC3B1B90DC3F5E26D6505D"
    swipe = {
      encrypted: true,
      ksn:     ksn,
      track_1: track_1,
      track_2: track_2,
      device_type: "audio",
      last_four:   "1234"}
    cc = VirtualMerchant::CreditCard.from_swipe(swipe)
    cc.encrypted_track_1.should eq(track_1)
    cc.encrypted_track_2.should eq(track_2)
    cc.ksn.should eq(ksn)
    cc.last_four.should eq('1234')
  end

  it "can blur the card number" do
    cc = VirtualMerchant::CreditCard.from_manual(
      name_on_card: "Lee Quarella",
      number: "1234567890123456",
      expiration: "0513",
      track_2: ";5555555555555555=555555555555555?",
      security_code: "1234")
    cc.blurred_number.should eq("12**********3456")
    cc.number.should eq("1234567890123456")
  end
end
