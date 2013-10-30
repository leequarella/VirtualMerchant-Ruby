module VirtualMerchant
  class Amount
    attr_accessor :total, :tax, :next_payment_date, :billing_cycle, :end_of_month

    def initialize(info)
      @total = sprintf( "%0.02f", info[:total])
      if info[:tax]
        @tax = sprintf( "%0.02f", info[:tax])
      else
        @tax = "0.00"
      end
      @next_payment_date = info[:next_payment_date]
      @billing_cycle = info[:billing_cycle]
      @end_of_month = info[:end_of_month] || 'Y'
    end
  end
end
