BosonNlpApi.configure do |config|
  config.token = Rails.application.secrets.boson_nlp_api[:token]
  if Rails.application.secrets.boson_nlp_api[:base_uri]
    config.base_uri = Rails.application.secrets.boson_nlp_api[:base_uri]
  end
end
