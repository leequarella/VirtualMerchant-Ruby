require 'virtual_merchant/credentials'

describe VirtualMerchant::Credentials, "#amount" do
  it "initiallizes" do
    ksn  = "2F9CFB042D001600"
    creds = VirtualMerchant::Credentials.new(
      account_id:      111,
      user_id:         222,
      pin:            "abc",
      source:         'DERP',
      ksn:             ksn,
      vendor_id:      'HERP',
      device_type:    '003',
      referer:        "https://thisisauri.com")
    creds.account_id.should eq("111")
    creds.user_id.should eq("222")
    creds.pin.should eq("abc")
    creds.referer.should eq("https://thisisauri.com")
    creds.demo.should eq false
    creds.source.should eq('DERP')
    creds.ksn.should eq(ksn)
    creds.device_type.should eq('003')
    creds.vendor_id.should eq('HERP')
  end
end
