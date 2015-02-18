# Be sure to restart your server when you modify this file.
if Rails.env.development?
  Rails.application.config.session_store :cookie_store, key: '_robin8_session', domain: 'lvh.me'
elsif Rails.env.staging?
  Rails.application.config.session_store :cookie_store, key: '_robin8_session'
elsif Rails.env.production?
  Rails.application.config.session_store :cookie_store, key: '_robin8_session', domain: 'robin8.com'
end