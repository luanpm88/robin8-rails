Rails.application.configure do
  GOOGLE_CLIENT_ID = '1093899821527-6lr9shuc8blj8g1f01e5dm1ffbus215l.apps.googleusercontent.com'
  GOOGLE_CLIENT_SECRET = 'wJA71M_rI-O2rMmZs2Qaowhv'
  FACEBOOK_APP_ID = '420339794748110'
  FACEBOOK_APP_SECRET = 'a8a02193ddcb77a91d8035bd985b643a'
  TWITTER_API_KEY = 'chfbNFBkf56gJT2BDzmCNNfgv'
  TWITTER_API_SECRET = 'WJvtq91oZgvGIJQl33J8kprn4eeWRlCzj4qlYulAyzwuxKATS3'
  LINKEDIN_API_KEY = '77pzzhbbrahh62'
  LINKEDIN_API_SECRET = 'h9xZrB8SnYrx03KZ'
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  config.action_mailer.default_url_options = { host: 'localhost:3000' }
end
