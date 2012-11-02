require 'virtual_merchant/credentials'

describe VirtualMerchant::Credentials, "#amount" do
  it "initiallizes" do
    creds = VirtualMerchant::Credentials.new(
      account_id: 111,
      user_id: 222,
      pin: "abc",
      referer: "https://thisisauri.com")
    creds.account_id.should eq("111")
    creds.user_id.should eq("222")
    creds.pin.should eq("abc")
    creds.referer.should eq("https://thisisauri.com")
    creds.demo.should be_false
  end
end
