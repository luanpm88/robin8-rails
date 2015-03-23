require 'mailgun'
class Follower < ActiveRecord::Base
  
  LIST_TYPES = [
    [ "Immediate updates", "immediate@mg.robin8.com" ],
    [ "Daily digest", "daily@mg.robin8.com" ],
    [ "Weekly digest", "weekly@mg.robin8.com" ],
    [ "Monthly digest", "monthly@mg.robin8.com" ]
  ]

  belongs_to :news_room

  validates :email, :email => true
  validates :list_type, inclusion: { in: LIST_TYPES.map{ |l| l[1] } }

  after_update :add_follower_to_list

  private

    def add_follower_to_list
      # UpdateListWorker.perform_async
      mg_client = Mailgun::Client.new Rails.application.secrets.mailgun[:api_key]
      p '~'*90
      p mg_client
    end

end