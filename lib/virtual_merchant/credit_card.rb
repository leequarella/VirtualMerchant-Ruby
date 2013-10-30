module VirtualMerchant
  class CreditCard
    attr_accessor :name_on_card, :number, :expiration, :security_code, :swipe, :track2,
      :encrypted_track_1, :encrypted_track_2, :ksn, :last_four, :encrypted, :swiped

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
      if info[:encrypted]
        self.from_encrypted(info)
      elsif info[:swipe]
        self.from_swipe(info[:swipe])
      else
        self.from_manual(info)
      end
    end

    def from_encrypted (info)
      @encrypted         = true
      @encrypted_track_1 = info[:track_1]
      @encrypted_track_2 = info[:track_2]
      @ksn               = info[:serial]
      @last_four         = info[:last_four]
    end

    def from_swipe(swipe_raw)
      @swiped       = true
      @swipe        = swipe_raw
      @track2       = extract_track_2(swipe)
      @number       = extract_card_number(swipe)
      @expiration   = extract_expiration(swipe)
      @name_on_card = extract_name(swipe)
      @last_four    = extract_last_four
    end

    def from_manual(info)
      @name_on_card  = info[:name_on_card]                if info[:name_on_card]
      @number        = info[:number].to_s.gsub(/\s+/, "") if info[:number]
      @expiration    = info[:expiration].to_s             if info[:expiration]
      @security_code = info[:security_code].to_s          if info[:security_code]
      @track2        = info[:track_2]                     if info[:track_2]
      @last_four     = extract_last_four
    end

    def encrypted?
      self.encrypted
    end

    def swiped?
      self.swiped
    end

    def extract_card_number(swipe)
      card_number = swipe[2.. swipe.index('^')-1]
      card_number = card_number.split(' ').join('')
    end

    def extract_expiration(swipe)
      secondCarrot = swipe.index("^", swipe.index("^")+1)
      card_expiration_year = swipe[secondCarrot+1..secondCarrot+2]
      card_expiration_month = swipe[(secondCarrot + 3)..(secondCarrot + 4)]
      card_expiration = card_expiration_month.to_s + card_expiration_year.to_s
    end

    def extract_name(swipe)
      secondCarrot = swipe.index("^", swipe.index("^")+1)
      if swipe.index('/')
        first_name_on_card = swipe[swipe.index('/')+1..secondCarrot-1]
        last_name_on_card = swipe[swipe.index('^')+1..swipe.index('/')-1]
      else
        if !swipe.index(" ")
          first_name_on_card = "Gift"
          last_name_on_card = "Card"
        else
          first_name_on_card = swipe.slice(swipe.index('^') + 1, swipe.index(' '))
          last_name_on_card = swipe.slice(swipe.index(" ") + 1, secondCarrot)
        end
      end
      name_on_card = first_name_on_card + " " + last_name_on_card
    end

    def extract_track_2(swipe)
      # Magtek reader:  Track 2 starts with a semi-colon and goes to the end
      # I think that is standard for all readers, but not positive. -LQ
      track2 = swipe.slice(swipe.index(";"), swipe.length)
      if track2.index("+")
        #  Some AMEX have extra stuff at the end of track 2 that causes
        #virtual merchant to return an INVLD DATA5623 message.
        #Soooo... let's slice that off
        track2 = track2.slice(0, track2.index("+"))
      end
      track2
    end

    def extract_last_four
      self.number[(self.number.length - 4)..self.number.length]
    end

   def blurred_number
      number = self.number.to_s
      leng = number.length
      n = number[0..1]
      (leng-6).times {n+= "*"}
      n += number[number.length-4..number.length]
      n
    end
  end
end
