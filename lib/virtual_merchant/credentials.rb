module VirtualMerchant
  class Credentials
    attr_accessor :account_id, :user_id, :pin, :referer, :demo, :source, :ksn,
      :device_type, :vendor_id
    def initialize(info)
      @account_id     = info[:account_id].to_s
      @user_id        = info[:user_id].to_s
      @pin            = info[:pin].to_s
      @source         = info[:source].to_s
      @ksn            = info[:ksn].to_s
      @vendor_id      = info[:vendor_id].to_s
      @device_type    = info[:device_type].to_s
      @referer        = info[:referer].to_s
      @demo           = info[:demo] || false
    end
  end
end
