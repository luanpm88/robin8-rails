class Message < ActiveRecord::Base
  belongs_to :receiver, :polymorphic => true
  belongs_to :item, :polymorphic => true
  # belongs_to :sender, :polymorphic => true

  # MessageTypes = ['income', 'announcement']

  scope :unread, -> {where(:is_read => false)}
  scope :read, -> {where(:is_read => true)}

  after_create :generate_push_message

  def item_name
    self.item.name  rescue nil
  end

  def read
    self.read_at = Time.now
    self.is_read = true
    self.save
    self.item.reset_new_income  if self.message_type == 'income'  && self.item
  end

  def self.update_income(invite, campaign)
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
