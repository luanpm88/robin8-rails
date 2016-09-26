# StatusPage.configure do
#
#   self.basic_auth_credentials = {
#     username: Rails.application.secrets[:status_page][:username],
#     password: Rails.application.secrets[:status_page][:password]
#   }
#
#   self.interval = 10
#   # Use service
#   self.use :database
#   self.use :cache
#   # self.use :redis
#   # Custom redis url
#   self.use :redis, url: "redis://:#{Rails.application.secrets[:redis][:password]}@127.0.0.1:6379/0"
#   self.use :sidekiq
# end
