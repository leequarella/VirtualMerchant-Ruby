A gem for processing credit cards with VirtualMerchant's API.

## Setup

Add it to your Gemfile then run `bundle` to install it.

```ruby
gem "virtual_merchant"
```


## Usage
### Create Virtual Merchant Objects
#### Credit Card Objects
```ruby
    #Create CreditCard via manual entry
    cc = VirtualMerchant::CreditCard.new(
      name_on_card:  <name_on_card>,
      number:        <card_number>,
      expiration:    <card_exp>,
      security_code: <cvv2>)

    # OR
    # via unencrypted MSR
    cc = VirtualMerchant::CreditCard.new(swipe: <swipe_data>)

    # OR
    # via encrypted MSR
    cc = VirtualMerchant::CreditCard.new(
      encrypted: true,
      track_1:   <encrypted_track_1>,
      track_2:   <encrypted_track_2>,
      last_four: <last_four>
```
Public Methods:
```ruby
    encrypted?
      self.encrypted
    
    swiped?
      self.swiped
    
    valid?
      self.errors.count == 0
    
    blurred_number
      "1234123412341234" -> "12**********1234"
```

####Amount Objects
```ruby
    amount = VirtualMerchant::Amount.new(
      total:             <total amount to charge>,
      tax:               <amount of tax included in the total>, #optional
      next_payment_date: <'MM/DD/YYYY'>, #required for recurring payments
      billing_cycle:     <'WEEKLY/MONTHLY'>, #required for recurring payments
      end_of_month:      <'Y/N'>) #required for recurring payments occuring on
                                  #last day of month
```

####Credentials Objects
```ruby
    creds = VirtualMerchant::Credentials.new(
      account_id:     <vm_account_id>,
      user_id:        <vm_user_id>,
      pin:            <vm_user_pass>,
      source:         <vm_mobile_source>, #only required for encrypted MSR
      ksn:            <ksn>, #only required for encrypted MSR
      vender_id:      <vender_id>, #only required for encrypted MSR
      device_type:    <device_type, 001 for BulleT 002 for iDynamo
                       003 for uDynamo>, #only required for encrypted MSR
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
    response = VirtualMerchant.complete(amount, creds, transaction_id)

    #Delete Authorized Transaction
    response = VirtualMerchant.delete(creds, transaction_id)
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
(This will also be the response if there was a problem reading the card)

    * approved: false
    * error: errorCode
    * result_message: errorMessage

### Debugging

There is a logger that will print some info from responses to make debugging a little easier.  It can be turned on with

```ruby
  VirtualMerchant::Logger.on!
```


###Testing

For testing, edit the config.yml file to include your virtual merchant account credentials and encrypted card data.



For more information on the Virtual Merchant API, view their docs at
https://www.myvirtualmerchant.com/VirtualMerchant/supportlandingvisitor.do
