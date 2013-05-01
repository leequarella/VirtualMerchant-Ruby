require 'spec_helper'
require 'virtual_merchant/communication'

describe VirtualMerchant::Communication, vcr: true do
  before :each do
    @xml = File.read("spec/support/sending.xml")
    @url = 'https://demo.myvirtualmerchant.com/VirtualMerchantDemo/processxml.do'
    @http_referer = 'https://somereferer.com'
    @sender = VirtualMerchant::Communication.new({xml: @xml, url: @url, http_referer: @http_referer})
  end

  it "gets initialiazed with xml to send, a url to send to, and an optional referer" do
    @sender.xml.should eq @xml
    @sender.url.should eq @url
    @sender.http_referer.should eq @http_referer
  end

  it "parses the string url into a uri object" do
    @sender.uri.should be_an_instance_of URI::HTTPS
  end

  describe "talking to VM", vcr: true do
    context "successful communication" do
      it "returns the xml string sent back by VM" do
        body = @sender.send
        body.class.should eq String
      end
    end

    context "failed communication" do
      it "returns false" do
        bad_url = "junk_url"
        sender = VirtualMerchant::Communication.new({xml: @xml, url: bad_url, http_referer: {}})
        sender.send.should be_false
      end
    end
  end
end
