module VirtualMerchant
  class UserInput
    attr_accessor :errors
    def initialize(user_input)
      @errors = {}
      if user_input[:swipe]
        validate_unencrypted_swipe(user_input[:swipe])
      else
        validate_card_number(user_input[:number])
      end
    end

    def validate_card_number(number)
      unless number && luhn_validate(number.to_s.gsub(/\s+/, ""))
        errors[5000] = "The Credit Card Number supplied in the authorization request appears to be invalid."
      end
    end

    private
      def luhn_validate(number)
        s1 = s2 = 0
        number.to_s.reverse.chars.each_slice(2) do |odd, even|
          s1 += odd.to_i
          double = even.to_i * 2
          double -= 9 if double >= 10
          s2 += double
        end
        (s1 + s2) % 10 == 0
      end

      def validate_unencrypted_swipe(swipe_raw)
        if swipe_raw.index('%') == nil
          @errors[5012] = "The track data sent appears to be invalid."
        end
        validate_track_1 swipe_raw
        validate_track_2 swipe_raw
      end

      def validate_track_1 swipe_raw
        track1 = swipe_raw[1.. swipe_raw.index('?')-1]
        if track1 == nil || track1 == "E"
          @errors[5012] = "The track data sent appears to be invalid."
        end
      end

      def validate_track_2 swipe_raw
        unless swipe_raw.index(';')
          return @errors[5013] = "Transaction requires Track2 data to be sent."
        end
        track2 = swipe_raw[(swipe_raw.index(';') + 1).. swipe_raw.length-2]
        return unless track2 == nil || track2 == "E"
        @errors[5013] = "Transaction requires track 2 data to be sent."
      end
  end
end
