Gem::Specification.new do |s|
  s.name        = 'virtual_merchant'
  s.version     = '0.3.8'
  s.date        = '2014-04-01'
  s.summary     = "Virtual Merchant API"
  s.description = "Makes it easy to charge credit cards with the VirtualMerchant API."
  s.authors     = ["Lee Quarella"]
  s.email       = 'leequarella@gmail.com'
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
