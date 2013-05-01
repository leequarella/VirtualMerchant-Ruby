require 'virtual_merchant/credit_card'

describe VirtualMerchant::CreditCard, "#amount" do
  it "initiallizes" do
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

  it "initiallizes from a swipe" do
    cc = VirtualMerchant::CreditCard.from_swipe(
      "%B5555555555555555^CARDHOLDER/LEE F^5555555555555555555555555555555?;5555555555555555=555555555555555?")
    cc.name_on_card.should eq("LEE F CARDHOLDER")
    cc.number.should eq("5555555555555555")
    cc.expiration.should eq("5555")
    cc.track2.should eq(";5555555555555555=555555555555555?")
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
