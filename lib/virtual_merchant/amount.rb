class VMAmount
  attr_accessor :total, :tax

  def initialize(info)
    @total = info[:total].to_s
    @tax = info[:tax].to_s || "0.00"
  end
end
