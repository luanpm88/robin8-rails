class PhoneValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    lookup_client = Twilio::REST::LookupsClient.new
    begin
      response = lookup_client.phone_numbers.get(value)
      response.phone_number #if invalid, throws an exception. If valid, no problems.
    rescue => e
      if e.code == 20404
        object.errors[attribute] << (options[:message] || @l.t('errors.messages.phone'))
      else
        raise e
      end
    end
  end
end 
