require 'virtual_merchant/amount'

describe VirtualMerchant::Amount, "#amount" do
  it "initiallizes" do
    amount = VirtualMerchant::Amount.new(total: 10.99)
    amount.total.should eq("10.99")
    amount.tax.should eq("0.00")
  end

  it "sets values passed as float to string with 2 decimals" do
    amount = VirtualMerchant::Amount.new(total: 10.9, tax: 0.1)
    amount.total.should eq("10.90")
    amount.tax.should eq("0.10")
  end

  it "accepts decimals passed as strings" do
    amount = VirtualMerchant::Amount.new(total: "10.99", tax: "0.10")
    amount.total.should eq("10.99")
    amount.tax.should eq("0.10")
  end

  it "initializes with recurring data" do
    amount = VirtualMerchant::Amount.new(total: 10.99, next_payment_date: '10/30/2013',
                                        billing_cycle: 'MONTHLY')
    amount.total.should eq("10.99")
    amount.tax.should eq("0.00")
    amount.next_payment_date.should eq("10/30/2013")
    amount.billing_cycle.should eq("MONTHLY")
    amount.end_of_month.should eq("Y")
  end
end
