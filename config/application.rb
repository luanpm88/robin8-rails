require File.expand_path('../boot', __FILE__)

require 'rails/all'

ROADIE_I_KNOW_ABOUT_VERSION_3 = true # Remove after Roadie 3.1

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Robin8
  class Application < Rails::Application
    config.before_configuration do
      $REDIS_CONFIG = ::YAML::load(File.read(File.join(Rails.root.to_s, 'config/redis.yml')))[Rails.env.to_s]
    end
    
    # 跨域请求
    config.middleware.insert_before 0, "Rack::Cors" do
      allow do
        origins 'local.robin8.com'
        resource '*', :headers => :any, :methods => [:get, :post, :options]
      end
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    config.time_zone = 'Beijing'
    config.active_record.default_timezone = :local

    config.generators do |g|
      g.orm :active_record
    end

    config.middleware.use Rack::Attack

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.assets.paths << Rails.root.join('vendor', 'assets', 'components')
    config.assets.paths << Rails.root.join("app", "assets", "fonts")
    config.autoload_paths += %W(#{config.root}/lib #{config.root}/app/mongo_models)

    config.paths.add File.join('app', 'api'), glob: File.join('**', '*.rb')
    config.autoload_paths += Dir[Rails.root.join('app', 'api', '*')]

    config.action_dispatch.perform_deep_munge = false
    config.i18n.available_locales = ['en', 'zh']
    # I18n.enforce_available_locales = false

    #echo "export china_instance='Y'" >> ~/.bashrc
    config.china_instance = (ENV['china_instance'] == 'Y' ? true : false)
    puts "Start China Instance ....  value: #{config.china_instance} "

    config.cache_store = :redis_store, { :host => "localhost",
                                         :port => 6379,
                                         :db => 0,
                                         :namespace => "robcache",
                                         :expires_in => 90.minutes }
  end

  require Rails.root.to_s + '/lib/blue_snap.rb'
end
