require 'virtual_merchant'

describe VirtualMerchant, "#amount" do
  it "receives a response from VM" do
    creds = VMCredentials.new(
      account_id: 111,
      user_id: 222,
      pin: "abc",
      referer: "https://thisisauri.com")
    cc = VMCreditCard.new(
      name_on_card: "Lee Quarella",
      number: "1234567890123456",
      expiration: "0513",
      security_code: "1234")
    amount = VMAmount.new(total: 10.99)

    response = VirtualMerchant.charge(cc, amount, creds)
    response.should be_an_instance_of VMResponse
  end
end
