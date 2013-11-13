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
      tax:               <amount of tax included in the total>, #optional
      next_payment_date: <'MM/DD/YYYY'>, #required for recurring payments
      billing_cycle:     <'WEEKLY/MONTHLY'>, #required for recurring payments
      end_of_month:      <'Y/N'>) #required for recurring payments occuring on
                                  #last day of month

    creds = VirtualMerchant::Credentials.new(
      account_id:     <vm_account_id>,
      user_id:        <vm_user_id>,
      pin:            <vm_user_pass>,
      source:         <vm_mobile_source>, #only required for encrypted MSR
      ksn:            <ksn>, #only required for encrypted MSR
      vender_id:      <vender_id>, #only required for encrypted MSR
      device_type:    <device_type, 001 for BulleT 002 for iDynamo
                       003 for uDynamo>, #only required for encrypted MSR
      transaction_id: <transaction_id>, #only required for completing and
                       deleting authorized transactions
      demo:           <boolean>, #optional
      referer:        <uri of the http referer>, #optional)
```

###Charge, Authorize, Refund, or Void
```ruby
    #Charge
    response = VirtualMerchant.charge(cc, amount, creds)

    #Authorize
    response = VirtualMerchant.authorize(cc, amount, creds)

    #Add Recurring Payment
    response = VirtualMerchant.add_recurring(cc, amount, creds)

    #Refund
    response = VirtualMerchant.refund(cc, amount, creds)

    #Void
    response = VirtualMerchant.void(transaction_id, creds)
```
###Complete and Delete Authorized Transactions
Complete is used to convert an existing authorized transaction to a sale
without a second authorization.

Delete attempts a reversal on a Sale and Auth Only credit transaction.

WARNING: Transactions deleted from the batch cannot be recovered.
```ruby
    #Complete Authorized Transaction
    response = VirtualMerchant.complete(cc, amount, creds)

    #Delete Authorized Transaction
    response = VirtualMerchant.delete(cc, amount, creds)
```

###Response

The response returned is a VirtualMerchant::Response object.

If a single transaction was sucessful and the card was approved, the response will have the following attrs:

    * approved: true
    * result_message: ssl_result_message
    * result: ssl_result
    * approval_code: ssl_approval_code
    * blurred_card_number: ssl_card_number
    * exp_date: ssl_exp_date
    * cvv2_response: ssl_cvv2_response
    * transaction_id: ssl_txn_id
    * transaction_time: ssl_txn_tim


If a recurring transaction was sucessful and the card was approved, the response will have the following attrs:

    * approved: true
    * result_message: ssl_result_message
    * blurred_card_number: ssl_card_number
    * exp_date: ssl_exp_date
    * billing_cycle: ssl_billing_cycle
    * start_payment_date: ssl_start_payment_date
    * transaction_type: ssl_transaction_type
    * recurring_id: ssl_recurring_id
    * next_payment_date: ssl_next_payment_date
    * skip_payment: ssl_skip_payment
    * recurring_batch_count: ssl_recurring_batch_count


Otherwise there was some problem with a transaction, so the response will have these attrs:

    * approved: false
    * error: errorCode
    * result_message: errorMessage


For more information on the Virtual Merchant API, view their docs at
https://www.myvirtualmerchant.com/VirtualMerchant/supportlandingvisitor.do
