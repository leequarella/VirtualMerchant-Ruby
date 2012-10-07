Gem::Specification.new do |s|
  s.name        = 'virtual_merchant'
  s.version     = '0.0.2'
  s.date        = '2012-10-07'
  s.summary     = "Virtual Merchant API"
  s.description = "Makes it easy to charge credit cards with the VirtualMerchant API."
  s.authors     = ["Lee Quarella"]
  s.email       = 'lee@lucidfrog.com'
  s.files       = ["lib/virtual_merchant.rb",
                   "lib/virtual_merchant/amount.rb",
                   "lib/virtual_merchant/credentials.rb",
                   "lib/virtual_merchant/credit_card.rb",
                   "lib/virtual_merchant/response.rb"]
  s.homepage    = 'https://github.com/leequarella/VirtualMerchant-Ruby'
end
