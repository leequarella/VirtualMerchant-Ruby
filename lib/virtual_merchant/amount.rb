module VirtualMerchant
  class Amount
    attr_accessor :total, :tax
  
    def initialize(info)
      @total = sprintf( "%0.02f", info[:total])
      if info[:tax]
        @tax = sprintf( "%0.02f", info[:tax])
      else
        @tax = "0.00"
      end
    end
  end
end
