module VirtualMerchant
  class SwipeExtractor
    def self.get_card_number(swipe)
      card_number = swipe[2.. swipe.index('^')-1]
      card_number = card_number.split(' ').join('')
    end

    def self.get_expiration(swipe)
      secondCarrot = swipe.index("^", swipe.index("^")+1)
      card_expiration_year = swipe[secondCarrot+1..secondCarrot+2]
      card_expiration_month = swipe[(secondCarrot + 3)..(secondCarrot + 4)]
      card_expiration = card_expiration_month.to_s + card_expiration_year.to_s
    end

    def self.get_name(swipe)
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

    def self.get_track_2(swipe)
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

    def self.get_last_four(number)
      number[(number.length - 4)..number.length]
    end
  end
end
