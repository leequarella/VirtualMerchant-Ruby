class VMResponse
  attr_accessor :result_message, :result, :blurred_card_number, :exp_date, :approval_code,
    :cvv2_response, :transaction_id, :transaction_time, :error, :approved

  def initialize(info)
    @result_message = info[:result_message]
    if info[:error]
      @result_type = "error"
      @error = info[:error]
      @approved = false
    else
      @approved = true
      @result_type = "approval"
      @result = info[:result]
      @blurred_card_number = info[:blurred_card_number]
      @exp_date = info[:exp_date]
      @approval_code = info[:approval_code]
      @cvv2_response = info[:cvv2_response]
      @transaction_id = info[:transaction_id]
      @transaction_time = info[:transaction_time]
    end
  end
end
