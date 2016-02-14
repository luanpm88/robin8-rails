source 'https://rubygems.org'
# source 'https://ruby.taobao.org'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.0'
gem 'bundler', '>= 1.7.0'
# Use mysql as the database for Active Record
gem 'mysql2'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'quiet_assets', group: [:development, :staging]

# To send HTML mails
gem 'roadie', '~> 3.0.5'

# Displays page rendering performance
gem 'rack-mini-profiler'

# create multiple log files
gem 'multi_logger'

gem 'slackistrano', require: false
gem 'slack-notifier', require: false

gem 'htmlentities'
gem 'truncate_html'
gem 'email_validator'
gem 'oauth2'
gem 'legato'
gem 'redis-objects'
gem 'redis-rails'
gem 'rest-client'
gem "typhoeus"

gem 'mongoid', '~> 5.0.0'

# Send notification when error occur
gem 'exception_notification'

# Character encoding detecting library
gem 'charlock_holmes'

gem 'twilio-ruby', '~> 4.2.1'

#monitor server
gem 'newrelic_rpm'

# 微信相关
gem 'weixin_authorize'

source 'http://rails-assets.org' do
  gem 'rails-assets-bootstrap-sass', '3.3.4'
  gem 'rails-assets-bootstrap.growl', '2.0.1'
  gem 'rails-assets-sass-bootstrap-glyphicons'
  gem 'rails-assets-font-awsome', '4.3'
  gem 'rails-assets-momentjs'
  gem 'rails-assets-eonasdan-bootstrap-datetimepicker', '4.17.37'
  gem 'rails-assets-backbone.marionette', '2.4.1'
  gem 'rails-assets-backbone.modelbinder'
  gem 'rails-assets-underscore.string'
  gem 'rails-assets-select2', '3.5.2'
  gem 'rails-assets-spinkit'
  gem 'rails-assets-bootstrap-sweetalert'
  gem 'rails-assets-backbone.babysitter'
  gem 'rails-assets-please-wait'
  gem 'rails-assets-timeago'
  gem 'rails-assets-datatables'
  gem 'rails-assets-datatables-tabletools'
  gem 'rails-assets-select2-bootstrap-css'
  gem 'rails-assets-backbone-relational'
  gem 'rails-assets-spinjs'
  gem 'rails-assets-datejs'
  gem 'rails-assets-underscore.inflection'
  gem 'rails-assets-bootstrap-validator'
end

gem 'devise'
gem 'devise_invitable'
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-linkedin-oauth2'
gem 'omniauth-linkedin'
gem 'omniauth-google-oauth2'
gem 'omniauth-facebook'
gem 'omniauth-weibo-oauth2'
# gem 'omniauth-wechat-oauth2'
gem "omniauth-wechat-oauth2", git: 'https://github.com/yangsr/omniauth-wechat-oauth2.git'
gem 'active_model_serializers', "~> 0.8.0"

gem 'qy_wechat', '~> 1.0.1'

gem 'sinatra', require: nil
gem 'sidekiq'
gem 'sidetiq'
gem 'sidekiq-limit_fetch'
gem 'will_paginate', '~> 3.0.6'
gem 'will_paginate-bootstrap'
gem 'has_scope'

gem 'twitter'
gem "koala", "~> 1.11.0rc" #flexible library for Facebook
gem 'httparty'
gem 'activeresource'

gem 'aylien_text_api'

gem 'ejs'
gem 'countries'
gem 'whenever'
gem 'friendly_id', '~> 5.1.0'

gem 'docx'

# pure Ruby PDF generation library
gem 'prawn'
gem 'imgkit'

# to create Docx
gem 'caracal-rails'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# gem 'mailgun'
gem 'mailgun-ruby'

gem 'paperclip', '~> 4.2.1'
gem 'premailer-rails'
gem 'hpricot'
gem "ransack", github: "activerecord-hackery/ransack", branch: "rails-4.2"
gem 'activeadmin', '~> 1.0.0.pre1'
gem 'country_select', github: 'stefanpenner/country_select'
gem 'geocoder'
gem 'china_sms'
gem 'qiniu', '~> 6.5.1'


group :development, :test do
  # Deploy with Capistrano
  gem 'capistrano-rails', '~> 1.1.3'
  gem 'capistrano-rbenv', '~> 2.0.3'
  gem 'capistrano-bundler', '~> 1.1.4'
  gem 'capistrano-sidekiq', '~> 0.4.0'
  gem 'capistrano-ssh-doctor', '~> 1.0.0'
  gem 'capistrano3-unicorn', '~> 0.2.0'
  gem 'pry-rails'
  gem 'pry-nav',    '0.2.4'
  gem 'pry-stack_explorer', '0.4.9.1'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  gem 'rspec-rails'
  gem 'shoulda-matchers', '~> 3.0'
  gem 'rspec-activemodel-mocks'
  gem 'factory_girl_rails'
  gem 'database_cleaner'
  gem 'ffaker'
  gem 'rspec-mocks'
  gem "capybara"
  gem 'guard-rspec'
  gem 'spring-commands-rspec'
  gem 'railroady'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'puma'
end

group :test do
  gem 'rspec-sidekiq'
end

group :production do
  gem 'unicorn', '4.8.3'
end


#------------------- 2.0 新增
# gem 'kaminari', :require => 'kaminari/grape'
gem 'grape', '~> 0.9.0'
gem 'grape-entity', '~> 0.4.3'
gem 'grape-present_cache', :git => 'https://github.com/u2/grape-present_cache.git'

gem 'jwt'

gem 'carrierwave'
gem 'carrierwave-qiniu', :github => "huobazi/carrierwave-qiniu"

gem "react_on_rails"

gem 'bootstrap-sass'
