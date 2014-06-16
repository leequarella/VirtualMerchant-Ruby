require 'virtual_merchant/swipe_extractor'
module VirtualMerchant
  class CreditCard
    attr_accessor :name_on_card, :number, :expiration, :security_code, :swipe, :track2,
      :encrypted_track_1, :encrypted_track_2, :last_four, :encrypted, :swiped, :valid, :errors

    def self.from_swipe(swipe)
      if swipe.class == Hash && swipe[:encrypted]
        new(swipe)
      else
        new(swipe: swipe)
      end
    end

    def self.from_manual(data)
      new(data)
    end

    def initialize(info)
      @errors = {}
      if info[:encrypted]
        self.from_encrypted(info)
      elsif info[:swipe]
        self.from_swipe(info[:swipe])
      else
        self.from_manual(info)
      end
    end

    def from_encrypted (info)
      @errors            = {}
      @encrypted         = true
      @encrypted_track_1 = info[:track_1]
      @encrypted_track_2 = info[:track_2]
      @last_four         = info[:last_four]
    end

    def from_swipe(swipe_raw)
      @errors = {}
      if check_swipe(swipe_raw)
        @valid        = true
        @swiped       = true
        @swipe        = swipe_raw
        @track2       = SwipeExtractor.get_track_2(swipe)
        @number       = SwipeExtractor.get_card_number(swipe)
        @expiration   = SwipeExtractor.get_expiration(swipe)
        @name_on_card = SwipeExtractor.get_name(swipe)
        @last_four    = SwipeExtractor.get_last_four(@number)
      else
        @valid = false
      end
    end

    def from_manual(info)
      @errors = {}
      if info[:number] && check_luhn(info[:number].to_s.gsub(/\s+/, ""))
        @name_on_card  = info[:name_on_card]                if info[:name_on_card]
        @number        = info[:number].to_s.gsub(/\s+/, "")
        @expiration    = info[:expiration].to_s             if info[:expiration]
        @security_code = info[:security_code].to_s          if info[:security_code]
        @track2        = info[:track_2]                     if info[:track_2]
        @last_four     = SwipeExtractor.get_last_four(@number)
        @valid = true
      else
        errors[5000] = "The Credit Card Number supplied in the authorization request appears to be invalid."
        @valid = false
      end
    end

    def encrypted?
      self.encrypted
    end

    def swiped?
      self.swiped
    end

    def valid?
      self.valid
    end

    def check_swipe(swipe_raw)
      if swipe_raw.index('%') == nil
        @errors[5012] = "The track data sent appears to be invalid."
        return false
      end
      if swipe_raw.index(';') == nil
        @errors[5013] = "Transaction requires Track2 data to be sent."
        return false
      end
      track1 = swipe_raw[1.. swipe_raw.index('?')-1]
      if track1 == nil || track1 == "E"
        @errors[5012] = "The track data sent appears to be invalid."
        return false
      end
      track2 = swipe_raw[swipe_raw.index(';')+1.. swipe_raw.length-2]
      if track2 == nil || track2 == "E"
        @errors[5013] = "Transaction requires Track2 data to be sent."
        return false
      end
      return true
    end

    def check_luhn(code)
      s1 = s2 = 0
      code.to_s.reverse.chars.each_slice(2) do |odd, even|
        s1 += odd.to_i
        double = even.to_i * 2
        double -= 9 if double >= 10
        s2 += double
      end
      (s1 + s2) % 10 == 0
    end

   def blurred_number
     begin
       number = self.number.to_s
       leng = number.length
       n = number[0..1]
       (leng-6).times {n+= "*"}
       n += number[number.length-4..number.length]
       n
     rescue Exception => e
       puts "-"
       puts "Error in VirtualMerchant-Ruby Gem when trying to blur card number: #{e}."
       puts "You either passed a nil value for card_number or a number that is too short."
       puts caller
       puts "-"
     end
    end
  end
end
