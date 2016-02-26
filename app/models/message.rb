class Message < ActiveRecord::Base
  serialize :reciever_ids, Array

  belongs_to :receiver, :polymorphic => true
  belongs_to :item, :polymorphic => true
  # belongs_to :sender, :polymorphic => true

  # MessageTypes = ['income', 'announcement', 'campaign']

  scope :created_desc, -> {order("created_at desc")}
  scope :unread, -> {where(:is_read => false)}
  scope :read, -> {where(:is_read => true)}

  def item_name
    self.item.name  rescue nil
  end

  # new campaign  to all  or list
  def self.new_campaign(campaign, kol_ids = [])
    message = Message.new(:message_type => 'campaign', :title => '邀请您参与转发', :logo_url => (campaign.img_url + "!logo" rescue nil), :name => campaign.name,
                          :sender => (campaign.user.name  rescue nil), :item => campaign  )
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
    generate_push_message(message)
  end

  def self.new_announcement(announcement)
    message = Message.new(:message_type => 'announcement', :title => announcement.name, :logo_url => announcement.img_url, :name => 'Robin8 系统通知',
                          :sender => 'Robin8', :item => announcement  )
    message.receiver_type = "All"
    message.save
    generate_push_message(message)
  end


  # create or update
  def self.new_income(invite, campaign)
    message = Message.find_or_initialize_by(:message_type => 'income', :receiver => invite.kol, :item => invite)
    if message.new_record?
      message.logo_url = campaign.img_url
      message.sender = campaign.user.company  rescue nil
      message.name = campaign.name
      message.logo_url = campaign.img_url + "!logo" rescue nil
    end
    message.is_read = false
    message.title ="新收入 ￥#{invite.redis_new_income.value / 100.0}"
    message.save

    generate_push_message(message)
  end


  def self.test_income(kol_id = 84)
    kol = Kol.find kol_id
    campaign_invite = kol.campaign_invites.last
    new_income(campaign_invite,campaign_invite.campaign)
  end


  def self.test_campaign(kol_id = 84)
    kol = Kol.find kol_id
    campaign_invite = kol.campaign_invites.last
    self.new_campaign(campaign_invite.campaign, kol.id)
  end


  def self.generate_push_message(message)
    puts "----generate_push_message"
    PushMessage.create_message_push(message)
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
