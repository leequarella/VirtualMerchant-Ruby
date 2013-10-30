require 'virtual_merchant/credentials'

describe VirtualMerchant::Credentials, "#amount" do
  it "initiallizes" do
    ksn  = "2F9CFB042D001600"
    creds = VirtualMerchant::Credentials.new(
      account_id: 111,
      user_id: 222,
      pin: "abc",
      source: 'DERP',
      ksn:  ksn,
      referer: "https://thisisauri.com")
    creds.account_id.should eq("111")
    creds.user_id.should eq("222")
    creds.pin.should eq("abc")
    creds.referer.should eq("https://thisisauri.com")
    creds.demo.should be_false
    creds.source.should eq('DERP')
    creds.ksn.should eq(ksn)
  end
end
