Gem::Specification.new do |s|
  s.name        = 'virtual_merchant'
  s.version     = '0.3.3'
  s.date        = '2012-11-02'
  s.summary     = "Virtual Merchant API"
  s.description = "Makes it easy to charge credit cards with the VirtualMerchant API."
  s.authors     = ["Lee Quarella"]
  s.email       = 'lee@lucidfrog.com'
  s.license     = 'MIT'
  s.files       = ["lib/virtual_merchant.rb",
                   "lib/virtual_merchant/amount.rb",
                   "lib/virtual_merchant/communication.rb",
                   "lib/virtual_merchant/credentials.rb",
                   "lib/virtual_merchant/credit_card.rb",
                   "lib/virtual_merchant/logger.rb",
                   "lib/virtual_merchant/response.rb",
                   "lib/virtual_merchant/xml_generator.rb",
                   "lib/virtual_merchant/gateway.rb"]
  s.homepage    = 'https://github.com/leequarella/VirtualMerchant-Ruby'
end
