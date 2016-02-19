class Message < ActiveRecord::Base
  serialize :reciever_ids, Array

  belongs_to :receiver, :polymorphic => true
  belongs_to :item, :polymorphic => true
  # belongs_to :sender, :polymorphic => true

  # MessageTypes = ['income', 'announcement', 'campaign']

  scope :unread, -> {where(:is_read => false)}
  scope :read, -> {where(:is_read => true)}

  after_create :generate_push_message

  def item_name
    self.item.name  rescue nil
  end

  # def read
  #   self.read_at = Time.now
  #   self.is_read = true
  #   self.save
  #   self.item.reset_new_income  if self.message_type == 'income'  && self.item
  # end

  # new campaign  to all  or list
  def self.new_campaign(campaign, kol_ids = [])
    message = Message.new(:message_type => 'campaign', :title => campaign.name, :logo_url => campaign.img_url,
                          :sender => (campaign.user.campaign  rescue nil), :item => campaign  )
    # to all
    if kol_ids.size == 0
      message.receiver_type = "All"
      message.save
    else
      message.receiver_type = "List"
      message.receiver_ids = kol_ids
      if message.save
        # 列表消息 需要插入到用户 message list
        Kol.where(:id => kol_ids).each do  |kol|
          kol.list_message_ids << message.id
        end
      end
    end
  end

  def self.new_announcement(announcement)
    message = Message.new(:message_type => 'announcement', :title => announcement.name, :logo_url => announcement.img_url,
                          :sender => 'Robin8', :item => announcement  )
    message.receiver_type = "All"
    message.save
  end


  # create or update
  def self.new_income(invite, campaign)
    income_message = Message.find_or_initialize_by(:message_type => 'income', :owner => invite.kol, :item => invite)
    if income_message.new_record
      income_message.logo_url = campaign.img_url
      income_message.sender = campaign.user.campaign  rescue nil
    end
    income_message.is_read = false
    income_message.title = "新收入 #{invite.redis_new_income.value / 100.0} "
    income_message.save
  end

  def generate_push_message
    PushMessage.create_message_push(self)
  end
end



# t.string :message_type
# t.boolean :is_read, :default => false
# t.datetime :read_at
# t.string :title
# t.string :desc
# t.string :url
# t.string :logo_url
#
#
# # t.string :sender_type
# # t.integer :sender_id
# t.string :sender
#
# t.string :receiver_type
# t.integer :receiver_id
# t.text :receiver_ids
#
# t.string :item_type
# t.string :item_id
