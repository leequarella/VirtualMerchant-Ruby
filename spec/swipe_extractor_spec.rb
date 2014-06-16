require 'virtual_merchant/swipe_extractor'

describe VirtualMerchant::SwipeExtractor do
  before(:each) do
    @swipe = "%B5555555555555555^CARDHOLDER/LEE F^5555555555555555555555555555555?;5555555555555555=555555555555555?"
  end

  it "should extract the card number" do
    VirtualMerchant::SwipeExtractor.get_card_number(@swipe).should eq("5555555555555555")
  end

  it "should extract the last four" do
    VirtualMerchant::SwipeExtractor.get_last_four("5555555555555555").should eq("5555")
  end

  it "should extract the expiration" do
    VirtualMerchant::SwipeExtractor.get_expiration(@swipe).should eq("5555")
  end

  it "should extract track2" do
    VirtualMerchant::SwipeExtractor.get_track_2(@swipe).should eq(";5555555555555555=555555555555555?")
  end

  it "should extract the members name" do
    VirtualMerchant::SwipeExtractor.get_name(@swipe).should eq("LEE F CARDHOLDER")
  end
end
