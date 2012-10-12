A gem for processing credit cards with VirtualMerchant's API.

## Setup

Add it to your Gemfile then run `bundle` to install it.

```ruby
gem "virtual_merchant"
```


## Usage

```ruby
    #Create CreditCard via manual entry
    cc = VMCreditCard.new(
      name_on_card: <name_on_card>,
      number: <card_number>,
      expiration: <card_exp>,
      security_code: <cvv2>)

    # OR
    # via MSR
    cc = VMCreditCard.new(
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

The response returned is a VMResponse object.

If the transaction was sucessful and the card was approved, the response will have the following attrs:

    * result_type = "approval"
    * result_message: ssl_result_message
    * result: ssl_result
    * approval_code: ssl_approval_code
    * blurred_card_number: ssl_card_number
    * exp_date: ssl_exp_date
    * cvv2_response: ssl_cvv2_response
    * transaction_id: ssl_txn_id
    * transaction_time: ssl_txn_tim


Otherwise there was some problem with the transaction, so the response will have these attrs:

    * result_type: "error"
    * error: errorCode
    * result_message: errorMessage


For more information on the Virtual Merchant API, view their docs at
https://www.myvirtualmerchant.com/VirtualMerchant/supportlandingvisitor.do
