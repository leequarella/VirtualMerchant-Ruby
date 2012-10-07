A gem from processing credit cards with VirtualMerchant's API.


```ruby
    #Create CreditCard via manual entry
    cc = CreditCard.new(
      name_on_card: <name_on_card>,
      number: <card_number>,
      expiration: <card_exp>,
      security_code: <cvv2>)

    # OR
    # via MSR
    cc = CreditCard.new(
      swipe: <swipe_data>)

    amount = VMAmount.new(
      total: <total amount to charge>,
      tax: <amount of tax included in the total, optional>)

    creds = VMCredentials.new(
      merchant_id: <vm_account_id>,
      user_id: <vm_user_id>,
      pin: <vm_user_pass>,
      demo: <boolean, optional>,
      referer: <uri of the http referer, optional>)

    response = VirtualMerchant.charge(cc, amount, creds)
```


