require "virtual_merchant/response"

approval_xml = File.read("spec/support/approval_response.xml")
bad_approval_xml = File.read("spec/support/bad_approval_response.xml")
error_xml = File.read("spec/support/error_response.xml")
declined_void_xml = File.read("spec/support/declined_void_response.xml")

describe VirtualMerchant::Response do
  it 'initializes from a happy approval xml string' do
    response = VirtualMerchant::Response.new(approval_xml)
    response.approval_code.should eq "4444"
    response.approved.should be_true
    response.cvv2_response.should be_nil
    response.blurred_card_number.should eq "50**********3003"
    response.exp_date.should eq "0513"
    response.result_message.should eq "APPROVAL"
    response.result.should eq "0"
    response.transaction_id.should eq "AA49315-6E6EB901-763A-4D7B-9671-B33DDEBEF52D"
    response.transaction_time.should eq "01/25/2013 11:15:47 AM"
  end

  it "initializes from an unhappy approval xml string" do
    response = VirtualMerchant::Response.new(bad_approval_xml)
    response.approved.should be_false
    response.result_message.should eq "CALL AUTH CENTER"
    response.error.should eq "1"
  end

  it "initializes from an error xml string" do
    response = VirtualMerchant::Response.new(error_xml)
    response.approved.should be_false
    response.result_message.should eq( 
      "The Credit Card Number supplied in the authorization request appears to be invalid.")
    response.error.should eq "5000"
  end

  it "initializes from a 'false' param" do
    response = VirtualMerchant::Response.new(false)
    response.approved.should be_false
    response.result_message.should eq "VirtualMerchant did not respond."
    response.error.should eq "-1"
  end
end
