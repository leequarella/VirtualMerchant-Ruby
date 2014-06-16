require 'virtual_merchant/swipe_extractor'
require 'virtual_merchant/user_input'
module VirtualMerchant
  class CreditCard
    attr_accessor :name_on_card, :number, :expiration, :security_code, :swipe, :track2,
      :encrypted_track_1, :encrypted_track_2, :last_four, :encrypted, :swiped, :valid,
      :errors

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
      check_for_errors(info)
      return unless valid?
      if info[:encrypted]
        from_encrypted(info)
      elsif info[:swipe]
        from_unencrypted_swipe(info[:swipe])
      else
        from_manual(info)
      end
    end

    def check_for_errors info
      @errors = VirtualMerchant::UserInput.new(info).errors
    end

    def encrypted?
      self.encrypted
    end

    def swiped?
      self.swiped
    end

    def valid?
      errors.count == 0
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

    private
      def from_encrypted (info)
        @encrypted         = true
        @encrypted_track_1 = info[:track_1]
        @encrypted_track_2 = info[:track_2]
        @last_four         = info[:last_four]
      end

      def from_unencrypted_swipe(swipe_raw)
        build_card_from swipe_raw if valid?
      end

      def build_card_from swipe
        @swiped       = true
        @swipe        = swipe
        @track2       = SwipeExtractor.get_track_2(swipe)
        @number       = SwipeExtractor.get_card_number(swipe)
        @expiration   = SwipeExtractor.get_expiration(swipe)
        @name_on_card = SwipeExtractor.get_name(swipe)
        @last_four    = SwipeExtractor.get_last_four(@number)
      end

      def from_manual(info)
        @name_on_card  = info[:name_on_card]                if info[:name_on_card]
        @number        = info[:number].to_s.gsub(/\s+/, "")
        @expiration    = info[:expiration].to_s             if info[:expiration]
        @security_code = info[:security_code].to_s          if info[:security_code]
        @track2        = info[:track_2]                     if info[:track_2]
        @last_four     = SwipeExtractor.get_last_four(@number)
      end
  end
end
