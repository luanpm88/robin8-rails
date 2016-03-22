class PushMessage < ActiveRecord::Base
  include GeTui::Dispatcher

  serialize :receiver_ids, Array
  serialize :receiver_cids, Array
  serialize :template_content, Hash
  serialize :receiver_list, Hash
  serialize :result_serial, Hash
  after_commit :async_send_to_client, :on => :create
  # template_type  'transmission', 'notification'       =>   'transmission'


  def self.transmission_template_content(message)
    content = {:action => message.message_type, :title => message.title, :sender => message.sender, :name => message.name}
    if message.message_type == 'income'
      receiver = message.receiver
      new_income =  receiver.new_income
      new_income = rand(100) if Rails.env.development? && new_income == 0
      content.merge!({:new_income =>  new_income, :unread_message_count => receiver.unread_messages.count})
    end
    content
  end

  def self.create_message_push(message)
    #to one
    if message.message_type == 'income'  || message.message_type == 'screenshot_passed' ||  message.message_type == 'screenshot_rejected'
      receiver = message.receiver
      push_message = self.new(:receiver_type => 'Single', :template_type => 'transmission', :receiver_ids => [receiver.id],
                              :title => message.title, :receiver_cids => [receiver.device_token] )
      push_message.template_content = transmission_template_content(message)
      push_message.message_id = message.id
      push_message.item_id = message.item_id
      push_message.item_type = message.item_type
      push_message.save
    elsif message.message_type == 'announcement'
      push_message = self.new(:receiver_type => 'All', :template_type => 'transmission', :title => message.title,
                              :receiver_list => {:app_id_list => [GeTui::Dispatcher::AppId] })
      push_message.template_content = transmission_template_content(message)
      push_message.message_id = message.id
      push_message.item_id = message.item_id
      push_message.item_type = message.item_type
      push_message.save
    elsif message.message_type == 'campaign'
      push_message = self.new(:template_type => 'transmission', :template_content => transmission_template_content(message),
                              :title => message.title)
      if message.receiver_type == 'All'
        push_message.receiver_type = 'App'
        push_message.receiver_list = {:app_id_list => [GeTui::Dispatcher::AppId] }
      elsif message.receiver_type == 'Kol'
        receiver = message.receiver
        push_message.receiver_type = 'Single'
        push_message.receiver_ids = [receiver.id]
        push_message.receiver_cids = [receiver.device_token]
      elsif message.receiver_type == 'List'
        receivers = Kol.where(:id => message.receiver_ids)
        push_message.receiver_type = 'List'
        push_message.receiver_ids = receivers.collect{|t| t.id }
        push_message.receiver_cids = receivers.collect{|t| t.device_token}
      end
      push_message.message_id = message.id
      push_message.item_id = message.item_id
      push_message.item_type = message.item_type
      push_message.save
    # to list
    elsif message.message_type == 'remind_upload'
      push_message = self.new(:template_type => 'transmission', :template_content => transmission_template_content(message),
                              :title => message.title)
      receivers = Kol.where(:id => message.receiver_ids)
      push_message.receiver_type = 'List'
      push_message.receiver_ids = receivers.collect{|t| t.id }
      push_message.receiver_cids = receivers.collect{|t| t.device_token}
      push_message.message_id = message.id
      push_message.item_id = message.item_id
      push_message.item_type = message.item_type
      push_message.save
    end
  end

  def async_send_to_client
    puts "====async_send_to_client"
    if Rails.env.development?
      PusherWorker.new.perform(self.id)
    else
      PusherWorker.perform_async(self.id)
    end
  end

  # t.string :receiver_type
  # t.string :receiver_ids
  # t.text :reciver_cids
  # t.string :receiver_list
  # t.string :template_type
  # t.text :template_content
  # t.boolean :is_offline, :default => true
  # t.integer :offline_expire_time, :default => 1000 * 3600 * 12
  # t.string :result
  # t.text :result_serial
  # t.string :details
  # t.string :task_id

end
