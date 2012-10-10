require 'virtual_merchant/credit_card'

describe VMCreditCard, "#amount" do
  it "initiallizes" do
    cc = VMCreditCard.new(
      name_on_card: "Lee Quarella",
      number: "1234567890123456",
      expiration: "0513",
      security_code: "1234")
    cc.name_on_card.should eq("Lee Quarella")
    cc.number.should eq("1234567890123456")
    cc.expiration.should eq("0513")
    cc.security_code.should eq("1234")
  end
end
