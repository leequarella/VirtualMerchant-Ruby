require 'virtual_merchant/user_input'

describe VirtualMerchant::UserInput do
  describe "Manual Input" do
    let(:valid_input){{
        name_on_card:  "Lee M Cardholder",
        number:        "5000300020003003",
        expiration:    "0515",
        security_code: "1234"}}
    it "takes a valid credit card and adds no errors" do
      valid_data = VirtualMerchant::UserInput.new(valid_input)
      expect(valid_data.errors.count).to eq 0
    end
    it "Reports an error if card number doesn't exist" do
      valid_input[:number] = nil
      valid_data = VirtualMerchant::UserInput.new(valid_input)
      valid_data.errors.count.should eq 1
      expect(valid_data.errors[5000])
        .to eq "The Credit Card Number supplied in the authorization request appears to be invalid."
    end
    it "Reports an error if card number doesn't pass luhn test" do
      valid_input[:number] = '1234'
      valid_data = VirtualMerchant::UserInput.new(valid_input)
      valid_data.errors.count.should eq 1
      expect(valid_data.errors[5000])
        .to eq "The Credit Card Number supplied in the authorization request appears to be invalid."
    end
  end

  describe "Swipe data"
    it "is invalid on no track 1" do
      user_input = VirtualMerchant::UserInput.new(swipe:
        ";5555555555555555=555555555555555?")
      user_input.errors.has_key?(5012).should eq true
    end

    it "reports an error if track 2 is missing" do
      user_input = VirtualMerchant::UserInput.new(swipe:
        "%B5555555555555555^CARDHOLDER/LEE F^5555555555555555555555555555555?")
      user_input.errors.has_key?(5013).should eq true
    end

    it "is invalid on track 1 read error" do
      user_input = VirtualMerchant::UserInput.new(swipe:
        "%E?;5555555555555555=555555555555555?")
      user_input.errors.has_key?(5012).should eq true
    end

    it "is invalid on track 2 read error" do
      user_input = VirtualMerchant::UserInput.new(swipe:
        "%B5555555555555555^CARDHOLDER/LEE F^5555555555555555555555555555555?;E?")
      user_input.errors.has_key?(5013).should eq true
    end
end
