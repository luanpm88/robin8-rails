class TwitterConnectValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    if value.twitter_identity.blank?
      object.errors[attribute] << (options[:message] || I18n.t('errors.messages.twitter_connect'))
    end
  end
end 
