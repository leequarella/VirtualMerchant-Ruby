require 'virtual_merchant/amount'

describe VMAmount, "#amount" do
  it "initiallizes" do
    amount = VMAmount.new(total: 10.99)
    amount.total.should eq("10.99")
    amount.tax.should eq("0.00")
  end

  it "sets tax passed as float to string with 2 decimals" do
    amount = VMAmount.new(total: 10.99, tax: 0.1)
    amount.total.should eq("10.99")
    amount.tax.should eq("0.10")
  end

  it "sets tax passed as string" do
    amount = VMAmount.new(total: 10.99, tax: "0.10")
    amount.total.should eq("10.99")
    amount.tax.should eq("0.10")
  end
end
