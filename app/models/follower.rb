require 'mailgun'
class Follower < ActiveRecord::Base
  
  LIST_TYPES = [
    [ "Immediate updates", "immediate@mg.myprgenie.com" ],
    [ "Daily digest", "daily@mg.myprgenie.com" ],
    [ "Weekly digest", "weekly@mg.myprgenie.com" ],
    [ "Monthly digest", "monthly@mg.myprgenie.com" ]
  ]

  belongs_to :news_room

  validates :email, :email => true
  validates :list_type, inclusion: { in: LIST_TYPES.map{ |l| l[1] } }

  scope :monthly, -> { where(list_type: 'monthly@mg.myprgenie.com') }
  scope :immediate, -> { where(list_type: 'monthly@mg.myprgenie.com') }
  scope :weekly, -> { where(list_type: 'weekly@mg.myprgenie.com') }
  scope :daily, -> { where(list_type: 'daily@mg.myprgenie.com') }

  after_update :add_follower_to_list

  private

    def add_follower_to_list
      mg_client = Mailgun::Client.new Rails.application.secrets.mailgun[:api_key]
      begin
        list = mg_client.get("/lists/#{list_type}")
      rescue Mailgun::CommunicationError
        list = mg_client.post('/lists', { address: list_type })
      end
      if list.code == 200
        begin
          mg_client.post("/lists/#{list_type}/members", { address: email })
        rescue Mailgun::CommunicationError
          mg_client.put("/lists/#{list_type}/members/#{email}", { address: email })
        end
      end
    end

end