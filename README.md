A gem for processing credit cards with VirtualMerchant's API.

## Setup

Add it to your Gemfile then run `bundle` to install it.

```ruby
gem "virtual_merchant"
```


## Usage
###Create Virtual Merchant Objects
```ruby
    #Create CreditCard via manual entry
    cc = VirtualMerchant::CreditCard.from_manual(
      name_on_card:  <name_on_card>,
      number:        <card_number>,
      expiration:    <card_exp>,
      security_code: <cvv2>)

    # OR
    # via unencrypted MSR
    cc = VirtualMerchant::CreditCard.from_swipe(<swipe_data>)

    # OR
    # via encrypted MSR
    cc = VirtualMerchant::CreditCard.from_swipe(
      encrypted: true,
      track_1:   <encrypted_track_1>,
      track_2:   <encrypted_track_2>,
      last_four: <last_four>

    amount = VirtualMerchant::Amount.new(
      total:             <total amount to charge>,
      tax:               <amount of tax included in the total, optional>,
      next_payment_date: <'MM/DD/YYYY', required for recurring payments>,
      billing_cycle:     <'WEEKLY/MONTHLY', required for recurring payments>,
      end_of_month:      <'Y/N', required for recurring payments occuring on
                           last day of month>)

    creds = VirtualMerchant::Credentials.new(
      account_id: <vm_account_id>,
      user_id:    <vm_user_id>,
      pin:        <vm_user_pass>,
      source:     <vm_mobile_source>,
      ksn:        <ksn>,
      demo:       <boolean, optional>,
      referer:    <uri of the http referer, optional>)
```

###Charge, Refund, or Void
```ruby
    #Charge
    response = VirtualMerchant.charge(cc, amount, creds)

    #Add Recurring Payment
    response = VirtualMerchant.add_recurring(cc, amount, creds)

    #Refund
    response = VirtualMerchant.refund(cc, amount, creds)

    #Void
    response = VirtualMerchant.void(transaction_id, creds)
```

The response returned is a VirtualMerchant::Response object.

If the transaction was sucessful and the card was approved, the response will have the following attrs:

    * result_type: "approval"
    * result_message: ssl_result_message
    * result: ssl_result
    * approval_code: ssl_approval_code
    * blurred_card_number: ssl_card_number
    * exp_date: ssl_exp_date
    * cvv2_response: ssl_cvv2_response
    * transaction_id: ssl_txn_id
    * transaction_time: ssl_txn_tim
    * approved: true


Otherwise there was some problem with the transaction, so the response will have these attrs:

    * result_type: "error"
    * error: errorCode
    * result_message: errorMessage
    * approved: false


For more information on the Virtual Merchant API, view their docs at
https://www.myvirtualmerchant.com/VirtualMerchant/supportlandingvisitor.do
