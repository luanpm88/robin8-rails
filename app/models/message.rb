class Message < ActiveRecord::Base
  serialize :receiver_ids, Array

  belongs_to :receiver, :polymorphic => true
  belongs_to :item, :polymorphic => true
  # belongs_to :sender, :polymorphic => true

  # MessageTypes = ['income','announcement','campaign','screenshot_passed','screenshot_rejected','remind_upload'，'common']

  scope :created_desc, -> {order("created_at desc")}
  scope :unread, -> {where(:is_read => false)}
  scope :read, -> {where(:is_read => true)}

  def item_name
    self.item.name  rescue nil
  end

  # new new_remind_upload list
  def self.new_remind_upload(campaign, kol_ids = [])
    wait_upload_invites = CampaignInvite.waiting_upload.where(:campaign_id => campaign.id)
    kol_ids = wait_upload_invites.collect{|t| t.kol_id}
    message = Message.new(:message_type => 'remind_upload', :sub_message_type => campaign.per_budget_type, :title => "活动: #{campaign.name} 还有一天就结束了!快来上传截图吧!", :logo_url => (campaign.img_url rescue nil), :name => campaign.name,
                          :sender => (campaign.user.company || campaign.user.name  rescue nil), :item => campaign, :receiver_type => "List"  )
    message.receiver_ids = kol_ids
    if message.save
      Kol.where(:id => kol_ids).each {|kol| kol.list_message_ids << message.id }
    end
    generate_push_message(message)
  end

  # new campaign  to all  or list
  def self.new_campaign(campaign_id, kol_ids = [], unmatch_kol_id = [])
    return if kol_ids.size == 0 && unmatch_kol_id.size == 0
    campaign = Campaign.find campaign_id
    if campaign.is_recruit_type?
      content = '你有一个新的招募活动还有十分钟就开始了!快来抢活动吧!'
    else
      content =  "活动: #{campaign.name} 还有十分钟就开始了!快来抢活动吧!"
    end
    message = Message.new(:message_type => 'campaign', :sub_message_type => campaign.per_budget_type, :title => content, :logo_url => (campaign.img_url rescue nil), :name => campaign.name,
                          :sender => (campaign.user.company || campaign.user.name  rescue nil), :item => campaign  )
    if kol_ids.present? && kol_ids.size > 0
      message.receiver_type = "List"
      message.receiver_ids = kol_ids
      message.save
      # if message.save
      #   kols = Kol.where(id: kol_ids)
      #   kols.each {|kol| kol.list_message_ids << message.id }     # 列表消息 需要插入到用户 message list
      # end
      # 推送到每个人的消息列表,太慢,被某程序员取消了
    elsif unmatch_kol_id.size > 0
      kol_ids = Kol.active.where.not(:id => unmatch_kol_id).collect{|t| t.id }
      message.receiver_type = "List"
      message.receiver_ids = kol_ids
      message.save
      # if message.save
      #   Kol.where(:id => kol_ids).each {|kol| kol.list_message_ids << message.id }     # 列表消息 需要插入到用户 message list
      # end
    end
    device_tokens = campaign.push_device_tokens  rescue nil
    campaign.push_device_tokens.del
    generate_push_message(message , device_tokens) if Campaign.can_push_message(campaign)
  end

  def self.new_announcement(announcement)
    message = Message.new(:message_type => 'announcement', :title => announcement.name, :logo_url => announcement.img_url, :name => 'Robin8 系统通知',
                          :sender => 'Robin8', :item => announcement  )
    message.receiver_type = "All"
    message.save
    generate_push_message(message)
  end


  def self.new_check_message(message_type,invite, campaign)
    message = Message.new(:message_type => message_type, :sub_message_type => campaign.per_budget_type, :receiver => invite.kol, :item => campaign)
    if  message_type == 'screenshot_passed'
      message.title = "活动: #{campaign.name} 截图已经通过审核，快来查查你的收益"
    elsif message_type == 'screenshot_rejected'
      message.title = "活动: #{campaign.name} 截图未通过审核，请尽快重新上传"
    end
    message.sender = campaign.user.company || campaign.user.name  rescue nil
    message.name = campaign.name
    message.logo_url = campaign.img_url rescue nil
    message.is_read = false
    message.save
    generate_push_message(message)
  end

  # create or update
  def self.new_income(invite, campaign)
    message = Message.find_or_initialize_by(:message_type => 'income', :receiver => invite.kol, :item => campaign)
    if message.new_record?
      message.logo_url = campaign.img_url
      message.sender = campaign.user.company || campaign.user.name  rescue nil
      message.name = campaign.name
      message.logo_url = campaign.img_url rescue nil
    end
    message.is_read = false
    message.title ="新收入 ￥#{invite.redis_new_income.value / 100.0}"
    message.save

    generate_push_message(message)
  end

  # create or update
  def self.new_campaign_compensation(invite, campaign)
    message = Message.new(:message_type => 'common', :receiver => invite.kol, :item => campaign, :sender => 'Robin8')
    message.name = campaign.name
    message.logo_url = campaign.img_url rescue nil
    message.is_read = false
    message.title = "您有一个活动补偿红包,请在钱包中查看"
    message.save

    generate_push_message(message)
  end

  def self.thursday_push
    message = Message.new(:message_type => 'notice', :title => '明天是Robin8提现日,今天别忘记提交申请哦!' , :name => 'Robin8 系统通知',:sender => 'Robin8')
    message.receiver_type = "All"
    message.save
    generate_push_message(message)
  end


  def self.generate_push_message(message , device_tokens = nil )
    puts "----generate_push_message"
    if Rails.env == "staging" or Rails.env == "development" or Rails.env == "qa"
      return
    end
    PushMessage.create_message_push(message , device_tokens)
  end

  class << self
    alias_method :push_campaign, :new_campaign
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
